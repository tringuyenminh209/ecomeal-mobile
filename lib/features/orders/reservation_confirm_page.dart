import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_events.dart';
import '../../core/jst_date.dart';
import '../../core/stripe_payments.dart';
import '../../core/tax.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/customer_shell.dart';
import '../../widgets/status_badge.dart';
import '../home/batch_detail_page.dart';
import '../home/customer_home_page.dart' show activeListingsProvider;
import '../payment/add_card_page.dart';
import '../payment/card_widgets.dart';
import '../payment/payment_gateway.dart';
import '../payment/payment_methods_page.dart';
import 'order_gateway.dart';
import 'order_history_page.dart';
import 'payment_outcome.dart';
import 'payment_result_view.dart';
import '../../core/haptics.dart';
import '../../widgets/batch_photo.dart';
import '../coupons/coupons.dart';
import '../coupons/coupons_page.dart' show CouponTile;
import '../auth/auth_controller.dart';

// SCR-M05 — 06_画面設計 §SCR-M05. Figma「M05 予約確認・決済」211:608: 16:16527 (支払い方法なし) / 378:82
// (選択済み) / 389:913 (処理中) / 389:935 (完了) / 389:959 (カード拒否) / 389:985 (結果確認待ち).
// Thanh toán vẫn là giả (ADR-006, 0043): server kiểm tra thẻ rồi tạo đơn trong cùng 1 transaction.
// Figma vẽ cả Bottom Navigation ở các frame này, nhưng 06 §0 chỉ cho tab gốc có thanh tab — không vẽ.
// Giữ thẻ「無料キャンセル」(BR-003) dù Figma mới bỏ — 06 §SCR-M05 差異 (1).
class ReservationConfirmPage extends ConsumerStatefulWidget {
  const ReservationConfirmPage({
    super.key,
    required this.batchId,
    required this.routeStopId,
    required this.stopName,
    required this.plannedPickupTime,
    required this.unitPrice,
    required this.expiresAt,
    this.photoUrl,
  });

  final String batchId;
  final String routeStopId;
  final String stopName;
  final DateTime plannedPickupTime;
  final int unitPrice;
  final DateTime expiresAt;
  // Ảnh món của lô (0038) — cùng ảnh khách vừa xem ở SCR-M04; null = ảnh minh hoạ chung
  final String? photoUrl;

  @override
  ConsumerState<ReservationConfirmPage> createState() => _ReservationConfirmPageState();
}

class _ReservationConfirmPageState extends ConsumerState<ReservationConfirmPage> {
  // 1 khoá cho cả lần mở màn này: bấm trả lại sau khi bị từ chối / mất mạng vẫn là "cùng 1 lần thanh toán" —
  // nếu lần trước thật ra đã thành công, server trả lại đơn đó thay vì trừ tiền lần 2.
  final String _idempotencyKey = const Uuid().v4();
  PaymentPhase _phase = PaymentPhase.review;
  String? _selectedCardId; // null = dùng thẻ mặc định
  PaymentMethod? _paidCard; // thẻ đã dùng — hiện ở màn kết quả
  int? _paidAmount;
  String? _paidCouponId; // dùng lại khi 結果確認待ち phải gọi thanh toán lần nữa (cùng khoá)

  @override
  void initState() {
    super.initState();
    logAppEvent(ref, AppEvent.checkoutView, widget.batchId); // 0051: "đã mở màn đặt chỗ"
  }
  bool _cardExpired = false;
  bool _rechecking = false;
  // Lỗi hiện ở màn review (khung đỏ trên nút). 1 biến thay cho 6 cờ bool cũ — các lỗi loại trừ nhau nên enum
  // bảo đảm chỉ 1 câu + 1 nút được chọn (audit C02 2026-10-19). null = không có lỗi.
  PaymentFailure? _reviewError;
  bool _useCoupon = true; // 0056 (Figma 470:1318): coupon có lợi nhất được bật sẵn, khách có thể tắt

  PaymentMethod? _selectedCard(List<PaymentMethod> methods) {
    if (methods.isEmpty) return null;
    for (final m in methods) {
      if (m.id == _selectedCardId) return m;
    }
    return methods.firstWhere((m) => m.isDefault, orElse: () => methods.first);
  }

  Future<void> _pay(PaymentMethod card, int amount, String? couponId) async {
    setState(() {
      _phase = PaymentPhase.processing;
      _paidCard = card;
      _paidAmount = amount;
      _paidCouponId = couponId;
      _reviewError = null;
    });
    try {
      final result = await ref.read(orderGatewayProvider).createOrder(
            surplusBatchId: widget.batchId,
            pickupRouteStopId: widget.routeStopId,
            paymentMethodId: card.id,
            idempotencyKey: _idempotencyKey,
            couponId: couponId,
          );
      _onPaid(result);
    } catch (e) {
      Haptics.error();
      if (!mounted) return;
      final failure = classifyPaymentError(e);
      setState(() {
        switch (failure) {
          case PaymentFailure.declined:
          case PaymentFailure.cardExpired:
            _phase = PaymentPhase.declined;
            _cardExpired = failure == PaymentFailure.cardExpired;
          case PaymentFailure.unknown:
            _phase = PaymentPhase.unknown;
          case PaymentFailure.sessionExpired:
            // không phải lỗi đặt hàng: đăng xuất trên máy → SessionGuard đóng màn này và báo 「ログインし直してください」
            _phase = PaymentPhase.review;
          case PaymentFailure.methodMissing:
            _phase = PaymentPhase.review;
            _reviewError = failure;
            _selectedCardId = null;
          case PaymentFailure.rateLimited ||
              PaymentFailure.couponUnavailable ||
              PaymentFailure.priceUnavailable ||
              PaymentFailure.serviceError ||
              PaymentFailure.dailyLimit ||
              PaymentFailure.soldOutAtStop ||
              PaymentFailure.batchUnavailable ||
              PaymentFailure.other:
            _phase = PaymentPhase.review;
            _reviewError = failure;
        }
      });
      if (failure == PaymentFailure.sessionExpired) unawaited(ref.read(authControllerProvider.notifier).expireSession());
      if (failure == PaymentFailure.couponUnavailable) ref.invalidate(usableCouponsProvider);
      if (failure == PaymentFailure.methodMissing) ref.invalidate(myPaymentMethodsProvider);
    }
  }

  // SCR-M06 đọc lại orders.price_paid — đúng con số server đã tính, kể cả khi giá động vừa nhảy bậc.
  void _onPaid(CreateOrderResult result) {
    Haptics.success();
    if (!mounted) return;
    setState(() {
      _phase = PaymentPhase.done;
      _paidAmount = result.pricePaid;
    });
    ref.invalidate(usableCouponsProvider); // coupon đã dùng không còn hiện ở SCR-M19 / lần đặt sau
    ref.invalidate(activeListingsProvider); // 「残り n袋」 giảm ngay (0073), túi vừa hết thì biến khỏi SCR-M03
  }

  // 結果確認待ち: đọc đơn theo khoá. Có đơn đã chốt tiền → thành công. Có đơn mà chưa chốt (0070: lần trước mất kết
  // quả lúc chốt) → gọi thanh toán lại với cùng khoá: server đối chiếu với Stripe, chốt nốt hoặc báo bị từ chối, không
  // trừ tiền 2 lần. Không có đơn → chưa trừ tiền, quay lại review (giữ khoá — request cũ tới muộn vẫn an toàn).
  Future<void> _recheck() async {
    setState(() => _rechecking = true);
    try {
      final order = await ref.read(orderGatewayProvider).findOrderByIdempotencyKey(_idempotencyKey);
      if (!mounted) return;
      final card = _paidCard;
      if (order != null && !order.paymentConfirmed && card != null) {
        await _pay(card, _paidAmount ?? order.pricePaid, _paidCouponId);
      } else if (order != null) {
        _onPaid(order);
      } else {
        setState(() => _phase = PaymentPhase.review);
        _toast(context.l10n.paymentNotFound);
      }
    } catch (_) {
      if (mounted) _toast(context.l10n.errorRecheckFailed);
    } finally {
      if (mounted) setState(() => _rechecking = false);
    }
  }

  void _toast(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  // 06 §SCR-M05 遷移: sang tab 予約 của CustomerShell và đóng SCR-M04/M05 — KHÔNG push 1 trang lịch sử rời
  // (sẽ mất thanh tab). Tab đó sống trong IndexedStack nên phải invalidate để tải lại có đơn mới.
  void _goToOrders() {
    ref.invalidate(myOrdersProvider);
    ref.read(customerTabProvider.notifier).state = CustomerTab.orders;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // Lô hết / hết giờ / giá không trả được: về tab ホーム (đóng M04/M05) và tải lại danh sách túi
  void _goToBrowse() {
    ref.invalidate(activeListingsProvider);
    ref.read(customerTabProvider.notifier).state = CustomerTab.home;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _chooseCard(String? currentId) async {
    final id = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => PaymentMethodsPage(isSelecting: true, selectedId: currentId)),
    );
    if (id == null || !mounted) return;
    setState(() {
      _selectedCardId = id;
      if (_reviewError == PaymentFailure.methodMissing) _reviewError = null;
      _phase = PaymentPhase.review;
    });
  }

  Future<void> _addFirstCard() async {
    final id = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const AddCardPage()));
    if (id == null || !mounted) return;
    setState(() {
      _selectedCardId = id;
      if (_reviewError == PaymentFailure.methodMissing) _reviewError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final window = pickupWindowLabel(widget.plannedPickupTime); // cùng hàm với SCR-M04
    if (_phase != PaymentPhase.review) {
      return PopScope(
        // Đang xử lý / chờ kết quả: không cho rời màn (Figma: không có nút quay lại). Hoàn tất → về tab 予約;
        // bị từ chối → về màn review như nút「予約内容に戻る」.
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (_phase == PaymentPhase.done) _goToOrders();
          if (_phase == PaymentPhase.declined) setState(() => _phase = PaymentPhase.review);
        },
        child: PaymentResultView(
          phase: _phase,
          amount: _paidAmount ?? 0,
          card: _paidCard,
          stopName: widget.stopName,
          pickupWindow: window,
          cardExpired: _cardExpired,
          rechecking: _rechecking,
          onViewReservation: _goToOrders,
          onPayWithAnotherCard: () => _chooseCard(_paidCard?.id),
          onBackToReview: () => setState(() => _phase = PaymentPhase.review),
          onRecheck: _recheck,
        ),
      );
    }
    return _buildReview(context, window);
  }

  Widget _buildReview(BuildContext context, String window) {
    // Cùng provider với SCR-M04 (Chương 16) và cùng khoá → giá vừa thấy ở SCR-M04 hiện ngay, không tải lại.
    final priceParams = (unitPrice: widget.unitPrice, expiresAt: widget.expiresAt);
    final priceAsync = ref.watch(currentPriceProvider(priceParams));
    final methodsAsync = ref.watch(myPaymentMethodsProvider);
    final card = methodsAsync.whenOrNull(data: _selectedCard);
    final basePrice = priceAsync.valueOrNull?.currentPrice;
    // 0056: coupon có lợi nhất (nếu có). Số tiền hiển thị = giá − coupon; server tính lại khi tạo đơn
    final coupon = bestCoupon(ref.watch(usableCouponsProvider).valueOrNull ?? const []);
    final discount = basePrice != null && coupon != null && _useCoupon ? couponDiscount(coupon.amount, basePrice) : 0;
    final price = basePrice == null ? null : basePrice - discount;
    final l10n = context.l10n;
    final priceText = price == null ? '—' : '¥$price';
    // Chưa có giá hoặc chưa có thẻ thì KHÔNG cho trả — người dùng không được đồng ý trả một số tiền mà màn hình
    // chưa hiển thị. create_order vẫn tự tính lại giá ở server.
    final canPay = price != null && card != null;
    // Chưa có thẻ: nút dưới cùng là bước tiếp theo — mở màn thêm thẻ (audit C04, Figma 972:1785). Chưa biết giá thì vẫn khoá.
    final needsCard = card == null && methodsAsync.hasValue;
    final reviewError = _reviewError;
    final errorAction = reviewError == null ? null : reviewErrorAction(reviewError);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reservationConfirmTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              children: [
                // Lỗi KHÔNG ẩn phần trên (thẻ, coupon, đơn): khách cần thấy để tắt coupon / đổi thẻ (audit C02, Figma 949:21244〜)
                const SizedBox(height: 12),
                _OutlinedBox(
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping, size: 20, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.pickupByEcoTruck, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 3),
                            Text('${widget.stopName}・$window', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _PaymentMethodSection(
                  methodsAsync: methodsAsync,
                  card: card,
                  onAdd: _addFirstCard,
                  onChange: () => _chooseCard(card?.id),
                  onRetry: () => ref.invalidate(myPaymentMethodsProvider),
                ),
                if (coupon != null) ...[
                  const SizedBox(height: 20),
                  Text(l10n.couponSectionLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  CouponTile(
                    coupon: coupon,
                    trailing: Switch(
                      key: const Key('useCouponSwitch'),
                      value: _useCoupon,
                      onChanged: (v) => setState(() => _useCoupon = v),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                // "Cancellation note": nền vàng nhạt, viền Amber.
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.amberSoft,
                    border: Border.all(color: AppColors.amber),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.freeCancelTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(l10n.freeCancelBody, style: const TextStyle(fontSize: 11, height: 1.6, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (ref.watch(paymentTestModeProvider)) PaymentNote(text: l10n.testPaymentNote, icon: Icons.science_outlined),
              ],
            ),
          ),
          // "Sticky summary": 1 thẻ = món (ảnh, 提携店, tên, giờ + điểm) / đường kẻ / 「合計（数量 1）」 + giá.
          // create_order luôn tạo đúng 1 phần → số lượng cố định 1.
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _OutlinedBox(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            BatchPhoto(photoUrl: widget.photoUrl, width: 56, height: 56, radius: 10),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.partnerStore, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                                  const SizedBox(height: 4),
                                  Text(l10n.mysteryBag, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text('$window ${widget.stopName}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        if (discount > 0) ...[
                          _SummaryLine(label: l10n.subtotalLabel, value: '¥$basePrice'),
                          const SizedBox(height: 4),
                          _SummaryLine(
                            key: const Key('couponDiscountLine'),
                            label: l10n.couponSectionLabel,
                            value: '−¥$discount',
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.totalWithQuantity(1), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            Text(priceText, key: const Key('totalPrice'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        // Figma 432:1022: giá đã gồm thuế — hiện phần thuế 8% nằm trong đó (app tự tính, cùng công thức với 0046).
                        if (price != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.taxIncludedLine(reducedTaxRate),
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              Text(
                                '¥${includedTax(price)}',
                                key: const Key('taxAmount'),
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Lỗi giá đặt ngay trên nút (vùng cố định, luôn nhìn thấy).
                  if (priceAsync.hasError && !priceAsync.isLoading) ...[
                    Row(
                      children: [
                        Expanded(child: Text(l10n.errorPriceLoad, style: const TextStyle(fontSize: 12, color: AppColors.error))),
                        TextButton(
                          key: const Key('retryPriceButton'),
                          onPressed: () => ref.invalidate(currentPriceProvider(priceParams)),
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (reviewError != null) ...[
                    _ErrorBox(message: reviewErrorMessage(reviewError, l10n)),
                    const SizedBox(height: 10),
                  ] else if (price != null && methodsAsync.hasValue) ...[
                    Text(
                      card == null ? l10n.addPaymentMethodHint : l10n.payNotice('¥$price'),
                      key: const Key('payNotice'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                  ],
                  FilledButton(
                    key: const Key('confirmReservationButton'),
                    onPressed: switch (errorAction) {
                      ReviewErrorAction.seeReservations => _goToOrders,
                      ReviewErrorAction.browse => _goToBrowse,
                      _ when needsCard => price == null ? null : _addFirstCard,
                      _ => canPay ? () => _pay(card, price, discount > 0 ? coupon?.id : null) : null,
                    },
                    child: Text(switch (errorAction) {
                      ReviewErrorAction.seeReservations => l10n.actionSeeReservations,
                      ReviewErrorAction.browse => l10n.actionFindOtherBags,
                      ReviewErrorAction.retry => l10n.tryAgain,
                      null => needsCard ? l10n.addPaymentMethodButton : l10n.payButton(priceText),
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 「支払い方法（必須）」+ dòng「＋ 支払い方法を追加」(16:16527) hoặc thẻ đang chọn (378:82, chạm để đổi).
class _PaymentMethodSection extends StatelessWidget {
  const _PaymentMethodSection({
    required this.methodsAsync,
    required this.card,
    required this.onAdd,
    required this.onChange,
    required this.onRetry,
  });
  final AsyncValue<List<PaymentMethod>> methodsAsync;
  final PaymentMethod? card;
  final VoidCallback onAdd;
  final VoidCallback onChange;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          selected == null ? l10n.paymentMethodRequired : l10n.paymentMethodSection,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        methodsAsync.when(
          loading: () => const _OutlinedBox(child: SizedBox(height: 30, child: Center(child: LinearProgressIndicator()))),
          error: (_, __) => _OutlinedBox(
            child: Row(
              children: [
                Expanded(child: Text(l10n.errorPaymentMethodsLoad, style: const TextStyle(fontSize: 12, color: AppColors.error))),
                TextButton(key: const Key('retryPaymentMethodsButton'), onPressed: onRetry, child: Text(l10n.retry)),
              ],
            ),
          ),
          data: (_) => selected == null
              ? InkWell(
                  key: const Key('addPaymentMethodRow'),
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(12),
                  child: _OutlinedBox(
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                          child: const Text('＋', style: TextStyle(fontSize: 18, color: AppColors.primary)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.addPaymentMethod, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(l10n.addPaymentMethodSub, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                )
              : PaymentMethodTile(
                  key: const Key('selectedCardRow'),
                  method: selected,
                  subtitle: selected.isDefault ? l10n.defaultCardLabel : l10n.cardExpiresOn(selected.expiryLabel),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  onTap: onChange,
                ),
        ),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          StatusBadge(label: context.l10n.errorBadge, tone: BadgeTone.error),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12, height: 1.45, color: AppColors.error))),
        ],
      ),
    );
  }
}

class _OutlinedBox extends StatelessWidget {
  const _OutlinedBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

// Dòng 「小計 ¥650」/「クーポン −¥100」 trong thẻ tóm tắt (Figma 470:1318).
class _SummaryLine extends StatelessWidget {
  const _SummaryLine({super.key, required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: color == null ? FontWeight.w400 : FontWeight.w700, color: color)),
      ],
    );
  }
}

// Nút chính khi có lỗi ở màn review = "việc khách làm được tiếp" (Figma 949:21244〜, ghi chú 949:21567).
// null = giữ nút thường (thanh toán / thêm thẻ): lỗi coupon (đã tải lại coupon) và thẻ bị xoá (chọn thẻ ở trên).
enum ReviewErrorAction { seeReservations, browse, retry }

ReviewErrorAction? reviewErrorAction(PaymentFailure failure) => switch (failure) {
  PaymentFailure.dailyLimit => ReviewErrorAction.seeReservations,
  PaymentFailure.soldOutAtStop || PaymentFailure.batchUnavailable || PaymentFailure.priceUnavailable => ReviewErrorAction.browse,
  PaymentFailure.couponUnavailable || PaymentFailure.methodMissing => null,
  _ => ReviewErrorAction.retry,
};

String reviewErrorMessage(PaymentFailure failure, AppLocalizations l10n) => switch (failure) {
  PaymentFailure.methodMissing => l10n.errorPaymentMethodMissing,
  PaymentFailure.rateLimited => l10n.errorRateLimited,
  PaymentFailure.couponUnavailable => l10n.errorCouponUnavailable,
  PaymentFailure.priceUnavailable => l10n.errorPriceTooLow,
  PaymentFailure.serviceError => l10n.errorPaymentService,
  PaymentFailure.dailyLimit => l10n.errorDailyLimit,
  PaymentFailure.soldOutAtStop => l10n.errorSoldOutAtStop,
  PaymentFailure.batchUnavailable => l10n.errorBatchUnavailable,
  _ => l10n.errorReservationFailed,
};
