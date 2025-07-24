# Tuition Helper App - Architecture Documentation

## Overview

The Tuition Helper App is a modern, offline-first Flutter application built with a clean architecture pattern using the Provider state management system. It's designed to help tutors manage their students, sessions, payments, and schedules efficiently across Android, iOS, and Web platforms.

## Project Structure

```
lib/
├── app.dart                    # Main app widget and initialization
├── main.dart                   # Application entry point
├── core/                       # Core utilities and configurations
├── models/                     # Data models and entities
├── providers/                  # State management (Provider pattern)
├── routes/                     # Navigation and routing
├── screens/                    # UI screens and pages
├── services/                   # Business logic and external services
└── widgets/                    # Reusable UI components
```

## Detailed Architecture

### 📱 Entry Points

#### `main.dart`
- **Purpose**: Application entry point
- **Responsibilities**:
  - Flutter framework initialization
  - Firebase initialization (optional, graceful fallback)
  - App services initialization
  - Error handling and recovery UI
  - Launch the main app widget

#### `app.dart`
- **Purpose**: Main application widget and configuration
- **Responsibilities**:
  - Multi-provider setup for state management
  - Theme configuration (light/dark modes)
  - Routing configuration
  - Localization setup
  - Global app settings
  - Contains `AppInitializer` class for service initialization

### 🏗️ Core (`core/`)

Foundation layer containing shared utilities and configurations.

#### `core/constants/`
- `app_constants.dart`: Application-wide constants, API endpoints, app info

#### `core/database/`
- Database schema definitions and migration utilities

#### `core/themes/`
- `light_theme.dart`: Light theme configuration
- `dark_theme.dart`: Dark theme configuration
- Theme definitions for consistent UI across the app

#### `core/utils/`
- `validation_utils.dart`: Input validation utilities (email, phone, etc.)
- Helper functions and utilities used across the app

### 🎯 Models (`models/`)

Data layer defining the structure of business entities.

#### Core Models:
- **`guardian_model.dart`**: Parent/guardian information
- **`student_model.dart`**: Student details and academic info
- **`session_model.dart`**: Tutoring session records
- **`payment_model.dart`**: Payment transactions and billing
- **`notification_model.dart`**: In-app and push notifications
- **`location_model.dart`**: Geographic locations and addresses

#### Generated Files (`.g.dart`):
- Auto-generated Hive adapters for local storage
- Created using `build_runner` for type-safe serialization

**Key Features:**
- Hive annotations for offline storage
- JSON serialization/deserialization
- CRUD operation methods
- Data validation
- Sync status tracking

### 🔄 Providers (`providers/`)

State management layer using the Provider pattern for reactive UI updates.

#### Available Providers:
- **`guardian_provider.dart`**: Guardian management state
- **`theme_provider.dart`**: App theme and appearance settings
- **`calendar_provider.dart`**: Calendar events and scheduling
- **`location_provider.dart`**: Location services and data
- **`payment_provider.dart`**: Payment tracking and history
- **`session_provider.dart`**: Session management and scheduling

**Key Features:**
- ChangeNotifier pattern for reactive updates
- Local state management
- Data validation before updates
- Loading states and error handling
- Search and filtering capabilities

### 🛠️ Services (`services/`)

Business logic layer handling data operations and external integrations.

#### Core Services:

**`database_service.dart`**
- SQLite database operations
- CRUD operations for all entities
- Data relationships and foreign keys
- Database migrations and schema updates

**`storage_service.dart`**
- Hive local storage management
- Fast key-value storage for settings
- Offline data caching
- Data synchronization utilities

**`notification_service.dart`**
- Local notifications using Flutter Local Notifications
- Firebase Cloud Messaging (FCM) integration
- Notification scheduling and management
- Custom notification channels

**`backup_service.dart`**
- Local and cloud backup functionality
- Data export/import operations
- Backup history management
- Data restoration utilities

**`location_service.dart`**
- GPS location tracking
- Geocoding and reverse geocoding
- Location-based features
- Address validation and formatting

**`calendar_service.dart`**
- Calendar integration
- Event scheduling and management
- Recurring event handling
- Calendar statistics and reporting

### 🧭 Routes (`routes/`)

Navigation layer managing app routing and navigation flow.

#### `routes/app_routes.dart`
- Route name constants
- Centralized route definitions
- Parameter passing utilities

#### `routes/route_generator.dart`
- Dynamic route generation
- Route parameter validation
- Navigation error handling
- Deep linking support

### 📱 Screens (`screens/`)

Presentation layer containing all UI screens and user interfaces.

#### Screen Categories:

**`splash_screen.dart`**
- App loading screen
- Initialization progress display
- Animated app logo and branding

**`home/`**
- `home_screen.dart`: Main dashboard with navigation tabs
- Quick stats and overview widgets
- Bottom navigation implementation

**`guardians/`**
- `guardian_add_screen.dart`: Add new guardian form
- `guardian_edit_screen.dart`: Edit existing guardian
- `guardian_detail_screen.dart`: Guardian profile view
- `guardian_list_screen.dart`: List all guardians
- `guardian_widgets.dart`: Reusable guardian UI components
- `add_edit_guardian_screen.dart`: Combined add/edit functionality

**`calendar/`**
- Calendar view and event management
- Session scheduling interface

**`payments/`**
- Payment tracking and history
- Payment collection interface

**`reports/`**
- Analytics and reporting screens
- Data visualization and charts

**`settings/`**
- App configuration and preferences
- User profile management

**`maps/`**
- Map integration for location features
- Route planning and navigation

### 🧩 Widgets (`widgets/`)

Reusable UI components used across multiple screens.

**Common Widget Types:**
- Custom form fields and inputs
- Data display cards and lists
- Loading indicators and animations
- Dialog boxes and modals
- Charts and visualization components

## 🏛️ Architecture Patterns

### Clean Architecture
- **Separation of Concerns**: Each layer has specific responsibilities
- **Dependency Inversion**: Higher layers depend on abstractions, not concrete implementations
- **Testability**: Easy to unit test individual components

### MVVM Pattern with Provider
- **Model**: Data models and business entities
- **View**: Flutter widgets and screens
- **ViewModel**: Provider classes managing state and business logic

### Repository Pattern
- Services act as repositories for data access
- Abstract data sources (local storage, remote APIs)
- Consistent interface for data operations

## 🔄 Data Flow

```
UI (Screens) ↔ State Management (Providers) ↔ Business Logic (Services) ↔ Data (Models)
     ↓                    ↓                         ↓                       ↓
  User Input         State Updates           Service Calls           Storage Operations
```

1. **User Interaction**: User interacts with UI screens
2. **State Update**: Providers update application state
3. **Service Call**: Services handle business logic and data operations
4. **Data Persistence**: Models are saved to local storage/database
5. **UI Refresh**: Providers notify listeners to update UI

## 🚀 Key Features

### Offline-First Architecture
- Local SQLite database for primary storage
- Hive for fast key-value caching
- Background sync when online
- Graceful offline operation

### State Management
- Provider pattern for reactive UI
- Centralized state management
- Efficient rebuild optimization
- Error state handling

### Modular Design
- Feature-based organization
- Reusable components
- Easy to extend and maintain
- Clear separation of concerns

### Cross-Platform Support
- Single codebase for Android, iOS, and Web
- Platform-specific optimizations
- Responsive design patterns
- Native platform integrations

## 🛠️ Development Guidelines

### Adding New Features
1. Create data model in `models/`
2. Add business logic to appropriate service in `services/`
3. Create provider for state management in `providers/`
4. Build UI screens in `screens/`
5. Add navigation routes in `routes/`
6. Create reusable widgets in `widgets/`

### Code Organization
- Keep related files in the same directory
- Use clear, descriptive file names
- Follow Dart naming conventions
- Add comprehensive documentation
- Write unit tests for business logic

### State Management Best Practices
- Use Provider for app-wide state
- Keep UI state local when possible
- Implement proper error handling
- Show loading states during operations
- Optimize rebuild performance

## 📚 Dependencies

### Core Dependencies
- **flutter**: UI framework
- **provider**: State management
- **hive & hive_flutter**: Fast local storage
- **sqflite**: SQLite database
- **shared_preferences**: Simple key-value storage

### Feature Dependencies
- **firebase_core & firebase_messaging**: Push notifications
- **geolocator & geocoding**: Location services
- **flutter_local_notifications**: Local notifications
- **table_calendar**: Calendar widgets
- **fl_chart**: Data visualization
- **file_picker**: File operations

### Development Dependencies
- **build_runner**: Code generation
- **hive_generator**: Hive adapter generation
- **flutter_lints**: Code quality
- **mockito**: Testing utilities

## 🔧 Build & Run

### Prerequisites
- Flutter SDK 3.8.1+
- Dart 3.0+
- Android Studio / VS Code
- Platform-specific SDKs (Android/iOS/Web)

### Commands
```bash
# Get dependencies
flutter pub get

# Generate code (Hive adapters)
flutter packages pub run build_runner build

# Run on different platforms
flutter run -d android
flutter run -d ios
flutter run -d chrome
flutter run -d macos
```

### Known Issues & Solutions

#### Firebase Configuration
The app gracefully handles missing Firebase configuration files:
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)

If Firebase features are not needed, the app will continue to work with local notifications and storage only.

#### Android Build Issues
If you encounter core library desugaring errors:
1. The app already includes desugaring configuration
2. Clean and rebuild: `flutter clean && flutter pub get`
3. For Android API level issues, check `android/app/build.gradle.kts`

## 🧪 Testing

### Test Structure
```
test/
├── unit_tests/         # Service and provider tests
├── widget_tests/       # UI component tests
└── integration_tests/  # End-to-end tests
```

### Testing Guidelines
- Test business logic in services
- Test state management in providers
- Test UI components in isolation
- Create integration tests for user flows

## 📝 Contributing

1. Follow the established architecture patterns
2. Write comprehensive tests
3. Document new features and APIs
4. Use consistent coding style
5. Update this README when adding new major components

## 🔍 Current Implementation Status

### ✅ Completed Features
- Core architecture setup
- Data models with Hive integration
- Provider-based state management
- Local storage services
- Guardian management (CRUD operations)
- Home screen with dashboard
- Navigation and routing
- Theme management
- Offline-first architecture

### 🚧 In Progress
- Additional UI screens
- Calendar integration
- Payment management
- Maps and location features
- Comprehensive testing

### 📋 Upcoming Features
- Advanced reporting and analytics
- Cloud synchronization
- Advanced notification scheduling
- Multi-language support
- Data import/export

---

This architecture ensures maintainability, scalability, and testability while providing a smooth user experience across all supported platforms.
