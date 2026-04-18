import 'package:firebase_auth/firebase_auth.dart';

/// Lokasi: lib/services/auth_service.dart
/// Jembatan komunikasi ke luar (Backend Firebase Auth)
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream status login (digunakan di main.dart untuk routing otomatis)
  Stream<User?> get userStream => _auth.authStateChanges();

  /// Logika Login Google menggunakan Senjata Bawaan Firebase
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // MENGGUNAKAN CARA MODERN:
      // Kita memanggil GoogleAuthProvider bawaan dari firebase_auth.
      // Ini otomatis menangani alur OAuth tanpa perlu package google_sign_in terpisah!
      final googleProvider = GoogleAuthProvider();

      // Menjalankan proses login.
      // Firebase akan otomatis membuka jendela login Google bawaan perangkat.
      return await _auth.signInWithProvider(googleProvider);
    } catch (e) {
      print("Boss Raid (Login) Error: $e");
      rethrow;
    }
  }

  /// Logika Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
