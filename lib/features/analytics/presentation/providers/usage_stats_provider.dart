import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/app_usage_service.dart';

final usagePermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(appUsageServiceProvider);
  return await service.checkUsagePermission();
});

final usageStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(appUsageServiceProvider);
  final hasPermission = await service.checkUsagePermission();
  if (!hasPermission) {
    return {};
  }
  return service.getUsageStats();
});
