import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naija_food_finder_uk/core/router/app_router.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=== FIREBASE INITIALIZATION ===');
  print('Platform: ${DefaultFirebaseOptions.currentPlatform}');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully!');
    print('Firebase App Name: ${Firebase.app().name}');
    print('Firebase Project ID: ${Firebase.app().options.projectId}');
    print('Firebase Storage Bucket: ${Firebase.app().options.storageBucket}');
  } catch (e, stackTrace) {
    print('Firebase initialization FAILED!');
    print('Error: $e');
    print('Stack trace: $stackTrace');
  }
  print('===============================');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize theme controller
    ref.read(themeControllerProvider);

    // Watch theme mode
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Naija Food Finder UK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
