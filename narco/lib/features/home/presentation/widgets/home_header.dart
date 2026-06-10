import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/appTheme.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/biometric_service.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userService = ref.watch(userServiceProvider);
    final userName = userService.getUserName() ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1 : logo + app name + notification ──────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo + app name
              Row(
                children: [
                  const AppLogo(size: 40, circular: true),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName.isNotEmpty ? userName : 'Narco',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Notification / settings row
              Row(
                children: [
                  _HeaderIconButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () => _showComingSoon(context),
                  ),
                  const SizedBox(width: 10),
                  _HeaderIconButton(
                    icon: Icons.settings_outlined,
                    onTap: () => _showSettings(context, ref),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.comingSoon),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _SettingsSheet(),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Icon(icon, color: AppTheme.textPrimary, size: 20),
        ),
      ),
    );
  }
}

class _SettingsSheet extends ConsumerWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userService = ref.watch(userServiceProvider);
    final biometricService = ref.watch(biometricServiceProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paramètres',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
          FutureBuilder<bool>(
            future: biometricService.canAuthenticate(),
            builder: (context, snapshot) {
              final canUseBiometrics = snapshot.data ?? false;
              if (!canUseBiometrics) return const SizedBox.shrink();

              return SwitchListTile(
                title: const Text('Déverrouillage biométrique'),
                subtitle: const Text('Utiliser votre empreinte/visage au démarrage'),
                value: userService.isBiometricEnabled(),
                onChanged: (val) async {
                  await userService.setBiometricEnabled(val);
                },
                activeThumbColor: AppTheme.primary,
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Déconnexion', style: TextStyle(color: AppTheme.error)),
            leading: const Icon(Icons.logout_rounded, color: AppTheme.error),
            onTap: () async {
              // Simple logout for demo: clear name
              await userService.setUserName('');
              if (context.mounted) Navigator.pop(context);
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
