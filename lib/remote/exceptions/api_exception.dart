// Hierarki exception untuk error dari server FinTale.
// Sesuai kode error di kontrak versi 2.

/// Exception dasar untuk semua error dari API server FinTale.
class ApiException implements Exception {
  final String code;
  final String message;

  const ApiException({required this.code, required this.message});

  @override
  String toString() => 'ApiException($code): $message';

  /// Memetakan kode error dari server ke subclass yang tepat.
  factory ApiException.fromCode(String code, String message) {
    switch (code) {
      case 'invalid_request':
        return InvalidRequestException(message: message);
      case 'unauthorized':
        return UnauthorizedException(message: message);
      case 'not_subscribed':
        return NotSubscribedException(message: message);
      case 'rate_limited':
        return RateLimitedException(message: message);
      case 'parse_failed':
        return ParseFailedException(message: message);
      case 'server_error':
        return ServerErrorException(message: message);
      default:
        return UnknownApiException(code: code, message: message);
    }
  }
}

/// 400/422 — Request tidak valid (skema salah, field tidak dikenal, dsb).
class InvalidRequestException extends ApiException {
  const InvalidRequestException({required super.message})
    : super(code: 'invalid_request');
}

/// 401 — Token tidak ada atau tidak valid.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({required super.message})
    : super(code: 'unauthorized');
}

/// 403 — Pengguna belum berlangganan.
class NotSubscribedException extends ApiException {
  const NotSubscribedException({required super.message})
    : super(code: 'not_subscribed');
}

/// 429 — Terlalu banyak request.
class RateLimitedException extends ApiException {
  const RateLimitedException({required super.message})
    : super(code: 'rate_limited');
}

/// 422 — Server gagal memparsing input.
class ParseFailedException extends ApiException {
  const ParseFailedException({required super.message})
    : super(code: 'parse_failed');
}

/// 500 — Error internal server.
class ServerErrorException extends ApiException {
  const ServerErrorException({required super.message})
    : super(code: 'server_error');
}

/// Kode error tidak dikenal.
class UnknownApiException extends ApiException {
  const UnknownApiException({required super.code, required super.message});
}
