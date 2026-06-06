import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/user_service.dart';

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.read(userServiceProvider).isLoggedIn();
});
