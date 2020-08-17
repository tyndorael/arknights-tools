import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

import 'package:arknightstools/config/flavor_config.dart';

class DioHelper {
  static Dio _dio;
  static DioCacheManager _manager;
  static final String baseUrl = FlavorConfig.instance.values.baseUrl;

  static Dio getDio() {
    if (null == _dio) {
      _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          contentType: "application/application-json; charset=utf-8"))
        ..interceptors.add(getCacheManager().interceptor);
      if (!FlavorConfig.isProduction()) {
        _dio.interceptors.add(LogInterceptor(responseBody: true));
      }
    }
    return _dio;
  }

  static DioCacheManager getCacheManager() {
    if (null == _manager) {
      _manager = DioCacheManager(CacheConfig(baseUrl: baseUrl));
    }
    return _manager;
  }
}
