import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_flutter_app/features/auth/bloc/auth_bloc.dart';
import 'package:firebase_flutter_app/features/auth/data/auth_repository.dart';
import 'package:firebase_flutter_app/features/auth/data/user_model.dart';

// Mocks
class MockAuthRepository extends Mock implements AuthRepository {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;
  late MockUser mockUser;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUser = MockUser();
    authBloc = AuthBloc(mockAuthRepository);

    // Setup default mock user properties
    when(() => mockUser.uid).thenReturn('test-uid-123');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.displayName).thenReturn('Test User');
    when(() => mockUser.photoURL).thenReturn(null);
    when(() => mockUser.emailVerified).thenReturn(true);
    when(() => mockUser.isAnonymous).thenReturn(false);
    when(() => mockUser.phoneNumber).thenReturn(null);
    when(() => mockUser.metadata).thenReturn(UserMetadata(0, 0));
    when(() => mockUser.providerData).thenReturn([]);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when user is signed in',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(mockUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.currentUser).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when no user is signed in',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(null);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>(),
        ],
      );
    });

    group('AuthSignInWithEmailRequested', () {
      const email = 'test@example.com';
      const password = 'password123';

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on successful sign in',
        build: () {
          final mockCredential = MockUserCredential();
          when(() => mockCredential.user).thenReturn(mockUser);
          when(() => mockAuthRepository.signInWithEmailAndPassword(
                email: email,
                password: password,
              )).thenAnswer((_) async => mockCredential);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignInWithEmailRequested(
          email: email,
          password: password,
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.signInWithEmailAndPassword(
                email: email,
                password: password,
              )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] on sign in failure',
        build: () {
          when(() => mockAuthRepository.signInWithEmailAndPassword(
                email: email,
                password: password,
              )).thenThrow(FirebaseAuthException('invalid-credential', 'Invalid credentials'));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignInWithEmailRequested(
          email: email,
          password: password,
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });

    group('AuthSignUpWithEmailRequested', () {
      const email = 'newuser@example.com';
      const password = 'newpassword123';
      const displayName = 'New User';

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on successful sign up',
        build: () {
          final mockCredential = MockUserCredential();
          when(() => mockCredential.user).thenReturn(mockUser);
          when(() => mockAuthRepository.signUpWithEmailAndPassword(
                email: email,
                password: password,
                displayName: displayName,
              )).thenAnswer((_) async => mockCredential);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignUpWithEmailRequested(
          email: email,
          password: password,
          displayName: displayName,
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when email already in use',
        build: () {
          when(() => mockAuthRepository.signUpWithEmailAndPassword(
                email: email,
                password: password,
                displayName: displayName,
              )).thenThrow(FirebaseAuthException('email-already-in-use', 'Email already exists'));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignUpWithEmailRequested(
          email: email,
          password: password,
          displayName: displayName,
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });

    group('AuthSignInAnonymouslyRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on successful anonymous sign in',
        build: () {
          final mockCredential = MockUserCredential();
          when(() => mockUser.isAnonymous).thenReturn(true);
          when(() => mockCredential.user).thenReturn(mockUser);
          when(() => mockAuthRepository.signInAnonymously())
              .thenAnswer((_) async => mockCredential);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthSignInAnonymouslyRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ],
      );
    });

    group('AuthSignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] on successful sign out',
        build: () {
          when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthSignOutRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>(),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.signOut()).called(1);
        },
      );
    });

    group('AuthForgotPasswordRequested', () {
      const email = 'test@example.com';

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthPasswordResetSent] on successful password reset',
        build: () {
          when(() => mockAuthRepository.sendPasswordResetEmail(email))
              .thenAnswer((_) async {});
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthForgotPasswordRequested(email)),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthPasswordResetSent>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when user not found',
        build: () {
          when(() => mockAuthRepository.sendPasswordResetEmail(email))
              .thenThrow(FirebaseAuthException('user-not-found', 'User not found'));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthForgotPasswordRequested(email)),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });
  });
}

// Helper class for Firebase Auth exceptions in tests
class FirebaseAuthException implements Exception {
  final String code;
  final String message;

  FirebaseAuthException(this.code, this.message);

  @override
  String toString() => message;
}
