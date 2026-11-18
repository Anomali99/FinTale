// Penyedia token autentikasi untuk header Authorization ke server FinTale.
// Implementasi nyata akan menggantikan stub ini saat auth server siap.

/// Antarmuka penyedia token autentikasi.
abstract class AuthTokenProvider {
  /// Mengembalikan token Bearer, atau null jika tidak tersedia.
  Future<String?> getToken();
}

/// Implementasi stub — selalu mengembalikan null.
/// Header Authorization tidak akan dikirim selama stub ini dipakai.
/// Ganti dengan implementasi nyata saat auth server FinTale siap.
class StubAuthTokenProvider implements AuthTokenProvider {
  const StubAuthTokenProvider();

  @override
  Future<String?> getToken() async => null;
}
