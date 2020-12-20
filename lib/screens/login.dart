import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

// TODO: [MVP] неправильная иконка приложения при входе через Google

// TODO: реализовать аутентификацию через: Google, Apple Id, FB, VK, Telegram
// + Google Sign In https://medium.com/flutter-community/flutter-implementing-google-sign-in-71888bca24ed
// Facebook Sign In https://medium.com/@karlwhiteprivate/flutter-facebook-sign-in-with-firebase-in-2020-66556a8c3586
// Apple SignIn https://medium.com/@karlwhiteprivate/flutter-firebase-sign-in-with-apple-c99967df142f
// VK Sign In https://ru.stackoverflow.com/questions/667654/%D0%90%D0%B2%D1%82%D0%BE%D1%80%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F-vk-%D0%B2-%D1%81%D0%B2%D1%8F%D0%B7%D0%BA%D0%B5-%D1%81-firebase

// Аутентификация пользователя через вк:
// https://firebase.google.com/docs/auth/android/custom-auth
// Надо будет развернуть сервер с firebase admin, авторизовать на нём пользователя из вк,
// получить custom token для firebase, и его уже передавать в firebase auth.
// Либо можно на клиенте авторизовывать в вк, а в firebase передавать как авторизацию по почте,
// придумав пароль за пользователя.

// TODO: flutter telegram-auth

class LoginScreen extends StatelessWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/login',
      builder: (_) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (BuildContext context) =>
            LoginCubit(getRepository<AuthenticationRepository>(context)),
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: 250,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Logo(),
            SizedBox(height: 48),
            OutlineButton(
              shape: StadiumBorder(),
              onLongPress: () {}, // чтобы сократить время для splashColor
              onPressed: () {
                save(() => getBloc<LoginCubit>(context).logInWithGoogle());
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: kButtonIconSize,
                    height: kButtonIconSize,
                    child: FittedBox(
                      child: Icon(
                        FontAwesomeIcons.google,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Войти через Google'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
