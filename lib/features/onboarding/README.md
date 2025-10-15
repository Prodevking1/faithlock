# FastApp Onboarding System

Simple onboarding system with two types for different needs.

## Two Onboarding Types

### 1. FastOnboardingScreen (Simple)
**File:** `fast_onboarding_screen.dart`
**Controller:** `OnboardingController`

**Use when:**
- ✅ Just showing information
- ✅ No user input needed
- ✅ No permissions to request
- ✅ Simple app introduction

```dart
Get.to(() => const FastOnboardingScreen());
```

### 2. FastInteractiveOnboardingScreen (With Actions)
**File:** `fast_interactive_onboarding_screen.dart`
**Controller:** `FastInteractiveOnboardingController`

**Use when:**
- ✅ Need user preferences
- ✅ Request permissions
- ✅ Collect user data
- ✅ Settings configuration

```dart
Get.to(() => const FastInteractiveOnboardingScreen());
```

## Decision: Which One to Use?

### Simple Questions:
1. **Do you need user input?** → Interactive
2. **Do you need permissions?** → Interactive  
3. **Just showing app features?** → Simple

### Examples:

**Music App (Interactive):**
```dart
// Needs: genres, permissions, username
Get.to(() => const FastInteractiveOnboardingScreen());
```

**News App (Simple):**
```dart
// Just: welcome, features, benefits
Get.to(() => const FastOnboardingScreen());
```

## Interactive Setup

```dart
// 1. Define steps with actions
static List<OnboardingStep> get steps => [
  OnboardingStep(
    title: 'Choose Your Music',
    description: 'Select your favorite genres',
    icon: Icons.music_note,
    actions: [
      InteractiveAction(
        id: 'genres',
        type: InteractiveActionType.selection,
        title: 'Favorite Genres',
        options: ['Rock', 'Pop', 'Jazz'],
        isMultiSelect: true,
      ),
    ],
    requiresActions: true,
  ),
];

// 2. Navigate
Get.to(() => const FastInteractiveOnboardingScreen());
```

## Backend Integration

Process user data in the interactive controller:

```dart
Future<void> _processActionResult(ActionResult result) async {
  switch (result.actionId) {
    case 'genres':
      final genres = result.value as List<String>?;
      await musicService.saveGenres(genres);
      break;
    case 'username':
      final name = result.value as String?;
      await userService.updateName(name);
      break;
  }
}
```

## Quick Decision Helper

```dart
class OnboardingHelper {
  static void launch({required bool needsUserInteraction}) {
    if (needsUserInteraction) {
      Get.to(() => const FastInteractiveOnboardingScreen());
    } else {
      Get.to(() => const FastOnboardingScreen());
    }
  }
}

// Usage
OnboardingHelper.launch(needsUserInteraction: true);  // Interactive
OnboardingHelper.launch(needsUserInteraction: false); // Simple
```

## Action Types

### Selection
```dart
InteractiveAction(
  id: 'preferences',
  type: InteractiveActionType.selection,
  options: ['Option 1', 'Option 2'],
  isMultiSelect: true,
)
```

### Input
```dart
InteractiveAction(
  id: 'username',
  type: InteractiveActionType.input,
  title: 'Enter Username',
  placeholder: 'Your username',
)
```

### Permission
```dart
InteractiveAction(
  id: 'notifications',
  type: InteractiveActionType.permission,
  permissionTypes: [PermissionType.pushNotifications],
)
```

### Toggle
```dart
InteractiveAction(
  id: 'dark_mode',
  type: InteractiveActionType.toggle,
  title: 'Enable Dark Mode',
)
```

That's it! Two types, clear choice.