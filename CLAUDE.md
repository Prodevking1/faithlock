# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Fast App is a Flutter boilerplate designed to launch production-ready mobile apps rapidly. It features a simplified CMS system for MVP development, comprehensive UI component library, and pre-configured services.

## Development Commands

### Environment Setup
```bash
# Development environment
./scripts/run_dev.sh

# Staging environment
./scripts/run_staging.sh

# Production environment
./scripts/run_prod.sh
```

### Build and Deployment
```bash
# Generate environment files
flutter packages pub run build_runner build

# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

### Testing and Quality
```bash
# Run tests
flutter test

# Run lints
flutter analyze

# Format code
flutter format .
```

## Architecture Overview

### Core Structure
- **GetX Pattern**: State management with reactive programming using `GetxController`
- **Service Layer**: Centralized services in `lib/services/` for analytics, storage, notifications
- **CMS System**: Simplified content management in `lib/core/cms/` with `AppSettings` and `SimpleContent`
- **Shared Components**: Reusable UI widgets in `lib/shared/widgets/` with iOS-native styling

### Key Architectural Decisions

#### CMS Simplification for MVP
The original complex feature flag system has been simplified to:
- `AppSettings`: Simple boolean toggles for features
- `SimpleContent`: Centralized text content with key-based access
- `CMSProvider`: Lightweight provider for configuration access

#### Service Integration
Services are initialized in `main.dart` and accessed through dependency injection:
- **Supabase**: Backend-as-a-Service for auth and database
- **Analytics**: Amplitude integration with conditional tracking
- **Notifications**: OneSignal for push, local notifications for reminders
- **Storage**: Secure local storage for data persistence

#### Component Library Structure
40+ UI components organized by category:
- **Inputs**: Text, email, password, phone with validation
- **Buttons**: Primary, outlined, destructive, icon variants
- **Lists**: Sections, tiles, scrollable containers
- **Cards**: Info, action, system cards with consistent styling
- **Navigation**: App bars, bottom bars, tab controls

### Data Flow Patterns

#### Controller Pattern
```dart
class ExampleController extends GetxController {
  // Observable state
  final RxList<Model> items = <Model>[].obs;

  // Service dependencies
  final ServiceClass _service = ServiceClass();

  // Business logic methods
  Future<void> loadData() async { ... }
}
```

#### CMS Usage Pattern
```dart
// Feature flags
if (AppSettings.enableAnalytics) { ... }

// Text content
SimpleContent.getText('errors.network')

// Through provider
CMSProvider.instance.getErrorMessage('network')
```

## Environment Configuration

### Required Environment Variables
Create `.env` file in project root:
```
SUPABASE_URL=your-supabase-project-url
SUPABASE_ANON_KEY=your-supabase-anon-key
GOOGLE_MAP_KEY=your-google-maps-api-key
```

### Runtime Environment Detection
Environment is determined through dart-define flags in run scripts, affecting:
- API endpoints
- Debug settings
- Feature availability

## Key Integration Points

### Supabase Integration
- Authentication through `SupabaseAuthService`
- Database operations through `SupabaseDatabaseService`
- File storage through `SupabaseStorageService`

### Analytics Integration
- Amplitude events tracked conditionally based on `AppSettings.enableAnalytics`
- User properties and session management
- Custom event definitions in controllers

### Navigation System
- GetX route management in `app_routes.dart`
- Initial route determination based on auth state
- Route protection through permission system

## Component Usage Guidelines

Reference `COMPONENTS_GUIDE.md` for detailed component selection by screen type. Key principles:
- Use `Fast*` components for consistent iOS/Android styling
- Group related components with `FastListSection`
- Follow established patterns for common screen types (auth, dashboard, forms)

## Development Conventions

### File Organization
- Controllers in `features/[feature]/controllers/`
- Models in `features/[feature]/models/`
- Screens in `features/[feature]/screens/`
- Shared components in `shared/widgets/[category]/`

### Naming Conventions
- Controllers: `[Feature]Controller`
- Models: `[Entity]Model`
- Services: `[Purpose]Service`
- Widgets: `Fast[ComponentType]`

### State Management
- Use `Obx()` for reactive UI updates
- Keep controllers focused on single responsibility
- Initialize dependencies in controller constructors

## Testing Strategy

### Unit Testing
- Test business logic in controllers
- Mock service dependencies
- Focus on data transformation and validation

### Widget Testing
- Test component behavior and rendering
- Verify accessibility properties
- Test responsive layouts

## Performance Considerations

- Lazy loading with `Get.lazyPut()` for services
- Image caching through `ImageCacheService`
- Efficient list rendering with `FastSliverList` for large datasets
- Conditional feature loading based on `AppSettings` flags

## Onboarding System

FastApp includes a flexible onboarding system with two types for different use cases:

### Simple Onboarding (FastOnboardingScreen)
Use for information-only flows without user interaction:
```dart
import 'package:faithlock/features/onboarding/export.dart';

// Direct navigation
Get.to(() => FastOnboardingScreen());

// Or using helper
OnboardingHelper.launchSimple();
```

### Interactive Onboarding (FastInteractiveOnboardingScreen)
Use when you need user input, permissions, or data collection:
```dart
import 'package:faithlock/features/onboarding/export.dart';

// Direct navigation
Get.to(() => FastInteractiveOnboardingScreen());

// Or using helper with smart detection
OnboardingHelper.smartLaunch(
  needsUserInput: true,
  needsPermissions: true,
);
```

### Decision Helper
The `OnboardingHelper` class provides automatic selection:
```dart
// Automatic selection based on requirements
OnboardingHelper.launch(needsUserInteraction: true);  // → Interactive
OnboardingHelper.launch(needsUserInteraction: false); // → Simple

// Smart launcher with detailed requirements
OnboardingHelper.smartLaunch(
  needsUserInput: false,
  needsPermissions: true,    // Will choose Interactive
  needsPreferences: false,
  needsConfiguration: false,
);
```

### Backend Integration
Interactive onboarding supports automatic data processing:
```dart
// Override in FastInteractiveOnboardingController
Future<void> _processActionResult(ActionResult result) async {
  switch (result.actionId) {
    case 'username':
      await userService.updateProfile({'name': result.value});
      break;
    case 'preferences':
      await userService.savePreferences(result.value);
      break;
  }
}
```

See `/lib/features/onboarding/README.md` for complete usage guide.
