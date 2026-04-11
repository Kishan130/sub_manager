import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../subscriptions/presentation/providers/subscription_provider.dart';
import '../../subscriptions/presentation/screens/add_subscription_screen.dart';
import '../../subscriptions/presentation/screens/subscription_detail_screen.dart';
import '../../../../utils/ai_insights.dart';
import '../../analytics/presentation/providers/usage_stats_provider.dart';
import '../../../../services/app_usage_service.dart';
import '../../subscriptions/data/default_platforms.dart';
import '../../../../models/subscription.dart';
import '../../../../core/theme.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(usageStatsProvider);
    }
  }

  Widget _buildLogo(Subscription sub) {
    if (sub.logoAssetPath.startsWith('http')) {
      return CircleAvatar(backgroundColor: Colors.transparent, backgroundImage: NetworkImage(sub.logoAssetPath));
    }
    final match = defaultPlatforms.firstWhere(
      (p) => p['name'] == sub.name,
      orElse: () => <String, dynamic>{},
    );
    final logoUrl = match['logoUrl'] as String?;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return CircleAvatar(backgroundColor: Colors.transparent, backgroundImage: NetworkImage(logoUrl));
    }

    final dynamicUrl = 'https://www.google.com/s2/favicons?domain=${sub.name.replaceAll(' ', '').toLowerCase()}.com&sz=128';
    return CircleAvatar(
      backgroundColor: Color(int.tryParse(sub.logoAssetPath) ?? 0xFF000000),
      backgroundImage: NetworkImage(dynamicUrl),
      onBackgroundImageError: (e, s) {}, // fallback to child silently
      child: Text(sub.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subsAsync = ref.watch(userSubscriptionsProvider);
    final usageAsync = ref.watch(usageStatsProvider);
    final permissionAsync = ref.watch(usagePermissionProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
      ),
      body: subsAsync.when(
        data: (subs) {
          if (subs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.inbox_rounded, size: 50, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 20),
                  Text('No subscriptions yet', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first subscription to get started',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final usageStats = usageAsync.value ?? {};
          final totalSpend = AiInsights.calculateTotalMonthlySpending(subs);
          final unusedAlerts = AiInsights.getUnusedAlerts(subs, usageStats);

          // Calculate average efficiency
          double avgScore = 0;
          if (subs.isNotEmpty) {
            final totalScore = subs.fold(0.0, (sum, sub) => sum + AiInsights.calculateEfficiencyScore(sub, usageStats));
            avgScore = totalScore / subs.length;
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userSubscriptionsProvider);
              ref.invalidate(usageStatsProvider);
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: colorScheme.primary,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ─── Top Premium Card ───────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withAlpha(isDark ? 40 : 60),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Spend',
                              style: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${totalSpend.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${subs.length} active subs',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(220),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircularPercentIndicator(
                        radius: 44.0,
                        lineWidth: 8.0,
                        percent: (avgScore / 100).clamp(0.0, 1.0),
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${avgScore.toStringAsFixed(0)}%",
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Score',
                              style: TextStyle(
                                color: Colors.white.withAlpha(180),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        progressColor: AppTheme.secondaryColor,
                        backgroundColor: Colors.white.withAlpha(40),
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                    ],
                  ),
                ),

                // ─── Usage Permission Alert ──────────────────────────────
                if (permissionAsync.value == false) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.error.withAlpha(50),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.error.withAlpha(25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.privacy_tip_rounded, color: colorScheme.onErrorContainer, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Usage Access Required',
                                style: textTheme.titleSmall?.copyWith(
                                  color: colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Grant Usage Access to unlock AI Insights and subscription analytics.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onErrorContainer.withAlpha(200),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await ref.read(appUsageServiceProvider).requestUsagePermission();
                              ref.invalidate(usagePermissionProvider);
                              ref.invalidate(usageStatsProvider);
                            },
                            icon: const Icon(Icons.settings_rounded, size: 18),
                            label: const Text('Grant Permission'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: colorScheme.errorContainer,
                              backgroundColor: colorScheme.onErrorContainer,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ─── AI Recommendations ──────────────────────────────────
                if (unusedAlerts.isNotEmpty || subs.any((s) => AiInsights.calculateEfficiencyScore(s, usageStats) > 80)) ...[
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.auto_awesome, size: 18, color: colorScheme.primary),
                      ),
                      const SizedBox(width: 10),
                      Text('AI Recommendations', style: textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ─── Consider Dropping ──────────────────────────────────
                  if (unusedAlerts.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withAlpha(isDark ? 20 : 15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.errorColor.withAlpha(isDark ? 60 : 40)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorColor.withAlpha(30),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.remove_circle_outline, color: AppTheme.errorColor, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Consider Dropping',
                                style: textTheme.titleSmall?.copyWith(color: AppTheme.errorColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...unusedAlerts.map((alert) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.errorColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(alert, style: textTheme.bodySmall?.copyWith(
                                    color: AppTheme.errorColor,
                                    height: 1.4,
                                  )),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),

                  // ─── Great Value (Keep) ─────────────────────────────────
                  if (subs.any((s) => AiInsights.calculateEfficiencyScore(s, usageStats) > 80))
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withAlpha(isDark ? 20 : 15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.successColor.withAlpha(isDark ? 60 : 40)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor.withAlpha(30),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.check_circle_outline, color: AppTheme.successColor, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Great Value (Keep)',
                                style: textTheme.titleSmall?.copyWith(color: AppTheme.successColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...subs.where((s) => AiInsights.calculateEfficiencyScore(s, usageStats) > 80).map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.successColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${s.name} — excellent ROI!',
                                    style: textTheme.bodySmall?.copyWith(color: AppTheme.successColor),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                ],

                // ─── Active Subscriptions ─────────────────────────────────
                const SizedBox(height: 28),
                Text('Active Subscriptions', style: textTheme.titleLarge),
                const SizedBox(height: 16),

                ...subs.map((sub) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: Key(sub.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                    ),
                    onDismissed: (_) {
                      ref.read(firestoreServiceProvider).deleteSubscription(sub.id);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.outline.withAlpha(50),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        leading: _buildLogo(sub),
                        title: Text(
                          sub.name,
                          style: textTheme.titleSmall,
                        ),
                        subtitle: Text(
                          'Next: ${sub.nextBillingDate.toLocal()}'.split(' ')[0],
                          style: textTheme.bodySmall,
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withAlpha(15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '₹${sub.cost.toStringAsFixed(0)}',
                            style: textTheme.titleSmall?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => SubscriptionDetailScreen(subscription: sub)));
                        },
                      ),
                    ),
                  ),
                )),
              ],
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
        error: (e, trace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('Error loading data', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('$e', style: textTheme.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSubscriptionScreen())),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Platform'),
      ),
    );
  }
}
