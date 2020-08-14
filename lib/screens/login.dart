import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minsk8/import.dart';

// TODO: Step-by-step guide to Android code signing and code signing https://blog.codemagic.io/the-simple-guide-to-android-code-signing/

// How to add SHA1 https://stackoverflow.com/a/57505927

// TODO: flutter_secure_storage для хранения токена авторизации?
// TODO: [MVP] реализовать аутентификацию через: FB, Google, Apple Id, VK, Telegram
// Google Sign In https://medium.com/flutter-community/flutter-implementing-google-sign-in-71888bca24ed
// Facebook Sign In https://medium.com/@karlwhiteprivate/flutter-facebook-sign-in-with-firebase-in-2020-66556a8c3586
// Apple SignIn https://medium.com/@karlwhiteprivate/flutter-firebase-sign-in-with-apple-c99967df142f
// https://ru.stackoverflow.com/questions/667654/%D0%90%D0%B2%D1%82%D0%BE%D1%80%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F-vk-%D0%B2-%D1%81%D0%B2%D1%8F%D0%B7%D0%BA%D0%B5-%D1%81-firebase
// https://qna.habr.com/q/587426
// TODO: как объединять аккаунты https://firebase.google.com/docs/auth/android/account-linking
// TODO: аутентификация через одноразовый пароль в телегу
// http://www.outsidethebox.ms/18835/
// https://habr.com/ru/post/331502/
// https://habr.com/ru/post/321682/
// https://github.com/Flutterando/auth-service/

// Аутентификация пользователя через вк:
// https://firebase.google.com/docs/auth/android/custom-auth
// Надо будет развернуть сервер с firebase admin, авторизовать на нём пользователя из вк,
// получить custom token для firebase, и его уже передавать в firebase auth.
// Либо можно на клиенте авторизовывать в вк, а в firebase передавать как авторизацию по почте,
// придумав пароль за пользователя.

class LoginScreen extends StatelessWidget {
  LoginScreen({this.onClose});

  final Function(AuthData authData) onClose;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Login'),
          RaisedButton(
            onPressed: () async {
              final credential = await signInWithGoogle();
              final authResult =
                  await FirebaseAuth.instance.signInWithCredential(credential);
              final user = authResult.user;
              // if (user.isAnonymous) return null;
              final idToken = await user.getIdToken();
              Navigator.of(context).pop();
              onClose(AuthData(user: user, token: idToken.token));
            },
          ),
        ],
      ),
    );
    return Scaffold(
      body: child,
    );
  }

  Future<AuthCredential> signInWithGoogle() async {
    final googleSignInAccount = await _googleSignIn.signIn();
    final googleSignInAuthentication = await googleSignInAccount.authentication;
    return GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
  }
}
