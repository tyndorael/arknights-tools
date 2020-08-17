import 'dart:async';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:arknightstools/config/flavor_config.dart';
import 'package:arknightstools/utils/http/Dio.dart';

Future<List<LocalizedTag>> fetchTagsByLocale(String locale) async {
  String baseUrl = FlavorConfig.instance.values.baseUrl;
  final HttpMetric metric = FirebasePerformance.instance
      .newHttpMetric('$baseUrl/tags?locale=$locale', HttpMethod.Post);
  await metric.start();

  try {
    Response response = await DioHelper.getDio().get('$baseUrl/tags',
        queryParameters: {"locale": locale},
        options: buildServiceCacheOptions(forceRefresh: false));

    metric
      ..responseContentType = response.headers.value('content-type')
      ..httpResponseCode = response.statusCode;

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      List jsonResponse = response.data;
      return jsonResponse.map((tag) => new LocalizedTag.fromJson(tag)).toList();
    }
  } catch (error) {
    throw Exception('Failed to load tags');
  } finally {
    await metric.stop();
  }
  await metric.stop();
  throw Exception('Failed to load tags');
}

class LocalizedTag {
  final int id;
  final String name;

  LocalizedTag({this.id, this.name});

  factory LocalizedTag.fromJson(Map<String, dynamic> json) {
    return LocalizedTag(
      id: json['id'],
      name: json['name'],
    );
  }
}
