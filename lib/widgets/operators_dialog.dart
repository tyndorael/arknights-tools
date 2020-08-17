import 'package:arknightstools/utils/Tag.dart';
import 'package:flutter/material.dart';
import 'package:arknightstools/utils/Consts.dart';
import 'package:arknightstools/services/recruitment.dart';

class OperatorsDialog extends StatelessWidget {
  //final List<Widget> operators;
  final RecruitmentData operatorsFilteredByTags;
  final List<Tag> allTags;

  OperatorsDialog(
      {@required this.operatorsFilteredByTags, @required this.allTags});

  Color getColorByOperatorStars(int stars) {
    switch (stars) {
      case 6:
        return Colors.redAccent;
        break;
      case 5:
        return Colors.amber;
        break;
      case 4:
        return Colors.blue;
        break;
      case 3:
        return Colors.green;
        break;
      case 2:
        return Colors.white70;
        break;
      default:
        return Colors.grey;
    }
  }

  List<Widget> buildListOfOperators() {
    List<Widget> list = [];
    for (var i = 0; i < operatorsFilteredByTags.groups.length; i++) {
      String tagGrouping = operatorsFilteredByTags.groups[i]["comb"]
          .map((t) => allTags.firstWhere((element) => element.id == t))
          .toString();
      tagGrouping = tagGrouping.substring(1, tagGrouping.length - 1);
      List<dynamic> operators = operatorsFilteredByTags.groups[i]["operators"];
      if (operators.isNotEmpty) {
        list.add(
          Column(
            children: <Widget>[
              new Text(
                tagGrouping,
                style: TextStyle(
                  color: Consts.operatorsTextColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              new Column(
                children: operators
                    .map(
                      (operator) => Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                          bottom: 8.0,
                        ),
                        child: new ListTile(
                          leading: ClipOval(
                            child: Image(
                              image: AssetImage(
                                'assets/avatars/${operator['id'].replaceAll('char_', '')}.png',
                              ),
                            ),
                          ),
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                operator["onlyObtainableByRecruitment"]
                                    ? '${operator["name"]} 🌟'
                                    : operator["name"],
                                style: TextStyle(
                                  color: Consts.operatorsTextColor,
                                ),
                              ),
                              SizedBox(
                                width: 8.0,
                              ),
                              Container(
                                decoration: new BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  color: getColorByOperatorStars(
                                    int.parse(operator["stars"].toString()),
                                  ),
                                ),
                                height: 42.0,
                                width: 50.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '${operator["stars"]}',
                                      style: TextStyle(
                                        color: Consts.operatorsBackgroundColor,
                                      ),
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Consts.operatorsBackgroundColor,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      }
    }
    return list;
  }

  dialogContent(BuildContext context) {
    List<Widget> listOfWidgets = this.buildListOfOperators();
    return Stack(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width - 10,
          height: MediaQuery.of(context).size.height - 10,
          padding: EdgeInsets.only(
            top: Consts.operatorsDialogPadding,
            bottom: Consts.operatorsDialogPadding,
            left: Consts.operatorsDialogPadding,
            right: Consts.operatorsDialogPadding,
          ),
          decoration: new BoxDecoration(
            color: Consts.operatorsBackgroundColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.operatorsDialogPadding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Container(
            child: ListView.builder(
              itemCount: listOfWidgets.length,
              itemBuilder: (context, index) {
                return listOfWidgets[index];
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.operatorsDialogPadding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }
}
