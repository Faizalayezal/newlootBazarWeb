import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lootbazarweb/network_manager/repository.dart';

final repositoryProvider = Provider<Repository>((ref) {
  return Repository();
});