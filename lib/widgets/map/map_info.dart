import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

Widget buildMapInfo(String data, {Widget child, Function onClose}) {
  return Stack(
    children: [
      child,
      Positioned(
        top: 48,
        left: 16,
        right: 16,
        child: IgnorePointer(
          child: Material(
            elevation: kButtonElevation,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.white,
              child: Text(
                  'Укажите желаемое местоположение, чтобы смотреть лоты поблизости'),
            ),
          ),
        ),
      ),
      Positioned(
        top: 48,
        right: 16,
        child: Tooltip(
          message: 'Закрыть',
          child: Material(
            child: InkWell(
              child: Icon(
                Icons.close,
                color: Colors.black.withOpacity(0.8),
                size: 20,
              ),
              onTap: onClose,
            ),
          ),
        ),
      ),
    ],
  );
}
