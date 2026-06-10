import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserService {
  static const _boxName = 'user_profile';

  Box get _box => Hive.box(_boxName);

  String? getUserName() => _box.get('name') as String?;

  Future<void> setUserName(String name) async {
    await _box.put('name', name);
  }

  bool isBiometricEnabled() => _box.get('biometricEnabled', defaultValue: false) as bool;

  Future<void> setBiometricEnabled(bool enabled) async {
    await _box.put('biometricEnabled', enabled);
  }

  bool isLoggedIn() {
    final name = getUserName();
    return name != null && name.isNotEmpty;
  }

  List<String> get receivedTokenIds {
    final list = _box.get('receivedIds') as List<dynamic>?;
    return list?.cast<String>() ?? [];
  }

  Future<bool> isTokenAlreadyReceived(String tokenId) async {
    return receivedTokenIds.contains(tokenId);
  }

  Future<void> markTokenReceived(String tokenId) async {
    final ids = receivedTokenIds.toList();
    ids.add(tokenId);
    await _box.put('receivedIds', ids);
  }
}

final userServiceProvider = Provider<UserService>((ref) => UserService());
