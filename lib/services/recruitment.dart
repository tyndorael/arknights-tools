import 'dart:async';
import 'dart:convert';
import 'package:arknightstools/config/flavor_config.dart';
import 'package:arknightstools/utils/Server.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:http/http.dart' as http;

Future<RecruitmentData> fetchRecruimentData({List<int> tags, Server server}) async {
  String url = FlavorConfig.instance.values.baseUrl;

  final HttpMetric metric =
      FirebasePerformance.instance.newHttpMetric(url, HttpMethod.Post);
  await metric.start();

  try {
    final response = await http.post('$url/tags/recruitment?locale=${server.code}',
        headers: {"Content-Type": "application/json"},
        body: json.encode({'tags': tags}));
    metric
      ..responsePayloadSize = response.contentLength
      ..responseContentType = response.headers['Content-Type']
      ..httpResponseCode = response.statusCode;
    if (response.statusCode == 200) {
      return RecruitmentData.fromJson(json.decode(response.body));
    }
  } catch (e) {
    throw Exception('Failed to find recruitment data');
  } finally {
    await metric.stop();
  }
  await metric.stop();
  throw Exception('Failed to find recruitment data');
}

class RecruitmentData {
  final List<dynamic> tags;
  final List<dynamic> groups;

  RecruitmentData({this.tags, this.groups});

  factory RecruitmentData.fromJson(Map<String, dynamic> json) {
    return RecruitmentData(
      tags: json['tags'],
      groups: json['groups'],
    );
  }
}
