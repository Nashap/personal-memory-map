# Personal Memory Map

Personal Memory Map is a beautifully designed, private space for keeping memories connected to meaningful moments and places. It is built as a polished student portfolio project using Flutter and Dart, with a strong emphasis on clean UI/UX and data privacy.

## ✨ Features

- **Memories & Moments**: Create, edit, and safely store your personal memories.
- **Persistent Photos**: Attach single or multiple photos to any memory and have them persist reliably.
- **Location Support**: Add geographical coordinates and names to places you've visited.
- **Powerful Search & Filters**: Quickly find memories by title, description, location, category, mood, or year.
- **Memory Dashboard**: View statistics, category breakdowns, year activity, and your most visited locations in a beautiful profile tab.
- **Favorites**: Star your best moments for quick access.
- **Timeline View**: Scroll through a beautifully curated feed of your journey.
- **Dark & Light Mode**: Seamlessly switch between themes, which are persistently saved.
- **100% Offline & Private**: All data and photos are stored strictly locally using SQLite.

## 🛠 Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Local Storage**: SQFlite (SQLite)
- **Local Images**: Path Provider, Image Picker
- **Architecture**: Model-View-Provider pattern with a dedicated Repository layer.

> **Note**: To ensure complete privacy and offline capability, this app intentionally does **not** implement Google Maps, cloud synchronization, AI features, or cloud authentication.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- Windows development tools (Visual Studio) for Windows builds
- Android Studio or command-line tools for Android builds

### Run the App
```bash
flutter pub get
flutter run
```

### Run Tests
```bash
# Run tests sequentially to avoid SQLite locking issues
flutter test --concurrency=1
```

### Build for Windows
```bash
flutter build windows --release
```
The executable will be located in `build\windows\x64\runner\Release\personal_memory_map.exe`.

### Build for Android (APK)
```bash
flutter build apk --release
```
The APK will be located in `build\app\outputs\flutter-apk\app-release.apk`.

*(Note: Depending on your local Flutter SDK version and Java JDK, Android Gradle building might require workarounds if using Gradle 8+ with older Flutter SDKs).*
