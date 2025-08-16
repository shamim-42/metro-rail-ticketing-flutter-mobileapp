abstract class TopUpState {}

class TopUpInitial extends TopUpState {}

class TopUpLoading extends TopUpState {}

class TopUpSuccess extends TopUpState {
  final int amount;
  final String paymentMethod;

  TopUpSuccess({
    required this.amount,
    required this.paymentMethod,
  });
}

class TopUpFailure extends TopUpState {
  final String message;

  TopUpFailure(this.message);
}
