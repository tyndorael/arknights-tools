import 'package:flutter/material.dart';

class TagButton extends StatelessWidget {
  TagButton({@required this.tag, @required this.label, @required this.onPressed});
  final String tag;
  final Text label;
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      key: ValueKey(tag),
      child: label,
      onPressed: onPressed,
      padding: EdgeInsets.all(20.0),
      color: Colors.black87,
      highlightColor: Colors.grey,
      splashColor: Colors.grey,
      colorBrightness: Brightness.dark,
      height: 40.0,
      minWidth: 120.0,
      elevation: 8,
      highlightElevation: 2,
    );
  }
}
