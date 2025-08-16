import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/services/user_api_service.dart';
import 'topup_event.dart';
import 'topup_state.dart';

class TopUpBloc extends Bloc<TopUpEvent, TopUpState> {
  TopUpBloc() : super(TopUpInitial()) {
    on<DepositMoney>(_onDepositMoney);
  }

  Future<void> _onDepositMoney(
    DepositMoney event,
    Emitter<TopUpState> emit,
  ) async {
    emit(TopUpLoading());

    try {
      print('💰 Depositing ${event.amount} via ${event.paymentMethod}');

      final response = await UserApiService.depositMoney(
        event.amount,
        paymentMethod: event.paymentMethod,
      );

      print('💰 Deposit response: ${response.statusCode}');
      print('💰 Deposit data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          emit(TopUpSuccess(
            amount: event.amount,
            paymentMethod: event.paymentMethod,
          ));
        } else {
          emit(TopUpFailure(data['message'] ?? 'Deposit failed'));
        }
      } else {
        emit(TopUpFailure(
            'Failed to deposit money. Status: ${response.statusCode}'));
      }
    } catch (e) {
      print('❌ Deposit error: $e');
      emit(TopUpFailure('Failed to deposit money: $e'));
    }
  }
}
