import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minsk8/import.dart';

// IF (SELECT id FROM mytable WHERE other_key = 'SOMETHING' LIMIT 1) < 0 THEN
//  INSERT INTO mytable (other_key) VALUES ('SOMETHING')
// END IF

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

class LoginScreen extends StatefulWidget {
  LoginScreen({this.onClose});

  final Function(AuthData authData) onClose;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _isLoading = false;

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
              onLongPress: _isLoading
                  ? null
                  : () {}, // чтобы сократить время для splashColor
              onPressed: _isLoading ? null : _signInWithGoogle,
            ),
            if (isInDebugMode)
              OutlineButton(
                shape: StadiumBorder(),
                child: Text('Sign Out'),
                onLongPress: _isLoading
                    ? null
                    : () {}, // чтобы сократить время для splashColor
                onPressed: _isLoading ? null : _signOut,
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

  void _signIn({Future<AuthCredential> Function() getCredentials}) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final credential = await getCredentials();
      final authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = authResult.user;
      final token = await _getToken(context: context, user: user);
      Navigator.of(context).pop();
      widget.onClose(AuthData(user: user, token: token));
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      final snackBar = SnackBar(
        content: Text(error.toString()),
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
  }

  void _signInWithGoogle() {
    _signIn(getCredentials: () async {
      // TODO: после регистрации на Web, запускать без дополнительных вопросов (как WeBull)
      // var googleSignInAccount = _googleSignIn.currentUser;
      // googleSignInAccount ??=
      //     await _googleSignIn.signInSilently(); // exception workaround: CTRL+F5
      // googleSignInAccount ??= await _googleSignIn.signIn();
      final googleSignInAccount = await _googleSignIn.signIn();
      final googleSignInAuthentication =
          await googleSignInAccount.authentication;
      return GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
    });
  }

  void _signOut() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final user = await FirebaseAuth.instance.currentUser();
      final idToken = await user.getIdToken();
      final signInProvider = idToken.signInProvider;
      await FirebaseAuth.instance.signOut();
      if (signInProvider == 'google.com' && await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
        await _googleSignIn.signOut();
      }
    } catch (error) {
      debugPrint(error.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
