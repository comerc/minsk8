import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

class KindButton extends StatelessWidget {
  KindButton(this.model, {this.isSelected});

  final KindModel model;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Выберите категорию',
      child: Material(
        elevation: kButtonElevation,
        color: isSelected ? Colors.red : Colors.white,
        child: InkWell(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (model.isNew ?? false)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    color: Colors.red,
                    child: Text(
                      'новое',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TODO: поменять иконки для категорий
                  Logo(
                    size: kBigButtonIconSize,
                    hasShaderMask: !isSelected,
                  ),
                  SizedBox(height: 8),
                  Text(
                    model.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Colors.black.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).pop(model.value);
          },
        ),
      ),
    );
  }
}
