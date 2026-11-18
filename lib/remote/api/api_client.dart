// Klien HTTP dasar untuk API server FinTale.
// Menambahkan header Authorization dan X-Contract-Version secara otomatis.
// JANGAN log body request atau response — data pengguna bersifat sensitif.

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_token_provider.dart';
import '../exceptions/api_exception.dart';

class ApiClient {
  final AuthTokenProvider _tokenProvider;
  final String _baseUrl;

  static const _timeout = Duration(seconds: 15);
  static const _contractVersion = '2';

  ApiClient({
    required String baseUrl,
    required AuthTokenProvider tokenProvider,
  }) : _baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl,
       _tokenProvider = tokenProvider;

  /// Mengirim GET ke [path] (contoh: '/v1/entitlement').
  Future<Map<String, dynamic>> get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = await _buildHeaders();

    final response = await http.get(uri, headers: headers).timeout(_timeout);
    _throwIfError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Mengirim POST ke [path] dengan [body] sebagai JSON.
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = await _buildHeaders();

    final response = await http
        .post(uri, headers: headers, body: jsonEncode(body))
        .timeout(_timeout);
    _throwIfError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, String>> _buildHeaders() async {
    final token = await _tokenProvider.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Contract-Version': _contractVersion,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Memeriksa status code dan melempar [ApiException] yang sesuai jika error.
  void _throwIfError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    // Coba parse body sebagai JSON error sesuai format kontrak
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>?;
      if (error != null) {
        final code = error['code'] as String? ?? 'unknown';
        final message = error['message'] as String? ?? 'Error tidak dikenal';
        throw ApiException.fromCode(code, message);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      // Body bukan JSON valid — fallback ke kode HTTP
    }

    // Fallback: petakan kode HTTP ke kode error kontrak
    final fallbackCode = switch (response.statusCode) {
      400 || 422 => 'invalid_request',
      401 => 'unauthorized',
      403 => 'not_subscribed',
      429 => 'rate_limited',
      500 => 'server_error',
      _ => 'unknown',
    };
    throw ApiException.fromCode(
      fallbackCode,
      'HTTP ${response.statusCode}',
    );
  }
}
