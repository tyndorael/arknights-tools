import 'package:flutter/material.dart';

class Server {
  const Server(this.code, this.name, this.icon);
  final String code;
  final String name;
  final Icon icon;
  static const List<Server> servers = <Server>[
    const Server('en','EN',Icon(Icons.android,color:  const Color(0xFF167F67),)),
    const Server('cn','CN',Icon(Icons.flag,color:  const Color(0xFF167F67),)),
    const Server('jp','JP',Icon(Icons.format_indent_decrease,color:  const Color(0xFF167F67),)),
    const Server('kr','KR',Icon(Icons.mobile_screen_share,color:  const Color(0xFF167F67),)),
  ];
}