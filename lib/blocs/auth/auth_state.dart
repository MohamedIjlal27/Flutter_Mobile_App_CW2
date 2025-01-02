import 'package:e_travel/models/auth/auth_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthUser user;

  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

class AuthPasswordResetSent extends AuthState {
  final String email;

  AuthPasswordResetSent(this.email);
}
