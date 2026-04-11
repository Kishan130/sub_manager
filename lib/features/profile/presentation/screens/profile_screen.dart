import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/firebase_auth_service.dart';
import '../../../../core/providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
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
                  onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
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
                trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withAlpha(100)),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.delete_outline,
                iconColor: const Color(0xFFFF6B6B),
                title: 'Delete Account',
                subtitle: 'Permanently remove your data',
                trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withAlpha(100)),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ─── Notifications Section ──────────────────────────────────────
          _SectionHeader(title: 'Notifications', icon: Icons.notifications_outlined),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.payment_outlined,
                iconColor: const Color(0xFFFFB300),
                title: 'Billing Alerts',
                subtitle: 'Get notified before payments',
                trailing: Switch.adaptive(
                  value: true,
                  onChanged: (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
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
                trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withAlpha(100)),
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.headset_mic_outlined,
                iconColor: const Color(0xFF66BB6A),
                title: 'Contact Support',
                subtitle: 'Get help from our team',
                trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withAlpha(100)),
                onTap: () {},
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
                side: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
