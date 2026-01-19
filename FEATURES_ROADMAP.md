# Naija Food Finder UK - Features Roadmap

This document outlines planned features and enhancements for the Naija Food Finder UK application.

---

## Status Legend
- ✅ **Completed** - Feature is fully implemented and tested
- 🚧 **In Progress** - Currently being developed
- 📋 **Planned** - Scheduled for development
- 💡 **Idea** - Under consideration

---

## Priority 1 - Core Features

### 1. Favorites Persistence ✅
**Status:** Completed
**Effort:** Medium (2-3 days)
**Description:** Save user's favorite restaurants to Firestore for persistence across sessions and devices.

**Implementation Details:**
- ✅ Created `favorites` subcollection in Firestore with user ID
- ✅ Migrated from in-memory StateProvider to Firestore
- ✅ Add/remove favorites with real-time sync
- ✅ Load favorites on app start
- ✅ Sync across multiple devices

**Files Modified:**
- `lib/features/restaurants/data/repositories/favorites_repository.dart`
- `lib/features/restaurants/data/providers/restaurants_provider.dart`

**Benefits:**
- ✅ Users don't lose favorites when closing app
- ✅ Cross-device synchronization
- ✅ Better user retention

---

### 2. Review Pagination 📋
**Status:** Planned
**Effort:** Small (1-2 days)
**Description:** Load reviews in batches to improve performance for restaurants with many reviews.

**Implementation Details:**
- Implement Firestore pagination with `limit()` and `startAfter()`
- Load 10-20 reviews initially
- Add "Load More" button at bottom of review list
- Show loading skeleton while fetching more
- Track pagination state in provider

**Files to Modify:**
- `lib/features/restaurants/data/repositories/reviews_repository.dart`
- `lib/features/restaurants/presentation/screens/restaurant_details_screen.dart`

**Benefits:**
- Faster initial load times
- Better performance for popular restaurants
- Reduced data usage

---

### 3. Enhanced Filter Modal 🚧
**Status:** Partially Completed
**Effort:** Medium (2-3 days)
**Description:** Add more filtering options to help users find exactly what they want.

**Completed Filters:**
- ✅ **Price Range:** £, ££, £££
- ✅ **Cuisine Type Selection:** Select cuisine type

**Remaining Filters:**
- **Distance Radius Slider:** 0.5mi to 10mi range
- **Dietary Options:** Vegetarian, Vegan, Halal, Gluten-Free
- **Features:** Delivery, Takeaway, Dine-in, Outdoor Seating
- **Rating Minimum:** 3.0+, 4.0+, 4.5+

**Implementation Details:**
- Add price field to Restaurant model
- Create multi-select cuisine widget
- Add distance slider with live preview
- Save filter preferences to SharedPreferences
- Show active filter count badge

**Files to Create:**
- `lib/features/restaurants/presentation/widgets/advanced_filters_widget.dart`

**Files to Modify:**
- `lib/features/restaurants/data/models/restaurant_model.dart`
- `lib/features/restaurants/data/providers/filter_provider.dart`
- `lib/features/restaurants/presentation/screens/restaurants_list_screen.dart`

**Benefits:**
- More precise search results
- Better user experience
- Reduced scrolling time

---

## Priority 2 - User Experience

### 4. Push Notifications 📋
**Status:** Planned
**Effort:** Large (4-5 days)
**Description:** Send notifications to users about new restaurants, offers, and updates.

**Notification Types:**
- New Nigerian restaurant opened nearby
- Favorite restaurant posted special offer
- Someone replied to your review
- Weekly top-rated restaurants digest

**Implementation Details:**
- Add `firebase_messaging` package
- Implement FCM token management
- Create Cloud Functions for notifications
- Add notification preferences screen
- Handle notification taps (deep linking)

**Files to Create:**
- `lib/core/services/notification_service.dart`
- `lib/features/settings/presentation/screens/notification_settings_screen.dart`
- `functions/src/notifications.ts` (Cloud Functions)

**Benefits:**
- Increase user engagement
- Drive app opens
- Timely updates

---

### 5. Search Autocomplete 📋
**Status:** Planned
**Effort:** Medium (2-3 days)
**Description:** Show search suggestions as users type.

**Suggestion Types:**
- Recent searches (stored locally)
- Popular restaurants (from Firestore)
- Cuisine types
- City/area names

**Implementation Details:**
- Save recent searches to SharedPreferences
- Create search suggestions widget
- Implement debounced search
- Add "Clear history" option
- Track popular searches in Firestore

**Files to Create:**
- `lib/features/restaurants/presentation/widgets/search_suggestions_widget.dart`
- `lib/core/services/search_history_service.dart`

**Files to Modify:**
- `lib/features/restaurants/presentation/screens/restaurants_list_screen.dart`

**Benefits:**
- Faster search
- Better discoverability
- Improved UX

---

### 6. Offline Mode 📋
**Status:** Planned
**Effort:** Large (5-7 days)
**Description:** Cache restaurant data for offline viewing.

**Offline Features:**
- View recently opened restaurants
- Read cached reviews
- View saved favorites
- Queue writes (favorites, reviews) for sync

**Implementation Details:**
- Enable Firestore persistence
- Implement local database with `sqflite`
- Cache images with `cached_network_image`
- Show offline indicator
- Auto-sync when online

**Files to Create:**
- `lib/core/services/offline_service.dart`
- `lib/core/database/local_database.dart`

**Packages to Add:**
- `sqflite`
- `connectivity_plus`

**Benefits:**
- Works without internet
- Faster app experience
- Better user retention

---

## Priority 3 - Social Features

### 7. User Profiles 📋
**Status:** Planned
**Effort:** Large (4-5 days)
**Description:** Let users create and customize their profiles.

**Profile Features:**
- Profile picture upload (Firebase Storage)
- Display name and bio
- View user's reviews
- Review count and average rating given
- List of favorite restaurants
- Join date and activity stats

**Implementation Details:**
- Create `users` collection in Firestore
- Implement image upload to Firebase Storage
- Create profile screen with tabs (Reviews, Favorites, About)
- Add edit profile screen
- Show user profile when clicking on review author

**Files to Create:**
- `lib/features/profile/data/models/user_profile_model.dart`
- `lib/features/profile/data/repositories/profile_repository.dart`
- `lib/features/profile/presentation/screens/profile_screen.dart`
- `lib/features/profile/presentation/screens/edit_profile_screen.dart`

**Benefits:**
- Social proof
- User engagement
- Community building

---

### 8. Review Reactions 📋
**Status:** Planned
**Effort:** Medium (2-3 days)
**Description:** Allow users to react to reviews (helpful, not helpful).

**Features:**
- "Helpful" button on reviews
- Show helpful count
- Sort reviews by most helpful
- Report inappropriate reviews
- Owner response to reviews

**Implementation Details:**
- Add `reactions` subcollection to reviews
- Implement helpful counter with transaction
- Add sorting options dropdown
- Create review moderation system
- Add report modal with reasons

**Files to Modify:**
- `lib/features/restaurants/data/models/review_model.dart`
- `lib/features/restaurants/data/repositories/reviews_repository.dart`
- `lib/features/restaurants/presentation/widgets/review_card.dart`

**Benefits:**
- Quality reviews surface
- Community moderation
- Better decision making

---

### 9. Photo Uploads 📋
**Status:** Planned
**Effort:** Large (5-6 days)
**Description:** Let users upload photos of restaurants and food.

**Features:**
- Upload multiple photos per restaurant
- Photo gallery in restaurant details
- Community photos section
- Photo attribution (show uploader)
- Image compression and optimization

**Implementation Details:**
- Use `image_picker` for photo selection
- Upload to Firebase Storage
- Create `photos` collection in Firestore
- Implement photo viewer with zoom
- Add photo moderation system

**Files to Create:**
- `lib/features/restaurants/data/models/photo_model.dart`
- `lib/features/restaurants/data/repositories/photos_repository.dart`
- `lib/features/restaurants/presentation/widgets/photo_gallery_widget.dart`
- `lib/features/restaurants/presentation/screens/upload_photo_screen.dart`

**Packages to Add:**
- `image_picker`
- `flutter_image_compress`
- `photo_view`

**Benefits:**
- Visual decision making
- User-generated content
- Community engagement

---

## Priority 4 - Business Features

### 10. Restaurant Claims 💡
**Status:** Idea
**Effort:** Very Large (7-10 days)
**Description:** Allow restaurant owners to claim and manage their listings.

**Features:**
- Claim verification process
- Update business information
- Upload menu and photos
- Respond to reviews
- View analytics (views, favorites, calls)

**Implementation Details:**
- Create business owner role
- Add verification workflow
- Create business dashboard
- Implement owner verification (email, documents)
- Add admin panel for approvals

**Files to Create:**
- `lib/features/business/` (entire feature module)
- Cloud Functions for verification emails

**Benefits:**
- Accurate information
- Business engagement
- Review responses

---

### 11. Booking/Reservations Integration 💡
**Status:** Idea
**Effort:** Large (4-5 days)
**Description:** Integrate with booking platforms for table reservations.

**Integration Options:**
- OpenTable API
- Resy integration
- Custom booking system

**Features:**
- Check table availability
- Book directly from app
- Booking confirmation
- Reminders
- Cancellation management

**Implementation Details:**
- Integrate third-party APIs
- Create booking flow screens
- Add booking history
- Implement reminder notifications

**Benefits:**
- One-stop solution
- Increased bookings
- Better UX

---

### 12. Delivery Integration 💡
**Status:** Idea
**Effort:** Medium (3-4 days)
**Description:** Link to food delivery services.

**Integration Options:**
- Uber Eats deep linking
- Deliveroo integration
- Just Eat links
- Custom delivery tracking

**Features:**
- Show delivery options
- Direct link to order
- Estimated delivery time
- Delivery fee display

**Implementation Details:**
- Add delivery URLs to restaurant data
- Implement deep linking with `url_launcher`
- Show delivery partners in restaurant details
- Track which service users prefer

**Benefits:**
- Convenience
- Increased orders
- Platform value

---

## Additional Feature Ideas

### 13. Loyalty/Rewards Program 💡
- Points for reviews and visits
- Unlock badges and achievements
- Partner with restaurants for discounts
- Leaderboard for top reviewers

### 14. Events & Promotions 💡
- Restaurant events calendar
- Special offers and deals
- Happy hour tracking
- Live music nights

### 15. Social Sharing 💡
- Share restaurant on social media
- Share review on Instagram/Twitter
- Invite friends to join app
- Share favorite lists

### 16. AR Menu Preview 💡
- Use AR to preview dishes
- 3D food models
- Portion size visualization

### 17. Voice Search 💡
- Search by voice command
- "Find Nigerian restaurants near me"
- Accessibility feature

### 18. Multi-language Support 💡
- English (default)
- Yoruba
- Igbo
- Pidgin

---

## Technical Improvements

### Performance Optimization 📋
- Implement image lazy loading
- Add pagination to all lists
- Optimize Firestore queries with indexes
- Reduce app bundle size

### Testing Coverage 📋
- Unit tests for repositories
- Widget tests for screens
- Integration tests for user flows
- E2E tests for critical paths

### Analytics & Monitoring 📋
- Firebase Analytics integration
- Crashlytics for error tracking
- Performance monitoring
- User behavior tracking

### Security Enhancements 📋
- Implement Firestore security rules
- Add rate limiting
- Input validation and sanitization
- XSS protection

---

## How to Prioritize

When deciding what to build next, consider:

1. **User Impact** - How many users will benefit?
2. **Business Value** - Does it drive revenue or growth?
3. **Effort** - How long will it take?
4. **Dependencies** - What needs to be built first?
5. **User Feedback** - What are users asking for?

**Recommended Order:**
1. ✅ Authentication & Map (DONE)
2. ✅ Call & Directions (DONE)
3. ✅ Get real Firestore data (57 restaurants) (DONE)
4. ✅ Favorites Persistence (DONE)
5. ✅ Enhanced Filters - Partial (DONE: Price, Cuisine)
6. ✅ User Profiles (DONE)
7. ✅ Reviews System (DONE)
8. ✅ Map Enhancements (DONE: Zoom, Gestures, 3D)
9. ✅ UX Polish (DONE: Empty states, Loading skeletons, Errors)
10. Review Pagination
11. Photo Uploads
12. Push Notifications
13. Offline Mode
14. Complete Enhanced Filters (Distance, Dietary, Features, Rating)

---

## Contributing

When implementing a feature:
1. Update status to 🚧 In Progress
2. Create feature branch: `feature/feature-name`
3. Implement with tests
4. Update documentation
5. Submit PR for review
6. Mark as ✅ Completed when merged

---

## Questions or Suggestions?

For feature requests or questions, please:
- Open an issue on GitHub
- Discuss in team meetings
- Update this roadmap with new ideas

---

**Last Updated:** 2026-01-19
**Maintained By:** Development Team

---

## Recent Accomplishments (v0.5.0)

### January 2026
- ✅ Added 7 additional restaurants (Luton, Hatfield, Stevenage)
- ✅ Implemented custom map zoom controls
- ✅ Enhanced map gestures (zoom, pan, tilt, rotate)
- ✅ Added 3D buildings and detailed map view
- ✅ Created reusable empty state widgets
- ✅ Created reusable error state widgets with retry
- ✅ Added Hero animations for restaurant images
- ✅ Implemented loading skeletons for better UX
- ✅ Added price range data to all restaurants
- ✅ Updated Firestore rules for restaurant creation
- ✅ Comprehensive documentation updates
