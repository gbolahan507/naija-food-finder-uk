import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../lib/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final random = Random();

  // Price range symbols
  final priceRanges = ['£', '££', '£££', '££££'];

  print('📊 Fetching all restaurants...');

  final snapshot = await firestore.collection('restaurants').get();
  final restaurants = snapshot.docs;

  print('Found ${restaurants.length} restaurants');
  print('🔄 Adding price ranges...\n');

  int updated = 0;

  for (final doc in restaurants) {
    final data = doc.data();

    // Skip if already has price range
    if (data['priceRange'] != null) {
      print('⏭️  ${data['name']} - already has price range: ${data['priceRange']}');
      continue;
    }

    // Assign price range based on rating (higher rated = potentially more expensive)
    // But with some randomness for variety
    final rating = (data['rating'] as num?)?.toDouble() ?? 3.5;
    String priceRange;

    if (rating >= 4.5) {
      // High rated: 40% luxury, 40% expensive, 20% moderate
      final rand = random.nextDouble();
      if (rand < 0.4) {
        priceRange = '££££';
      } else if (rand < 0.8) {
        priceRange = '£££';
      } else {
        priceRange = '££';
      }
    } else if (rating >= 4.0) {
      // Good rated: 50% expensive, 30% moderate, 20% luxury
      final rand = random.nextDouble();
      if (rand < 0.5) {
        priceRange = '£££';
      } else if (rand < 0.8) {
        priceRange = '££';
      } else {
        priceRange = '££££';
      }
    } else if (rating >= 3.5) {
      // Average rated: 60% moderate, 30% budget, 10% expensive
      final rand = random.nextDouble();
      if (rand < 0.6) {
        priceRange = '££';
      } else if (rand < 0.9) {
        priceRange = '£';
      } else {
        priceRange = '£££';
      }
    } else {
      // Lower rated: 70% budget, 30% moderate
      final rand = random.nextDouble();
      if (rand < 0.7) {
        priceRange = '£';
      } else {
        priceRange = '££';
      }
    }

    // Update the restaurant
    await doc.reference.update({'priceRange': priceRange});

    print('✅ ${data['name']} - Added price range: $priceRange (rating: ${rating.toStringAsFixed(1)})');
    updated++;
  }

  print('\n✨ Successfully updated $updated restaurants with price ranges!');
  print('🎉 Done!');
}
