import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:arknightstools/app/main.dart';
import 'package:arknightstools/config/flavor_config.dart';

void main() {
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  FlavorConfig(
    flavor: Flavor.DEV,
    color: Colors.green,
    values: FlavorValues(
      appName: "Arknights Tools",
      baseUrl: "http://10.0.2.2:4000/v1",
      admobAndroidId: "ca-app-pub-3854977390540746~9644958839",
    ),
  );
  runApp(MyApp());
}
