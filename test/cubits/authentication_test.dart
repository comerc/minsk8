// ignore_for_file: prefer_const_constructors
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:minsk8/import.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

// ignore: must_be_immutable
class MockUserModel extends Mock implements UserModel {}

void main() {
  final user = MockUserModel();
  AuthenticationRepository authenticationRepository;

  setUp(() {
    authenticationRepository = MockAuthenticationRepository();
    when(authenticationRepository.user).thenAnswer((_) => const Stream.empty());
  });

  group('AuthenticationState', () {
    group('AuthenticationState.unknown', () {
      test('supports value comparisons', () {
        expect(
          AuthenticationState.unknown(),
          AuthenticationState.unknown(),
        );
      });
    });

    group('AuthenticationState.authenticated', () {
      test('supports value comparisons', () {
        final user = MockUserModel();
        expect(
          AuthenticationState.authenticated(user),
          AuthenticationState.authenticated(user),
        );
      });
    });

    group('AuthenticationState.unauthenticated', () {
      test('supports value comparisons', () {
        expect(
          AuthenticationState.unauthenticated(),
          AuthenticationState.unauthenticated(),
        );
      });
    });
  });

  group('AuthenticationCubit', () {
    test('throws when authenticationRepository is null', () {
      expect(
        () => AuthenticationCubit(null),
        throwsAssertionError,
      );
    });

    test('initial state is AuthenticationState.unknown', () {
      final authenticationCubit = AuthenticationCubit(authenticationRepository);
      expect(authenticationCubit.state, const AuthenticationState.unknown());
      authenticationCubit.close();
    });

    blocTest<AuthenticationCubit, AuthenticationState>(
      'subscribes to user stream',
      build: () {
        when(authenticationRepository.user).thenAnswer(
          (_) => Stream.value(user),
        );
        return AuthenticationCubit(authenticationRepository);
      },
      expect: <AuthenticationState>[
        AuthenticationState.authenticated(user),
      ],
    );

    group('changeUser', () {
      blocTest<AuthenticationCubit, AuthenticationState>(
        'emits [authenticated] when user is not null',
        build: () => AuthenticationCubit(authenticationRepository),
        act: (bloc) => bloc.changeUser(user),
        expect: <AuthenticationState>[
          AuthenticationState.authenticated(user),
        ],
      );

      blocTest<AuthenticationCubit, AuthenticationState>(
        'emits [unauthenticated] when user is empty',
        build: () => AuthenticationCubit(authenticationRepository),
        act: (bloc) => bloc.changeUser(UserModel.empty),
        expect: const <AuthenticationState>[
          AuthenticationState.unauthenticated(),
        ],
      );
    });

    group('requestLogout', () {
      blocTest<AuthenticationCubit, AuthenticationState>(
        'calls logOut on authenticationRepository '
        'when AuthenticationLogoutRequested is added',
        build: () => AuthenticationCubit(authenticationRepository),
        act: (bloc) => bloc.requestLogout(),
        verify: (_) {
          verify(authenticationRepository.logOut()).called(1);
        },
      );
    });
  });
}
