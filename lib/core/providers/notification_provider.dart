import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/notification_service.dart';
import '../../features/subscriptions/presentation/providers/subscription_provider.dart';
import 'theme_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Notifier that manages billing alert preferences and persists them.
class BillingAlertsNotifier extends Notifier<bool> {
  static const _key = 'billing_alerts_enabled';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? true; // Enabled by default
  }

  void toggle() {
    state = !state;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_key, state);
  }

  void setEnabled(bool enabled) {
    state = enabled;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_key, state);
  }
}

/// The global billing alerts provider used throughout the app.
final billingAlertsProvider =
    NotifierProvider<BillingAlertsNotifier, bool>(BillingAlertsNotifier.new);

/// This background provider watches subscriptions and the toggle state
/// to automatically schedule or cancel push notifications.
final notificationSchedulerProvider = Provider<void>((ref) {
  final isEnabled = ref.watch(billingAlertsProvider);
  final notificationService = ref.read(notificationServiceProvider);

  if (!isEnabled) {
    notificationService.cancelAllAlerts();
    return;
  }

  final subsAsync = ref.watch(userSubscriptionsProvider);
  subsAsync.whenData((subs) {
    notificationService.scheduleSubscriptionAlerts(subs);
  });
});

