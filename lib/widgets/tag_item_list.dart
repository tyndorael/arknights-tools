import 'package:flutter/material.dart';
import '../utils/Tag.dart';

class TagItemList extends StatefulWidget {
  final Tag tag;
  TagItemList(Tag tag)
      : tag = tag,
        super(key: new ObjectKey(tag));
  @override
  TagItemState createState() {
    return new TagItemState(tag);
  }
}

class TagItemState extends State<TagItemList> {
  final Tag tag;
  TagItemState(this.tag);
  
  @override
  Widget build(BuildContext context) {
    return new ListTile(
      onTap: () {
        setState(() {
          tag.isSelected = !tag.isSelected;
        });
      },
      title: new Row(
        children: <Widget>[
          new Expanded(
            child: new Text(
              tag.name,
              style: TextStyle(color: Colors.black87),
            ),
          ),
          new Checkbox(
              value: tag.isSelected,
              activeColor: Colors.black,
              checkColor: Colors.white,
              focusColor: Colors.black,
              onChanged: (bool value) {
                setState(() {
                  tag.isSelected = value;
                });
              })
        ],
      ),
    );
  }
}
