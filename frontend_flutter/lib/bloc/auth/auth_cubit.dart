import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api_client.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiClient _api;
  static const String _tokenKey = 'repairmate_jwt_token';

  AuthCubit({required ApiClient api})
      : _api = api,
        super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token == null || token.isEmpty) {
        _api.setAuthToken(null);
        emit(const Unauthenticated());
        return;
      }

      final user = await _api.getMe(token);
      emit(Authenticated(user: user, token: token));
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      _api.setAuthToken(null);
      emit(const Unauthenticated());
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      final res = await _api.login(email: email, password: password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, res.token);
      emit(Authenticated(user: res.user, token: res.token));
    } on ApiException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('Failed to sign in. Please try again. ($e)'));
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final res = await _api.signup(name: name, email: email, password: password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, res.token);
      emit(Authenticated(user: res.user, token: res.token));
    } on ApiException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('Failed to create account. Please try again. ($e)'));
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _api.setAuthToken(null);
    emit(const Unauthenticated());
  }
}
