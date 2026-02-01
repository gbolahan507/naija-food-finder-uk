/// Configuration for external APIs
class ApiConfig {
  // Google Places API key
  // In production, use environment variables or secure storage
  // For development, replace with your actual API key
  static const String googlePlacesApiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
    defaultValue: 'AIzaSyCdNGMDe9vquP3ZKkkFEtA1mzkGRTAaFuk',
  );

  // API request configurations
  static const int defaultSearchRadius = 50000; // 50km in meters
  static const String defaultRegion = 'uk';
  static const String defaultLanguage = 'en';

  // Cost optimization settings
  static const Duration cacheExpiry = Duration(minutes: 30);
  static const Duration syncThreshold = Duration(days: 7);
  static const int maxSyncsPerSession = 10;

  // Search keywords for Nigerian/African restaurants
  static const List<String> searchKeywords = [
    'nigerian restaurant',
    'african restaurant',
    'west african restaurant',
  ];

  // Relevance scoring keywords
  static const Map<String, int> relevanceKeywords = {
    'nigerian': 10,
    'naija': 10,
    'jollof': 8,
    'suya': 8,
    'african': 5,
    'west african': 7,
    'pounded yam': 8,
    'egusi': 8,
    'amala': 8,
    'fufu': 7,
  };

  // Minimum relevance score to include in results
  static const int minimumRelevanceScore = 5;
}
