import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/appTheme.dart';
import '../../domain/models/token_type.dart';
import '../providers/token_creation_vm.dart';

class CreateTokenScreen extends ConsumerStatefulWidget {
  const CreateTokenScreen({super.key});

  @override
  ConsumerState<CreateTokenScreen> createState() => _CreateTokenScreenState();
}

class _CreateTokenScreenState extends ConsumerState<CreateTokenScreen> {
  final _valeurController = TextEditingController();
  final _proprietaireController = TextEditingController();

  @override
  void dispose() {
    _valeurController.dispose();
    _proprietaireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tokenCreationViewModelProvider);

    ref.listen<TokenCreationState>(tokenCreationViewModelProvider, (previous, next) {
      if (next.isSuccess && (previous == null || !previous.isSuccess)) {
        context.pushReplacement('/token-confirmation');
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Créer un Jeton'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.error.withValues(alpha: 0.5)),
                ),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: AppTheme.error),
                ),
              ),

            _buildDropdown(
              label: 'Type de Jeton',
              value: state.tokenType,
              items: TokenType.values,
              itemLabel: (t) => t.label,
              onChanged: (v) => ref.read(tokenCreationViewModelProvider.notifier).setTokenType(v!),
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _valeurController,
              label: 'Valeur (${state.tokenType.defaultUnite})',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => ref.read(tokenCreationViewModelProvider.notifier).setValeur(value),
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _proprietaireController,
              label: 'Destinataire (Propriétaire)',
              onChanged: (value) => ref.read(tokenCreationViewModelProvider.notifier).setProprietaire(value),
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: state.isSubmitting
                  ? null
                  : () => ref.read(tokenCreationViewModelProvider.notifier).createToken(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: state.isSubmitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text(
                      'Créer le Jeton',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(itemLabel(e)))).toList(),
      onChanged: onChanged,
    );
  }
}
