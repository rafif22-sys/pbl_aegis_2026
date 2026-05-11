// core/services/api_client.dart
/// Base HTTP client — hanya berisi baseUrl dan headers.
class ApiClient {
  // Device fisik      → 'http://192.168.x.x:8000/api'
  static const String baseUrl = 'http://172.16.93.15:8000/api';

  static Map<String, String> headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept':       'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}