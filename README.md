# Naija Food Finder UK 🇳🇬🇬🇧

Find Nigerian restaurants and African shops across the United Kingdom

![CI](https://github.com/gbolahan507/naija-food-finder-uk/workflows/CI/badge.svg)
[![Flutter](https://img.shields.io/badge/Flutter-3.38.5-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)

## 📱 About

Naija Food Finder UK is a mobile application built with Flutter that helps the Nigerian diaspora in the UK discover authentic Nigerian restaurants and African shops. Whether you're craving jollof rice, suya, or pounded yam, find it near you!

## ✨ Features

### Core Features
- 🏠 **Restaurant Discovery** - Browse Nigerian and African restaurants across the UK
- 🔍 **Smart Search** - Real-time search by name, location, or cuisine type
- 🗺️ **Interactive Map View** - Visualize all restaurants on Google Maps with custom markers
- 📍 **Location-Based** - See restaurants sorted by distance from you
- ⭐ **Ratings & Reviews** - Check ratings and read reviews from the community
- ❤️ **Favorites** - Save your favorite restaurants for quick access
- 📤 **Share** - Share restaurant details with friends and family
- 🔐 **User Authentication** - Sign in with email/password or Google

### Advanced Features
- 🔄 **Sort Options** - Sort by distance, rating, name, or number of reviews
- 🏷️ **Filter by Cuisine** - Nigerian, Ghanaian, Caribbean, and more
- 🗺️ **Map Features**:
  - Interactive restaurant markers with info windows
  - Switch between normal and satellite map views
  - Tap markers to view restaurant details
  - Auto-center to fit all visible restaurants
  - Real-time filter integration (search/filter sync with map)
  - Filter status indicator on map
- 🚗 **Delivery & Takeaway** - See which restaurants offer delivery or takeaway
- 🕐 **Opening Hours** - Check if a restaurant is currently open
- 📍 **Detailed Information** - View full address, phone number, and services
- ♻️ **Pull to Refresh** - Fresh data with a simple pull gesture
- 👤 **User Profiles** - Personalized profiles with authentication
- 🔄 **Real-time Sync** - Data syncs across devices when signed in

## 🛠️ Tech Stack

**Frontend:**
- Flutter 3.38.5
- Dart 3.10.4
- Riverpod (State Management)
- GoRouter (Navigation)
- Google Maps Flutter (Map Integration)
- Geolocator (Location Services)

**Backend:**
- Firebase Firestore (Database)
- Firebase Authentication (Email/Password + Google Sign-In)
- Firebase Storage (Coming soon)
- Google Maps API (Map & Geolocation Services)

**Architecture:**
- Feature-first architecture
- MVVM pattern
- Repository pattern
- Clean separation of concerns

**CI/CD:**
- GitHub Actions
- Automated testing
- Android & iOS builds

## 🎨 Design

- Nigerian flag colors (Green #008751, White, Gold #FFD700)
- Material Design 3
- Custom theme system
- Responsive layouts

## 📊 Project Status

**Current Version:** 0.4.0
**Status:** Active Development 🚀
**Progress:** 90% MVP Complete

### ✅ Completed Features
- [x] Project architecture and setup
- [x] Firebase Firestore integration
- [x] Restaurant list with search
- [x] Restaurant details screen
- [x] Navigation system (bottom nav + routing)
- [x] Favorites system with real-time sync
- [x] Sort functionality (distance, rating, name, reviews)
- [x] Pull-to-refresh
- [x] Share restaurant functionality
- [x] User authentication (Email/Password + Google Sign-In)
- [x] User profile management
- [x] Sign in/Sign up screens
- [x] Logout functionality
- [x] Google Maps integration with interactive markers
- [x] Map view with normal/satellite toggle
- [x] Filter integration with map (search/filter sync)
- [x] Location service helper
- [x] CI/CD pipeline

### 🔨 In Progress
- [ ] Reviews and ratings system
- [ ] User-specific data sync
- [ ] Advanced map features (clustering, custom markers)

### 📋 Upcoming Features
- [ ] Advanced filters
- [ ] User profiles
- [ ] Photo galleries
- [ ] Opening hours display
- [ ] Call and directions integration

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.27.2 or higher)
- Dart SDK (3.10.0 or higher)
- Firebase account
- iOS/Android development environment

### Installation

1. Clone the repository
```bash
git clone https://github.com/gbolahan507/naija-food-finder-uk.git
cd naija-food-finder-uk
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Google Maps API
   - Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Enable Maps SDK for Android and iOS
   - For **Android**: Add your API key to `android/app/src/main/AndroidManifest.xml`
     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_API_KEY_HERE" />
     ```
   - For **iOS**: Add your API key to `ios/Runner/AppDelegate.swift`
     ```swift
     GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
     ```

4. Run the app
```bash
flutter run
```

## 📂 Project Structure
```
lib/
├── core/
│   ├── constants/      # Colors, strings, assets
│   ├── theme/          # App theme configuration
│   ├── router/         # Navigation setup
│   ├── navigation/     # Bottom navigation
│   └── services/       # Location service, utilities
├── features/
│   ├── auth/           # Authentication (login, signup, profile)
│   └── restaurants/
│       ├── data/       # Models, repositories, providers
│       └── presentation/ # Screens (list, map, details) and widgets
└── main.dart
```

## 🤝 Contributing

Contributions are welcome! This project is part of a portfolio for UK Global Talent Visa application, demonstrating technical excellence and community impact.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Developer

Built by **Hameed Abolaji**
- GitHub: [@gbolahan507](https://github.com/gbolahan507)
- Focus: Flutter Mobile Development
- Purpose: Helping the Nigerian diaspora in the UK

## 🎯 Project Goals

1. **Community Impact** - Serve 25,000+ Nigerians in the UK
2. **Technical Excellence** - Showcase production-ready mobile development
3. **Scalability** - Built to handle thousands of restaurants and users
4. **User Experience** - Intuitive, fast, and beautiful interface

## 📈 Metrics

- **Active Development:** 5-day streak
- **Contributions:** 60+ contributions
- **Code Quality:** All CI checks passing
- **Backend:** Real-time Firebase integration
- **Authentication:** Email/Password + Google Sign-In
- **Features:** 15+ major features implemented

---

**Made with ❤️ for the Nigerian community in the UK** 🇳🇬🇬🇧
