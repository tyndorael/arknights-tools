import 'dart:io';
import 'package:arknightstools/utils/Server.dart';
import 'package:arknightstools/widgets/operators_dialog.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

import 'package:arknightstools/widgets/loading.dart';
import 'package:arknightstools/widgets/custom_dialog.dart';
import 'package:arknightstools/utils/analytics/Analytics.dart';
import 'package:arknightstools/utils/analytics/Tags.dart';
import 'package:arknightstools/utils/Tag.dart';
import 'package:arknightstools/widgets/automatic_recruitment_help_dialog.dart';
import 'package:arknightstools/services/recruitment.dart';

class RecruitmentAutomaticScreen extends StatefulWidget {
  @override
  _RecruitmentAutomaticScreenState createState() =>
      _RecruitmentAutomaticScreenState();
}

class _RecruitmentAutomaticScreenState
    extends State<RecruitmentAutomaticScreen> {
  final picker = ImagePicker();
  bool isLoading = false;
  bool isImageLoaded = false;
  File pickedImage;
  List<Tag> tagsFromImage = [];
  Future<RecruitmentData> recruitmentData;
  RecruitmentData result;

  @override
  void initState() {
    AnalyticsUtils.setCurrentScreen(
        screenName: Tags.AUTOMATIC_RECRUITMENT_SCREEN_NAME);
    super.initState();
  }

  Future<PermissionStatus> requestPermission(Permission permission) async {
    final status = await permission.request();
    return status;
  }

  Future pickImage() async {
    setState(() {
      isLoading = true;
      pickedImage = null;
      isImageLoaded = false;
      tagsFromImage = [];
    });
    try {
      AnalyticsUtils.logEvent(
        name: Tags.AUTOMATIC_RECRUITMENT_PICK_SCREENSHOT,
      );
      var storagePermissionStatus = await Permission.storage.status;
      // check storage permission... image picker bug
      if (storagePermissionStatus.isUndetermined ||
          storagePermissionStatus.isDenied) {
        storagePermissionStatus = await requestPermission(Permission.storage);
      }

      File temStore;
      if (storagePermissionStatus.isGranted) {
        final pickedFile = await picker.getImage(source: ImageSource.gallery);
        temStore = File(pickedFile.path);
      } else {
        AnalyticsUtils.logEvent(
          name: Tags.AUTOMATIC_RECRUITMENT_PICK_SCREENSHOT_ERROR,
          data: <String, dynamic>{
            'error': 'error storage permission',
          },
        );
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => CustomDialog(
            title: 'Error',
            description:
                'Something bad happens when i tried to select a screenshot. You can use the manual recruitment if you want. 😢',
            icon: Icons.error,
            iconBackground: Colors.redAccent,
          ),
        );
        return;
      }

      if (temStore == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      setState(() {
        pickedImage = temStore;
        isImageLoaded = true;
      });
      AnalyticsUtils.logEvent(
          name: Tags.AUTOMATIC_RECRUITMENT_PICK_SCREENSHOT_SUCCESS);
      recognizeText();
    } catch (e) {
      AnalyticsUtils.logEvent(
        name: Tags.AUTOMATIC_RECRUITMENT_PICK_SCREENSHOT_ERROR,
        data: <String, dynamic>{
          'error': e.toString(),
        },
      );
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CustomDialog(
          title: 'Error',
          description:
              'Something bad happens when i tried to select a screenshot.',
          icon: Icons.error,
          iconBackground: Colors.redAccent,
        ),
      );
    }
  }

  Future recognizeText() async {
    if (!isImageLoaded) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
      TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
      VisionText readText = await recognizeText.processImage(ourImage);
      List<String> inputs = [];
      for (TextBlock block in readText.blocks) {
        for (TextLine line in block.lines) {
          for (TextElement word in line.elements) {
            inputs.add(word.text);
          }
        }
      }

      List<Tag> allTags = Tag.getTagsEN();
      List<Tag> auxTagsFromImage = [];

      inputs.forEach((input) {
        var index = allTags.indexWhere((element) => element.name == input);
        if (index != -1) {
          auxTagsFromImage.add(allTags[index]);
        }
      });

      Tag seniorOperator = allTags.firstWhere((element) => element.id == 14);
      Tag topOperator = allTags.firstWhere((element) => element.id == 11);

      if (inputs.contains("Senior") &&
          inputs.contains("Operator") &&
          !auxTagsFromImage.contains(seniorOperator)) {
        auxTagsFromImage.add(seniorOperator);
      }

      if (inputs.contains("Top") &&
          inputs.contains("Operator") &&
          !auxTagsFromImage.contains(topOperator)) {
        auxTagsFromImage.add(topOperator);
      }

      if (auxTagsFromImage.isNotEmpty) {
        setState(() {
          tagsFromImage = auxTagsFromImage;
        });
        showOperators();
        return;
      }

      setState(() {
        isLoading = false;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CustomDialog(
          title: 'Error',
          description: 'i can\'t find tags in the image.',
          icon: Icons.error,
          iconBackground: Colors.redAccent,
        ),
      );
    } catch (e) {
      AnalyticsUtils.logEvent(
        name: Tags.AUTOMATIC_RECRUITMENT_PICK_SCREENSHOT_MODEL_ERROR,
        data: <String, dynamic>{
          'error': e.toString(),
        },
      );
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CustomDialog(
          title: 'Error',
          description: 'i can\'t find tags in the image.',
          icon: Icons.error,
          iconBackground: Colors.redAccent,
        ),
      );
      return;
    }
  }

  void showOperators() {
    if (tagsFromImage.isEmpty) {
      showCustomDialog(context, 'Warning', 'i can\'t find tags in the image.',
          Icons.warning);
      return;
    }
    setState(() {
      isLoading = true;
    });

    AnalyticsUtils.logEvent(
      name: Tags.AUTOMATIC_RECRUITMENT_OPERATORS_REQUEST,
      data: <String, dynamic>{
        'tags': tagsFromImage.toString(),
      },
    );
    recruitmentData = fetchRecruimentData(
        tags: tagsFromImage.map((e) => e.id).toList(),
        server: Server.servers[0]);

    recruitmentData.then((response) {
      if (response.groups.isEmpty) {
        showCustomDialog(
            context, 'Not found', 'i can\'t find operators :(', Icons.warning);
        return;
      }
      if (response.groups.isEmpty) {
        return;
      }
      AnalyticsUtils.logEvent(
        name: Tags.AUTOMATIC_RECRUITMENT_OPERATORS_LOADED,
        data: <String, dynamic>{
          'tags': tagsFromImage.toString(),
        },
      );

      setState(() {
        isLoading = false;
        result = response;
      });

      showOperatorsDialog(context);
    }, onError: (error) {
      setState(() {
        isLoading = false;
      });
      AnalyticsUtils.logEvent(
        name: Tags.AUTOMATIC_RECRUITMENT_OPERATORS_ERROR,
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

  void showOperatorsDialog(BuildContext context) {
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
        allTags: Tag.allTagsEN,
      ),
    );
  }

  void showCustomDialog(
      BuildContext context, String title, String message, IconData icon) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CustomDialog(
        title: title,
        description: message,
        icon: icon,
      ),
    );
  }

  Widget showLoading() {
    return Container(
      padding: EdgeInsets.only(
        top: 100.0,
      ),
      child: Loading(),
    );
  }

  List<Widget> showInstructionsAndButtons() {
    if (isLoading) {
      return [showLoading()];
    }

    List<Widget> instructionsAndButtons = [
      Text(
        'First take a screenshot from the recruitment screen (EN) in the game and select it from the gallery.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15.0,
          color: Theme.of(context).primaryColor,
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton.icon(
            icon: Icon(Icons.photo_library),
            label: Text('Select a screenshot'),
            color: Theme.of(context).primaryColor,
            highlightColor: Theme.of(context).accentColor,
            splashColor: Theme.of(context).accentColor,
            colorBrightness: Theme.of(context).primaryColorBrightness,
            elevation: 8,
            highlightElevation: 2,
            onPressed: pickImage,
          ),
          RaisedButton.icon(
            icon: Icon(Icons.help),
            label: Text('Help'),
            color: Theme.of(context).primaryColor,
            highlightColor: Theme.of(context).accentColor,
            splashColor: Theme.of(context).accentColor,
            colorBrightness: Theme.of(context).primaryColorBrightness,
            elevation: 8,
            highlightElevation: 2,
            onPressed: showHelpDialog,
          ),
        ],
      ),
      Text(
        'When you select a screenshot it\'s going to show the operators you can get... good luck!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15.0,
          color: Theme.of(context).primaryColor,
        ),
      ),
    ];

    if (tagsFromImage.isNotEmpty && result.groups.isNotEmpty) {
      instructionsAndButtons.addAll(showTagsInformation());
      instructionsAndButtons.addAll(showOperatorsAgain());
    }

    return instructionsAndButtons
        .map(
          (widget) => Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: widget,
          ),
        )
        .toList();
  }

  List<Widget> showTagsInformation() {
    return [
      Card(
        child: Container(
          decoration: new BoxDecoration(
            color: tagsFromImage.length != 5
                ? Colors.red
                : Theme.of(context).primaryColor,
            shape: BoxShape.rectangle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Text(
                'Your tags are: ${tagsFromImage.toString().substring(1, tagsFromImage.toString().length - 1)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                ),
              ),
              tagsFromImage.length != 5
                  ? Column(
                      children: <Widget>[
                        Text(
                          'If there are some tags missing you can use the Manual Recruitment',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> showOperatorsAgain() {
    return [
      Text(
        'If you close the list of operators you can see it again pressing this button:',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15.0,
          color: Theme.of(context).primaryColor,
        ),
      ),
      RaisedButton.icon(
        icon: Icon(Icons.refresh),
        label: Text('Show me again'),
        color: Theme.of(context).primaryColor,
        highlightColor: Theme.of(context).accentColor,
        splashColor: Theme.of(context).accentColor,
        colorBrightness: Theme.of(context).primaryColorBrightness,
        elevation: 8,
        highlightElevation: 2,
        onPressed: () {
          showOperatorsDialog(context);
        },
      ),
    ];
  }

  void showHelpDialog() {
    AnalyticsUtils.logEvent(
      name: Tags.AUTOMATIC_RECRUITMENT_PICK_SCREENSHOT_HELP,
    );
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AutomaticRecruitmentHelpDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: new EdgeInsets.only(top: 10.0, left: 8.0, right: 8.0),
      child: new Column(
        children: showInstructionsAndButtons(),
      ),
    );
  }
}
