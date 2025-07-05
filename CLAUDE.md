# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter mobile application called "freego_flutter" - a social travel platform with features including:
- Video sharing and streaming
- Social networking (friends, groups, chat)
- Travel planning and booking (hotels, restaurants, scenic spots)
- E-commerce integration
- Payment processing
- Map integration (Amap/Gaode Maps)
- WeChat SDK integration

## Development Commands

### Core Flutter Commands
```bash
# Install dependencies
flutter pub get

# Run the app in development mode
flutter run

# Build for Android
flutter build apk

# Build for iOS
flutter build ios

# Clean build artifacts
flutter clean

# Analyze code for issues
flutter analyze

# Run tests
flutter test

# Update dependencies
flutter pub upgrade

# Generate code (for freezed, json_serializable)
flutter packages pub run build_runner build

# Watch for changes and regenerate code
flutter packages pub run build_runner watch
```

### Code Generation
The project uses code generation for:
- JSON serialization (`json_serializable`)
- Immutable data classes (`freezed`)
- Localizations (`flutter_intl`)

Run `flutter packages pub run build_runner build` after modifying model classes or adding new translations.

## Architecture

### State Management
- **Primary**: Flutter Riverpod for state management
- **Provider Location**: `lib/provider/` (currently contains `user_provider.dart`)
- **Pattern**: Uses Riverpod providers for reactive state management

### Project Structure
```
lib/
├── components/           # UI components organized by feature
│   ├── chat_group/      # Group chat functionality
│   ├── chat_neo/        # Individual chat
│   ├── video/           # Video streaming and playback
│   ├── user/            # User authentication and profile
│   ├── hotel_neo/       # Hotel booking
│   ├── restaurant/      # Restaurant features
│   ├── scenic/          # Scenic spots
│   ├── travel/          # Travel planning
│   ├── wallet/          # Payment and wallet
│   └── ...
├── config/              # Configuration constants
├── data/                # Data layer
├── http/                # HTTP client and API calls
├── l10n/                # Localization files
├── local_storage/       # Local storage utilities
├── manager/             # Business logic managers
├── model/               # Data models
├── provider/            # Riverpod providers
├── util/                # Utility functions
└── main.dart           # Application entry point
```

### Key Dependencies
- **State Management**: `flutter_riverpod`
- **HTTP Client**: `dio`
- **Local Storage**: `shared_preferences`, `sqflite`
- **Media**: `video_player`, `image_picker`, `camera`
- **Maps**: `amap_flutter_map`, `amap_flutter_location`
- **WeChat Integration**: `fluwx`
- **Payments**: `in_app_purchase`, `flutter_inapp_purchase`
- **Video Processing**: `ffmpeg_kit_flutter_video`, `video_compress`

### Configuration
- **API Keys**: Stored in `lib/config/const_config.dart`
- **WeChat SDK**: Configured with App ID `wxc17e18662283c752`
- **Deep Links**: Handled via `uni_links` package
- **Maps**: Uses Amap (Gaode) with separate Android/iOS keys

### Navigation
- Uses named routes defined in `main.dart`
- Supports deep linking for video content (`/video/{id}`)
- Route observer for analytics: `RouteObserverUtil.instance.routeObserver`

### Platform-Specific Notes
- **Android**: Uses `TextInputBinding()` for input handling
- **iOS**: Requires additional configuration for:
  - Image picker permissions
  - Location services
  - Camera permissions
  - WeChat SDK setup

### Testing
- Uses `flutter_test` framework
- Run tests with `flutter test`
- No custom test configuration detected

### Code Quality
- Follows `flutter_lints` standards
- Analysis options in `analysis_options.yaml`
- Uses standard Flutter formatting

### Asset Management
Multiple asset directories:
- `assets/` - General assets
- `images/` - Image assets
- `svg/` - Vector graphics
- Feature-specific subdirectories for organized assets

## Important Notes

- This is a complex social travel application with numerous third-party integrations
- WeChat SDK integration requires proper setup on both platforms
- Map functionality depends on Amap/Gaode Maps configuration
- Payment features use both Apple and Google in-app purchase systems
- Video processing uses FFmpeg for compression and editing
- Deep linking is configured for video content sharing