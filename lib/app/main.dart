import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:arknightstools/screens/main_screen.dart';

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arknights Tools',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        accentColor: Colors.cyan[600],
        unselectedWidgetColor: Colors.black,

        // Define the default font family.
        fontFamily: 'Roboto',

        backgroundColor: Color(0xFFEAEAEA),

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.cyan[600],
          ),
          headline4: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic, color: Colors.black,),
          headline5: TextStyle(fontSize: 17.0, color: Colors.black,),
          headline6: TextStyle(fontSize: 18.0, fontStyle: FontStyle.italic,),
          bodyText2: TextStyle(fontSize: 16.0, fontFamily: 'Hind',),
        ),
      ),
      navigatorObservers: <NavigatorObserver>[observer],
      home: MainScreen(),
    );
  }
}
