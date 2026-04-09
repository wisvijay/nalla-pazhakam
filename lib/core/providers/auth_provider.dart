import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Whether Firebase was successfully initialised ──────────────────────────
final firebaseReadyProvider = StateProvider<bool>((ref) => false);

// ── Auth change notifier (used as GoRouter refreshListenable) ──────────────
class AuthChangeNotifier extends ChangeNotifier {
  StreamSubscription<User?>? _sub;
  bool _isSignedIn = false;

  AuthChangeNotifier(bool firebaseReady) {
    if (!firebaseReady) return;
    _isSignedIn = FirebaseAuth.instance.currentUser != null;
    _sub = FirebaseAuth.instance.authStateChanges().listen((user) {
      final signedIn = user != null;
      if (_isSignedIn != signedIn) {
        _isSignedIn = signedIn;
        notifyListeners();
      }
    });
  }

  bool get isSignedIn => _isSignedIn;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final authNotifierProvider = ChangeNotifierProvider<AuthChangeNotifier>((ref) {
  final ready = ref.watch(firebaseReadyProvider);
  return AuthChangeNotifier(ready);
});

// ── Simple stream provider for auth state ─────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  final ready = ref.watch(firebaseReadyProvider);
  if (!ready) return Stream.value(null);
  return FirebaseAuth.instance.authStateChanges();
});

// ── Convenience providers ──────────────────────────────────────────────────
final currentUserProvider = Provider<User?>((ref) =>
    ref.watch(authStateProvider).valueOrNull);

final isSignedInProvider = Provider<bool>((ref) =>
    ref.watch(currentUserProvider) != null);

// ── Auth operations ────────────────────────────────────────────────────────
class AuthService {
  static Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await cred.user?.updateDisplayName(displayName);
    return cred;
  }

  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> signOut() => FirebaseAuth.instance.signOut();

  static Future<void> sendPasswordReset(String email) =>
      FirebaseAuth.instance.sendPasswordResetEmail(email: email);
}
