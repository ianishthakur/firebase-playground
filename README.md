# Firebase Flutter Showcase App 🔥

A comprehensive Flutter application showcasing **ALL Firebase free tier features** with modern UI/UX design and BLoC state management.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Free%20Tier-orange.svg)
![BLoC](https://img.shields.io/badge/State-BLoC-purple.svg)

## ✨ Features

### 🔐 Authentication

- Email/Password Sign In & Sign Up
- Google Sign In
- Anonymous Authentication
- Password Reset
- Profile Management
- Account Deletion

### 📊 Databases

- **Cloud Firestore** - NoSQL document database
- **Realtime Database** - JSON tree database
- CRUD operations with real-time sync
- Switch between databases seamlessly

### 📁 Cloud Storage

- File upload with progress tracking
- Image picker (Camera & Gallery)
- File management (view, delete)
- Storage usage statistics

### 📱 Push Notifications (FCM)

- FCM token management
- Topic subscriptions
- Foreground & background notifications
- Notification history

### 📈 Analytics

- Automatic event tracking
- Custom event logging
- Screen view tracking
- User properties

### 💥 Crashlytics

- Automatic crash reporting
- Non-fatal error logging
- Custom error tracking

### ⚙️ Remote Config

- Dynamic app configuration
- Feature flags
- A/B testing ready

### 🎯 Performance Monitoring

- App startup tracking
- Network request monitoring
- Custom traces

### 🤖 ML Kit (On-Device)

- **Text Recognition (OCR)** - Extract text from images
- **Face Detection** - Detect faces with landmarks
- **Barcode Scanning** - QR codes & barcodes
- **Image Labeling** - Object identification
- **Translation** - 59+ languages

### 🛡️ App Check

- Device attestation
- Backend protection

## 🎨 Design

- Modern 2025 UI/UX design
- Premium glassmorphism effects
- Smooth animations with `flutter_animate`
- Dark/Light theme support
- Custom typography (Satoshi & Clash Display)
- Responsive layouts

## 📁 Project Structure

```
lib/
├── main.dart
├── core/
│   ├── di/
│   │   └── injection.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── widgets/
│       ├── premium_button.dart
│       ├── premium_card.dart
│       ├── premium_text_field.dart
│       └── splash_screen.dart
└── features/
    ├── auth/
    │   ├── bloc/
    │   ├── data/
    │   └── presentation/
    ├── home/
    ├── database/
    ├── storage/
    ├── notifications/
    ├── analytics/
    ├── ml/
    ├── remote_config/
    ├── profile/
    └── settings/
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.38.5
- Dart SDK 3.10.4
- Android Studio / VS Code
- Firebase account

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd firebase_flutter_app
```

### Step 2: Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project (or use existing)
3. Add Android & iOS apps

#### Android Setup

```bash
# Package name: com.example.firebase_flutter_app
```

1. Download `google-services.json`
2. Place it in `android/app/`
3. Update `android/build.gradle`:

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

4. Update `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'
```

#### iOS Setup

1. Download `GoogleService-Info.plist`
2. Place it in `ios/Runner/`
3. Open Xcode and add to Runner target

### Step 3: Enable Firebase Services

In Firebase Console, enable these services:

1. **Authentication**
   - Email/Password
   - Google Sign-In
   - Anonymous

2. **Cloud Firestore**
   - Start in test mode
   - Rules for production:

   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId}/{document=**} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

3. **Realtime Database**
   - Start in test mode
   - Rules:

   ```json
   {
     "rules": {
       "users": {
         "$uid": {
           ".read": "$uid === auth.uid",
           ".write": "$uid === auth.uid"
         }
       }
     }
   }
   ```

4. **Cloud Storage**
   - Rules:

   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /users/{userId}/{allPaths=**} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

5. **Cloud Messaging** - Enable FCM

6. **Analytics** - Automatically enabled

7. **Crashlytics** - Enable in console

8. **Remote Config** - Add default parameters:
   - `welcome_message`: "Welcome to Firebase Showcase!"
   - `feature_ml_enabled`: true
   - `max_upload_size_mb`: 10

9. **Performance Monitoring** - Enable

10. **App Check** - Configure for debug/production

### Step 4: Install Dependencies

```bash
flutter pub get
```

### Step 5: Add Fonts (Optional)

Download and add these fonts to `assets/fonts/`:

- Satoshi (Regular, Medium, Bold, Black)
- Clash Display (Medium, Semibold, Bold)

Or use system fonts by updating `pubspec.yaml`.

### Step 6: Run the App

```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## 📱 Platform-Specific Setup

### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access for ML features and file upload</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access for file upload</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access for video recording</string>
```

## 🧪 Testing Features

### Authentication

- Create account with email
- Sign in with Google
- Use anonymous sign-in
- Test password reset

### Database

- Create, edit, delete notes
- Switch between Firestore/Realtime DB
- Observe real-time updates

### Storage

- Upload images from camera/gallery
- View uploaded files
- Delete files

### ML Kit

- Scan text from images
- Detect faces in photos
- Scan QR codes/barcodes
- Label objects in images
- Translate text

### Notifications

- Copy FCM token
- Subscribe to topics
- Send test notification from Firebase Console

### Settings

- Refresh Remote Config
- Log analytics events
- Test Crashlytics

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| firebase_core | Firebase initialization |
| firebase_auth | Authentication |
| cloud_firestore | NoSQL database |
| firebase_database | Realtime database |
| firebase_storage | File storage |
| firebase_messaging | Push notifications |
| firebase_analytics | Analytics |
| firebase_crashlytics | Crash reporting |
| firebase_remote_config | Remote configuration |
| firebase_performance | Performance monitoring |
| firebase_app_check | App verification |
| google_mlkit_* | ML Kit features |
| flutter_bloc | State management |
| go_router | Navigation |
| flutter_animate | Animations |

## 🎯 Firebase Free Tier Limits

| Service | Free Limit |
|---------|------------|
| Authentication | Unlimited |
| Firestore | 1GB storage, 50K reads/day |
| Realtime DB | 1GB storage, 10GB downloads/month |
| Storage | 5GB storage, 1GB downloads/day |
| Cloud Messaging | Unlimited |
| Analytics | Unlimited |
| Crashlytics | Unlimited |
| Remote Config | Unlimited |
| Performance | Unlimited |
| ML Kit (On-device) | Unlimited |

## 🧪 Testing

This project includes comprehensive test coverage with unit tests, BLoC tests, widget tests, and integration tests.

### Test Structure

```
test/
├── helpers/
│   └── test_helpers.dart              # Shared mocks, fakes & utilities
├── features/
│   ├── auth/
│   │   ├── bloc/
│   │   │   └── auth_bloc_test.dart    # Authentication BLoC tests
│   │   ├── data/
│   │   │   └── user_model_test.dart   # User model unit tests
│   │   └── presentation/screens/
│   │       └── login_screen_test.dart # Login screen widget tests
│   ├── database/
│   │   ├── bloc/
│   │   │   └── database_bloc_test.dart # Database BLoC tests
│   │   └── data/
│   │       └── note_model_test.dart    # Note model unit tests
│   ├── storage/
│   │   └── bloc/
│   │       └── storage_bloc_test.dart  # Storage BLoC tests
│   └── ml/
│       └── bloc/
│           └── ml_bloc_test.dart       # ML Kit BLoC tests
└── core/
    └── widgets/
        └── premium_widgets_test.dart   # Custom widget tests

integration_test/
└── app_test.dart                       # End-to-end integration tests
```

### Test Coverage

| Feature | Unit Tests | BLoC Tests | Widget Tests |
|---------|:----------:|:----------:|:------------:|
| Authentication | ✅ UserModel | ✅ AuthBloc | ✅ LoginScreen |
| Database | ✅ NoteModel | ✅ DatabaseBloc | - |
| Storage | ✅ FileModel | ✅ StorageBloc | - |
| ML Kit | - | ✅ MLBloc | - |
| Core Widgets | - | - | ✅ PremiumWidgets |

### Running Tests

```bash
# Run all unit & widget tests
flutter test

# Run tests with coverage report
flutter test --coverage

# Run specific test file
flutter test test/features/auth/bloc/auth_bloc_test.dart

# Run tests matching a pattern
flutter test --name "AuthBloc"

# Run tests with verbose output
flutter test --reporter expanded

# Generate HTML coverage report (requires lcov)
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Running Integration Tests

```bash
# Run on connected device/emulator
flutter test integration_test/app_test.dart

# Run on specific device
flutter test integration_test/app_test.dart -d <device_id>

# Run with Flutter driver
flutter drive --target=integration_test/app_test.dart
```

### Test Dependencies

The following packages are used for testing:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^10.0.0      # BLoC testing utilities
  mocktail: ^1.0.4        # Mocking library
  integration_test:
    sdk: flutter
```

### Writing New Tests

1. **Unit Tests**: Test individual functions, methods, and classes in isolation
2. **BLoC Tests**: Use `bloc_test` package with `blocTest()` for state management
3. **Widget Tests**: Test UI components with `WidgetTester`
4. **Integration Tests**: Test complete user flows on real devices

Example BLoC test:

```dart
blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthAuthenticated] on successful sign in',
  build: () {
    when(() => mockRepo.signIn(email, password))
        .thenAnswer((_) async => mockUser);
    return AuthBloc(mockRepo);
  },
  act: (bloc) => bloc.add(SignInRequested(email, password)),
  expect: () => [
    isA<AuthLoading>(),
    isA<AuthAuthenticated>(),
  ],
);
```

### Continuous Integration

For CI/CD pipelines, add these commands:

```yaml
# GitHub Actions example
- name: Run Tests
  run: flutter test --coverage

- name: Upload Coverage
  uses: codecov/codecov-action@v3
  with:
    files: coverage/lcov.info
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure all tests pass (`flutter test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Firebase Team for the amazing free tier
- Flutter Team for the beautiful framework
- BLoC Library for state management

---

Made with ❤️ and Flutter
