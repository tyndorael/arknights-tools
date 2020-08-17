import 'dart:async';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:arknightstools/config/flavor_config.dart';
import 'package:arknightstools/utils/http/Dio.dart';

Future<List<Room>> fetchRoomsByLocale(String locale) async {
  String baseUrl = FlavorConfig.instance.values.baseUrl;
  final HttpMetric metric = FirebasePerformance.instance
      .newHttpMetric('$baseUrl/building/rooms?locale=$locale', HttpMethod.Post);
  await metric.start();

  try {
    Response response = await DioHelper.getDio().get('$baseUrl/building/rooms',
        queryParameters: {"locale": locale},
        options: buildServiceCacheOptions(forceRefresh: false));

    metric
      ..responseContentType = response.headers.value('content-type')
      ..httpResponseCode = response.statusCode;

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      List jsonResponse = response.data;
      return jsonResponse.map((room) => new Room.fromJson(room)).toList();
    }
  } catch (error) {
    throw Exception('Failed to load buildings');
  } finally {
    await metric.stop();
  }
  await metric.stop();
  throw Exception('Failed to load buildings');
}

class Room {
  final String id;
  final String name;
  final String category;
  final String description;

  Room({this.id, this.name, this.category, this.description});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
    );
  }
}
