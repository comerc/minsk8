import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

// TODO: [MVP] подключить rate_my_app

class FeedbackScreen extends StatelessWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/feedback',
      builder: (_) => this,
      fullscreenDialog: true,
    );
  }

  final _market = Platform.isIOS ? 'Apple Store' : 'Google Play';

  @override
  Widget build(BuildContext context) {
    final child = Container(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Logo(size: kBigButtonIconSize),
          SizedBox(height: 16),
          Text('⭐ ⭐ ⭐ ⭐ ⭐'),
          SizedBox(
            height: 16,
          ),
          Text(
            'Нравится приложение?',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            'Оцени нас в $_market\nи оставь отзыв',
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 24,
          ),
          Text(
            'Мы станем ещё лучше',
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                FlatButton(
                  onLongPress: () {}, // чтобы сократить время для splashColor
                  onPressed: () {
                    // TODO: [MVP] how to open market?
                    // launch_review
                    // For iOS 9 and above, your Info.plist file MUST have the following:
                    // <key>LSApplicationQueriesSchemes</key>
                    // <array>
                    //         <string>itms-beta</string>
                    //         <string>itms</string>
                    // </array>
                    // LaunchReview.launch(
                    //   androidAppId: kAndroidAppId,
                    //   iOSAppId: kIOSAppId,
                    // );
                  },
                  color: Colors.green,
                  textColor: Colors.white,
                  child: Text('Оценить приложение'),
                ),
                OutlineButton(
                  onLongPress: () {}, // чтобы сократить время для splashColor
                  onPressed: () {
                    launchFeedback(
                      subject: 'Сообщить о проблеме',
                      body: 'member_id=${getMemberId(context)}\n',
                    );
                  },
                  textColor: Colors.green,
                  child: Text('Сообщить о проблеме'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: ExtendedAppBar(
        isForeground: true,
        withModel: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ScrollBody(child: child),
      ),
    );
  }
}
