import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

void showCancelItemDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        height: 200,
        color: Colors.amber,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Modal BottomSheet'),
              RaisedButton(
                child: const Text('Close BottomSheet'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ),
      );
    },
  );
}
