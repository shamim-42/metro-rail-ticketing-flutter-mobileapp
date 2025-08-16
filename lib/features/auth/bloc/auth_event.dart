import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthRegisterRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;

  AuthRegisterRequested(
      this.fullName, this.email, this.phoneNumber, this.password);

  @override
  List<Object?> get props => [fullName, email, phoneNumber, password];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}
