import 'package:equatable/equatable.dart';
import '../../models/models.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class Authenticated extends AuthState {
  final User user;
  final String token;

  const Authenticated({required this.user, required this.token});

  @override
  List<Object?> get props => [user, token];
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

final class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
