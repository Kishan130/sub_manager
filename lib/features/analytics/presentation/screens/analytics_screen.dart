import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../subscriptions/presentation/providers/subscription_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subsAsync = ref.watch(userSubscriptionsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Premium chart colors
    final chartColors = [
      const Color(0xFF7C4DFF), // Purple
      const Color(0xFF00BFA5), // Teal
      const Color(0xFFFFB300), // Amber
      const Color(0xFFFF6B6B), // Coral
      const Color(0xFF42A5F5), // Blue
      const Color(0xFF66BB6A), // Green
      const Color(0xFFEC407A), // Pink
      const Color(0xFF26C6DA), // Cyan
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
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
                    child: Icon(Icons.pie_chart_outline_rounded, size: 50, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 20),
                  Text('No data yet', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Add subscriptions to see analytics',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          // Calculate category distribution
          Map<String, double> categoryCosts = {};
          for (var sub in subs) {
            if (!sub.isActive) continue;
            double cost = sub.billingCycle == 'yearly' ? sub.cost / 12 : sub.cost;
            categoryCosts[sub.category] = (categoryCosts[sub.category] ?? 0) + cost;
          }

          final totalCost = categoryCosts.values.fold(0.0, (a, b) => a + b);

          final List<PieChartSectionData> pieSections = [];
          int colorIndex = 0;

          categoryCosts.forEach((category, cost) {
            final percent = totalCost > 0 ? (cost / totalCost * 100) : 0.0;
            pieSections.add(PieChartSectionData(
              color: chartColors[colorIndex % chartColors.length],
              value: cost,
              title: '${percent.toStringAsFixed(0)}%',
              radius: 65,
              titleStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              badgePositionPercentageOffset: 1.1,
            ));
            colorIndex++;
          });

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ─── Section Header ────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.donut_large_rounded, size: 18, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Text('Category Breakdown', style: textTheme.titleLarge),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                'Monthly spending by category',
                style: textTheme.bodyMedium,
              ),

              const SizedBox(height: 28),

              // ─── Chart Container ───────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colorScheme.outline.withAlpha(50)),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 240,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 50,
                          sections: pieSections,
                          centerSpaceColor: colorScheme.surface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Total Spend Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, size: 18, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Total: ₹${totalCost.toStringAsFixed(0)}/mo',
                            style: textTheme.titleSmall?.copyWith(color: colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Legend ────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outline.withAlpha(50)),
                ),
                child: Column(
                  children: [
                    ...categoryCosts.entries.toList().asMap().entries.map((entry) {
                      final idx = entry.key;
                      final e = entry.value;
                      final color = chartColors[idx % chartColors.length];
                      final percent = totalCost > 0 ? (e.value / totalCost * 100) : 0.0;

                      return Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            title: Text(e.key, style: textTheme.titleSmall),
                            subtitle: Text('${percent.toStringAsFixed(1)}% of total', style: textTheme.bodySmall),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withAlpha(15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '₹${e.value.toStringAsFixed(0)}/mo',
                                style: textTheme.titleSmall?.copyWith(
                                  color: color,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          if (idx < categoryCosts.length - 1)
                            Divider(
                              height: 1,
                              indent: 20,
                              endIndent: 20,
                              color: colorScheme.outline.withAlpha(40),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
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
              Text('Error: $e', style: textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
