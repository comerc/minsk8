// ignore_for_file: prefer_const_constructors
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mockito/mockito.dart';
import 'package:minsk8/import.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  group('SignUpState', () {
    const email = EmailModel.dirty('email');
    const passwordString = 'password';
    const password = PasswordModel.dirty(passwordString);
    const confirmedPassword = ConfirmedPasswordModel.dirty(
      password: passwordString,
      value: passwordString,
    );

    test('supports value comparisons', () {
      expect(SignUpState(), SignUpState());
    });

    test('returns same object when no properties are passed', () {
      expect(SignUpState().copyWith(), SignUpState());
    });

    test('returns object with updated status when status is passed', () {
      expect(
        SignUpState().copyWith(status: FormzStatus.pure),
        SignUpState(status: FormzStatus.pure),
      );
    });

    test('returns object with updated email when email is passed', () {
      expect(
        SignUpState().copyWith(email: email),
        SignUpState(email: email),
      );
    });

    test('returns object with updated password when password is passed', () {
      expect(
        SignUpState().copyWith(password: password),
        SignUpState(password: password),
      );
    });

    test(
        'returns object with updated confirmedPassword'
        ' when confirmedPassword is passed', () {
      expect(
        SignUpState().copyWith(confirmedPassword: confirmedPassword),
        SignUpState(confirmedPassword: confirmedPassword),
      );
    });
  });

  group('SignUpCubit', () {
    const invalidEmailString = 'invalid';
    const invalidEmail = EmailModel.dirty(invalidEmailString);

    const validEmailString = 'test@gmail.com';
    const validEmail = EmailModel.dirty(validEmailString);

    const invalidPasswordString = 'invalid';
    const invalidPassword = PasswordModel.dirty(invalidPasswordString);

    const validPasswordString = 't0pS3cret1234';
    const validPassword = PasswordModel.dirty(validPasswordString);

    const invalidConfirmedPasswordString = 'invalid';
    const invalidConfirmedPassword = ConfirmedPasswordModel.dirty(
      password: validPasswordString,
      value: invalidConfirmedPasswordString,
    );

    const validConfirmedPasswordString = 't0pS3cret1234';
    const validConfirmedPassword = ConfirmedPasswordModel.dirty(
      password: validPasswordString,
      value: validConfirmedPasswordString,
    );

    AuthenticationRepository authenticationRepository;

    setUp(() {
      authenticationRepository = MockAuthenticationRepository();
    });

    test('throws AssertionError when authenticationRepository is null', () {
      expect(() => SignUpCubit(null), throwsAssertionError);
    });

    test('initial state is SignUpState', () {
      final signUpCubit = SignUpCubit(authenticationRepository);
      expect(signUpCubit.state, SignUpState());
      signUpCubit.close();
    });

    group('emailChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when email/password/confirmedPassword are invalid',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) => cubit.emailChanged(invalidEmailString),
        expect: const <SignUpState>[
          SignUpState(email: invalidEmail, status: FormzStatus.invalid),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository)
          ..emit(SignUpState(
              password: validPassword,
              confirmedPassword: validConfirmedPassword)),
        act: (cubit) => cubit.emailChanged(validEmailString),
        expect: const <SignUpState>[
          SignUpState(
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
            status: FormzStatus.valid,
          ),
        ],
      );
    });

    group('passwordChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when email/password/confirmedPassword are invalid',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) => cubit.passwordChanged(invalidPasswordString),
        expect: const <SignUpState>[
          SignUpState(
            confirmedPassword: ConfirmedPasswordModel.dirty(
              password: invalidPasswordString,
              value: '',
            ),
            password: invalidPassword,
            status: FormzStatus.invalid,
          ),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository)
          ..emit(SignUpState(
              email: validEmail, confirmedPassword: validConfirmedPassword)),
        act: (cubit) => cubit.passwordChanged(validPasswordString),
        expect: const <SignUpState>[
          SignUpState(
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
            status: FormzStatus.valid,
          ),
        ],
      );
    });

    group('confirmedPasswordChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when email/password/confirmedPassword are invalid',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) =>
            cubit.confirmedPasswordChanged(invalidConfirmedPasswordString),
        expect: const <SignUpState>[
          SignUpState(
            confirmedPassword: invalidConfirmedPassword,
            status: FormzStatus.invalid,
          ),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository)
          ..emit(SignUpState(email: validEmail, password: validPassword)),
        act: (cubit) =>
            cubit.confirmedPasswordChanged(validConfirmedPasswordString),
        expect: const <SignUpState>[
          SignUpState(
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
            status: FormzStatus.valid,
          ),
        ],
      );
    });

    group('signUpFormSubmitted', () {
      blocTest<SignUpCubit, SignUpState>(
        'does nothing when status is not validated',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: const <SignUpState>[],
      );

      blocTest<SignUpCubit, SignUpState>(
        'calls signUp with correct email/password/confirmedPassword',
        build: () => SignUpCubit(authenticationRepository)
          ..emit(
            SignUpState(
              status: FormzStatus.valid,
              email: validEmail,
              password: validPassword,
              confirmedPassword: validConfirmedPassword,
            ),
          ),
        act: (cubit) => cubit.signUpFormSubmitted(),
        verify: (_) {
          verify(
            authenticationRepository.signUp(
              email: validEmailString,
              password: validPasswordString,
            ),
          ).called(1);
        },
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [submissionInProgress, submissionSuccess] '
        'when signUp succeeds',
        build: () => SignUpCubit(authenticationRepository)
          ..emit(
            SignUpState(
              status: FormzStatus.valid,
              email: validEmail,
              password: validPassword,
              confirmedPassword: validConfirmedPassword,
            ),
          ),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: const <SignUpState>[
          SignUpState(
            status: FormzStatus.submissionInProgress,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
          ),
          SignUpState(
            status: FormzStatus.submissionSuccess,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
          )
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [submissionInProgress, submissionFailure] '
        'when signUp fails',
        build: () {
          when(authenticationRepository.signUp(
            email: anyNamed('email'),
            password: anyNamed('password'),
          )).thenThrow(Exception('oops'));
          return SignUpCubit(authenticationRepository)
            ..emit(
              SignUpState(
                status: FormzStatus.valid,
                email: validEmail,
                password: validPassword,
                confirmedPassword: validConfirmedPassword,
              ),
            );
        },
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: const <SignUpState>[
          SignUpState(
            status: FormzStatus.submissionInProgress,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
          ),
          SignUpState(
            status: FormzStatus.submissionFailure,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
          )
        ],
      );
    });
  });
}
