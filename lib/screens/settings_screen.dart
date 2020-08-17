import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'package:arknightstools/config/flavor_config.dart';
import 'package:arknightstools/utils/Consts.dart';
import 'package:arknightstools/utils/analytics/Analytics.dart';
import 'package:arknightstools/utils/analytics/Tags.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    AnalyticsUtils.setCurrentScreen(screenName: Tags.ABOUT_SCREEN_NAME);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Consts.backgroundColor,
      body: ListView(
        padding: EdgeInsets.only(
          top: Consts.padding,
        ),
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                FlavorConfig.instance.values.appName,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 25.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          ListTile(
            title: Text(
              "Dr.",
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            trailing: Text(
              "Tyndorael#6728",
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
          // ...
          // A title for the subsection:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  "About",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                ),
              ),
              Divider(
                color: Colors.black26,
              ),
            ],
          ),
          // The version tile :
          ListTile(
            enabled: false,
            title: Text(
              "Version",
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            trailing: FutureBuilder(
              future: getVersionNumber(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) =>
                  Text(
                snapshot.hasData ? snapshot.data : "Loading ...",
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          // ...
        ],
      ),
    );
  }

  Future<String> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    return version;
  }
}
