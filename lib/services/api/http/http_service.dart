import 'package:faithlock/config/logger.dart';
import 'package:http/http.dart' as http;

class HttpService {
  final String baseUrl;
  final http.Client _client;

  HttpService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  Future<http.Response> get(String endpoint,
      {Map<String, String>? headers}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      _logResponse(response);
      return response;
    } catch (e) {
      logger.error('GET request failed: $e');
      rethrow;
    }
  }

  Future<http.Response> post(String endpoint,
      {Map<String, String>? headers, Object? body}) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body,
      );
      _logResponse(response);
      return response;
    } catch (e) {
      logger.error('POST request failed: $e');
      rethrow;
    }
  }

  Future<http.Response> put(String endpoint,
      {Map<String, String>? headers, Object? body}) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body,
      );
      _logResponse(response);
      return response;
    } catch (e) {
      logger.error('PUT request failed: $e');
      rethrow;
    }
  }

  Future<http.Response> delete(String endpoint,
      {Map<String, String>? headers}) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      _logResponse(response);
      return response;
    } catch (e) {
      logger.error('DELETE request failed: $e');
      rethrow;
    }
  }

  void _logResponse(http.Response response) {
    logger.debug('Response status: ${response.statusCode}');
    logger.debug('Response body: ${response.body}');
  }

  void close() {
    _client.close();
  }
}
