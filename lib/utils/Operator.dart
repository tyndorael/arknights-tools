import 'package:flutter/material.dart';

class Operator {
  final String code;
  final String name;
  final List<String> tags;

  const Operator({@required this.code, @required this.name, this.tags});

  @override
  String toString() => this.name;

}