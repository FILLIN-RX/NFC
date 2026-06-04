import 'package:flutter/material.dart';

class TransferScreen extends StatelessWidget {
  final String? method;
  final String? tokenId;

  const TransferScreen({super.key, this.method, this.tokenId});

  @override
  Widget build(BuildContext context) {
    final channel = method == 'nfc' ? 'NFC' : 'Bluetooth';
    return Scaffold(
      appBar: AppBar(title: Text('Transfert $channel')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              method == 'nfc' ? Icons.nfc : Icons.bluetooth,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Transfert via $channel',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Jeton: ${tokenId != null ? '...${tokenId!.substring(tokenId!.length > 6 ? tokenId!.length - 6 : 0)}' : 'N/A'}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text('En attente du Dev 2...'),
          ],
        ),
      ),
    );
  }
}
