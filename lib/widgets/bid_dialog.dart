import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

// TODO: кнопка ОК и её функционал

class BidDialog extends StatelessWidget {
  BidDialog(this.item);

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
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
                  item.images[0].getDummyUrl(item.id),
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
                    item.price == null
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              FontAwesomeIcons.gift,
                              color: Colors.deepOrangeAccent,
                              size: kButtonIconSize,
                            ),
                          )
                        : Container(
                            color: Colors.white,
                            child: Container(
                              color: Colors.yellow.withOpacity(0.5),
                              height: kButtonHeight,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                item.price.toString(),
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
        Padding(
          padding: EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            item.price == null
                ? 'Точно сможете забрать?'
                : 'Предложить +1 = ${gold(item.price + 1)}?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Stack(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blueAccent,
                size: kButtonIconSize,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: kButtonIconSize + 8),
                child: Text(
                  item.price == null
                      ? 'Только 6 лотов задаром в день.\n\nПовышайте Карму, чтобы увеличить лимит:\nотдавайте и забирайте, приглашайте друзей.'
                      : 'Заморозится до завершения таймера.',
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Stack(
            children: [
              Icon(
                Icons.timer,
                color: Colors.black.withOpacity(0.8),
                size: kButtonIconSize,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: kButtonIconSize + 8),
                child: DeliveryLabel(),
              ),
            ],
          ),
        ),
        Tooltip(
          message: 'Show Map',
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/item_map',
                  arguments: ItemMapRouteArguments(item),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.pinkAccent,
                          size: kButtonIconSize,
                        ),
                        Spacer(),
                        Icon(
                          Icons.navigate_next,
                          color: Colors.black.withOpacity(0.8),
                          size: kButtonIconSize,
                        ),
                      ],
                    ),
                    Flex(
                      direction: Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: kButtonIconSize + 8),
                          constraints: BoxConstraints(maxWidth: 56.0 * 6),
                          child: AddressText(item),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
