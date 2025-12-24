/// Centralized string constants for the app
class AppStrings {
  // Private constructor to prevent instantiation
  AppStrings._();

  // App Info
  static const String appName = 'Naija Food Finder UK';
  static const String appNameShort = 'Naija Food Finder';
  static const String appTagline = 'Find Nigerian restaurants and African shops across the UK';

  // Bottom Navigation
  static const String navHome = 'Home';
  static const String navSearch = 'Search';
  static const String navMap = 'Map';
  static const String navProfile = 'Profile';

  // Home Screen
  static const String homeTitle = 'Restaurants';
  static const String homeSearchHint = 'Search restaurants...';
  static const String homeFilterAll = 'All';
  static const String homeFilterNigerian = 'Nigerian';
  static const String homeFilterGhanaian = 'Ghanaian';
  static const String homeFilterCaribbean = 'Caribbean';

  // Restaurant Card
  static const String restaurantDelivery = 'Delivery';
  static const String restaurantTakeaway = 'Takeaway';
  static const String restaurantOpenNow = 'Open Now';
  static const String restaurantClosed = 'Closed';
  static const String restaurantAway = 'away';
  static const String restaurantReviews = 'reviews';

  // Restaurant Details
  static const String detailsAbout = 'About';
  static const String detailsHours = 'Opening Hours';
  static const String detailsContact = 'Contact';
  static const String detailsReviews = 'Reviews';
  static const String detailsAddToFavorites = 'Add to Favorites';
  static const String detailsRemoveFromFavorites = 'Remove from Favorites';
  static const String detailsGetDirections = 'Get Directions';
  static const String detailsCallRestaurant = 'Call Restaurant';

  // Search Screen
  static const String searchTitle = 'Search';
  static const String searchFilters = 'Filters';
  static const String searchApplyFilters = 'Apply Filters';
  static const String searchClearFilters = 'Clear Filters';
  static const String searchDistance = 'Distance';
  static const String searchCuisineType = 'Cuisine Type';
  static const String searchFeatures = 'Features';
  static const String searchNoResults = 'No restaurants found';
  static const String searchTryDifferent = 'Try adjusting your filters';

  // Map Screen
  static const String mapTitle = 'Map';
  static const String mapListView = 'List View';
  static const String mapRecenter = 'Recenter';

  // Profile Screen
  static const String profileTitle = 'Profile';
  static const String profileFavorites = 'Favorites';
  static const String profileMyReviews = 'My Reviews';
  static const String profileSettings = 'Settings';
  static const String profileLogout = 'Log Out';
  static const String profileEditProfile = 'Edit Profile';

  // Auth Screens
  static const String authLogin = 'Log In';
  static const String authSignup = 'Sign Up';
  static const String authEmail = 'Email';
  static const String authPassword = 'Password';
  static const String authForgotPassword = 'Forgot Password?';
  static const String authDontHaveAccount = "Don't have an account?";
  static const String authAlreadyHaveAccount = 'Already have an account?';

  // Reviews
  static const String reviewsTitle = 'Reviews';
  static const String reviewsWriteReview = 'Write a Review';
  static const String reviewsYourRating = 'Your Rating';
  static const String reviewsYourReview = 'Your Review';
  static const String reviewsSubmit = 'Submit Review';

  // Common Actions
  static const String actionSave = 'Save';
  static const String actionCancel = 'Cancel';
  static const String actionDelete = 'Delete';
  static const String actionEdit = 'Edit';
  static const String actionShare = 'Share';
  static const String actionClose = 'Close';
  static const String actionOk = 'OK';

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'No internet connection. Please check your network.';
  static const String errorLocation = 'Unable to get your location. Please enable location services.';
  static const String errorAuth = 'Authentication failed. Please try again.';

  // Success Messages
  static const String successReviewSubmitted = 'Review submitted successfully!';
  static const String successAddedToFavorites = 'Added to favorites!';
  static const String successRemovedFromFavorites = 'Removed from favorites!';
}