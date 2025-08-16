import 'package:equatable/equatable.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/user_statistics_model.dart';

abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserProfileLoaded extends UserState {
  final UserModel user;

  UserProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserProfileUpdated extends UserState {
  final UserModel user;

  UserProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

class MoneyDeposited extends UserState {
  final int newBalance;

  MoneyDeposited(this.newBalance);

  @override
  List<Object?> get props => [newBalance];
}

class UserStatisticsLoaded extends UserState {
  final UserStatisticsModel statistics;

  UserStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class UserFailure extends UserState {
  final String message;

  UserFailure(this.message);

  @override
  List<Object?> get props => [message];
}
