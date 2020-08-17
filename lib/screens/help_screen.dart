import 'dart:io';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';

import 'package:arknightstools/config/flavor_config.dart';
import 'package:arknightstools/utils/analytics/Analytics.dart';
import 'package:arknightstools/utils/analytics/Tags.dart';

const String testDevice = '91DD14EC32F7E146887917ABB9FB3660';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null
        ? <String>['91DD14EC32F7E146887917ABB9FB3660']
        : null,
    keywords: <String>['game', 'arknights', 'mobile'],
    childDirected: true,
    nonPersonalizedAds: true,
  );
  BannerAd _bannerAd;

  String getAppId() {
    if (Platform.isIOS) {
      return 'IOS_APP_ID';
    } else if (Platform.isAndroid) {
      return FlavorConfig.instance.values.admobAndroidId;
    }
    return null;
  }

  @override
  void initState() {
    FirebaseAdMob.instance.initialize(appId: getAppId());
    _bannerAd = createBannerAd()
      ..load()
      ..show(
        anchorType: AnchorType.bottom,
        anchorOffset: 0.0,
        horizontalCenterOffset: 0.0,
      );
    AnalyticsUtils.setCurrentScreen(screenName: Tags.HELP_SCREEN_NAME);
    super.initState();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: FlavorConfig.isProduction()
          ? 'ca-app-pub-3854977390540746/3045807182'
          : BannerAd.testAdUnitId,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle textLabelStyle = TextStyle(
      fontSize: 15.0,
      color: Colors.black87,
    );

    return Scaffold(
      backgroundColor: Color(0xFFEAEAEA),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            const Text(
              'This is an app for helping you to know which operator you can get with the recruit option ingame.',
              style: textLabelStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10.0,
            ),
            Center(
              child: const Text(
                'I hope you can get the operator you want 😸',
                style: TextStyle(
                  fontSize: 17.0,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            const ListTile(
              leading: Icon(
                Icons.add_photo_alternate,
                color: Colors.black87,
              ),
              title: const Text(
                'In the first menu option you can see what operators you can get from a screenshot in-game... for example:',
                style: textLabelStyle,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Image.asset(
              'assets/example/recruitment_screen.jpg',
              width: 380.0,
            ),
            SizedBox(
              height: 10.0,
            ),
            const ListTile(
              leading: Icon(
                Icons.border_color,
                color: Colors.black87,
              ),
              title: const Text(
                'In the second menu, you can select tags and check which operators you can get.',
                style: textLabelStyle,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            const ListTile(
              leading: Icon(
                Icons.build,
                color: Colors.black87,
              ),
              title: const Text(
                'In the third menu, you can see the skills of the operators for each building in the base as well as how to unlock them.',
                style: textLabelStyle,
              ),
            ),
            SizedBox(
              height: 70.0,
            ),
          ],
        ),
      ),
    );
  }
}
