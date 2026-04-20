import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../services/firebase_auth_service.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../subscriptions/presentation/providers/subscription_provider.dart';
import 'faq_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // ─── Change Password Dialog ───────────────────────────────────────────────
  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentPwdController = TextEditingController();
    final newPwdController = TextEditingController();
    final confirmPwdController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFA5).withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lock_outline,
                        color: Color(0xFF00BFA5), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Change Password')),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: currentPwdController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Current Password',
                          prefixIcon: Icon(Icons.lock_clock_outlined),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Enter your current password'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: newPwdController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Enter a new password';
                          }
                          if (val.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmPwdController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm New Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (val) {
                          if (val != newPwdController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isLoading ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isLoading = true);
                          try {
                            final authService =
                                ref.read(authServiceProvider);
                            await authService.changePassword(
                              currentPwdController.text,
                              newPwdController.text,
                            );
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.white, size: 20),
                                      SizedBox(width: 8),
                                      Text('Password changed successfully!'),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF00C853),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isLoading = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Error: ${_parseFirebaseError(e.toString())}'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Update Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─── Delete Account Dialog ────────────────────────────────────────────────
  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B).withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFFF6B6B), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Delete Account')),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B).withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFF6B6B).withAlpha(60),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Color(0xFFFF6B6B), size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This action is irreversible. All your subscriptions and data will be permanently deleted.',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFFFF6B6B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Enter your password to confirm:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Enter your password'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isLoading ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isLoading = true);
                          try {
                            // 1. Delete all user subscriptions from Firestore
                            final authService =
                                ref.read(authServiceProvider);
                            final firestoreService =
                                ref.read(firestoreServiceProvider);
                            final userId = authService.currentUser?.uid;
                            if (userId != null) {
                              await firestoreService
                                  .deleteAllUserSubscriptions(userId);
                            }

                            // 2. Delete the Firebase Auth account
                            await authService
                                .deleteAccount(passwordController.text);

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            // Auth state listener will auto-redirect to login
                          } catch (e) {
                            setDialogState(() => isLoading = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Error: ${_parseFirebaseError(e.toString())}'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Delete Permanently'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─── Contact Support via Email ────────────────────────────────────────────
  Future<void> _launchContactSupport(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@submanager.app',
      queryParameters: {
        'subject': 'SubManager Support Request',
        'body':
            'Hi SubManager Team,\n\nI need help with:\n\n[Describe your issue here]\n\nApp Version: 1.0.0\n\nThank you!',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          _showContactInfoDialog(context);
        }
      }
    } catch (_) {
      if (context.mounted) {
        _showContactInfoDialog(context);
      }
    }
  }

  void _showContactInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF66BB6A).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.headset_mic_outlined,
                    color: Color(0xFF66BB6A), size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('Contact Support')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reach us via email:'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.email_outlined,
                        color: Theme.of(ctx).colorScheme.primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: SelectableText(
                        'support@submanager.app',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We typically respond within 24 hours.',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(ctx).colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Parses raw Firebase error strings into user-friendly messages.
  static String _parseFirebaseError(String error) {
    if (error.contains('wrong-password') ||
        error.contains('invalid-credential')) {
      return 'Incorrect password. Please try again.';
    }
    if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }
    if (error.contains('requires-recent-login')) {
      return 'Session expired. Please log out and back in, then try again.';
    }
    if (error.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    }
    if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    }
    // Fallback — strip the Firebase exception wrapper
    final cleaned = error
        .replaceAll(RegExp(r'\[firebase_auth/[^\]]+\]'), '')
        .replaceAll('Exception: ', '')
        .trim();
    return cleaned.isNotEmpty ? cleaned : 'An unexpected error occurred.';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final billingAlertsEnabled = ref.watch(billingAlertsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // ─── User Profile Header ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                    : [const Color(0xFFEDE7F6), const Color(0xFFE8EAF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.outline.withAlpha(50),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C4DFF), Color(0xFF5E35B1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5E35B1).withAlpha(60),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      (user?.email?.isNotEmpty == true)
                          ? user!.email![0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.email ?? 'Unknown User',
                        style: textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853).withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '● Active Account',
                          style: TextStyle(
                            color: Color(0xFF00C853),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ─── Appearance Section ──────────────────────────────────────────
          _SectionHeader(title: 'Appearance', icon: Icons.palette_outlined),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                iconColor: const Color(0xFF7C4DFF),
                title: 'Dark Mode',
                subtitle: isDark ? 'On' : 'Off',
                trailing: Switch.adaptive(
                  value: isDark,
                  onChanged: (_) =>
                      ref.read(themeProvider.notifier).toggleTheme(),
                  activeTrackColor: colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ─── Account Section ────────────────────────────────────────────
          _SectionHeader(title: 'Account', icon: Icons.person_outline),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.lock_outline,
                iconColor: const Color(0xFF00BFA5),
                title: 'Change Password',
                subtitle: 'Update your password',
                trailing: Icon(Icons.chevron_right,
                    color: colorScheme.onSurface.withAlpha(100)),
                onTap: () => _showChangePasswordDialog(context, ref),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.delete_outline,
                iconColor: const Color(0xFFFF6B6B),
                title: 'Delete Account',
                subtitle: 'Permanently remove your data',
                trailing: Icon(Icons.chevron_right,
                    color: colorScheme.onSurface.withAlpha(100)),
                onTap: () => _showDeleteAccountDialog(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ─── Notifications Section ──────────────────────────────────────
          _SectionHeader(
              title: 'Notifications', icon: Icons.notifications_outlined),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.payment_outlined,
                iconColor: const Color(0xFFFFB300),
                title: 'Billing Alerts',
                subtitle: billingAlertsEnabled
                    ? 'You will be notified before payments'
                    : 'Billing reminders are disabled',
                trailing: Switch.adaptive(
                  value: billingAlertsEnabled,
                  onChanged: (_) =>
                      ref.read(billingAlertsProvider.notifier).toggle(),
                  activeTrackColor: colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ─── Support Section ────────────────────────────────────────────
          _SectionHeader(title: 'Help & Support', icon: Icons.help_outline),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.quiz_outlined,
                iconColor: const Color(0xFF42A5F5),
                title: 'FAQ',
                subtitle: 'Frequently asked questions',
                trailing: Icon(Icons.chevron_right,
                    color: colorScheme.onSurface.withAlpha(100)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FaqScreen()),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.headset_mic_outlined,
                iconColor: const Color(0xFF66BB6A),
                title: 'Contact Support',
                subtitle: 'Get help from our team',
                trailing: Icon(Icons.chevron_right,
                    color: colorScheme.onSurface.withAlpha(100)),
                onTap: () => _launchContactSupport(context),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ─── Logout Button ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF6B6B),
                side:
                    const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => authService.signOut(),
            ),
          ),
          const SizedBox(height: 16),

          // ─── App Version ────────────────────────────────────────────────
          Center(
            child: Text(
              'SubManager v1.0.0',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withAlpha(80),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Developed By ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF1A1A2E).withAlpha(200),
                        const Color(0xFF16213E).withAlpha(200),
                      ]
                    : [
                        const Color(0xFFF3E5F5).withAlpha(180),
                        const Color(0xFFE8EAF6).withAlpha(180),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF7C4DFF).withAlpha(60),
              ),
            ),
            child: Column(
              children: [
                // Accent line
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C4DFF), Color(0xFF00BFA5)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C4DFF), Color(0xFF5E35B1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C4DFF).withAlpha(50),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.code_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Developed by',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withAlpha(120),
                    fontSize: 12,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kishan Vachhani',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF).withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'B.Tech Computer Engineering',
                    style: textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF7C4DFF),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(50),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
