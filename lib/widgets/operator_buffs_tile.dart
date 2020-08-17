import 'package:arknightstools/services/operators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';

class OperatorBuffsTile extends StatelessWidget {
  final Operator operator;

  OperatorBuffsTile({@required this.operator});

  Widget showBuffRequirements(Buff buff, BuildContext context) {
    String label = '';
    int phase = buff.conditions.phase;
    int level = buff.conditions.level;

    if (phase == 0 && level == 1) {
      // beginning
      return Container();
    } else if (phase == 0 && level > 1) {
      // unlock at level X without elite 1 or more.
      label = 'Lv. $level to unlock';
    } else if (phase == 1 && level == 1) {
      // unlock at level 1 with elite 1
      label = 'Elite $level to unlock';
    } else if (phase == 2 && level == 1) {
      // unlock at level 1 with elite 2
      label = 'Elite $phase to unlock';
    }

    if (label.isEmpty) {
      return Container();
    }

    return Text(
      label,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: 14.0,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            width: 70.0,
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Column(
                children: <Widget>[
                  ClipOval(
                    child: Image(
                      width: 60.0,
                      height: 60.0,
                      image: AssetImage(
                        'assets/avatars/${operator.id.replaceAll('char_', '')}.png',
                      ),
                    ),
                  ),
                  Text(
                    operator.name,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: operator.buffs
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              e.name,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            ParsedText(
                              text: e.description,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Theme.of(context).primaryColor,
                              ),
                              parse: <MatchText>[
                                MatchText(
                                    pattern:
                                        r"<\s*@cc.vup[^>]*>(.*?)<\s*\/\s*>",
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 14,
                                    ),
                                    renderText: ({String str, String pattern}) {
                                      Map<String, String> map =
                                          Map<String, String>();
                                      RegExp customRegExp = RegExp(pattern);
                                      Match match =
                                          customRegExp.firstMatch(str);
                                      map['display'] = match.group(1);
                                      map['value'] = match.group(1);
                                      return map;
                                    }),
                                MatchText(
                                    pattern: r"<\s*@cc.kw[^>]*>(.*?)<\s*\/\s*>",
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 14,
                                    ),
                                    renderText: ({String str, String pattern}) {
                                      Map<String, String> map =
                                          Map<String, String>();
                                      RegExp customRegExp = RegExp(pattern);
                                      Match match =
                                          customRegExp.firstMatch(str);
                                      map['display'] = match.group(1);
                                      map['value'] = match.group(1);
                                      return map;
                                    }),
                                MatchText(
                                    pattern:
                                        r"<\s*@cc.vdown[^>]*>(.*?)<\s*\/\s*>",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                    renderText: ({String str, String pattern}) {
                                      Map<String, String> map =
                                          Map<String, String>();
                                      RegExp customRegExp = RegExp(pattern);
                                      Match match =
                                          customRegExp.firstMatch(str);
                                      map['display'] = match.group(1);
                                      map['value'] = match.group(1);
                                      return map;
                                    }),
                              ],
                            ),
                            showBuffRequirements(e, context),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
