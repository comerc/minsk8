import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:minsk8/import.dart';
import 'package:provider/provider.dart';

// TODO: кнопка ОК и её функционал
// https://hasura.io/docs/1.0/graphql/manual/api-reference/schema-metadata-api/scheduled-triggers.html
// https://hasura.io/docs/1.0/graphql/manual/scheduled-triggers/create-one-off-scheduled-event.html

// TODO: автоповышение

class WantDialog extends StatelessWidget {
  WantDialog(this.unit);

  final UnitModel unit;

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileModel>(context, listen: false);
    final imageHeight = 96.0;
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(vertical: 16),
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                height: imageHeight,
                width: imageHeight,
                margin: EdgeInsets.only(bottom: kButtonHeight / 2),
                child: ExtendedImage.network(
                  unit.images[0].getDummyUrl(unit.id),
                  fit: BoxFit.cover,
                  enableLoadState: false,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    unit.price == null
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.all(8),
                            child: Logo(size: kButtonIconSize),
                          )
                        : Container(
                            color: Colors.white,
                            child: Container(
                              color: Colors.yellow.withOpacity(0.5),
                              height: kButtonHeight,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                unit.price.toString(),
                                style: TextStyle(
                                  fontSize: 23,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Text(
          unit.price == null
              ? 'Точно сможете забрать?'
              : 'Предложить ${getPluralKarma(unit.price + 1)}?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 8),
        Tooltip(
          message: 'Show Map',
          child: ListTile(
            dense: true,
            title: Text('Самовывоз'),
            subtitle: unit.address == null ? null : Text(unit.address),
            trailing: Icon(
              Icons.navigate_next,
              color: Colors.black.withOpacity(0.8),
              size: kButtonIconSize,
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/unit_map',
                arguments: UnitMapRouteArguments(unit),
              );
            },
          ),
        ),
        Divider(height: 1),
        AutoIncreaseField(
          child: Text(
            '1111',
          ),
        ),
        Divider(height: 1),
        SizedBox(height: 16),
        Text(
          unit.price == null
              ? 'Только ${getWantLimit(profile.balance)} лотов даром в день'
              : 'Карма заморозится до конца таймера',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: kFontSize,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlineButton(
              child: Text('Отмена'),
              onLongPress: () {}, // чтобы сократить время для splashColor
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            SizedBox(
              width: 16,
            ),
            FlatButton(
              child: Text('Да'),
              onLongPress: () {}, // чтобы сократить время для splashColor
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              color: Colors.red,
              textColor: Colors.white,
            ),
          ],
        ),
      ],
    );
  }
}
