abstract class TopUpEvent {}

class DepositMoney extends TopUpEvent {
  final int amount;
  final String paymentMethod;

  DepositMoney({
    required this.amount,
    required this.paymentMethod,
  });
}
