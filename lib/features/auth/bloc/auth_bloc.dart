import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Auth state is handled by Supabase's authStateChanges stream
    emit(const AuthState(isAuthenticated: true));
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(isAuthenticated: false));
  }
}

class AuthState extends Equatable {
  final bool isAuthenticated;

  const AuthState({this.isAuthenticated = false});

  @override
  List<Object?> get props => [isAuthenticated];
}
