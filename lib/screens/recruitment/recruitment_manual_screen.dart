import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arknightstools/services/tags.dart';
import 'package:arknightstools/utils/Server.dart';
import 'package:arknightstools/utils/Tag.dart';
import 'package:arknightstools/utils/analytics/Analytics.dart';
import 'package:arknightstools/utils/analytics/Tags.dart';
import 'package:arknightstools/services/recruitment.dart';
import 'package:arknightstools/widgets/custom_dialog.dart';
import 'package:arknightstools/widgets/help_dialog.dart';
import 'package:arknightstools/widgets/loading.dart';
import 'package:arknightstools/widgets/operators_dialog.dart';

class RecruitmentManualScreen extends StatefulWidget {
  RecruitmentManualScreen({Key key}) : super(key: key);

  @override
  _RecruitmentManualScreenState createState() =>
      _RecruitmentManualScreenState();
}

class _RecruitmentManualScreenState extends State<RecruitmentManualScreen> {
  bool isLoading = true;
  bool hasTagError = false;
  List<Tag> selectedTags = [];
  Server selectedServer = Server.servers[0];
  Future<RecruitmentData> recruitmentData;

  @override
  void initState() {
    AnalyticsUtils.setCurrentScreen(
        screenName: Tags.MANUAL_RECRUITMENT_SCREEN_NAME);
    Future.delayed(const Duration(milliseconds: 500), () {
      loadTagsByLocale();
    });
    super.initState();
  }

  addStringToSharedPreferences(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  void loadTagsByLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String locale = prefs.getString('selectedServerCode') ?? 'en';
    setState(() {
      isLoading = true;
      hasTagError = false;
      selectedServer =
          Server.servers.firstWhere((element) => element.code == locale);
    });
    AnalyticsUtils.logEvent(
      name: Tags.TAGS_REQUEST,
      data: <String, dynamic>{
        'locale': selectedServer.code,
      },
    );
    fetchTagsByLocale(locale).then((value) {
      AnalyticsUtils.logEvent(
        name: Tags.TAGS_REQUEST_SUCCESS,
      );
      selectedTags = value.map((t) => new Tag(t.id, t.name, false)).toList();
      // order EN tags
      if (selectedServer.code == 'en') {
        selectedTags.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      }
      setState(() {
        isLoading = false;
      });
    }, onError: (error) {
      setState(() {
        isLoading = false;
        hasTagError = true;
      });
      AnalyticsUtils.logEvent(
        name: Tags.TAGS_REQUEST_ERROR,
        data: <String, dynamic>{
          'error': error.toString(),
        },
      );
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CustomDialog(
          title: 'Error',
          description: 'Something bad happens when i tried to get tags.',
          icon: Icons.error,
          iconBackground: Colors.redAccent,
        ),
      );
    });
  }

  void loadCombinations() {
    List<int> tagsSelected = selectedTags
        .where((tag) => tag.isSelected)
        .map((tag) => tag.id)
        .toList();
    if (tagsSelected.isEmpty) {
      showCustomDialog(
          context, 'Warning', 'Please select at least one tag', Icons.warning);
      return;
    }
    setState(() {
      isLoading = true;
    });
    AnalyticsUtils.logEvent(
      name: Tags.MANUAL_RECRUITMENT_OPERATORS_REQUEST,
      data: <String, dynamic>{
        'tags': tagsSelected.toString(),
      },
    );
    recruitmentData =
        fetchRecruimentData(tags: tagsSelected, server: selectedServer);

    recruitmentData.then((result) {
      if (result.groups.isEmpty) {
        showCustomDialog(
            context, 'Not found', 'i can\'t find operators :(', Icons.warning);
        return;
      }
      if (result.groups.isEmpty) {
        return;
      }
      AnalyticsUtils.logEvent(
        name: Tags.MANUAL_RECRUITMENT_OPERATORS_LOADED,
        data: <String, dynamic>{
          'tags': tagsSelected.toString(),
        },
      );
      showOperatorsDialog(context, result);
      setState(() {
        isLoading = false;
      });
    }, onError: (error) {
      setState(() {
        isLoading = false;
      });
      AnalyticsUtils.logEvent(
        name: Tags.MANUAL_RECRUITMENT_OPERATORS_ERROR,
        data: <String, dynamic>{
          'error': error.toString(),
        },
      );
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CustomDialog(
          title: 'Error',
          description: 'Something bad happens when i tried to get operators.',
          icon: Icons.error,
          iconBackground: Colors.redAccent,
        ),
      );
    });
  }

  void showCustomDialog(
      BuildContext context, String title, String message, IconData icon) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => HelpDialog(
        title: title,
        description: message,
        icon: icon,
      ),
    );
  }

  void showOperatorsDialog(BuildContext context, RecruitmentData result) {
    if (result.groups.every((element) => element["operators"].length <= 0)) {
      showCustomDialog(
        context,
        'Not found',
        'No operator could be found with your tags',
        Icons.error,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => OperatorsDialog(
        operatorsFilteredByTags: result,
        allTags: selectedTags,
      ),
    );
  }

  void clearTags() {
    setState(() {
      selectedTags.map((p) => p.isSelected = false).toList();
    });
  }

  Widget showLoading() {
    return Container(
      padding: EdgeInsets.only(
        top: 100.0,
      ),
      child: Loading(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var serverSelect = DropdownButton<Server>(
      value: selectedServer,
      dropdownColor: Theme.of(context).backgroundColor,
      iconEnabledColor: Theme.of(context).primaryColor,
      onChanged: (Server server) {
        setState(() {
          selectedServer = server;
        });
      },
      items: Server.servers.map((Server server) {
        return DropdownMenuItem<Server>(
          value: server,
          child: Row(
            children: <Widget>[
              Text(
                server.name,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          onTap: () {
            setState(() {
              selectedServer = server;
            });
            AnalyticsUtils.logEvent(
              name: Tags.SERVER_CHANGE,
              data: <String, dynamic>{
                'to': selectedServer.code,
              },
            );
            addStringToSharedPreferences('selectedServerCode', server.code);
            loadTagsByLocale();
          },
        );
      }).toList(),
    );
    var listOfTagCheckboxes = [
      new Expanded(
        flex: 1,
        child: hasTagError
            ? Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: Theme.of(context).primaryColor,
                      ),
                      iconSize: 80.0,
                      onPressed: () {
                        loadTagsByLocale();
                      },
                    ),
                    Text(
                      'Show Tags',
                      style: Theme.of(context).textTheme.headline5,
                    )
                  ],
                ),
              )
            : ListView.builder(
                itemCount: selectedTags.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(
                      selectedTags[index].name,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    trailing: Checkbox(
                        checkColor: Theme.of(context).accentColor,
                        activeColor: Theme.of(context).primaryColor,
                        value: selectedTags[index].isSelected,
                        onChanged: (bool val) {
                          setState(() {
                            selectedTags[index].isSelected =
                                !selectedTags[index].isSelected;
                          });
                        }),
                    onTap: () {
                      setState(() {
                        selectedTags[index].isSelected =
                            !selectedTags[index].isSelected;
                      });
                    },
                  );
                },
              ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          serverSelect,
          new RaisedButton.icon(
            icon: Icon(Icons.search),
            color: Theme.of(context).primaryColor,
            disabledColor: Theme.of(context).accentColor,
            highlightColor: Colors.grey,
            splashColor: Colors.grey,
            colorBrightness: Brightness.dark,
            elevation: 8,
            highlightElevation: 2,
            onPressed: !hasTagError ? loadCombinations : null,
            label: new Text('Show Operators'),
          ),
          SizedBox(width: 2.0),
          new RaisedButton(
            color: Theme.of(context).primaryColor,
            disabledColor: Theme.of(context).accentColor,
            highlightColor: Colors.grey,
            splashColor: Colors.grey,
            colorBrightness: Brightness.dark,
            elevation: 8,
            highlightElevation: 2,
            onPressed: !hasTagError ? clearTags : null,
            child: new Text('Clear'),
          ),
          new IconButton(
            icon: Icon(Icons.help),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              showCustomDialog(
                context,
                'Help',
                'Now you can change the game server!. Just change it with the box in the bottom left.\nIf there is a problem with loading tags you can press the refresh button.\n\n(🌟): this operator is only obtainable by recruitment.\nFor example: Indra.',
                Icons.help,
              );
            },
          ),
        ],
      ),
    ];

    return new Container(
      padding: new EdgeInsets.all(8.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isLoading ? [showLoading()] : listOfTagCheckboxes,
      ),
    );
  }
}
