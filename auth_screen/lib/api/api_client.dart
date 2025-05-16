import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'api_config.dart';

/// Exception thrown when an API call fails
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? response;

  ApiException(this.message, {this.statusCode, this.response});

  @override
  String toString() =>
      'ApiException: $message ${statusCode != null ? '(Status: $statusCode)' : ''}';
}

/// Base API client providing common functionality for API calls
class ApiClient {
  final http.Client _client;
  final Logger _logger;

  /// Create a new ApiClient with an optional custom HTTP client and logger
  ApiClient({http.Client? client, Logger? logger})
      : _client = client ?? http.Client(),
        _logger = logger ?? Logger();

  /// Dispose resources used by the client
  void dispose() {
    _client.close();
  }

  /// Make a GET request to the specified URL
  Future<Map<String, dynamic>> get(Uri url) async {
    try {
      _logger.d('GET request: ${url.toString()}');

      final response = await _client
          .get(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      _logger.e('GET request failed: $e');
      throw ApiException('Network error: $e');
    }
  }

  /// Handle HTTP response and parse JSON data
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonData = jsonDecode(response.body);
        return jsonData;
      } catch (e) {
        _logger.e('JSON parse error: $e');
        throw ApiException('Failed to parse response: $e',
            response: response.body);
      }
    } else {
      _logger.e('HTTP error: ${response.statusCode}');
      throw ApiException('HTTP request failed',
          statusCode: response.statusCode, response: response.body);
    }
  }
}
