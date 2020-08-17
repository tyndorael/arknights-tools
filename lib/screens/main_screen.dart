import 'package:arknightstools/screens/building/building_skills_screen.dart';
import 'package:arknightstools/screens/recruitment/recruitment_automatic_screen.dart';
import 'package:flutter/material.dart';

import 'package:arknightstools/config/flavor_config.dart';
import 'package:arknightstools/screens/settings_screen.dart';
import 'package:arknightstools/widgets/flavor_banner.dart';
import 'package:arknightstools/screens/help_screen.dart';
import 'package:arknightstools/screens/recruitment/recruitment_manual_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PageController _pageController;
  int _page = 0;

  List drawerItems = [
    {
      "icon": Icons.add_photo_alternate,
      "name": "Automatic Recruitment",
    },
    {
      "icon": Icons.border_color,
      "name": "Manual Recruitment",
    },
    { "icon": Icons.build,
    "name": "Building Skills"},
    {"icon": Icons.help, "name": "Help"},
    {"icon": Icons.info, "name": "About"}
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return FlavorBanner(
      child: Scaffold(
        appBar: AppBar(
          title: Text(FlavorConfig.instance.values.appName),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: Text(
                  "Welcome!",
                  style: Theme.of(context).textTheme.headline1,//TextStyle(color: Colors.white, fontSize: 20.0),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: drawerItems.length,
                itemBuilder: (BuildContext context, int index) {
                  Map item = drawerItems[index];
                  return ListTile(
                    leading: Icon(
                      item['icon'],
                      color: _page == index
                          ? Theme.of(context).accentColor
                          : Theme.of(context).textTheme.headline6.color,
                    ),
                    title: Text(
                      item['name'],
                      style: TextStyle(
                        color: _page == index
                            ? Theme.of(context).accentColor
                            : Theme.of(context).textTheme.headline6.color,
                      ),
                    ),
                    onTap: () {
                      _pageController.jumpToPage(index);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        ),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: <Widget>[
            RecruitmentAutomaticScreen(),
            RecruitmentManualScreen(),
            BuildingSkillsScreen(),
            HelpScreen(),
            SettingsScreen(),
          ],
        ),
      ),
    );
  }
}
