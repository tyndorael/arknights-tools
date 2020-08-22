import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:arknightstools/utils/Server.dart';
import 'package:arknightstools/utils/analytics/Analytics.dart';
import 'package:arknightstools/utils/analytics/Tags.dart';
import 'package:arknightstools/widgets/custom_dialog.dart';
import 'package:arknightstools/widgets/loading.dart';
import 'package:arknightstools/widgets/operator_buffs_tile.dart';
import 'package:arknightstools/services/building.dart';
import 'package:arknightstools/services/operators.dart';

class BuildingSkillsScreen extends StatefulWidget {
  @override
  _BuildingSkillsScreenState createState() => _BuildingSkillsScreenState();
}

class _BuildingSkillsScreenState extends State<BuildingSkillsScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  Server _selectedServer;
  List<Room> _rooms = [];
  List<Operator> _operators = [];
  List<Operator> _operatorsFilteredByRoom = [];
  Room _selectedRoom;
  TextEditingController _textController = TextEditingController();

  void firstLoad() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String locale =
          prefs.getString('selectedBuildingSkillServerCode') ?? 'en';
      AnalyticsUtils.logEvent(
        name: Tags.BUILDING_SKILLS_ROOMS_REQUEST,
        data: <String, dynamic>{
          'locale': locale,
        },
      );
      final rooms = await fetchRoomsByLocale(locale);
      AnalyticsUtils.logEvent(
        name: Tags.BUILDING_SKILLS_ROOMS_SUCCESS,
        data: <String, dynamic>{
          'locale': locale,
        },
      );
      AnalyticsUtils.logEvent(
        name: Tags.BUILDING_SKILLS_OPERATORS_REQUEST,
        data: <String, dynamic>{
          'locale': locale,
        },
      );
      final operators = await fetchOperatorsByLocale(locale, true);
      AnalyticsUtils.logEvent(
        name: Tags.BUILDING_SKILLS_OPERATORS_SUCCESS,
        data: <String, dynamic>{
          'locale': locale,
        },
      );
      setState(() {
        _rooms = rooms.where((element) => element.description != null).toList();
        _selectedServer =
            Server.servers.firstWhere((element) => element.code == locale);
        _operators = operators;
        _operatorsFilteredByRoom = operators;
        _isLoading = false;
        _hasError = false;
      });
    } catch (error) {
      AnalyticsUtils.logEvent(
        name: Tags.BUILDING_SKILLS_ROOMS_OPERATORS_ERROR,
        data: <String, dynamic>{
          'error': error.toString(),
        },
      );
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CustomDialog(
          title: 'Error',
          description: 'Something bad happens when i tried to get buildings.',
          icon: Icons.error,
          iconBackground: Colors.redAccent,
        ),
      );
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    AnalyticsUtils.setCurrentScreen(
        screenName: Tags.BUILDING_SKILLS_SCREEN_NAME);
    Future.delayed(const Duration(milliseconds: 500), () {
      firstLoad();
    });
    super.initState();
  }

  addStringToSharedPreferences(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  void selectServer(Server server) async {
    addStringToSharedPreferences(
        'selectedBuildingSkillServerCode', server.code);

    setState(() {
      _selectedServer = server;
      _selectedRoom = null;
      _isLoading = true;
      _hasError = false;
      _rooms = [];
      _operators = [];
      _operatorsFilteredByRoom = [];
    });

    try {
      AnalyticsUtils.logEvent(
        name: Tags.BUILDING_SKILLS_ROOMS_REQUEST,
        data: <String, dynamic>{
          'locale': server.code,
        },
      );
      final rooms = await fetchRoomsByLocale(server.code);
      AnalyticsUtils.logEvent(
        name: Tags.BUILDING_SKILLS_ROOMS_SUCCESS,
        data: <String, dynamic>{
          'locale': server.code,
        },
      );
      AnalyticsUtils.logEvent(
        name: Tags.BUILDING_SKILLS_OPERATORS_REQUEST,
        data: <String, dynamic>{
          'locale': server.code,
        },
      );
      final operators = await fetchOperatorsByLocale(server.code, true);
      AnalyticsUtils.logEvent(
        name: Tags.BUILDING_SKILLS_OPERATORS_SUCCESS,
        data: <String, dynamic>{
          'locale': server.code,
        },
      );
      setState(() {
        _rooms = rooms.where((element) => element.description != null).toList();
        _operators = operators;
        _operatorsFilteredByRoom = operators;
        _isLoading = false;
        _hasError = false;
      });
    } catch (error) {
      AnalyticsUtils.logEvent(
        name: Tags.BUILDING_SKILLS_ROOMS_OPERATORS_ERROR,
        data: <String, dynamic>{
          'error': error.toString(),
        },
      );
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void filterOperators() {
    if (_selectedRoom == null) {
      _operatorsFilteredByRoom = _operators;
      return;
    }

    setState(() {
      _operatorsFilteredByRoom = _operators
          .where((operator) => operator.buffs
              .where((buff) =>
                  buff.type == _selectedRoom.id ||
                  buff.category == _selectedRoom.id)
              .isNotEmpty)
          .toList();
    });
  }

  void onOperatorSearchChanged(String value) {
    if (_selectedRoom == null) {
      if (value.isEmpty) {
        setState(() {
          _operatorsFilteredByRoom = _operators.toList();
        });
      } else {
        setState(() {
          _operatorsFilteredByRoom = _operators
              .where((operator) =>
                  operator.name.toLowerCase().contains(value.toLowerCase()))
              .toList();
        });
      }
    } else {
      if (value.isEmpty) {
        filterOperators();
      } else {
        setState(() {
          _operatorsFilteredByRoom = _operatorsFilteredByRoom
              .where((operator) =>
                  operator.name.toLowerCase().contains(value.toLowerCase()))
              .toList();
        });
      }
    }
  }

  Widget showLoading() {
    return Center(
      child: Loading(),
    );
  }

  Widget showReload() {
    return Container(
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
              firstLoad();
            },
          ),
          Text(
            'Refresh',
            style: Theme.of(context).textTheme.headline5,
          )
        ],
      ),
    );
  }

  Widget showNotFound() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return showLoading();
    }

    if (_hasError) {
      return showReload();
    }

    var dropdownButtons = _rooms.isNotEmpty
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'Server:',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              DropdownButton<Server>(
                value: _selectedServer,
                dropdownColor: Theme.of(context).backgroundColor,
                iconEnabledColor: Theme.of(context).primaryColor,
                onChanged: (Server server) {
                  setState(() {
                    _selectedServer = server;
                  });
                },
                items: Server.servers.map((Server server) {
                  return DropdownMenuItem<Server>(
                    value: server,
                    child: Row(
                      children: <Widget>[
                        Text(
                          server.name,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      selectServer(server);
                    },
                  );
                }).toList(),
              ),
              Text(
                'Building:',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              DropdownButton(
                dropdownColor: Theme.of(context).backgroundColor,
                iconEnabledColor: Theme.of(context).primaryColor,
                hint: Text(
                  "All",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                value: _selectedRoom,
                items: _rooms.map((item) {
                  return DropdownMenuItem(
                    child: Text(
                      item.name,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    value: item,
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRoom = value;
                  });
                  filterOperators();
                },
              ),
            ],
          )
        : Container();

    var roomDescription = _selectedRoom != null
        ? Text(
            _selectedRoom.description,
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
          )
        : Container();

    var searchOperatorByName = TextField(
      controller: _textController,
      style: TextStyle(color: Theme.of(context).primaryColor),
      decoration: InputDecoration(
        hintText: 'Search Operator Here...',
        hintStyle: TextStyle(color: Theme.of(context).primaryColor),
        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        helperStyle: TextStyle(color: Theme.of(context).primaryColor),
      ),
      onChanged: onOperatorSearchChanged,
    );

    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            dropdownButtons,
            roomDescription,
            searchOperatorByName,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: _operatorsFilteredByRoom.isNotEmpty
                    ? ListView.separated(
                        itemCount: _operatorsFilteredByRoom.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(
                          height: 3.0,
                          color: Theme.of(context).primaryColor,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return OperatorBuffsTile(
                              operator: _operatorsFilteredByRoom[index]);
                        },
                      )
                    : showNotFound(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
