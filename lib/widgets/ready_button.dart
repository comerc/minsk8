import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';
// import 'package:minsk8/import.dart';

class ReadyButton extends StatelessWidget {
  ReadyButton({this.onTap, this.isRaised = false});

  final Function onTap;
  final bool isRaised;

  @override
  Widget build(BuildContext context) {
    // Tooltip перекрывает onLongPress для FlutterMap
    return Tooltip(
      message: 'Подтвердить',
      child: Material(
        elevation: isRaised ? kButtonElevation : 0,
        // borderRadius: BorderRadius.circular(8),
        color: Colors.red,
        child: InkWell(
          splashColor: Colors.white.withOpacity(0.4),
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
