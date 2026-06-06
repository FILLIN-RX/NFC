import 'package:flutter/material.dart';
import '../../../../core/appTheme.dart';
import '../widgets/action_buttons.dart';
import '../widgets/stats_badges.dart';

/// Écran principal de l'application Narco intégrant les badges de statistiques
/// et les boutons d'action sécurisés.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Narco Wallet'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Mission 2 : Affichage dynamique des statistiques (Envoyés/Reçus)
            const StatsBadges(),
            
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Solde total', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('75,000 FCFA', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Mission 2 : Boutons d'action incluant le lien vers l'historique
            const ActionButtons(),
          ],
        ),
      ),
    );
  }
}