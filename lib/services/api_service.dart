import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/alert.dart';

class ApiService {
  static const _baseUrl =
      'https://api.public-warning.app/api/v1/providers/nl-alert/alerts';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<List<Alert>> fetchAlerts({String? after}) async {
    final response = await _dio.get(
      _baseUrl,
      queryParameters: after != null ? {'after': after} : null,
    );
    final body = response.data;
    final data = (body is Map ? body['data'] : null) as List? ?? [];
    final alerts = <Alert>[];
    for (final item in data) {
      try {
        alerts.add(Alert.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        // Skip a single malformed entry rather than failing the whole fetch.
        debugPrint('[Api] malformed alert skipped: $e');
      }
    }
    return alerts;
  }
}
