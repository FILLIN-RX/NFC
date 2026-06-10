import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/appTheme.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/biometric_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _nameController = TextEditingController();
  bool _isSubmitting = false;
  bool _canCheckBiometrics = false;
  bool _enableBiometric = false;
  bool _isUnlockMode = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _checkUnlockMode();
  }

  Future<void> _checkBiometrics() async {
    final canCheck = await ref.read(biometricServiceProvider).canAuthenticate();
    if (mounted) {
      setState(() => _canCheckBiometrics = canCheck);
    }
  }

  void _checkUnlockMode() {
    final userService = ref.read(userServiceProvider);
    if (userService.isLoggedIn() && userService.isBiometricEnabled()) {
      setState(() => _isUnlockMode = true);
      // Auto-trigger biometric on unlock mode
      WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
    }
  }

  Future<void> _authenticate() async {
    final success = await ref.read(biometricServiceProvider).authenticate();
    if (success && mounted) {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSubmitting = true);
    final userService = ref.read(userServiceProvider);
    await userService.setUserName(name);
    await userService.setBiometricEnabled(_enableBiometric);
    
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    if (_isUnlockMode) {
      return _buildUnlockUI();
    }
    return _buildLoginUI();
  }

  Widget _buildUnlockUI() {
    final userName = ref.read(userServiceProvider).getUserName() ?? '';
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 32),
                Text(
                  'Bonjour $userName',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Veuillez déverrouiller pour continuer',
                  style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 48),
                IconButton(
                  iconSize: 80,
                  onPressed: _authenticate,
                  icon: const Icon(
                    Icons.fingerprint_rounded,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _authenticate,
                  child: const Text(
                    'Utiliser la biométrie',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginUI() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 60),
              _buildLogo(),
              const SizedBox(height: 32),
              const Text(
                'Bienvenue sur Narco',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Entrez votre nom pour commencer',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Votre nom',
                  hintText: 'Ex: Jean Dupont',
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppTheme.textSecondary.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.primary),
                  ),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: _nameController.text.trim().isEmpty ? null : (_) => _submit(),
              ),
              
              if (_canCheckBiometrics) ...[
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text(
                    'Activer le déverrouillage biométrique',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text('Utilisez votre empreinte ou visage pour accéder à l\'app'),
                  value: _enableBiometric,
                  onChanged: (val) => setState(() => _enableBiometric = val),
                  activeThumbColor: AppTheme.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nameController.text.trim().isEmpty || _isSubmitting
                      ? null
                      : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Commencer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return const AppLogo(size: 100, borderRadius: 28, showShadow: true);
  }
}
