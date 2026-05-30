import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  GoogleSignInAccount? userAccount;

  static const List<String> _scopes = [
    'email',
    'profile',
    'https://www.googleapis.com/auth/drive.file',
  ];

  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _googleSignIn.initialize(
        serverClientId: dotenv.env['SERVER_CLIENT_ID'],
      );
      _isInitialized = true;
    }
  }

  Future<auth.AuthClient?> getDriveClient() async {
    await _ensureInitialized();
    userAccount ??= await _googleSignIn.authenticate();
    if (userAccount == null) return null;

    try {
      var authorization = await userAccount!.authorizationClient
          .authorizationForScopes(_scopes);

      authorization ??= await userAccount!.authorizationClient.authorizeScopes(
        _scopes,
      );

      return authorization.authClient(scopes: _scopes);
    } catch (e) {
      return null;
    }
  }
}
