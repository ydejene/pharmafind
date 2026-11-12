
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/data/datasources/mock_auth_datasource.dart';
import 'package:pharmafind/data/repositories/auth_repository_impl.dart';
import 'package:pharmafind/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/register_with_email_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/send_password_reset_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/sign_in_with_email_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/sign_in_with_google_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/sign_out_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/update_user_profile_usecase.dart';
import 'package:pharmafind/presentation/bloc/auth/auth_bloc.dart';
import 'package:pharmafind/presentation/bloc/auth/auth_event.dart';
import 'package:pharmafind/presentation/bloc/auth/auth_state.dart';

AuthBloc _buildBloc() {
  final repo = AuthRepositoryImpl(datasource: MockAuthDataSource());
  return AuthBloc(
    getCurrentUser: GetCurrentUserUseCase(repo),
    signInWithEmail: SignInWithEmailUseCase(repo),
    registerWithEmail: RegisterWithEmailUseCase(repo),
    signInWithGoogle: SignInWithGoogleUseCase(repo),
    sendPasswordReset: SendPasswordResetUseCase(repo),
    signOut: SignOutUseCase(repo),
    updateUserProfile: UpdateUserProfileUseCase(repo),
  );
}

void main() {
  group('AuthBloc', () {
    test('emits AuthLoading then AuthAuthenticated on login', () async {
      final bloc = _buildBloc();
      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthLoginRequested(
        email: 'user@example.com',
        password: 'secret1',
      ));
      await Future.delayed(const Duration(milliseconds: 300));

      expect(states.any((s) => s is AuthLoading), isTrue);
      expect(states.last, isA<AuthAuthenticated>());

      await sub.cancel();
      await bloc.close();
    });

    test('emits AuthUnauthenticated on sign-out', () async {
      final bloc = _buildBloc();
      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(AuthSignOutRequested());
      await Future.delayed(const Duration(milliseconds: 300));

      expect(states.last, isA<AuthUnauthenticated>());

      await sub.cancel();
      await bloc.close();
    });

    test('emits AuthPasswordResetSent on password reset', () async {
      final bloc = _buildBloc();
      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthPasswordResetRequested(email: 'user@example.com'));
      await Future.delayed(const Duration(milliseconds: 300));

      expect(states.last, isA<AuthPasswordResetSent>());

      await sub.cancel();
      await bloc.close();
    });
  });
}
