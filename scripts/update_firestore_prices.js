// Run this script with: node scripts/update_firestore_prices.js
// Make sure to install: npm install firebase-admin

const admin = require('firebase-admin');

// Initialize Firebase Admin with your service account key
// You'll need to download the service account key from Firebase Console
// and save it as service-account-key.json
const serviceAccount = require('../service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Price range assignment based on rating
function assignPriceRange(rating) {
  const rand = Math.random();

  if (rating >= 4.5) {
    // High rated: 40% luxury, 40% expensive, 20% moderate
    if (rand < 0.4) return '££££';
    if (rand < 0.8) return '£££';
    return '££';
  } else if (rating >= 4.0) {
    // Good rated: 50% expensive, 30% moderate, 20% luxury
    if (rand < 0.5) return '£££';
    if (rand < 0.8) return '££';
    return '££££';
  } else if (rating >= 3.5) {
    // Average rated: 60% moderate, 30% budget, 10% expensive
    if (rand < 0.6) return '££';
    if (rand < 0.9) return '£';
    return '£££';
  } else {
    // Lower rated: 70% budget, 30% moderate
    return rand < 0.7 ? '£' : '££';
  }
}

async function updateRestaurants() {
  try {
    console.log('📊 Fetching all restaurants...');

    const snapshot = await db.collection('restaurants').get();
    console.log(`Found ${snapshot.size} restaurants`);
    console.log('🔄 Adding price ranges...\n');

    let updated = 0;
    const batch = db.batch();

    for (const doc of snapshot.docs) {
      const data = doc.data();

      // Skip if already has price range
      if (data.priceRange) {
        console.log(`⏭️  ${data.name} - already has price range: ${data.priceRange}`);
        continue;
      }

      const rating = data.rating || 3.5;
      const priceRange = assignPriceRange(rating);

      // Add to batch
      batch.update(doc.ref, { priceRange });

      console.log(`✅ ${data.name} - Adding price range: ${priceRange} (rating: ${rating.toFixed(1)})`);
      updated++;
    }

    // Commit the batch
    await batch.commit();

    console.log(`\n✨ Successfully updated ${updated} restaurants with price ranges!`);
    console.log('🎉 Done!');

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    process.exit(0);
  }
}

updateRestaurants();
