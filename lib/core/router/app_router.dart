import 'package:go_router/go_router.dart';
import '../../features/restaurants/presentation/screens/restaurants_list_screen.dart';
import '../../features/restaurants/presentation/screens/restaurant_details_screen.dart';
import '../../features/restaurants/data/models/restaurant_model.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const RestaurantsListScreen(),
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