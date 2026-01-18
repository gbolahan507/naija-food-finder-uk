import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Cleanup old mock data from Firestore
/// This will delete ALL documents in the restaurants collection
/// Run this ONCE before importing the new 50 restaurants
Future<void> cleanupOldRestaurants() async {
  final firestore = FirebaseFirestore.instance;

  debugPrint('🧹 Starting Firestore cleanup...');
  debugPrint('🗑️  Deleting all documents in "restaurants" collection...');

  try {
    // Get all documents in the restaurants collection
    final QuerySnapshot snapshot =
        await firestore.collection('restaurants').get();

    debugPrint('📊 Found ${snapshot.docs.length} documents to delete');

    if (snapshot.docs.isEmpty) {
      debugPrint('✅ No documents to delete. Collection is already empty!');
      return;
    }

    // Delete each document
    int count = 0;
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
      count++;
      debugPrint('🗑️  [$count/${snapshot.docs.length}] Deleted: ${doc.id}');
    }

    debugPrint('');
    debugPrint('🎉 Cleanup complete!');
    debugPrint('   ✅ Deleted $count documents');
    debugPrint('   📝 You can now run the import function to add 50 new restaurants');
  } catch (e, stackTrace) {
    debugPrint('❌ Error during cleanup: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}
