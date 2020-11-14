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

class MockLoginCubit extends MockBloc<LoginState> implements LoginCubit {}

class MockEmailModel extends Mock implements EmailModel {}

class MockPasswordModel extends Mock implements PasswordModel {}

void main() {
  group('MyLoginScreen', () {
    test('has a route', () {
      expect(MyLoginScreen().getRoute(), isA<Route>());
    });

    testWidgets('renders a MyLoginForm', (tester) async {
      await tester.pumpWidget(
        RepositoryProvider<AuthenticationRepository>.value(
          value: MockAuthenticationRepository(),
          child: MaterialApp(home: MyLoginScreen()),
        ),
      );
      expect(find.byType(MyLoginForm), findsOneWidget);
    });
  });

  const loginButtonKey = Key('loginForm_continue_raisedButton');
  const signInWithGoogleButtonKey = Key('loginForm_googleLogin_raisedButton');
  const emailInputKey = Key('loginForm_emailInput_textField');
  const passwordInputKey = Key('loginForm_passwordInput_textField');
  const createAccountButtonKey = Key('loginForm_createAccount_flatButton');

  const testEmail = 'test@gmail.com';
  const testPassword = 'testP@ssw0rd1';

  group('MyLoginForm', () {
    LoginCubit loginCubit;

    setUp(() {
      loginCubit = MockLoginCubit();
      when(loginCubit.state).thenReturn(const LoginState());
    });

    group('calls', () {
      testWidgets('emailChanged when email changes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: MyLoginForm(),
              ),
            ),
          ),
        );
        await tester.enterText(find.byKey(emailInputKey), testEmail);
        verify(loginCubit.emailChanged(testEmail)).called(1);
      });

      testWidgets('passwordChanged when password changes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: MyLoginForm(),
              ),
            ),
          ),
        );
        await tester.enterText(find.byKey(passwordInputKey), testPassword);
        verify(loginCubit.passwordChanged(testPassword)).called(1);
      });

      testWidgets('logInWithCredentials when login button is pressed',
          (tester) async {
        when(loginCubit.state).thenReturn(
          const LoginState(status: FormzStatus.valid),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: MyLoginForm(),
              ),
            ),
          ),
        );
        await tester.tap(find.byKey(loginButtonKey));
        verify(loginCubit.logInWithCredentials()).called(1);
      });

      testWidgets('logInWithGoogle when sign in with google button is pressed',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: MyLoginForm(),
              ),
            ),
          ),
        );
        await tester.tap(find.byKey(signInWithGoogleButtonKey));
        verify(loginCubit.logInWithGoogle()).called(1);
      });
    });

    group('renders', () {
      testWidgets('AuthenticationFailure SnackBar when submission fails',
          (tester) async {
        whenListen(
          loginCubit,
          Stream.fromIterable(const <LoginState>[
            LoginState(status: FormzStatus.submissionInProgress),
            LoginState(status: FormzStatus.submissionFailure),
          ]),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: MyLoginForm(),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(find.text('Authentication Failure'), findsOneWidget);
      });

      testWidgets('invalid email error text when email is invalid',
          (tester) async {
        final email = MockEmailModel();
        when(email.invalid).thenReturn(true);
        when(loginCubit.state).thenReturn(LoginState(email: email));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: MyLoginForm(),
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
        when(loginCubit.state).thenReturn(LoginState(password: password));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: MyLoginForm(),
              ),
            ),
          ),
        );
        expect(find.text('invalid password'), findsOneWidget);
      });

      testWidgets('disabled login button when status is not validated',
          (tester) async {
        when(loginCubit.state).thenReturn(
          const LoginState(status: FormzStatus.invalid),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: MyLoginForm(),
              ),
            ),
          ),
        );
        final loginButton = tester.widget<RaisedButton>(
          find.byKey(loginButtonKey),
        );
        expect(loginButton.enabled, isFalse);
      });

      testWidgets('enabled login button when status is validated',
          (tester) async {
        when(loginCubit.state).thenReturn(
          const LoginState(status: FormzStatus.valid),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: MyLoginForm(),
              ),
            ),
          ),
        );
        final loginButton = tester.widget<RaisedButton>(
          find.byKey(loginButtonKey),
        );
        expect(loginButton.enabled, isTrue);
      });

      testWidgets('Sign in with Google Button', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: MyLoginForm(),
              ),
            ),
          ),
        );
        expect(find.byKey(signInWithGoogleButtonKey), findsOneWidget);
      });
    });

    group('navigates', () {
      testWidgets('to MySignUpScreen when Create Account is pressed',
          (tester) async {
        await tester.pumpWidget(
          RepositoryProvider<AuthenticationRepository>(
            create: (_) => MockAuthenticationRepository(),
            child: MaterialApp(
              navigatorKey: navigatorKey,
              home: Scaffold(
                body: BlocProvider.value(
                  value: loginCubit,
                  child: MyLoginForm(),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.byKey(createAccountButtonKey));
        await tester.pumpAndSettle();
        expect(find.byType(MySignUpScreen), findsOneWidget);
      });
    });
  });
}
