import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/restaurants_provider.dart';
import '../widgets/restaurant_card.dart';
import '../../../../core/constants/app_colors.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);
    final restaurantsAsync = ref.watch(restaurantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: Colors.white),
            SizedBox(width: 8),
            Text('My Favorites'),
          ],
        ),
      ),
      body: favoritesAsync.when(
        data: (favoriteIds) {
          if (favoriteIds.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: AppColors.mediumGrey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on any restaurant\nto add it to your favorites!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.lightText,
                    ),
                  ),
                ],
              ),
            );
          }

          return restaurantsAsync.when(
            data: (allRestaurants) {
              final favoriteRestaurants = allRestaurants
                  .where((r) => favoriteIds.contains(r.id))
                  .toList();

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: AppColors.extraLightGrey,
                    child: Text(
                      '${favoriteRestaurants.length} ${favoriteRestaurants.length == 1 ? 'favorite' : 'favorites'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: favoriteRestaurants.length,
                      itemBuilder: (context, index) {
                        return RestaurantCard(
                          restaurant: favoriteRestaurants[index],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            ),
            error: (error, stack) => Center(
              child: Text('Error: $error'),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
