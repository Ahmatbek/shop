import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/shop_repository.dart';
import '../../models/models.dart';

// ---------- events ----------

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// App started: try to restore a saved session.
class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class LoginRequested extends AuthEvent {
  const LoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  @override
  List<Object?> get props => [name, email, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

// ---------- states ----------

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  const Authenticated(this.session);

  final UserSession session;

  @override
  List<Object?> get props => [session];
}

class Unauthenticated extends AuthState {
  const Unauthenticated({this.error});

  final String? error;

  @override
  List<Object?> get props => [error];
}

// ---------- bloc ----------

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
  }

  final ShopRepository _repository;

  void _onStarted(AuthStarted event, Emitter<AuthState> emit) {
    final session = _repository.restoreSession();
    emit(session == null ? const Unauthenticated() : Authenticated(session));
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final session = await _repository.login(event.email.trim(), event.password);
      emit(Authenticated(session));
    } on ApiException catch (e) {
      emit(Unauthenticated(error: e.message));
    }
  }

  Future<void> _onRegister(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final session = await _repository.register(
        event.name.trim(),
        event.email.trim(),
        event.password,
      );
      emit(Authenticated(session));
    } on ApiException catch (e) {
      emit(Unauthenticated(error: e.message));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const Unauthenticated());
  }
}
