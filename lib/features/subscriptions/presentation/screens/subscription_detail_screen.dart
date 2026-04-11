import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../../../../utils/ai_insights.dart';
import '../../../analytics/presentation/providers/usage_stats_provider.dart';
import '../../data/default_platforms.dart';
import '../../../../core/theme.dart';

class SubscriptionDetailScreen extends ConsumerWidget {
  final Subscription subscription;

  const SubscriptionDetailScreen({super.key, required this.subscription});

  String _formatDuration(int millis) {
    if (millis == 0) return "0s";
    final hours = millis ~/ (1000 * 60 * 60);
    final minutes = (millis % (1000 * 60 * 60)) ~/ (1000 * 60);
    final seconds = (millis % (1000 * 60)) ~/ 1000;

    if (hours > 0) return "${hours}h ${minutes}m";
    if (minutes > 0) return "${minutes}m ${seconds}s";
    return "${seconds}s";
  }

  Widget _buildLogo(Subscription sub, bool isDark) {
    final match = defaultPlatforms.firstWhere(
      (p) => p['name'] == sub.name,
      orElse: () => <String, dynamic>{},
    );
    
    final logoUrl = sub.logoAssetPath.startsWith('http') 
        ? sub.logoAssetPath 
        : (match['logoUrl'] as String? ?? '');

    final dynamicUrl = logoUrl.isNotEmpty 
        ? logoUrl 
        : 'https://www.google.com/s2/favicons?domain=${sub.name.replaceAll(' ', '').toLowerCase()}.com&sz=128';

    final bgColor = Color(int.tryParse(sub.logoAssetPath) ?? 
                    (match['color'] as int? ?? 0xFF6750A4));

    return CircleAvatar(
      radius: 44,
      backgroundColor: bgColor,
      child: ClipOval(
        child: Image.network(
          dynamicUrl,
          width: 88,
          height: 88,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                sub.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  DateTime _calculateLastPaymentDate(Subscription sub) {
    if (sub.billingCycle == 'yearly') {
      return DateTime(sub.nextBillingDate.year - 1, sub.nextBillingDate.month, sub.nextBillingDate.day);
    } else if (sub.billingCycle == 'weekly') {
      return sub.nextBillingDate.subtract(const Duration(days: 7));
    } else {
      return DateTime(sub.nextBillingDate.year, sub.nextBillingDate.month - 1, sub.nextBillingDate.day);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subsList = ref.watch(userSubscriptionsProvider).value ?? [];
    final currentSub = subsList.firstWhere(
      (s) => s.id == subscription.id,
      orElse: () => subscription,
    );

    final usageStats = ref.watch(usageStatsProvider).value ?? {};
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String pkgName = currentSub.androidPackageName;
    if (pkgName.isEmpty) {
      final match = defaultPlatforms.firstWhere(
        (p) => p['name'] == currentSub.name,
        orElse: () => <String, dynamic>{},
      );
      pkgName = match['packageName'] ?? '';
    }

    final lastPaymentDate = _calculateLastPaymentDate(currentSub);
    final score = AiInsights.calculateEfficiencyScore(currentSub, usageStats);
    final timesUsed = currentSub.usageHistory.length;
    final costPerUse = timesUsed > 0 ? (currentSub.cost / timesUsed) : currentSub.cost;
    final lastUsedStr = currentSub.usageHistory.isNotEmpty
        ? currentSub.usageHistory.last.toLocal().toString().split(' ')[0]
        : 'Never';

    final scoreColor = score > 70
        ? AppTheme.successColor
        : (score > 40 ? AppTheme.warningColor : AppTheme.errorColor);

    return Scaffold(
      appBar: AppBar(title: Text(currentSub.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ─── Hero Section ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppTheme.darkCardGradient
                    : const LinearGradient(
                        colors: [Color(0xFFEDE7F6), Color(0xFFE8EAF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.outline.withAlpha(50),
                ),
              ),
              child: Column(
                children: [
                  _buildLogo(currentSub, isDark),
                  const SizedBox(height: 16),
                  Text(
                    currentSub.name,
                    style: textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currentSub.category,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── Efficiency Score Card ────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outline.withAlpha(50)),
              ),
              child: Row(
                children: [
                  CircularPercentIndicator(
                    radius: 44.0,
                    lineWidth: 8.0,
                    percent: (score / 100).clamp(0.0, 1.0),
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${score.toStringAsFixed(0)}%",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: scoreColor,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Score',
                          style: textTheme.bodySmall?.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                    progressColor: scoreColor,
                    backgroundColor: scoreColor.withAlpha(30),
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Efficiency', style: textTheme.labelMedium),
                        const SizedBox(height: 8),
                        _DetailRow(
                          icon: Icons.currency_rupee,
                          label: 'Plan',
                          value: '₹${currentSub.cost.toStringAsFixed(0)} / ${currentSub.billingCycle}',
                          textTheme: textTheme,
                        ),
                        const SizedBox(height: 6),
                        _DetailRow(
                          icon: Icons.trending_down,
                          label: 'Cost/Use',
                          value: '₹${costPerUse.toStringAsFixed(0)}',
                          valueColor: AppTheme.warningColor,
                          textTheme: textTheme,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── Billing Details Card ─────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outline.withAlpha(50)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 18, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('Billing Details', style: textTheme.titleSmall?.copyWith(color: colorScheme.primary)),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.calendar_today_rounded, color: colorScheme.primary, size: 20),
                    ),
                    title: Text('Next Payment', style: textTheme.bodyMedium),
                    trailing: Text(
                      currentSub.nextBillingDate.toLocal().toString().split(' ')[0],
                      style: textTheme.titleSmall,
                    ),
                  ),
                  Divider(height: 1, indent: 20, endIndent: 20, color: colorScheme.outline.withAlpha(50)),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.history_rounded, color: colorScheme.primary, size: 20),
                    ),
                    title: Text('Last Payment', style: textTheme.bodyMedium),
                    trailing: Text(
                      lastPaymentDate.toLocal().toString().split(' ')[0],
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── Usage Stats Card ─────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outline.withAlpha(50)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Icon(Icons.analytics_outlined, size: 18, color: AppTheme.secondaryColor),
                        const SizedBox(width: 8),
                        Text('Usage Stats', style: textTheme.titleSmall?.copyWith(color: AppTheme.secondaryColor)),
                      ],
                    ),
                  ),
                  if (pkgName.isNotEmpty) ...[
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.timer_outlined, color: AppTheme.successColor, size: 20),
                      ),
                      title: Text('Auto-Tracked (30d)', style: textTheme.bodyMedium),
                      subtitle: Text('Monitored by Android', style: textTheme.bodySmall),
                      trailing: Text(
                        _formatDuration(usageStats[pkgName] ?? 0),
                        style: textTheme.titleSmall?.copyWith(color: AppTheme.successColor),
                      ),
                    ),
                    Divider(height: 1, indent: 20, endIndent: 20, color: colorScheme.outline.withAlpha(50)),
                  ],
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.ads_click_rounded, color: AppTheme.primaryColor, size: 20),
                    ),
                    title: Text('Manual Checks', style: textTheme.bodyMedium),
                    trailing: Text(
                      timesUsed.toString(),
                      style: textTheme.titleSmall,
                    ),
                  ),
                  Divider(height: 1, indent: 20, endIndent: 20, color: colorScheme.outline.withAlpha(50)),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.access_time_rounded, color: AppTheme.warningColor, size: 20),
                    ),
                    title: Text('Last Used', style: textTheme.bodyMedium),
                    trailing: Text(
                      lastUsedStr,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ─── Mark Used Button ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline_rounded, size: 22),
                label: const Text('Mark Used Today', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  await ref.read(firestoreServiceProvider).markUsedToday(currentSub);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Usage Recorded! ✓')),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Helper widget for detail rows in the efficiency section.
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final TextTheme textTheme;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.textTheme,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurface.withAlpha(120)),
        const SizedBox(width: 6),
        Text('$label: ', style: textTheme.bodySmall),
        Flexible(
          child: Text(
            value,
            style: textTheme.titleSmall?.copyWith(
              color: valueColor,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
