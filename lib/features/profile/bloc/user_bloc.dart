import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'user_event.dart';
import 'user_state.dart';
import '../../../shared/services/user_api_service.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/user_statistics_model.dart';
import '../../../shared/utils/api_error_handler.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<DepositMoney>(_onDepositMoney);
    on<LoadUserStatistics>(_onLoadUserStatistics);
  }

  Future<void> _onLoadUserProfile(
      LoadUserProfile event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final response = await UserApiService.getProfile();
      debugPrint('🔍 UserBloc: API Response Status: ${response.statusCode}');
      debugPrint('🔍 UserBloc: API Response Data: ${response.data}');

      // The backend returns: { success: true, data: { user: {...} }, message: "..." }
      final data = response.data['data']['user'];
      debugPrint('🔍 UserBloc: User Data: $data');

      final user = UserModel.fromJson(data);
      debugPrint('🔍 UserBloc: Parsed User Balance: ${user.balance}');

      emit(UserProfileLoaded(user));
    } catch (e) {
      debugPrint('❌ UserBloc: Error loading profile: $e');
      final errorMessage = ApiErrorHandler.parseError(e);
      emit(UserFailure(errorMessage));
    }
  }

  Future<void> _onUpdateUserProfile(
      UpdateUserProfile event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final response = await UserApiService.updateProfile(
        fullName: event.fullName,
        email: event.email,
        phoneNumber: event.phoneNumber,
      );
      final data = response.data['data']['user'];
      final user = UserModel.fromJson(data);
      emit(UserProfileUpdated(user));
    } catch (e) {
      final errorMessage = ApiErrorHandler.parseError(e);
      emit(UserFailure(errorMessage));
    }
  }

  Future<void> _onDepositMoney(
      DepositMoney event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final response = await UserApiService.depositMoney(
        event.amount,
        paymentMethod: event.paymentMethod,
      );
      final data = response.data['data'];
      final newBalance = data['user']['balance'] ?? 0;
      emit(MoneyDeposited(newBalance));
    } catch (e) {
      final errorMessage = ApiErrorHandler.parseError(e);
      emit(UserFailure(errorMessage));
    }
  }

  Future<void> _onLoadUserStatistics(
      LoadUserStatistics event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final response = await UserApiService.getStatistics();
      final data = response.data['data']['statistics'];
      final statistics = UserStatisticsModel.fromJson(data);
      emit(UserStatisticsLoaded(statistics));
    } catch (e) {
      final errorMessage = ApiErrorHandler.parseError(e);
      emit(UserFailure(errorMessage));
    }
  }
}
