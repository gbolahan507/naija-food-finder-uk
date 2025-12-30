import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naija_food_finder_uk/features/restaurants/data/providers/restaurants_provider.dart';
import 'package:naija_food_finder_uk/features/restaurants/presentation/screens/favorites_screen.dart';
import '../../features/auth/data/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/restaurants/presentation/screens/restaurants_list_screen.dart';
import '../../features/restaurants/presentation/screens/map_screen.dart';
import '../constants/app_colors.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Placeholder screens for other tabs
  final List<Widget> _screens = [
    const RestaurantsListScreen(),
    const SearchTabScreen(),
    const MapScreen(),
    const ProfileTabScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.mediumGrey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Placeholder screens
class SearchTabScreen extends StatelessWidget {
  const SearchTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: AppColors.mediumGrey,
            ),
            SizedBox(height: 16),
            Text(
              'Advanced Search',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coming soon!',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapTabScreen extends StatelessWidget {
  const MapTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 80,
              color: AppColors.mediumGrey,
            ),
            SizedBox(height: 16),
            Text(
              'Map View',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coming soon!',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTabScreen extends ConsumerWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final favoritesAsync = ref.watch(favoritesProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // Not signed in
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryGreen,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Guest User',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to save your preferences',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Favorites Button
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoritesScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.favorite),
                      label: favoritesAsync.when(
                        data: (favorites) =>
                            Text('Favorites (${favorites.length})'),
                        loading: () => const Text('Favorites'),
                        error: (_, __) => const Text('Favorites'),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: 200,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Sign In'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        side: const BorderSide(
                          color: AppColors.primaryGreen,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // User is signed in
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  final authController = ref.read(authControllerProvider);
                  await authController.signOut();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Signed out successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryGreen,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.displayName ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 32),

                // Favorites Button
                SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoritesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.favorite),
                    label: favoritesAsync.when(
                      data: (favorites) =>
                          Text('Favorites (${favorites.length})'),
                      loading: () => const Text('Favorites'),
                      error: (_, __) => const Text('Favorites'),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
