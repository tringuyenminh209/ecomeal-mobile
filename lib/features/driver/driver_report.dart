import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/rpc_error.dart';
import '../../core/supabase_client.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';

// SCR-D06「運営に連絡」(review page 02, Figma 625:1429; migration 0067 / API-085). Mở từ nút ở đáy SCR-D01.
// Gửi xong → toàn bộ admin nhận thông báo bắt buộc; khách bị ảnh hưởng do 運営 liên hệ (app không tự gửi gì cho khách).

const driverReportCategories = ['delay', 'vehicle', 'food', 'other'];
const driverReportDelayOptions = [10, 20, 30]; // 30 = 「30分以上」 (server chỉ nhận 10 / 20 / 30)
const _maxMessageLength = 500; // report_driver_incident: 1〜500 ký tự

// Dùng chung cho app tài xế (sheet) và app admin (danh sách 運行の連絡)
String driverReportCategoryLabel(String category, AppLocalizations l10n) => switch (category) {
  'delay' => l10n.driverReportDelay,
  'vehicle' => l10n.driverReportVehicle,
  'food' => l10n.driverReportFood,
  _ => l10n.driverReportOther,
};

String driverReportDelayLabel(int minutes, AppLocalizations l10n) =>
    minutes >= driverReportDelayOptions.last ? l10n.driverReportMinutesMax : l10n.driverReportMinutes(minutes);

abstract class DriverReportGateway {
  Future<void> report({required String category, int? delayMinutes, String? message});
}

class SupabaseDriverReportGateway implements DriverReportGateway {
  SupabaseDriverReportGateway(this._client);
  final SupabaseClient _client;

  @override
  Future<void> report({required String category, int? delayMinutes, String? message}) => _client.rpc(
    'report_driver_incident',
    params: {'p_category': category, 'p_delay_minutes': delayMinutes, 'p_message': message},
  );
}

final driverReportGatewayProvider = Provider<DriverReportGateway>(
  (ref) => SupabaseDriverReportGateway(SupabaseClientHolder.instance),
);

// Mở sheet; gửi xong thì báo bằng SnackBar ở màn D01
Future<void> openDriverReportSheet(BuildContext context) async {
  final sent = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const DriverReportSheet(),
  );
  if (sent == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.driverReportSent)));
  }
}

class DriverReportSheet extends ConsumerStatefulWidget {
  const DriverReportSheet({super.key});

  @override
  ConsumerState<DriverReportSheet> createState() => _DriverReportSheetState();
}

class _DriverReportSheetState extends ConsumerState<DriverReportSheet> {
  final _message = TextEditingController();
  String? _category;
  int _delay = driverReportDelayOptions.first;
  String? _error;
  bool _sending = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final category = _category;
    final message = _message.text.trim();
    // Cùng quy tắc với server (E-REPORT-422): chọn loại; 「その他」 phải có lời nhắn
    if (category == null) return setState(() => _error = l10n.driverReportSelect);
    if (category == 'other' && message.isEmpty) return setState(() => _error = l10n.driverReportNeedMessage);
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(driverReportGatewayProvider).report(
        category: category,
        delayMinutes: category == 'delay' ? _delay : null,
        message: message.isEmpty ? null : message,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = switch (rpcErrorCode(e)) {
          'E-REPORT-404' => l10n.driverReportNoRoute,
          'E-REPORT-429' => l10n.driverReportDuplicate,
          _ => l10n.driverReportError,
        };
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          children: [
            Text(l10n.driverReportTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(l10n.driverReportLead, style: TextStyle(fontSize: 13, height: 1.6, color: eco.textSecondary)),
            const SizedBox(height: 16),
            for (final c in driverReportCategories)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: _category == c ? eco.primary : eco.border, width: _category == c ? 2 : 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RadioListTile<String>(
                    key: Key('driverReport_$c'),
                    value: c,
                    groupValue: _category,
                    onChanged: (v) => setState(() {
                      _category = v;
                      _error = null;
                    }),
                    title: Text(driverReportCategoryLabel(c, l10n), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            if (_category == 'delay') ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: [
                  for (final m in driverReportDelayOptions)
                    ChoiceChip(
                      key: Key('driverReportDelay_$m'),
                      label: Text(driverReportDelayLabel(m, l10n)),
                      selected: _delay == m,
                      onSelected: (_) => setState(() => _delay = m),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 4),
            TextField(
              key: const Key('driverReportMessage'),
              controller: _message,
              minLines: 1,
              maxLines: 4,
              maxLength: _maxMessageLength,
              decoration: InputDecoration(hintText: l10n.driverReportMessageHint),
            ),
            if (_error != null) ...[
              Text(_error!, key: const Key('driverReportError'), style: TextStyle(fontSize: 12, color: eco.error)),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 4),
            FilledButton(
              key: const Key('driverReportSend'),
              onPressed: _sending ? null : _submit,
              child: _sending
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.driverReportSend),
            ),
          ],
        ),
      ),
    );
  }
}
