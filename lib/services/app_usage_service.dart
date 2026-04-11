import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appUsageServiceProvider = Provider<AppUsageService>((ref) {
  return AppUsageService();
});

class AppUsageService {
  static const MethodChannel _channel = MethodChannel('com.example.sub_manager/usage');

  Future<bool> checkUsagePermission() async {
    try {
      final bool hasPermission = await _channel.invokeMethod('checkUsagePermission');
      return hasPermission;
    } on PlatformException catch (e) {
      debugPrint("Failed to check permission: '${e.message}'.");
      return false;
    }
  }

  Future<void> requestUsagePermission() async {
    try {
      await _channel.invokeMethod('requestUsagePermission');
    } on PlatformException catch (e) {
      debugPrint("Failed to request permission: '${e.message}'.");
    }
  }

  // Returns a map of package name -> milliseconds spent in the foreground in the last 30 days
  Future<Map<String, int>> getUsageStats() async {
    try {
      final Map<dynamic, dynamic>? result = await _channel.invokeMethod('getUsageStats');
      if (result != null) {
        return result.map((key, value) => MapEntry(key.toString(), (value as num).toInt()));
      }
      return {};
    } on PlatformException catch (e) {
      debugPrint("Failed to get usage stats: '${e.message}'.");
      return {};
    }
  }
}
