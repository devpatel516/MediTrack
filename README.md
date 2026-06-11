# MediTrack Frontend

MediTrack is a Flutter-based medical visit tracking app for doctors and patients.

- Doctors can log in, create visit records, add prescriptions, set follow-up dates, and use voice-to-text with AI-assisted note extraction.
- Patients can log in, review their medical history, view prescriptions, and receive appointment reminder notifications.

This repository contains the Flutter frontend. The backend lives in a separate repository:

[MediTrack Backend](https://github.com/devpatel516/MediTrack-Backend)

## Project Summary

The app supports two user roles:

- `Doctor`: create and manage patient visit records.
- `Patient`: view visit history, notes, medicines, and next appointment details.

Main functionality included in this frontend:

- Authentication for doctor and patient users
- Doctor dashboard for creating visit records
- Voice dictation using `speech_to_text`
- AI-assisted diagnosis/notes extraction through the backend API
- Prescription and follow-up date entry
- Patient medical history view
- Local appointment reminder notifications

## Backend Setup First

Start the backend before running this Flutter app.

1. Open the backend repository: [devpatel516/MediTrack-Backend](https://github.com/devpatel516/MediTrack-Backend)
2. Follow the backend README to install dependencies, configure environment variables, and start the server
3. Confirm the backend is running properly
4. Then come back to this repository and start the Flutter frontend

## Prerequisites

Make sure you have:

- Flutter SDK installed
- Dart SDK installed
- Android Studio or VS Code with Flutter support
- An Android emulator, iOS simulator, or physical device

To verify Flutter is ready:

```bash
flutter doctor
```

## Installation

1. Clone this repository

```bash
git clone <this-repo-url>
cd internship
```

2. Install Flutter dependencies

```bash
flutter pub get
```

3. Run the app

```bash
flutter run
```

## API Configuration

The frontend currently points to this backend base URL in `lib/api_service.dart`:

```dart
static const String baseUrl = 'https://meditrack-api-gxb1.onrender.com/api';
```

If you want to use your local backend instead, update the `baseUrl` value in [lib/api_service.dart] to match your local server URL.

Example:

```dart
static const String baseUrl = 'http://localhost:5000/api';
```

Note: if you test on a physical phone or Android emulator, `localhost` may need to be replaced with your machine IP or emulator-specific host.

## Useful Commands

```bash
flutter pub get
flutter run
flutter test
flutter clean
```

## Tech Stack

- Flutter
- Dart
- `provider`
- `http`
- `flutter_secure_storage`
- `speech_to_text`
- `awesome_notifications`

## Project Structure

```text
lib/
  api_service.dart
  auth_provider.dart
  main.dart
  screens/
    auth_check.dart
    doctor_appointments_screen.dart
    doctor_dashboard.dart
    login_screen.dart
    patient_dashboard.dart
    register_screen.dart
    splash_screen.dart
```

## Notes

- Secure tokens are stored using `flutter_secure_storage`
- Notifications are used for appointment reminders
- AI note extraction depends on backend support being available

