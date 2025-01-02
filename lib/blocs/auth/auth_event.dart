abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({required this.email, required this.password});
}

class AuthSignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  AuthSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
  });
}

class AuthLogoutRequested extends AuthEvent {}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  AuthForgotPasswordRequested({required this.email});
}

class AuthCheckRequested extends AuthEvent {}
