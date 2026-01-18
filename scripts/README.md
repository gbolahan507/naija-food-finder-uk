# Scripts Directory

This directory contains utility scripts for the Naija Food Finder UK app.

## Import Restaurants Script

### Purpose
Imports real Nigerian restaurant data into Firestore database.

### Data Included
- **15 restaurants** from research
- **London:** 9 restaurants (Michelin-starred, chains, unique concepts)
- **Manchester:** 3 restaurants
- **Birmingham:** 1 restaurant

### How to Run

**Option 1: Direct Dart Execution (Recommended)**
```bash
dart run scripts/import_restaurants.dart
```

**Option 2: Via Flutter**
```bash
flutter run scripts/import_restaurants.dart -d macos
```

### What It Does
1. Initializes Firebase
2. Connects to Firestore
3. Adds restaurants to `restaurants` collection
4. Shows progress for each restaurant
5. Displays summary at the end

### Expected Output
```
🔥 Initializing Firebase...
✅ Firebase initialized successfully

📦 Preparing to import 15 restaurants...

✅ [1/15] Akoko
✅ [2/15] Chishuru
✅ [3/15] 805 Restaurant - Old Kent Road
...
✅ [15/15] Afrilicken Junction

==================================================
📊 Import Summary:
   ✅ Successful: 15
   ❌ Failed: 0
   📍 Total: 15
==================================================

✨ Import completed!
📱 Open your app to see the real restaurants
🔍 Check Firebase Console: https://console.firebase.google.com/
```

### After Running

1. **Check Firebase Console:**
   - Go to https://console.firebase.google.com/
   - Select your project
   - Navigate to Firestore Database
   - You should see `restaurants` collection with 15 documents

2. **Test in App:**
   - Run your Flutter app
   - Restaurants should now appear in the list
   - Map should show real restaurant locations
   - Search should work with real data

3. **Verify Data:**
   - Check that each restaurant has:
     - Name, address, city
     - Phone number (where available)
     - Coordinates (latitude/longitude)
     - Ratings and review counts
     - Cuisine types
     - Delivery/takeaway options

### Troubleshooting

**Error: "Bad state: Cannot get a field on a DocumentSnapshotPlatform which does not exist"**
- Solution: The restaurants collection doesn't exist yet. The script will create it.

**Error: "Permission denied"**
- Solution: Check Firestore security rules. For testing, you can temporarily allow writes:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // TEMPORARY - for import only
    }
  }
}
```

**Error: "Firebase not initialized"**
- Solution: Make sure `firebase_options.dart` exists and is configured correctly

### Next Steps After Import

1. **Add More Restaurants:**
   - Edit `import_restaurants.dart`
   - Add more restaurant objects to the list
   - Run script again

2. **Add Restaurant Photos:**
   - Upload images to Firebase Storage
   - Update `imageUrl` fields with real URLs

3. **Update Opening Hours:**
   - Add `openingHours` array to each restaurant
   - Use format from `restaurant_model.dart`

4. **Seed Reviews:**
   - Create similar script for reviews
   - Import sample reviews for each restaurant

### Re-running the Script

The script uses `.set()` which will **overwrite** existing documents with the same ID.

- **Safe to re-run** if you want to update data
- **Will replace** existing restaurants if IDs match
- **Won't delete** restaurants not in the script

### Data Source

All restaurant data sourced from:
- Official restaurant websites
- Google Maps
- TripAdvisor
- TimeOut London
- The Infatuation
- Michelin Guide

See `RESTAURANT_RESEARCH.md` for complete research notes.
