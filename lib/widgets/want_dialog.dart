import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/rendering.dart';
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
                                  fontSize: kPriceFontSize,
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
            title: Text(
              'Самовывоз',
              // такой же стиль для 'Автоповышение ставки'
              style: TextStyle(
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            subtitle: unit.address == null ? null : Text(unit.address),
            trailing: Icon(
              Icons.navigate_next,
              color: Colors.black.withOpacity(0.3),
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
            height: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 8),
                // Row(
                //   children: [
                Container(
                  decoration: BoxDecoration(
                    // color: Colors.red,
                    color: Colors.yellow.withOpacity(0.5),

                    // shape: BoxShape.rectangle,
                    // border: Border.all(
                    //     color: Colors.grey.withOpacity(0.4), width: 1),
                    // borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                  // width: kButtonHeight * kGoldenRatio * 4,
                  height: kButtonHeight,
                  child: ListWheelScrollViewX(
                    scrollDirection: Axis.horizontal,
                    itemExtent: kButtonHeight * kGoldenRatio,
                    useMagnifier: true,
                    magnification: kGoldenRatio,
                    builder: (BuildContext context, int index) {
                      return Container(
                        // width: 100,
                        // height: 22,
                        // padding: EdgeInsets.all(8),
                        // color: Colors.blueAccent,
                        alignment: Alignment.center,
                        child: Text(
                          index.toString(),
                          style: TextStyle(
                            fontSize: kPriceFontSize / kGoldenRatio,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),

                          // style: TextStyle(
                          //   fontSize: 12,
                          //   color: Colors.black.withOpacity(0.8),
                          // ),
                          // textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
                // ],
                // ),
                // SizedBox(height: 8),
              ],
            )),
        Divider(height: 1),
        SizedBox(height: 16),
        Text(
          unit.price == null
              ? 'Только ${getWantLimit(profile.balance)} лотов даром в день'
              : 'Карма заморозится до конца таймера',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: kFontSize,
            color: Colors.black.withOpacity(0.3),
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

class ListWheelScrollViewX extends StatelessWidget {
  ListWheelScrollViewX({
    Key key,
    @required this.builder,
    @required this.itemExtent,
    this.controller,
    this.onSelectedItemChanged,
    this.scrollDirection = Axis.vertical,
    this.diameterRatio = 2,
    this.useMagnifier = false,
    this.magnification = 1,
  }) : super(key: key);

  final Widget Function(BuildContext, int) builder;
  final Axis scrollDirection;
  final FixedExtentScrollController controller;
  final double itemExtent;
  final double diameterRatio;
  final bool useMagnifier;
  final double magnification;
  final void Function(int) onSelectedItemChanged;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: scrollDirection == Axis.horizontal ? 3 : 0,
      child: ListWheelScrollView.useDelegate(
        onSelectedItemChanged: onSelectedItemChanged,
        controller: controller,
        itemExtent: itemExtent,
        diameterRatio: diameterRatio,
        useMagnifier: useMagnifier,
        magnification: magnification,
        physics: FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (BuildContext context, int index) {
            return RotatedBox(
              quarterTurns: scrollDirection == Axis.horizontal ? 1 : 0,
              child: builder(context, index),
            );
          },
        ),
      ),
    );
  }
}
