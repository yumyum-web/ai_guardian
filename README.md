# AI Guardian

A woman's safety app.

## Table of Contents

- [About](#about)
- [Project File Structure](#project-file-structure)
- [Setup](#setup)
- [Tech Stack](#tech-stack)
- [Features](#features)

## About

`ai_guardian` is a Flutter-based mobile application designed to enhance women's safety by providing
features like SOS alerts, emergency SMS, location tracking, and more.

## Project File Structure

```
ai_guardian/
├── android/                # Android-specific files
├── assets/                 # App assets (images, icons, etc.)
│   └── images/             # Image assets
├── lib/                    # Main application code
│   ├── enums/              # Enumerations
│   ├── screens/            # UI screens
│   ├── widgets/            # Reusable widgets
│   ├── models/             # Data models
│   ├── services/           # Backend and API services
│   └── main.dart           # Application entry point
├── test/                   # Unit, widget and integration tests
├── .gitignore              # Git ignore file
├── .metadata               # Flutter project metadata
├── analysis_options.yaml   # Dart analysis options
├── devtools_options.json   # DevTools options
├── firebase.json           # Firebase configuration
├── pubspec.yaml            # Project dependencies and assets
└── README.md               # Project documentation
```

## Setup

Follow these steps to set up the project locally:

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd ai_guardian
   ```
2. Install Flutter and ensure it is added to your PATH. Refer to
   the [Flutter installation guide](https://flutter.dev/docs/get-started/install).
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Tech Stack

- **Framework**: Flutter
- **Programming Language**: Dart
- **State Management**: Provider (or any other state management library if used)
- **Backend**: Firebase (Authentication, Firestore)
- **APIs**: Google Maps API, Geolocator
- **Other Libraries**:
    - `shared_preferences` for local storage
    - `cached_network_image` for optimized image loading
    - `carousel_slider` for image sliders
    - `qr_flutter` for QR code generation
    - `mobile_scanner` for QR code scanning

## Features

- SOS alerts with location sharing
- Emergency SMS to pre-configured contacts
- Location tracking with Google Maps
- QR code generation and scanning
- Help bot for quick assistance
- Family and support contact management
