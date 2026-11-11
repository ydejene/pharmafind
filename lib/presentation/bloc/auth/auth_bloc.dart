import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/auth/register_with_email_usecase.dart';
import '../../../domain/usecases/auth/send_password_reset_usecase.dart';
import '../../../domain/usecases/auth/sign_in_with_email_usecase.dart';
import '../../../domain/usecases/auth/sign_in_with_google_usecase.dart';
import '../../../domain/usecases/auth/sign_out_usecase.dart';
import '../../../domain/usecases/auth/update_user_profile_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUserUseCase getCurrentUser;
  final SignInWithEmailUseCase signInWithEmail;
  final RegisterWithEmailUseCase registerWithEmail;
  final SignInWithGoogleUseCase signInWithGoogle;
  final SendPasswordResetUseCase sendPasswordReset;
  final SignOutUseCase signOut;
  final UpdateUserProfileUseCase updateUserProfile;

  AuthBloc({
    required this.getCurrentUser,
    required this.signInWithEmail,
    required this.registerWithEmail,
    required this.signInWithGoogle,
    required this.sendPasswordReset,
    required this.signOut,
    required this.updateUserProfile,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthPasswordResetRequested>(_onPasswordReset);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthProfileUpdateRequested>(_onProfileUpdate);
    on<AuthSignOutRequested>(_onSignOut);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = await getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await signInWithEmail(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await registerWithEmail(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
        role: event.role,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await signInWithGoogle();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPasswordReset(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await sendPasswordReset(event.email);
      emit(AuthPasswordResetSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onProfileUpdate(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    try {
      final updatedUser = currentState.user.copyWith(
        displayName: event.displayName,
        insuranceProvider: event.insuranceProvider,
        insuranceId: event.insuranceId,
        phone: event.phone,
      );
      await updateUserProfile(updatedUser);
      emit(AuthAuthenticated(updatedUser));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await signOut();
    emit(AuthUnauthenticated());
  }
}
