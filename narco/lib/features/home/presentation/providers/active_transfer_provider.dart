import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveTransferNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void start() => state = true;
  void stop() => state = false;
}

final activeTransferProvider =
    NotifierProvider<ActiveTransferNotifier, bool>(ActiveTransferNotifier.new);
