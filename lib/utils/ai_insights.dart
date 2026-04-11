import '../../models/subscription.dart';

class AiInsights {
  // Returns total monthly spending
  static double calculateTotalMonthlySpending(List<Subscription> subs) {
    double total = 0;
    for (var sub in subs) {
      if (!sub.isActive) continue;
      if (sub.billingCycle == 'yearly') {
        total += sub.cost / 12;
      } else {
        total += sub.cost;
      }
    }
    return total;
  }

  // Returns list of unused subscription alerts
  static List<String> getUnusedAlerts(List<Subscription> subs, Map<String, int> appUsage) {
    List<String> alerts = [];
    final now = DateTime.now();
    for (var sub in subs) {
      if (!sub.isActive) continue;
      if (sub.cost <= 50) continue; // Ignore very cheap ones

      if (sub.androidPackageName.isNotEmpty && appUsage.isNotEmpty) {
        // Native Usage Tracking Strategy
        final usageMillis = appUsage[sub.androidPackageName];
        if (usageMillis == null || usageMillis < 1000 * 60 * 30) { 
          // Less than 30 mins tracked in the last 30 days
          alerts.add("You barely used ${sub.name} this month! Consider cancelling to save ₹${sub.cost.toStringAsFixed(0)}.");
        }
      } else {
        // Fallback to manual checkin Strategy
        if (sub.usageHistory.isEmpty) {
          alerts.add("You haven't logged any usage for ${sub.name} yet.");
          continue; 
        }
        final lastUsed = sub.usageHistory.last;
        final daysUnused = now.difference(lastUsed).inDays;
        if (daysUnused > 30) {
           alerts.add("${sub.name} hasn't been used in >30 days. Save ₹${sub.cost.toStringAsFixed(0)} by cancelling it!");
        }
      }
    }
    return alerts;
  }

  static double calculateEfficiencyScore(Subscription sub, Map<String, int> appUsage) {
    if (sub.androidPackageName.isNotEmpty && appUsage.isNotEmpty) {
      final usageMillis = appUsage[sub.androidPackageName] ?? 0;
      // Heuristic: Using an app for > 5 hours a month = 100% efficiency
      double score = (usageMillis / (1000 * 60 * 60 * 5)) * 100;
      return score > 100 ? 100 : score;
    }

    // Fallback manual checks
    if (sub.usageHistory.isEmpty) return 0;
    final now = DateTime.now();
    final recentUses = sub.usageHistory.where((d) => now.difference(d).inDays <= 30).length;
    double score = (recentUses / 6) * 100;
    return score > 100 ? 100 : score;
  }
}
