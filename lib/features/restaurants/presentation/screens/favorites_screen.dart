import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/restaurants_provider.dart';
import '../widgets/restaurant_card.dart';
import 'restaurant_details_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';

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
            return EmptyState.noFavorites(
              onExplore: () {
                // Switch to restaurants tab
                DefaultTabController.of(context).animateTo(0);
              },
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
                        final restaurant = favoriteRestaurants[index];
                        return RestaurantCard(
                          restaurant: restaurant,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestaurantDetailsScreen(
                                  restaurant: restaurant,
                                ),
                              ),
                            );
                          },
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
            error: (error, stack) => ErrorState.custom(
              error: error.toString(),
              onRetry: () {
                ref.invalidate(restaurantsProvider);
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
        ),
        error: (error, stack) => ErrorState.custom(
          error: error.toString(),
          onRetry: () {
            ref.invalidate(favoritesProvider);
          },
        ),
      ),
    );
  }
}
