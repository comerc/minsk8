// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mockito/mockito.dart';
import 'package:minsk8/import.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockSignUpCubit extends MockBloc<SignUpState> implements SignUpCubit {}

class MockEmailModel extends Mock implements EmailModel {}

class MockPasswordModel extends Mock implements PasswordModel {}

class MockConfirmedPasswordModel extends Mock
    implements ConfirmedPasswordModel {}

void main() {
  group('MySignUpScreen', () {
    test('has a route', () {
      expect(MySignUpScreen().getRoute(), isA<Route>());
    });

    testWidgets('renders a MySignUpForm', (tester) async {
      await tester.pumpWidget(
        RepositoryProvider<AuthenticationRepository>(
          create: (_) => MockAuthenticationRepository(),
          child: MaterialApp(home: MySignUpScreen()),
        ),
      );
      expect(find.byType(MySignUpForm), findsOneWidget);
    });
  });

  const signUpButtonKey = Key('signUpForm_continue_raisedButton');
  const emailInputKey = Key('signUpForm_emailInput_textField');
  const passwordInputKey = Key('signUpForm_passwordInput_textField');
  const confirmedPasswordInputKey =
      Key('signUpForm_confirmedPasswordInput_textField');

  const testEmail = 'test@gmail.com';
  const testPassword = 'testP@ssw0rd1';
  const testConfirmedPassword = 'testP@ssw0rd1';

  group('MySignUpForm', () {
    SignUpCubit signUpCubit;

    setUp(() {
      signUpCubit = MockSignUpCubit();
      when(signUpCubit.state).thenReturn(const SignUpState());
    });

    group('calls', () {
      testWidgets('emailChanged when email changes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: MySignUpForm(),
              ),
            ),
          ),
        );
        await tester.enterText(find.byKey(emailInputKey), testEmail);
        verify(signUpCubit.emailChanged(testEmail)).called(1);
      });

      testWidgets('passwordChanged when password changes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: MySignUpForm(),
              ),
            ),
          ),
        );
        await tester.enterText(find.byKey(passwordInputKey), testPassword);
        verify(signUpCubit.passwordChanged(testPassword)).called(1);
      });

      testWidgets('confirmedPasswordChanged when confirmedPassword changes',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: MySignUpForm(),
              ),
            ),
          ),
        );
        await tester.enterText(
            find.byKey(confirmedPasswordInputKey), testConfirmedPassword);
        verify(signUpCubit.confirmedPasswordChanged(testConfirmedPassword))
            .called(1);
      });

      testWidgets('signUpFormSubmitted when sign up button is pressed',
          (tester) async {
        when(signUpCubit.state).thenReturn(
          const SignUpState(status: FormzStatus.valid),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: MySignUpForm(),
              ),
            ),
          ),
        );
        await tester.tap(find.byKey(signUpButtonKey));
        verify(signUpCubit.signUpFormSubmitted()).called(1);
      });
    });

    group('renders', () {
      testWidgets('Sign Up Failure SnackBar when submission fails',
          (tester) async {
        whenListen(
          signUpCubit,
          Stream.fromIterable(const <SignUpState>[
            SignUpState(status: FormzStatus.submissionInProgress),
            SignUpState(status: FormzStatus.submissionFailure),
          ]),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: MySignUpForm(),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(find.text('Sign Up Failure'), findsOneWidget);
      });

      testWidgets('invalid email error text when email is invalid',
          (tester) async {
        final email = MockEmailModel();
        when(email.invalid).thenReturn(true);
        when(signUpCubit.state).thenReturn(SignUpState(email: email));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: MySignUpForm(),
              ),
            ),
          ),
        );
        expect(find.text('invalid email'), findsOneWidget);
      });

      testWidgets('invalid password error text when password is invalid',
          (tester) async {
        final password = MockPasswordModel();
        when(password.invalid).thenReturn(true);
        when(signUpCubit.state).thenReturn(SignUpState(password: password));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: MySignUpForm(),
              ),
            ),
          ),
        );
        expect(find.text('invalid password'), findsOneWidget);
      });

      testWidgets(
          'invalid confirmedPassword error text'
          ' when confirmedPassword is invalid', (tester) async {
        final confirmedPassword = MockConfirmedPasswordModel();
        when(confirmedPassword.invalid).thenReturn(true);
        when(signUpCubit.state)
            .thenReturn(SignUpState(confirmedPassword: confirmedPassword));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: MySignUpForm(),
              ),
            ),
          ),
        );
        expect(find.text('passwords do not match'), findsOneWidget);
      });

      testWidgets('disabled sign up button when status is not validated',
          (tester) async {
        when(signUpCubit.state).thenReturn(
          const SignUpState(status: FormzStatus.invalid),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: MySignUpForm(),
              ),
            ),
          ),
        );
        final signUpButton = tester.widget<RaisedButton>(
          find.byKey(signUpButtonKey),
        );
        expect(signUpButton.enabled, isFalse);
      });

      testWidgets('enabled sign up button when status is validated',
          (tester) async {
        when(signUpCubit.state).thenReturn(
          const SignUpState(status: FormzStatus.valid),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: MySignUpForm(),
              ),
            ),
          ),
        );
        final signUpButton = tester.widget<RaisedButton>(
          find.byKey(signUpButtonKey),
        );
        expect(signUpButton.enabled, isTrue);
      });
    });
  });
}
