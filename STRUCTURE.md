# UFin Admin System

## Project Structure

This project follows a **clean architecture** pattern with feature-based modular structure.

### Directory Structure

```
lib/
├── main.dart                 # Application entry point
├── config/                   # Configuration files
│   ├── theme/               # Theme configuration
│   │   └── app_theme.dart
│   └── routes/              # Routing configuration
│       └── app_routes.dart
├── core/                     # Core utilities and providers
│   ├── providers/           # State management providers
│   │   └── auth_provider.dart
│   └── services/            # Core services
│       └── secure_storage_service.dart
└── features/                # Feature modules
    ├── auth/                # Authentication module
    │   ├── data/            # Data layer
    │   ├── domain/          # Business logic layer
    │   └── presentation/    # UI layer
    │       └── pages/
    │           ├── login_page.dart
    │           └── register_page.dart
    └── subscriptions/       # Subscriptions module
        ├── data/            # Data layer
        ├── domain/          # Business logic layer
        └── presentation/    # UI layer
            └── pages/
                └── subscriptions_page.dart
```

## Technologies Used

- **State Management**: Riverpod (flutter_riverpod)
- **Routing**: Go Router (go_router)
- **Secure Storage**: Flutter Secure Storage (flutter_secure_storage)
- **Environment Variables**: Flutter Dotenv (flutter_dotenv)
- **HTTP Client**: Dio (dio)
- **Logging**: Logger (logger)

## Getting Started

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Environment Configuration

The `.env` file is already configured with:
- API endpoints
- Secure storage settings
- App configuration
- Security settings

### 3. Running the Application

```bash
flutter run
```

## Features

### Auth Module
- User login and registration
- Secure token storage using Flutter Secure Storage
- Auth state management with Riverpod
- Protected routes using Go Router

### Subscriptions Module
- View available subscription plans
- Manage user subscriptions
- Display user information

## Architecture

This project follows **Clean Architecture** principles:

- **Presentation Layer**: UI components, pages, and state management
- **Domain Layer**: Business logic and entities
- **Data Layer**: API calls, local storage, and repositories

## Theme Configuration

Default theme configured in `config/theme/app_theme.dart`:
- Material Design 3
- Blue seed color (#2196F3)
- Light and Dark themes
- Custom input decoration
- Custom button styling

## Authentication Flow

1. User enters credentials on login/register page
2. Credentials are validated and sent to API
3. On success, token is stored securely using Flutter Secure Storage
4. Auth state is updated via Riverpod provider
5. Router automatically redirects to subscriptions page

## Extending the Project

### Adding a New Feature

1. Create new directory under `lib/features/`
2. Follow the same structure (data, domain, presentation)
3. Create providers in `lib/core/providers/` if needed
4. Add routes in `lib/config/routes/app_routes.dart`
5. Update main.dart imports

### Adding Services

1. Create new service in `lib/core/services/`
2. Export in `lib/core/services/services.dart`
3. Use in providers or UI layers

## Security

- Tokens stored securely using Flutter Secure Storage
- Environment variables stored in `.env` file (not version controlled)
- HTTPS connections recommended for API calls

## Next Steps

1. Implement actual API integration in data layer
2. Add error handling and logging
3. Create repository pattern for data access
4. Add unit and widget tests
5. Implement more features in each module
