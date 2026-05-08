# 📝 Notes App

A feature-rich Flutter notes application with Firebase backend, user authentication, and real-time synchronization.

## ✨ Features

- **User Authentication**: Sign up and sign in with Firebase Authentication
- **Create Notes**: Add new notes with title and content
- **Edit Notes**: Modify existing notes
- **Delete Notes**: Remove unwanted notes
- **Real-time Sync**: Automatic synchronization with Firebase Database
- **Local Storage**: Offline support with local database
- **Clean Architecture**: Well-structured code following SOLID principles
- **State Management**: BLoC pattern for state management
- **Responsive UI**: Works seamlessly on different screen sizes

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: BLoC
- **Backend**: Firebase (Authentication, Realtime Database, Cloud Firestore)
- **Local Storage**: SQLite (via Drift/Floor)
- **Architecture**: Clean Architecture (Domain, Data, Presentation layers)

## 📱 Platforms Supported

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ Linux
- ✅ macOS

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Git
- Android Studio / Xcode (for native development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/notes_app.git
   cd notes_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase** (if not already done)
   - Download `google-services.json` from Firebase Console
   - Place it in `android/app/`
   - Download `GoogleService-Info.plist` from Firebase Console
   - Place it in `ios/Runner/`

4. **Run the app**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── di/                           # Dependency Injection
│   ├── network/                      # Network connectivity
│   ├── theme/                        # App theme and colors
│   └── utils/                        # Constants and utilities
├── features/
│   ├── auth/                         # Authentication feature
│   │   ├── data/                     # Data layer
│   │   ├── domain/                   # Domain layer
│   │   └── presentation/             # UI layer
│   ├── notes/                        # Notes feature
│   │   ├── data/                     # Data layer
│   │   ├── domain/                   # Domain layer
│   │   └── presentation/             # UI layer
│   └── splash/                       # Splash screen
└── firebase_options.dart             # Firebase configuration
```

## 🔧 Available Commands

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Build APK (Android)
flutter build apk

# Build IPA (iOS)
flutter build ios

# Build Web
flutter build web

# Run tests
flutter test

# Analyze code
flutter analyze
```

## 📝 Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Add Android and iOS apps
4. Download configuration files and add to the project
5. Enable Firestore Database and Authentication
6. Set security rules for Firestore

## 🎨 UI/UX Features

- Clean and intuitive user interface
- Dark/Light theme support (if implemented)
- Smooth animations and transitions
- Easy-to-use note management

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 📦 Dependencies

Main packages used:
- `firebase_core` - Firebase initialization
- `firebase_auth` - User authentication
- `cloud_firestore` - Database
- `flutter_bloc` - State management
- `get_it` - Service locator
- `equatable` - Value comparison
- `dartz` - Functional programming
- `internet_connection_checker` - Network connectivity

## 🐛 Troubleshooting

### Common Issues

1. **Firebase initialization fails**
   - Ensure Google services files are in correct locations
   - Verify Firebase project ID matches in config files

2. **Build errors on iOS**
   ```bash
   cd ios
   pod install --repo-update
   cd ..
   flutter run
   ```

3. **Android build issues**
   - Clean build: `flutter clean && flutter pub get && flutter run`
   - Update Android SDK to latest version

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues and enhancement requests.

## 📧 Contact

For questions or support, contact: anila@localhost

## 🙏 Acknowledgments

- Flutter community
- Firebase documentation
- Clean Architecture principles
