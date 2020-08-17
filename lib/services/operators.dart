import 'dart:async';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:arknightstools/config/flavor_config.dart';
import 'package:arknightstools/utils/http/Dio.dart';

Future<List<Operator>> fetchOperatorsByLocale(
    String locale, bool showBuffs) async {
  String baseUrl = FlavorConfig.instance.values.baseUrl;
  Map<String, String> queryParams = {
    "locale": locale,
    "showBuffs": showBuffs.toString()
  };
  final HttpMetric metric = FirebasePerformance.instance
      .newHttpMetric('$baseUrl/operators?locale=$locale', HttpMethod.Post);
  await metric.start();

  try {
    Response response = await DioHelper.getDio().get('$baseUrl/operators',
        queryParameters: queryParams,
        options: buildServiceCacheOptions(forceRefresh: false));

    metric
      ..responseContentType = response.headers.value('content-type')
      ..httpResponseCode = response.statusCode;

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      List jsonResponse = response.data;
      return jsonResponse.map((tag) => new Operator.fromJson(tag)).toList();
    }
  } catch (error) {
    throw Exception('Failed to load tags');
  } finally {
    await metric.stop();
  }
  await metric.stop();
  throw Exception('Failed to load tags');
}

class Operator {
  String id;
  String name;
  String description;
  int stars;
  int potential;
  List<Position> tags;
  Position profession;
  Position position;
  String obtainableBy;
  List<Buff> buffs;
  bool onlyObtainableByRecruitment;

  Operator({
    this.id,
    this.name,
    this.description,
    this.stars,
    this.potential,
    this.tags,
    this.profession,
    this.position,
    this.obtainableBy,
    this.buffs,
    this.onlyObtainableByRecruitment,
  });

  factory Operator.fromJson(Map<String, dynamic> json) => Operator(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        stars: json["stars"],
        potential: json["potential"],
        tags:
            List<Position>.from(json["tags"].map((x) => Position.fromJson(x))),
        profession: Position.fromJson(json["profession"]),
        position: Position.fromJson(json["position"]),
        obtainableBy: json["obtainableBy"],
        buffs: List<Buff>.from(json["buffs"].map((x) => Buff.fromJson(x))),
        onlyObtainableByRecruitment: json["onlyObtainableByRecruitment"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "stars": stars,
        "potential": potential,
        "tags": List<dynamic>.from(tags.map((x) => x.toJson())),
        "profession": profession.toJson(),
        "position": position.toJson(),
        "obtainableBy": obtainableBy,
        "buffs": List<dynamic>.from(buffs.map((x) => x.toJson())),
        "onlyObtainableByRecruitment": onlyObtainableByRecruitment,
      };
}

class Buff {
  String id;
  String name;
  String category;
  String type;
  String description;
  Conditions conditions;

  Buff({
    this.id,
    this.name,
    this.category,
    this.type,
    this.description,
    this.conditions,
  });

  factory Buff.fromJson(Map<String, dynamic> json) => Buff(
        id: json["id"],
        name: json["name"],
        category: json["category"],
        type: json["type"],
        description: json["description"],
        conditions: Conditions.fromJson(json["conditions"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "category": category,
        "type": type,
        "description": description,
        "conditions": conditions.toJson(),
      };
}

class Conditions {
  int phase;
  int level;

  Conditions({
    this.phase,
    this.level,
  });

  factory Conditions.fromJson(Map<String, dynamic> json) => Conditions(
        phase: json["phase"],
        level: json["level"],
      );

  Map<String, dynamic> toJson() => {
        "phase": phase,
        "level": level,
      };
}

class Position {
  int id;
  String name;

  Position({
    this.id,
    this.name,
  });

  factory Position.fromJson(Map<String, dynamic> json) => Position(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
