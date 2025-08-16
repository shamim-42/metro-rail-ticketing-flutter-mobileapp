import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../shared/services/auth_api_service.dart';
import '../../../shared/models/auth_response_model.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLoginRequested>(_onLogin);
  }

  Future<void> _onRegister(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await AuthApiService.register(
        fullName: event.fullName,
        email: event.email,
        phoneNumber: event.phoneNumber,
        password: event.password,
      );
      final data = response.data['data'];
      final authResponse = AuthResponseModel.fromJson(data);
      emit(AuthSuccess(authResponse.user, authResponse.token));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogin(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await AuthApiService.login(
        email: event.email,
        password: event.password,
      );
      final data = response.data['data'];
      final authResponse = AuthResponseModel.fromJson(data);
      emit(AuthSuccess(authResponse.user, authResponse.token));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
