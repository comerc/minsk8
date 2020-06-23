import 'package:flutter/material.dart';
// import 'package:minsk8/import.dart';

class ReadyButton extends StatelessWidget {
  ReadyButton({this.onTap});

  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Подтвердить',
      child: Material(
        // borderRadius: BorderRadius.circular(8),
        color: Colors.red,
        child: InkWell(
          splashColor: Colors.white,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              'ГОТОВО',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
