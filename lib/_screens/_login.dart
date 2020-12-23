// ignore_for_file: unused_field
// ignore_for_file: unused_element
// ignore_for_file: prefer_final_fields
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minsk8/import.dart';

class AuthData {
  AuthData({
    this.user,
    this.token,
    this.isLogin = false,
  });

  final firebase_auth.User user;
  final String token;
  final bool isLogin;
}

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
              onLongPress: _isLoading
                  ? null
                  : () {}, // чтобы сократить время для splashColor
              onPressed: _isLoading ? null : _signInWithGoogle,
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
            if (isInDebugMode)
              OutlineButton(
                shape: StadiumBorder(),
                onLongPress: _isLoading
                    ? null
                    : () {}, // чтобы сократить время для splashColor
                onPressed: _isLoading ? null : _signOut,
                child: Text('Sign Out'),
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
    BuildContext context,
    firebase_auth.User user,
    int retry = 0,
  }) async {
    // if (retry < 4) {
    //   await Future.delayed(Duration(milliseconds: 100));
    // } else {
    //   await showDialog(
    //     context: context,
    //     child: AlertDialog(
    //       content: Text('Не удалось получить доступ, попробуйте ещё раз.'),
    //       actions: <Widget>[
    //         FlatButton(
    //           onPressed: () {
    //             navigator.pop();
    //           },
    //           child: Text('ОК'),
    //         ),
    //       ],
    //     ),
    //   );
    // }
    // final idToken = await user.getIdToken(refresh: true);
    // final map = parseIdToken(idToken.token);
    // if (map['https://hasura.io/jwt/claims'] == null) {
    //   return _getToken(context: context, user: user, retry: retry + 1);
    // }
    // return idToken.token;
    return null;
  }

  void _signIn(
      {Future<firebase_auth.AuthCredential> Function() getCredentials}) async {
    // try {
    //   setState(() {
    //     _isLoading = true;
    //   });
    //   final credential = await getCredentials();
    //   final authResult =
    //       await FirebaseAuth.instance.signInWithCredential(credential);
    //   final user = authResult.user;
    //   final token = await _getToken(context: context, user: user);
    //   navigator.pop();
    //   widget.onClose(
    //     AuthData(
    //       user: user,
    //       token: token,
    //       isLogin: true,
    //     ),
    //   );
    // } catch (error) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   final snackBar = SnackBar(
    //     content: Text(error.toString()),
    //     action: SnackBarAction(
    //       label: 'Сообщить о проблеме',
    //       onPressed: () {
    //         launchFeedback(
    //           subject: 'Сообщить о проблеме',
    //         );
    //       },
    //     ),
    //   );
    //   _scaffoldKey.currentState.showSnackBar(snackBar);
    //   out(error);
    // }
  }

  void _signInWithGoogle() {
    // _signIn(getCredentials: () async {
    //   // TODO: после регистрации на Web, запускать без дополнительных вопросов (как WeBull)
    //   // var googleSignInAccount = _googleSignIn.currentUser;
    //   // googleSignInAccount ??=
    //   //     await _googleSignIn.signInSilently(); // exception workaround: CTRL+F5
    //   // googleSignInAccount ??= await _googleSignIn.signIn();
    //   final googleSignInAccount = await _googleSignIn.signIn();
    //   final googleSignInAuthentication =
    //       await googleSignInAccount.authentication;
    //   return GoogleAuthProvider.getCredential(
    //     accessToken: googleSignInAuthentication.accessToken,
    //     idToken: googleSignInAuthentication.idToken,
    //   );
    // });
  }

  void _signOut() async {
    // try {
    //   setState(() {
    //     _isLoading = true;
    //   });
    //   final user = await FirebaseAuth.instance.currentUser();
    //   final idToken = await user.getIdToken();
    //   final signInProvider = idToken.signInProvider;
    //   await FirebaseAuth.instance.signOut();
    //   if (signInProvider == 'google.com' && await _googleSignIn.isSignedIn()) {
    //     await _googleSignIn.disconnect();
    //     await _googleSignIn.signOut();
    //   }
    // } catch (error) {
    //   out(error);
    // } finally {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }
  }
}
