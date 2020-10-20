import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minsk8/import.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  EquatableConfig.stringify = kDebugMode;
  // Bloc.observer = SimpleBlocObserver();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: AuthenticationRepository(),
      child: BlocProvider(
        create: (BuildContext context) => AuthenticationCubit(context),
        child: AppView(),
      ),
    );
  }
}

final _navigatorKey = GlobalKey<NavigatorState>();

NavigatorState get navigator => _navigatorKey.currentState;

class AppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      navigatorKey: _navigatorKey,
      builder: (BuildContext context, Widget child) {
        return BlocListener<AuthenticationCubit, AuthenticationState>(
          listener: (BuildContext context, AuthenticationState state) {
            final cases = {
              AuthenticationStatus.authenticated: () =>
                  navigator.pushAndRemoveUntil<void>(
                    MyHomeScreen.route(),
                    (Route route) => false,
                  ),
              AuthenticationStatus.unauthenticated: () =>
                  navigator.pushAndRemoveUntil<void>(
                    MyLoginScreen.route(),
                    (Route route) => false,
                  ),
              AuthenticationStatus.unknown: () => null,
            };
            assert(cases.length == AuthenticationStatus.values.length);
            cases[state.status]();
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => MySplashScreen.route(),
    );
  }
}
