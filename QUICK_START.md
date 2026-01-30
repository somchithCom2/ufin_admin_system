# Quick Start Guide - UFin Admin System

## ✅ Setup Complete

Your Flutter project has been configured with a **standard clean architecture** structure and two feature modules.

## 📦 Installed Dependencies

- **flutter_riverpod** (^2.5.1) - State management
- **go_router** (^14.2.0) - Navigation & routing
- **flutter_secure_storage** (^9.2.2) - Secure token storage
- **flutter_dotenv** (^5.2.1) - Environment variables
- **dio** (^5.5.0) - HTTP client
- **logger** (^2.4.0) - Logging

## 🏗️ Project Structure

```
lib/
├── main.dart                          # Entry point
├── config/
│   ├── theme/app_theme.dart          # Light & Dark themes (Material 3)
│   └── routes/app_routes.dart        # Go Router configuration
├── core/
│   ├── providers/auth_provider.dart   # Auth state management
│   └── services/secure_storage_service.dart  # Secure token storage
└── features/
    ├── auth/                          # Authentication module
    │   ├── data/                      # Repository & API calls
    │   ├── domain/                    # Business logic
    │   └── presentation/
    │       └── pages/
    │           ├── login_page.dart    # Login UI
    │           └── register_page.dart # Register UI
    └── subscriptions/                 # Subscriptions module
        ├── data/
        ├── domain/
        └── presentation/
            └── pages/
                └── subscriptions_page.dart
```

## 🚀 Next Steps

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the App
```bash
flutter run
```

### 3. Test the Flow
- **Login Page**: http://localhost:7357 (or your device)
- **Registration**: Click "Register" link
- **Subscriptions**: Shows after successful login
- **Logout**: Click logout button in app bar

## 🔐 Security & Environment

Your `.env` file is already configured with:
- API endpoints
- Secure storage settings
- App configuration
- Debug mode

**Note**: The `.env` file should never be committed to version control.

## 📱 Theme Configuration

### Default Theme (Material 3)
- **Primary Color**: Blue (#2196F3)
- **Light Theme**: Available
- **Dark Theme**: Available
- **Seed Color**: Used for Material 3 color generation

Change theme in `config/theme/app_theme.dart`:
```dart
static const seedColor = Color(0xFF2196F3); // Change this
```

## 🔑 Authentication Flow

1. **Login/Register** → Validate credentials
2. **Token Storage** → Securely stored via flutter_secure_storage
3. **State Management** → Riverpod provider manages auth state
4. **Auto Routing** → Go Router redirects based on auth status
5. **Protected Routes** → Unauthorized users redirected to login

## 📝 Adding New Features

### Create a New Module
1. Create `lib/features/your_module/`
2. Add subdirectories: `data/`, `domain/`, `presentation/`
3. Follow the same pattern as auth/subscriptions

### Add Routes
Edit `lib/config/routes/app_routes.dart`:
```dart
GoRoute(
  path: '/your_route',
  builder: (context, state) => const YourPage(),
),
```

### Add State Management
Create providers in `lib/core/providers/` and follow the auth_provider pattern.

## 🧪 Testing

Included test file:
- `test/widget_test.dart` - Widget testing template

Run tests:
```bash
flutter test
```

## 📚 API Integration

When ready to integrate with your backend:

1. Create data models in `features/*/data/models/`
2. Create API clients in `features/*/data/providers/`
3. Implement repositories in `features/*/data/repositories/`
4. Use Riverpod providers for state management

## 🐛 Debugging

Enable debug mode in `.env`:
```
DEBUG_MODE=true
```

View logs using the Logger package in any file:
```dart
import 'package:logger/logger.dart';

final logger = Logger();
logger.i('Info message');
logger.e('Error message');
```

## 📖 Resource Links

- [Flutter Documentation](https://flutter.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [Go Router Documentation](https://pub.dev/packages/go_router)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)

## ✨ Project Ready!

Your UFin Admin System is now configured and ready for development. Start with:

1. Implementing API integration in the data layer
2. Adding your business logic in the domain layer
3. Creating UI in the presentation layer
4. Adding more features following the same modular pattern

Happy coding! 🎉
