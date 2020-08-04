import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:launch_review/launch_review.dart';
import 'package:minsk8/import.dart';

class FeedbackScreen extends StatelessWidget {
  final _market = Platform.isIOS ? 'Apple Store' : 'Google Play';

  @override
  Widget build(BuildContext context) {
    final child = Container(
      alignment: Alignment.topCenter,
      color: Colors.white,
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
          Container(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                FlatButton(
                  child: Text('Оценить приложение'),
                  onLongPress: () {}, // чтобы сократить время для splashColor
                  onPressed: () {
                    // TODO: how to open market?
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
                ),
                OutlineButton(
                  child: Text('Сообщить о проблеме'),
                  onLongPress: () {}, // чтобы сократить время для splashColor
                  onPressed: () {
                    launchFeedback(context, subject: 'Сообщить о проблеме');
                  },
                  textColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: ExtendedAppBar(
        elevation: 0,
      ),
      body: buildScrollBody(child),
    );
  }
}
