import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../features/restaurants/data/models/restaurant_filter.dart';

/// Service to initialize price ranges for restaurants that don't have them
class PriceRangeInitializer {
  final FirebaseFirestore _firestore;
  final Random _random = Random();

  PriceRangeInitializer({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Initialize price ranges for all restaurants missing this field
  Future<void> initializePriceRanges() async {
    try {
      debugPrint('🔄 Checking restaurants for missing price ranges...');

      final snapshot = await _firestore.collection('restaurants').get();
      final batch = _firestore.batch();
      int updatedCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();

        // Skip if already has price range
        if (data['priceRange'] != null) {
          continue;
        }

        // Assign price range based on rating
        final rating = (data['rating'] as num?)?.toDouble() ?? 3.5;
        final priceRange = _assignPriceRange(rating);

        // Add to batch update
        batch.update(doc.reference, {'priceRange': priceRange.symbol});
        updatedCount++;

        debugPrint(
            '  ✅ ${data['name']} - Adding price range: ${priceRange.symbol} (rating: ${rating.toStringAsFixed(1)})');
      }

      if (updatedCount > 0) {
        // Commit all updates at once
        await batch.commit();
        debugPrint(
            '✨ Successfully added price ranges to $updatedCount restaurants!');
      } else {
        debugPrint('✓ All restaurants already have price ranges');
      }
    } catch (e) {
      debugPrint('❌ Error initializing price ranges: $e');
      // Don't throw - we don't want to prevent app from starting
    }
  }

  /// Assign price range based on rating with some randomness for variety
  PriceRange _assignPriceRange(double rating) {
    final rand = _random.nextDouble();

    if (rating >= 4.5) {
      // High rated: 40% luxury, 40% expensive, 20% moderate
      if (rand < 0.4) {
        return PriceRange.luxury;
      } else if (rand < 0.8) {
        return PriceRange.expensive;
      } else {
        return PriceRange.moderate;
      }
    } else if (rating >= 4.0) {
      // Good rated: 50% expensive, 30% moderate, 20% luxury
      if (rand < 0.5) {
        return PriceRange.expensive;
      } else if (rand < 0.8) {
        return PriceRange.moderate;
      } else {
        return PriceRange.luxury;
      }
    } else if (rating >= 3.5) {
      // Average rated: 60% moderate, 30% budget, 10% expensive
      if (rand < 0.6) {
        return PriceRange.moderate;
      } else if (rand < 0.9) {
        return PriceRange.budget;
      } else {
        return PriceRange.expensive;
      }
    } else {
      // Lower rated: 70% budget, 30% moderate
      return rand < 0.7 ? PriceRange.budget : PriceRange.moderate;
    }
  }
}
