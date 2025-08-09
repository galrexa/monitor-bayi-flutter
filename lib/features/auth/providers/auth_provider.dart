import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_service.dart';
import '../../shared/models/app_user.dart';

class AuthState {
  final User? firebaseUser;
  final AppUser? appUser;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.firebaseUser,
    this.appUser,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? firebaseUser,
    AppUser? appUser,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      appUser: appUser ?? this.appUser,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => firebaseUser != null && appUser != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _initialize();
  }

  void _initialize() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        try {
          final appUser = await FirebaseService.getUser(user.uid);
          if (appUser != null) {
            // Update FCM token
            await FirebaseService.updateUserFCMToken(user.uid);

            // Update last login
            final updatedUser = appUser.copyWith(lastLogin: DateTime.now());
            await FirebaseService.updateUser(updatedUser);

            state = state.copyWith(
              firebaseUser: user,
              appUser: updatedUser,
              isLoading: false,
              error: null,
            );
          } else {
            // User exists in Firebase Auth but not in Firestore
            print('User ${user.uid} exists in Auth but not in Firestore');
            state = state.copyWith(
              firebaseUser: user,
              appUser: null,
              isLoading: false,
              error: 'Profile tidak ditemukan. Silakan register ulang.',
            );
          }
        } catch (e) {
          print('Error loading user profile: $e');
          state = state.copyWith(
            firebaseUser: user,
            appUser: null,
            isLoading: false,
            error: 'Error memuat profil: $e',
          );
        }
      } else {
        state = state.copyWith(
          firebaseUser: null,
          appUser: null,
          isLoading: false,
          error: null,
        );
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await FirebaseService.signIn(email, password);
      // User state will be updated via authStateChanges listener
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final credential = await FirebaseService.signUp(email, password);

      // Create user profile
      final appUser = AppUser(
        id: credential.user!.uid,
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
      );

      await FirebaseService.createUser(appUser);
      // User state will be updated via authStateChanges listener
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await FirebaseService.signOut();
      // User state will be updated via authStateChanges listener
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Email tidak terdaftar';
        case 'wrong-password':
          return 'Password salah';
        case 'email-already-in-use':
          return 'Email sudah digunakan';
        case 'weak-password':
          return 'Password terlalu lemah';
        case 'invalid-email':
          return 'Format email tidak valid';
        case 'user-disabled':
          return 'Akun telah dinonaktifkan';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan. Coba lagi nanti';
        default:
          return 'Terjadi kesalahan: ${error.message}';
      }
    }
    return 'Terjadi kesalahan yang tidak terduga';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Helper providers
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authProvider).appUser;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
