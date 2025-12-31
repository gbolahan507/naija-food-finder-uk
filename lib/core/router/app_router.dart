import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../navigation/main_navigation.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/data/providers/auth_provider.dart';
import '../../features/restaurants/presentation/screens/restaurant_details_screen.dart';
import '../../features/restaurants/data/models/restaurant_model.dart';

// Auth guard widget that checks authentication state
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        // Debug: Print auth state
        print('=== AUTH STATE ===');
        print('User signed in: ${user != null}');
        if (user != null) {
          print('User ID: ${user.uid}');
          print('Email: ${user.email}');
          print('Display Name: ${user.displayName}');
        }
        print('==================');

        // Allow browsing without auth
        // Users can view restaurants, but need to sign in to review/favorite
        return const MainNavigation();
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) {
        print('=== AUTH ERROR ===');
        print('Error: $error');
        print('==================');
        return const MainNavigation();
      },
    );
  }
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/restaurant/:id',
        name: 'restaurant-details',
        builder: (context, state) {
          final restaurant = state.extra as Restaurant;
          return RestaurantDetailsScreen(restaurant: restaurant);
        },
      ),
    ],
  );
}
