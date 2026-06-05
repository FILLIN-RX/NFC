import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/appTheme.dart';
import '../../data/services/bluetooth_service.dart';

/// Liste des appareils Bluetooth (appairés + découverts) pour choisir le
/// destinataire d'un envoi.
class BluetoothDeviceList extends ConsumerStatefulWidget {
  final void Function(BtDevice device) onSelected;

  const BluetoothDeviceList({super.key, required this.onSelected});

  @override
  ConsumerState<BluetoothDeviceList> createState() => _BluetoothDeviceListState();
}

class _BluetoothDeviceListState extends ConsumerState<BluetoothDeviceList> {
  final List<BtDevice> _devices = [];
  StreamSubscription<BtDevice>? _discoverySub;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _loadBonded();
  }

  @override
  void dispose() {
    _discoverySub?.cancel();
    ref.read(bluetoothServiceProvider).stopDiscovery();
    super.dispose();
  }

  Future<void> _loadBonded() async {
    final service = ref.read(bluetoothServiceProvider);
    final granted = await service.ensurePermissions();
    if (!granted) return;
    final result = await service.bondedDevices();
    result.when(
      success: (devices) {
        if (!mounted) return;
        setState(() {
          for (final d in devices) {
            if (!_devices.contains(d)) _devices.add(d);
          }
        });
      },
      failure: (_) {},
    );
  }

  Future<void> _scan() async {
    final service = ref.read(bluetoothServiceProvider);
    if (!await service.ensurePermissions()) return;
    setState(() => _scanning = true);

    _discoverySub?.cancel();
    _discoverySub = service.discoveredDevices().listen((device) {
      if (!mounted) return;
      setState(() {
        if (!_devices.contains(device)) _devices.add(device);
      });
    });

    await service.startDiscovery();
    // Arrêt automatique du scan après 12 s.
    Timer(const Duration(seconds: 12), () async {
      await service.stopDiscovery();
      if (mounted) setState(() => _scanning = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Choisir un appareil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: _scanning ? null : _scan,
              icon: _scanning
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.bluetooth_searching, size: 18),
              label: Text(_scanning ? 'Recherche…' : 'Scanner'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _devices.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun appareil. Lancez un scan ou appairez un téléphone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                )
              : ListView.separated(
                  itemCount: _devices.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    return _DeviceTile(
                      device: device,
                      onTap: () => widget.onSelected(device),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final BtDevice device;
  final VoidCallback onTap;

  const _DeviceTile({required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppTheme.tertiary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bluetooth, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      device.address,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
