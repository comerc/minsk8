import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

class AddedItemDialog extends StatelessWidget {
  AddedItemDialog(this.item, {this.needModerate: false});

  final ItemModel item;
  final bool needModerate;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      children: [
        Icon(
          FontAwesomeIcons.gift,
          color: Colors.deepOrangeAccent,
          size: kButtonIconSize,
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            needModerate ? 'Лот успешно добавлен' : 'Ура! Ваш лот добавлен',
            textAlign: TextAlign.center,
            style: TextStyle(
              // fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            needModerate
                ? 'Мы Вам сообщим, когда лот пройдёт модерацию'
                : 'Победитель Вам напишет.\nСпасибо за доброе дело!',
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: needModerate ? 72 : 32,
            right: needModerate ? 72 : 32,
          ),
          child: Column(
            children: [
              MaterialButton(
                minWidth: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.plus,
                      size: kButtonIconSize,
                    ),
                    SizedBox(width: 8),
                    Text('Добавьте ещё один лот'),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                color: Colors.red,
                textColor: Colors.white,
                elevation: 0,
                highlightElevation: 0,
              ),
              if (!needModerate)
                MaterialButton(
                  minWidth: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.share,
                        size: kButtonIconSize,
                      ),
                      SizedBox(width: 8),
                      Text('Поделитесь и получите бонус'),
                    ],
                  ),
                  onPressed: () {
                    share(item);
                  },
                  color: Colors.white,
                  textColor: Colors.red,
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: BorderSide(color: Colors.red)),
                  elevation: 0,
                  highlightElevation: 0,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
