import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:pharma_find/data/repositories/auth_repository.dart';
import 'package:pharma_find/presentation/bloc/auth/auth_bloc.dart';
import 'package:pharma_find/presentation/bloc/auth/auth_event.dart';
import 'package:pharma_find/presentation/bloc/auth/auth_state.dart';

void main() {
  late AuthRepository authRepo;
  late AuthBloc authBloc;

  setUp(() {
    authRepo = AuthRepository();
    authBloc = AuthBloc(authRepository: authRepo);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful login',
      build: () => AuthBloc(authRepository: authRepo),
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: 'test@example.com', password: 'pass'),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful registration',
      build: () => AuthBloc(authRepository: authRepo),
      act: (bloc) => bloc.add(
        const AuthRegisterRequested(
          email: 'new@example.com',
          password: 'secure123',
          displayName: 'Test User',
        ),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on duplicate registration',
      build: () => AuthBloc(authRepository: authRepo),
      seed: () {
        authRepo.registerWithEmail(
          email: 'dup@example.com',
          password: 'secure123',
          displayName: 'First',
        );
        return AuthInitial();
      },
      act: (bloc) => bloc.add(
        const AuthRegisterRequested(
          email: 'dup@example.com',
          password: 'another123',
          displayName: 'Second',
        ),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] on logout',
      build: () => AuthBloc(authRepository: authRepo),
      seed: () {
        authRepo.signInWithEmail('user@test.com', 'pass');
        return AuthInitial();
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      expect: () => [
        isA<AuthUnauthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthPasswordResetSent] on password reset',
      build: () => AuthBloc(authRepository: authRepo),
      act: (bloc) => bloc.add(
        const AuthPasswordResetRequested(email: 'user@test.com'),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthPasswordResetSent>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on Google sign-in',
      build: () => AuthBloc(authRepository: authRepo),
      act: (bloc) => bloc.add(AuthGoogleSignInRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );
  });
}
