import 'package:dio/dio.dart';
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
    final data = (response.data['data'] as List?) ?? [];
    return data
        .map((j) => Alert.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}
