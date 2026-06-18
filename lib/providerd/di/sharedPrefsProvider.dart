import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lootbazarweb/utils/preferences.dart';

final sharedPrefsProvider = Provider<SharedPrefs>((ref) {
  return SharedPrefs();
});