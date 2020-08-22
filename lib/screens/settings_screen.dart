import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

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

  _launchTwitterURL() async {
    const url = 'https://twitter.com/tyndorael';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchGithubIssuesUrl() async {
    const url = 'https://github.com/tyndorael/arknights-tools/issues';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
          SizedBox(
            height: 10.0,
          ),
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
          SizedBox(
            height: 10.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  "Contact",
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
          ListTile(
            enabled: false,
            title: Text(
              "Twitter",
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            trailing: ClipOval(
              child: Material(
                color: Colors.blue,
                child: InkWell(
                  splashColor: Theme.of(context).accentColor,
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: Icon(
                      EvaIcons.twitter,
                      color: Colors.white,
                    ),
                  ),
                  onTap: _launchTwitterURL,
                ),
              ),
            ),
          ),
          ListTile(
            enabled: false,
            title: Text(
              "Github",
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            trailing: ClipOval(
              child: Material(
                color: Colors.black,
                child: InkWell(
                  splashColor: Theme.of(context).accentColor,
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: Icon(
                      EvaIcons.github,
                      color: Colors.white,
                    ),
                  ),
                  onTap: _launchGithubIssuesUrl,
                ),
              ),
            ),
          ),
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
