import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:minsk8/import.dart';

Widget buildProgressIndicator(BuildContext context) {
  return Platform.isIOS
      ? CupertinoActivityIndicator(
          animating: true,
          radius: 16,
        )
      : CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
        );
}
