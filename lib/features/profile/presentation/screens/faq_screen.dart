import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const List<Map<String, String>> _faqItems = [
    {
      'q': 'How does the Efficiency Score work?',
      'a':
          'The Efficiency Score (0–100%) measures how well you utilize a subscription. '
              'It uses Android\'s UsageStats API to track actual app usage over the last 30 days. '
              'If you use an app for more than 5 hours per month, you get 100%. '
              'For subscriptions without a linked app (e.g., Gym), it falls back to your manual "Mark Used" check-ins.',
    },
    {
      'q': 'How does automatic app tracking work?',
      'a':
          'SubManager uses Android\'s UsageStatsManager to monitor how long you spend in each subscribed app. '
              'You need to grant "Usage Access" permission from your device Settings. '
              'Once enabled, the app automatically correlates your real usage with your paid subscriptions—no manual input required.',
    },
    {
      'q': 'What data do you collect?',
      'a':
          'Your subscription data (name, cost, billing dates) is stored securely in Firebase Firestore, scoped exclusively to your account. '
              'App usage data is read locally from your device and never uploaded to external servers. '
              'We use Firebase Authentication for secure sign-in.',
    },
    {
      'q': 'Can I add custom subscriptions?',
      'a':
          'Yes! While we provide preset platforms (Netflix, Spotify, etc.), you can also manually enter any subscription name, cost, category, and billing cycle. '
              'This is useful for services like Gym memberships, Internet bills, or niche SaaS tools.',
    },
    {
      'q': 'How are billing alerts triggered?',
      'a':
          'When billing alerts are enabled in Settings, the app will check your upcoming renewal dates. '
              'You will be notified before a payment is due so you can choose to renew or cancel in time.',
    },
    {
      'q': 'What happens if I delete my account?',
      'a':
          'Deleting your account will permanently remove all your subscription data from our servers '
              'and delete your Firebase authentication record. This action is irreversible—please make sure you want to proceed before confirming.',
    },
    {
      'q': 'How do I change my password?',
      'a':
          'Go to Settings → Account → Change Password. You will need to enter your current password for verification, '
              'then type and confirm your new password. The change applies immediately via Firebase Auth.',
    },
    {
      'q': 'Is my data synced across devices?',
      'a':
          'Yes! Since your data is stored in Firebase Firestore, it automatically syncs across all devices '
              'where you sign in with the same account. Just log in on a new device and your subscriptions will appear.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withAlpha(30),
                  colorScheme.secondary.withAlpha(20),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outline.withAlpha(40),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.quiz_outlined,
                      color: colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Frequently Asked Questions',
                          style: textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        'Find answers to common questions about SubManager.',
                        style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withAlpha(150)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // FAQ Items
          ..._faqItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withAlpha(40),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      item['q']!,
                      style: textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    children: [
                      Text(
                        item['a']!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withAlpha(180),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),

          // Still have questions?
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withAlpha(40),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.help_outline,
                    color: colorScheme.primary.withAlpha(150), size: 32),
                const SizedBox(height: 12),
                Text('Still have questions?',
                    style: textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  'Reach out to our support team and we\'ll get back to you.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withAlpha(150)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
