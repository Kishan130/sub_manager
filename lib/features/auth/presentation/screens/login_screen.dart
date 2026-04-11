import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/firebase_auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      if (!_isLogin) {
        if (_passwordController.text != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
          setState(() => _isLoading = false);
          return;
        }
      }

      final authService = ref.read(authServiceProvider);
      if (_isLogin) {
        await authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await authService.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Logo & Branding ────────────────────────────────────
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C4DFF), Color(0xFF5E35B1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5E35B1).withAlpha(60),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 28),
                Text(
                  _isLogin ? 'Welcome Back' : 'Create Account',
                  style: textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? 'Sign in to manage your subscriptions'
                      : 'Start tracking your subscriptions today',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // ─── Login / Sign Up Toggle ─────────────────────────────
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('Login'),
                      icon: Icon(Icons.login_rounded),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('Sign Up'),
                      icon: Icon(Icons.person_add_rounded),
                    ),
                  ],
                  selected: {_isLogin},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _isLogin = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 28),

                // ─── Email Field ────────────────────────────────────────
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'your@email.com',
                    prefixIcon: Icon(Icons.email_outlined, color: colorScheme.primary.withAlpha(180)),
                  ),
                ),
                const SizedBox(height: 16),

                // ─── Password Field ─────────────────────────────────────
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline_rounded, color: colorScheme.primary.withAlpha(180)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: colorScheme.onSurface.withAlpha(120),
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),

                // ─── Confirm Password (Sign Up Only) ───────────────────
                if (!_isLogin) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_clock_rounded, color: colorScheme.primary.withAlpha(180)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: colorScheme.onSurface.withAlpha(120),
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // ─── Submit Button ────────────────────────────────────
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white.withAlpha(200),
                            ),
                          )
                        : Text(
                            _isLogin ? 'Login' : 'Create Account',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Bottom Brand ───────────────────────────────────────
                Center(
                  child: Text(
                    'SubManager',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withAlpha(60),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
