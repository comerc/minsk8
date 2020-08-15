import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

// TODO: Step-by-step guide to Android code signing and code signing https://blog.codemagic.io/the-simple-guide-to-android-code-signing/

// IF (SELECT id FROM mytable WHERE other_key = 'SOMETHING' LIMIT 1) < 0 THEN
//  INSERT INTO mytable (other_key) VALUES ('SOMETHING')
// END IF

// https://github.com/flutter/flutter/issues/33393#issuecomment-510395178

// A tutorial for using Firebase to add authentication and authorization to a realtime Hasura app https://hasura.io/blog/authentication-and-authorization-using-hasura-and-firebase/
// Hasura Authentication with Firebase https://medium.com/swlh/hasura-authentication-with-firebase-ee5543d57772
// Super Simple Authentication Flow with Flutter & Firebase https://medium.com/coding-with-flutter/super-simple-authentication-flow-with-flutter-firebase-737bba04924c

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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final child = ButtonTheme(
      minWidth: 250,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Logo(),
            SizedBox(height: 48),
            OutlineButton(
              shape: StadiumBorder(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    color: Colors.red,
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
              onLongPress: () {}, // чтобы сократить время для splashColor
              onPressed: () async {
                try {
                  final credential = await _signInWithGoogle();
                  final authResult = await FirebaseAuth.instance
                      .signInWithCredential(credential);
                  final user = authResult.user;
                  final token = await _getToken(context: context, user: user);
                  Navigator.of(context).pop();
                  onClose(AuthData(user: user, token: token));
                } on PlatformException catch (error) {
                  final snackBar = SnackBar(
                    content: Text(error.message),
                    action: SnackBarAction(
                      label: 'Сообщить о проблеме',
                      onPressed: () {
                        launchFeedback(
                          context,
                          subject: 'Сообщить о проблеме',
                          isAnonymous: true,
                        );
                      },
                    ),
                  );
                  _scaffoldKey.currentState.showSnackBar(snackBar);
                  debugPrint(error.toString());
                }
              },
            ),
            if (isInDebugMode)
              OutlineButton(
                shape: StadiumBorder(),
                child: Text('Sign Out'),
                onLongPress: () {}, // чтобы сократить время для splashColor
                onPressed: () {
                  _signOutWithGoogle();
                },
              ),
          ],
        ),
      ),
    );
    return Scaffold(
      key: _scaffoldKey,
      body: child,
      backgroundColor: Colors.white,
    );
  }

  Future<String> _getToken({
    context,
    user,
    retry = 0,
  }) async {
    if (retry < 4) {
      await Future.delayed(Duration(milliseconds: 100));
    } else {
      await showDialog(
        context: context,
        child: AlertDialog(
          content: Text('Не удалось получить доступ, попробуйте ещё раз.'),
          actions: <Widget>[
            FlatButton(
              child: Text('ОК'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
    final idToken = await user.getIdToken(refresh: true);
    final map = parseIdToken(idToken.token);
    if (map['https://hasura.io/jwt/claims'] == null) {
      return _getToken(context: context, user: user, retry: retry + 1);
    }
    return idToken.token;
  }

  Future<AuthCredential> _signInWithGoogle() async {
    // TODO: после регистрации на Web, запускать без дополнительных вопросов (как WeBull)
    // var googleSignInAccount = _googleSignIn.currentUser;
    // googleSignInAccount ??=
    //     await _googleSignIn.signInSilently(); // exception workaround: CTRL+F5
    // googleSignInAccount ??= await _googleSignIn.signIn();
    final googleSignInAccount = await _googleSignIn.signIn();
    final googleSignInAuthentication = await googleSignInAccount.authentication;
    return GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
  }

  Future<void> _signOutWithGoogle() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
  }
}
