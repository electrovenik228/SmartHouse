import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/auth_storage.dart';
import 'package:smarthome/models/user.dart';
import 'package:smarthome/providers/api_provider.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({required this.status, this.user, this.error});

  AuthState copyWith({AuthStatus? status, User? user, String? error}) => AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState(status: AuthStatus.loading)) {
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await _ref.read(apiClientProvider).getMe();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      await AuthStorage.deleteToken();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String username, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final token = await _ref.read(apiClientProvider).login(username, password);
      await AuthStorage.saveToken(token);
      final user = await _ref.read(apiClientProvider).getMe();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(status: AuthStatus.unauthenticated, error: 'Неверный логин или пароль');
    }
  }

  Future<void> logout() async {
    await AuthStorage.deleteToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);
