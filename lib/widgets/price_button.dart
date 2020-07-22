import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

class PriceButton extends StatelessWidget {
  PriceButton(this.unit);

  final UnitModel unit;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Price',
      child: Material(
        color: Colors.yellow.withOpacity(0.5),
        // borderRadius: BorderRadius.all(kImageBorderRadius),
        child: InkWell(
          splashColor: Colors.white.withOpacity(0.4),
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          child: Container(
            height: kButtonHeight,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Text(
              unit.price.toString(),
              style: TextStyle(
                fontSize: 23,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                if (unit.isClosed) {
                  return AlertDialog(
                    content: Text('Сколько предложено за лот'),
                    actions: [
                      FlatButton(
                        child: Text('ОК'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                }
                return InfoDialog(
                  icon: FontAwesomeIcons.moneyBill,
                  title: 'Сколько сейчас\nпредлагают за лот',
                  description:
                      'Нажмите "хочу забрать",\nчтобы предложить больше',
                );
              },
            );
          },
        ),
      ),
    );
  }
}
