# Arknights Tools

A new mobile app for doctors.

## Information

For this application I use Flutter and Firebase ML Kit for text recognition.

## Getting Started

Just clone the project and let the vscode get all packages.

## Libraries

* Flutter Spinkit - A collection of animated loading indicators for flutter

## Nice to have

* ~~Recruit for multiple servers.~~
* ~~Show if an operator can only get it from recruitment.~~
* Sanity calculator.
* ~~Fix flutter production bug. (Crash when it goes to background and system kill it).~~
* Farm Orundum (1-7 map).
* Users can send suggestions.
* ~~Use Kubernetes for backend.~~
* ~~Show operators for each base facility.~~

## Create launcher icons

```bash
flutter pub run flutter_launcher_icons:main
```

## Tools

Create screenshots for Google Play <https://www.appstorescreenshot.com/>

## Running

```bash
flutter run -t lib/main_dev.dart
```

```bash
flutter run -t lib/main_qa.dart
```

```bash
flutter run -t lib/main_production.dart
```

## Clean

```bash
flutter clean
```

## Build

### Production

Create app bundle for the release:

```bash
flutter build appbundle -t lib/main_production.dart
```

## Useful links

* Flutter production issue.
  * <https://github.com/flutter/flutter/issues/47635>
* Add proguard for Flutter.
  * <https://medium.com/@swav.kulinski/flutter-and-android-obfuscation-8768ac544421>
  * <https://flutter-es.io/docs/deployment/android>
* Use proguard with Firebase.
  * <https://stackoverflow.com/questions/51912130/flutter-build-crashes-using-proguard-with-firebase-auth>
