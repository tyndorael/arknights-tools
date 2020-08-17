import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsUtils {
  // FirebaseAnalytics constructor reuses a single instance, so it's ok to call like this
  static void setCurrentScreen({String screenName}) =>
      FirebaseAnalytics().setCurrentScreen(screenName: screenName);

  static void logEvent({@required String name, Map<String, dynamic> data}) {
    if (data != null) {
      FirebaseAnalytics().logEvent(
        name: name,
        parameters: data != null ? data : null,
      );
    } else {
      FirebaseAnalytics().logEvent(
        name: name,
      );
    }
  }
}
