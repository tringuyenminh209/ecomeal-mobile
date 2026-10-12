import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';

// UC-41 お気に入りの受取地点 (0053, API-067〜068). Đăng ký điểm nhận công khai (tối đa 5) → có túi đồ ăn mới ở đó thì
// server tự gửi thông báo (outbox new_batch). App chỉ đọc danh sách và bật/tắt.
class FavoriteStop {
  const FavoriteStop({required this.stopLocationId, required this.name, this.address});
  final String stopLocationId;
  final String name;
  final String? address;
}

abstract class FavoriteStopsGateway {
  Future<List<FavoriteStop>> fetchMyFavorites(); // API-068: favorite_stops (RLS: chỉ của mình), mới đăng ký trước
  Future<void> setFavorite(String stopLocationId, {required bool isFavorite}); // API-067
}

class SupabaseFavoriteStopsGateway implements FavoriteStopsGateway {
  SupabaseFavoriteStopsGateway(this._client);
  final SupabaseClient _client;

  @override
  Future<List<FavoriteStop>> fetchMyFavorites() async {
    final rows = await _client
        .from('favorite_stops')
        .select('stop_location_id, stop_locations!inner(name, address)')
        .order('created_at', ascending: false) as List;
    return rows.map((raw) {
      final row = raw as Map<String, dynamic>;
      final stop = row['stop_locations'] as Map<String, dynamic>;
      return FavoriteStop(
        stopLocationId: row['stop_location_id'] as String,
        name: stop['name'] as String,
        address: stop['address'] as String?,
      );
    }).toList();
  }

  @override
  Future<void> setFavorite(String stopLocationId, {required bool isFavorite}) =>
      _client.rpc('set_favorite_stop', params: {'p_stop_location_id': stopLocationId, 'p_is_favorite': isFavorite});
}

final favoriteStopsGatewayProvider =
    Provider<FavoriteStopsGateway>((ref) => SupabaseFavoriteStopsGateway(SupabaseClientHolder.instance));

// SCR-M04 (nút ☆), SCR-M07 (số đã đăng ký) và SCR-M16 cùng đọc — bật/tắt xong thì invalidate để cả 3 cập nhật.
final myFavoriteStopsProvider = FutureProvider.autoDispose<List<FavoriteStop>>((ref) {
  return ref.watch(favoriteStopsGatewayProvider).fetchMyFavorites();
});

// Câu lỗi khi bật/tắt: E-FAV-409 = đã đủ 5 điểm; còn lại (mất mạng…) câu chung.
String favoriteErrorMessage(Object error, AppLocalizations l10n) {
  final message = error is PostgrestException ? error.message : '';
  return message.contains('E-FAV-409') ? l10n.favoriteLimitReached : l10n.favoriteUpdateFailed;
}

// Nút ☆ tròn 40 (Figma 460:1181 "Favorite / on|off"): bật = nền xanh nhạt + sao đặc; tắt = viền + sao rỗng.
// Kết quả báo bằng SnackBar (đã thêm → nói rõ sẽ nhận thông báo).
class FavoriteStarButton extends ConsumerStatefulWidget {
  const FavoriteStarButton({super.key, required this.stopLocationId});
  final String stopLocationId;

  @override
  ConsumerState<FavoriteStarButton> createState() => _FavoriteStarButtonState();
}

class _FavoriteStarButtonState extends ConsumerState<FavoriteStarButton> {
  bool _saving = false;

  // Nút này nằm ở SCR-M04, nơi nút 「予約する」 cố định ở cuối màn: SnackBar nổi lên phía trên nút (không che, không chặn thao tác), tự tắt sau 4 giây
  SnackBar _snack(String text) => SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        duration: const Duration(seconds: 4),
      );

  Future<void> _toggle(bool current) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(favoriteStopsGatewayProvider).setFavorite(widget.stopLocationId, isFavorite: !current);
      ref.invalidate(myFavoriteStopsProvider);
      messenger.showSnackBar(_snack(current ? l10n.favoriteRemoved : l10n.favoriteAdded));
    } catch (e) {
      messenger.showSnackBar(_snack(favoriteErrorMessage(e, l10n)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final favorites = ref.watch(myFavoriteStopsProvider).valueOrNull;
    // Chưa tải xong danh sách thì chưa biết trạng thái → không hiện nút (tránh bấm nhầm "thêm" khi đã có)
    if (favorites == null) return const SizedBox(width: 40, height: 40);
    final isFavorite = favorites.any((f) => f.stopLocationId == widget.stopLocationId);
    return Semantics(
      toggled: isFavorite,
      child: IconButton(
        key: const Key('favoriteStarButton'),
        tooltip: isFavorite ? l10n.favoriteRemoveTooltip : l10n.favoriteAddTooltip,
        onPressed: _saving ? null : () => _toggle(isFavorite),
        style: IconButton.styleFrom(
          fixedSize: const Size(40, 40),
          backgroundColor: isFavorite ? context.eco.primarySoft : null,
          side: isFavorite ? null : BorderSide(color: context.eco.border),
        ),
        icon: Icon(
          isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 22,
          color: isFavorite ? context.eco.primary : context.eco.textSecondary,
        ),
      ),
    );
  }
}
