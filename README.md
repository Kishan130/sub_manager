# 📱 Sub Manager - Subscription Management Redefined

**Sub Manager** is a premium, high-performance mobile application designed to help users conquer subscription fatigue. It provides a centralized dashboard to track recurring expenses, analyze spending patterns with data-driven insights, and maximize the value of every digital service.

![App Dashboard Placeholder](https://via.placeholder.com/800x400?text=Sub+Manager+Dashboard)

## ✨ Key Features

- **🛍️ Unified Dashboard**: See all your subscriptions (Netflix, Spotify, Google One, etc.) in one clean, beautiful view.
- **📊 Advanced Analytics**: Visual spending breakdowns by category (Entertainment, Utility, Music) using interactive charts.
- **📈 Efficiency Scoring**: A smart algorithm that tracks your app usage and calculates an "Efficiency Score" to tell you if you're getting your money's worth.
- **🛡️ Secure Cloud Sync**: Seamless data persistence and synchronization across devices powered by Firebase.
- **🌗 Premium UI**: Modern glassmorphism design with full Dark Mode support and smooth micro-animations.
- **📅 Proactive Alerts**: Never miss a renewal date with automated billing cycle tracking.

## 🛠️ Tech Stack

- **Core**: [Flutter](https://flutter.dev/) (3.x)
- **State Management**: [Riverpod](https://riverpod.dev/)
- **Backend / Auth**: [Firebase](https://firebase.google.com/) (Auth, Firestore)
- **Charts**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Local Storage**: SharedPreferences
- **Theming**: Custom Material 3 Design System

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (Latest Stable)
- Android Studio / VS Code
- A Firebase Project (for sync features)

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Kishan130/sub_manager.git
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**:
   - Create a project on the [Firebase Console](https://console.firebase.google.com/).
   - Add an Android/iOS app and download the `google-services.json` (Android) or `GoogleService-Info.plist` (iOS).
   - Place `google-services.json` in `android/app/`.

4. **Signing (Optional)**:
   - Create a `key.properties` file in the `android/` folder with your keystore credentials for release builds.

5. **Run the app**:
   ```bash
   flutter run
   ```

## 🔒 Privacy & Security

Sub Manager values your privacy. We use on-device Android `UsageStats` to calculate efficiency scores locally. Sensitive data like your signing keys and Firebase project secrets are excluded from this repository for security reasons.

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---
Built with ❤️ by [Kishan Vachhani](https://github.com/Kishan130)
