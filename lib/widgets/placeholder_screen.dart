import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_controller.dart';
import '../l10n/l10n.dart';

// Màn chờ cho phần chưa triển khai (role chưa có app, tab chưa viết) — luôn kèm nút ログアウト để người dùng
// không bị kẹt. Dùng cho RoleGate (Chương 15) với các role chưa có màn hình trên app.
class PlaceholderScreen extends ConsumerWidget {
  const PlaceholderScreen({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  try {
                    await ref.read(authControllerProvider.notifier).signOut();
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.errorSignOutFailed),
                        ),
                      );
                    }
                  }
                },
                child: Text(context.l10n.signOutButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
