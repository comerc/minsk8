// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:minsk8/import.dart';

class MockAuthenticationBloc extends MockBloc<AuthenticationState>
    implements AuthenticationCubit {}

// ignore: must_be_immutable
class MockUserModel extends Mock implements UserModel {
  @override
  String get email => 'test@gmail.com';
}

void main() {
  const logoutButtonKey = Key('homeScreen_logout_iconButton');
  group('MyHomeScreen', () {
    AuthenticationCubit authenticationBloc;
    UserModel user;

    setUp(() {
      authenticationBloc = MockAuthenticationBloc();
      user = MockUserModel();
      when(authenticationBloc.state).thenReturn(
        AuthenticationState.authenticated(user),
      );
    });

    test('has a route', () {
      expect(MyHomeScreen().getRoute(), isA<Route>());
    });

    group('calls', () {
      testWidgets('AuthenticationLogoutRequested when logout is pressed',
          (tester) async {
        await tester.pumpWidget(
          BlocProvider.value(
            value: authenticationBloc,
            child: MaterialApp(
              home: MyHomeScreen(),
            ),
          ),
        );
        await tester.tap(find.byKey(logoutButtonKey));
        verify(authenticationBloc.requestLogout()).called(1);
      });
    });

    group('renders', () {
      testWidgets('avatar widget', (tester) async {
        await tester.pumpWidget(
          BlocProvider.value(
            value: authenticationBloc,
            child: MaterialApp(
              home: MyHomeScreen(),
            ),
          ),
        );
        expect(find.byType(MyAvatar), findsOneWidget);
      });

      testWidgets('email address', (tester) async {
        await tester.pumpWidget(
          BlocProvider.value(
            value: authenticationBloc,
            child: MaterialApp(
              home: MyHomeScreen(),
            ),
          ),
        );
        expect(find.text('test@gmail.com'), findsOneWidget);
      });

      testWidgets('name', (tester) async {
        when(user.name).thenReturn('Joe');
        await tester.pumpWidget(
          BlocProvider.value(
            value: authenticationBloc,
            child: MaterialApp(
              home: MyHomeScreen(),
            ),
          ),
        );
        expect(find.text('Joe'), findsOneWidget);
      });
    });
  });
}
