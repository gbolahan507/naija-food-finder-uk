import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naija_food_finder_uk/core/router/app_router.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/services/price_range_initializer.dart';
// import 'core/utils/import_data.dart';
// import 'core/utils/cleanup_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('=== FIREBASE INITIALIZATION ===');
  debugPrint('Platform: ${DefaultFirebaseOptions.currentPlatform}');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully!');
    debugPrint('Firebase App Name: ${Firebase.app().name}');
    debugPrint('Firebase Project ID: ${Firebase.app().options.projectId}');
    debugPrint(
        'Firebase Storage Bucket: ${Firebase.app().options.storageBucket}');

    // 🔥 CLEANUP & IMPORT - COMPLETED! ✅
    // Step 1: Delete old mock data
    // await cleanupOldRestaurants();
    // Step 2: Import 50 new restaurants
    // await addAll50Restaurants();

    // Initialize price ranges for restaurants that don't have them
    final priceRangeInitializer = PriceRangeInitializer();
    await priceRangeInitializer.initializePriceRanges();
  } catch (e, stackTrace) {
    debugPrint('Firebase initialization FAILED!');
    debugPrint('Error: $e');
    debugPrint('Stack trace: $stackTrace');
  }
  debugPrint('===============================');

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
