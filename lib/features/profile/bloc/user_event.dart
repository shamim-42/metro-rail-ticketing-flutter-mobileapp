import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserEvent {}

class UpdateUserProfile extends UserEvent {
  final String fullName;
  final String? email;
  final String? phoneNumber;

  UpdateUserProfile({
    required this.fullName,
    this.email,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [fullName, email, phoneNumber];
}

class DepositMoney extends UserEvent {
  final int amount;
  final String paymentMethod;

  DepositMoney(this.amount, {this.paymentMethod = 'cash'});

  @override
  List<Object?> get props => [amount, paymentMethod];
}

class LoadUserStatistics extends UserEvent {}
