import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'logger_service.dart';

class AuthService {
  static final _client = SupabaseService.client;

  static Future<void> signUpWithEmail(String email, String password) async {
    AppLogger.i('AuthService: signUpWithEmail → $email');
    try {
      await _client.auth.signUp(email: email, password: password);
      AppLogger.i('AuthService: signUp success');
    } catch (e, st) {
      AppLogger.e('AuthService: signUpWithEmail failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  static Future<void> signInWithEmail(String email, String password) async {
    AppLogger.i('AuthService: signInWithEmail → $email');
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      AppLogger.i('AuthService: signIn success');
    } catch (e, st) {
      AppLogger.e('AuthService: signInWithEmail failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  static Future<void> signInWithGoogle() async {
    AppLogger.i('AuthService: signInWithGoogle');
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: '915002219422-lpbdi2nsqnfdu4r8g4v4bhp5t2qb7d10.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        AppLogger.w('AuthService: Google sign-in cancelled by user');
        return;
      }
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      if (accessToken == null || idToken == null) {
        AppLogger.e('AuthService: Missing Google tokens');
        throw Exception('Google sign-in failed: missing tokens');
      }
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      AppLogger.i('AuthService: Google sign-in success');
    } catch (e, st) {
      AppLogger.e('AuthService: signInWithGoogle failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  static Future<void> signOut() async {
    AppLogger.i('AuthService: signOut');
    try {
      await _client.auth.signOut();
      AppLogger.i('AuthService: signOut success');
    } catch (e, st) {
      AppLogger.e('AuthService: signOut failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  static User? get currentUser => _client.auth.currentUser;

  static Future<bool> hasProfile() async {
    final uid = currentUser?.id;
    if (uid == null) return false;
    try {
      final row = await _client.from('users').select('id').eq('id', uid).maybeSingle();
      return row != null;
    } catch (e, st) {
      AppLogger.e('AuthService: hasProfile check failed', error: e, stackTrace: st);
      return false;
    }
  }

  static Future<void> createProfile({
    required String username,
    required String homeCityId,
  }) async {
    final uid = currentUser!.id;
    final email = currentUser!.email!;
    AppLogger.i('AuthService: createProfile uid=$uid username=$username');
    try {
      await _client.from('users').insert({
        'id': uid,
        'username': username,
        'email': email,
        'home_city_id': homeCityId,
      });
      AppLogger.i('AuthService: createProfile success');
    } catch (e, st) {
      AppLogger.e('AuthService: createProfile failed', error: e, stackTrace: st);
      rethrow;
    }
  }
}
