import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'core/providers/theme_provider.dart';
import 'features/splash/splash_screen.dart';
import 'core/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences for theme persistence
  final prefs = await SharedPreferences.getInstance();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization failed. Ensure google-services.json is added: $e");
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const SubManagerApp(),
    ),
  );
}

class SubManagerApp extends ConsumerStatefulWidget {
  const SubManagerApp({super.key});

  @override
  ConsumerState<SubManagerApp> createState() => _SubManagerAppState();
}

class _SubManagerAppState extends ConsumerState<SubManagerApp> {
  @override
  void initState() {
    super.initState();
    // Request notification permissions on app launch
    Future.microtask(() {
      ref.read(notificationServiceProvider).requestPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch this to keep the background notification scheduler alive and synced
    ref.watch(notificationSchedulerProvider);

    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'SubManager',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
