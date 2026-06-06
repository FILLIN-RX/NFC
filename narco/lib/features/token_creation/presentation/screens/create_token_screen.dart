import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 365));

  @override
  void dispose() {
    _valeurController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: AppTheme.dark, shape: BoxShape.circle),
              child: const Icon(Icons.bolt, color: AppTheme.primary, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('Narco'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text('Issue Token', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Configure your digital asset parameters to mint a new token securely.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 32),

            _buildAssetPreview(state),

            const SizedBox(height: 32),
            const Text('Token Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            _buildTypeSelector(state),

            const SizedBox(height: 24),
            _buildInputLabel('Value (${state.tokenType.defaultUnite})'),
            _buildTextField(
              controller: _valeurController,
              hint: '0.00',
              icon: Icons.euro,
              keyboardType: TextInputType.number,
              onChanged: (v) => ref.read(tokenCreationViewModelProvider.notifier).setValeur(v),
            ),

            const SizedBox(height: 24),
            _buildInputLabel('Description'),
            _buildTextField(
              controller: _descriptionController,
              hint: 'Enter purpose of this token...',
              onChanged: (v) => ref.read(tokenCreationViewModelProvider.notifier).setProprietaire(v),
            ),

            const SizedBox(height: 24),
            _buildInputLabel('Expiration Date'),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: _buildTextField(
                  hint: DateFormat('MM / yyyy').format(_selectedDate),
                  icon: Icons.calendar_today_outlined,
                  enabled: false,
                  onChanged: (_) {},
                ),
              ),
            ),

            const SizedBox(height: 40),
            _buildGenerateButton(state),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetPreview(TokenCreationState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('NARCO ASSET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Standard ${state.tokenType.label}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.circle, size: 12, color: Colors.black26),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Token Value', style: TextStyle(fontSize: 10, color: Colors.black54)),
          const SizedBox(height: 2),
          Text(
            '${state.valeurText.isEmpty ? "0.00" : state.valeurText} ${state.tokenType.defaultUnite}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          const Text('EXPIRATION DATE', style: TextStyle(fontSize: 10, color: Colors.black54)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('MM / yyyy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.bolt, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(TokenCreationState state) {
    return Row(
      children: [
        _buildTypeTab(TokenType.payment, state.tokenType == TokenType.payment, Icons.account_balance_wallet_outlined),
        const SizedBox(width: 12),
        _buildTypeTab(TokenType.voucher, state.tokenType == TokenType.voucher, Icons.card_giftcard),
      ],
    );
  }

  Widget _buildTypeTab(TokenType type, bool isSelected, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(tokenCreationViewModelProvider.notifier).setTokenType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.black : Colors.grey),
              const SizedBox(width: 8),
              Text(
                type.label,
                style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String hint,
    IconData? icon,
    bool enabled = true,
    TextInputType? keyboardType,
    required void Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: icon != null ? Icon(icon, color: Colors.grey.shade400, size: 20) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  Widget _buildGenerateButton(TokenCreationState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state.isSubmitting ? null : () => ref.read(tokenCreationViewModelProvider.notifier).createToken(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.dark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: state.isSubmitting
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Generate Token', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.auto_awesome, size: 18, color: AppTheme.primary),
                ],
              ),
      ),
    );
  }
}
