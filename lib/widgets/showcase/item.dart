import 'dart:async';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share/share.dart'; // as share;
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:minsk8/import.dart';

// TODO: загрузка блюриной миниатюры, пока грузится большая картинка
// TODO: пока грузится картинка, показывать серый прямоугольник

class ShowcaseItem extends StatefulWidget {
  ShowcaseItem({
    Key key,
    this.unit,
    this.tagPrefix,
    this.isCover,
  }) : super(key: key);

  final UnitModel unit;
  final String tagPrefix;
  final bool isCover;

  @override
  _ShowcaseItemState createState() {
    return _ShowcaseItemState();
  }
}

class _ShowcaseItemState extends State<ShowcaseItem> {
  bool _isBottom = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // hack for https://github.com/fluttercandies/loading_more_list/issues/20
        SizedBox(height: 16),
        _buildImage(),
        _buildBottom(),
      ],
    );
  }

  Widget _buildImage() {
    final unit = widget.unit;
    final isCover = widget.isCover;
    final image = unit.images[0];
    return Material(
      child: InkWell(
        onLongPress: () {}, // чтобы сократить время для splashColor
        onTap: () {
          // Navigator.of(context).push(PageRouteBuilder(
          //   settings: RouteSettings(
          //     arguments: UnitRouteArguments(unit, tag: tag),
          //   ),
          //   pageBuilder: (context, animation, secondaryAnimation) =>
          //       UnitScreen(),
          //   transitionsBuilder:
          //       (context, animation, secondaryAnimation, child) {
          //     return child;
          //   },
          // ));
          setState(() {
            _isBottom = false;
          });
          Navigator.pushNamed(
            context,
            '/unit',
            arguments: UnitRouteArguments(
              unit,
              member: unit.member,
              isShowcase: true,
            ),
          ).then((_) {
            setState(() {
              _isBottom = true;
            });
          });
        },
        splashColor: Colors.white.withOpacity(0.4),
        child: AspectRatio(
          aspectRatio:
              isCover ? 1 / getMagicHeight(1) : image.width / image.height,
          child: Hero(
            tag: '${widget.tagPrefix}-${unit.id}',
            child: Ink.image(
              fit: isCover ? BoxFit.cover : BoxFit.contain,
              image: ExtendedImage.network(
                image.getDummyUrl(unit.id),
                // shape: BoxShape.rectangle,
                // border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1),
                // borderRadius: BorderRadius.all(kImageBorderRadius),
                loadStateChanged: loadStateChanged,
              ).image,
              child: Stack(
                // fit: StackFit.expand,
                children: <Widget>[
                  _buildText(),
                  if (unit.isBlockedOrLocalDeleted)
                    _buildStatus(
                      'Заблокировано',
                      isClosed: true,
                    )
                  else if (unit.transferredAt != null)
                    _buildStatus(
                      'Забрали',
                      isClosed: true,
                    )
                  else if (unit.win != null)
                    _buildStatus(
                      'Завершено',
                      isClosed: true,
                    )
                  else if (unit.expiresAt != null)
                    CountdownTimer(
                      endTime: unit.expiresAt.millisecondsSinceEpoch,
                      builder: (BuildContext context, int seconds) {
                        return _buildStatus(
                          seconds < 1 ? 'Завершено' : formatDDHHMMSS(seconds),
                          isClosed: seconds < 1,
                        );
                      },
                    )
                  else if (unit.urgent != UrgentValue.none)
                    _buildStatus(
                      kUrgents
                          .firstWhere((UrgentModel urgentModel) =>
                              urgentModel.value == unit.urgent)
                          .name,
                      isClosed: false,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottom() {
    final unit = widget.unit;
    if (!_isBottom) {
      return SizedBox(
        height: kButtonHeight,
      );
    }
    return Row(
      children: <Widget>[
        unit.price == null ? GiftButton(unit) : PriceButton(unit),
        Spacer(),
        SizedBox(
          width: kButtonWidth,
          height: kButtonHeight,
          child: ShareButton(unit),
        ),
        SizedBox(
          width: kButtonWidth,
          height: kButtonHeight,
          child: WishButton(unit),
        ),
      ],
    );
  }

  Widget _buildText() {
    final text = widget.unit.text;
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
            colors: <Color>[
              Colors.grey.withOpacity(0.0),
              Colors.black.withOpacity(0.4),
            ],
          ),
        ),
        padding: EdgeInsets.only(
          left: 8,
          top: 32,
          right: 8,
          bottom: 8,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildStatus(String data, {bool isClosed}) {
    return Positioned(
      top: 0,
      left: 0,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isClosed
              ? Colors.grey.withOpacity(0.8)
              : Colors.pink.withOpacity(0.8),
          // border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1),
          // borderRadius: BorderRadius.all(Radius.circular(6.5)),
          // borderRadius: BorderRadius.only(
          //   // topLeft: kImageBorderRadius,
          //   bottomRight: kImageBorderRadius,
          // ),
        ),
        child: Text(
          data,
          style: TextStyle(
            fontSize: kFontSize,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// TODO: https://github.com/hnvn/flutter_flip_panel

class CountdownTimer extends StatefulWidget {
  CountdownTimer({
    this.endTime,
    this.builder,
    this.onClose,
  });

  final int endTime; // millisecondsSinceEpoch
  final Widget Function(BuildContext context, int seconds) builder;
  final Function onClose;

  @override
  _CountDownState createState() => _CountDownState();

  static int getSeconds(int endTime) {
    return Duration(
      milliseconds: (endTime - DateTime.now().millisecondsSinceEpoch),
    ).inSeconds;
  }
}

class _CountDownState extends State<CountdownTimer> {
  int _seconds;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    if (widget.endTime == null) return;
    _seconds = CountdownTimer.getSeconds(widget.endTime);
    if (_seconds < 1) return;
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (_seconds == 1 && widget.onClose != null) {
        widget.onClose();
        _disposeTimer();
        return;
      }
      setState(
        () {
          if (_seconds < 1) {
            _disposeTimer();
          } else {
            _seconds--;
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _disposeTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _seconds);
  }

  void _disposeTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

String formatDDHHMMSS(int seconds) {
  int days, hours, minutes = 0;
  if (seconds >= 86400) {
    days = (seconds / 86400).floor();
    seconds -= days * 86400;
  } else {
    // if days = -1 => Don't show;
    days = -1;
  }
  if (seconds >= 3600) {
    hours = (seconds / 3600).floor();
    seconds -= hours * 3600;
  } else {
    // hours = days == -1 ? -1 : 0;
    hours = 0;
  }
  if (seconds >= 60) {
    minutes = (seconds / 60).floor();
    seconds -= minutes * 60;
  } else {
    // minutes = hours == -1 ? -1 : 0;
    minutes = 0;
  }
  var sDD = (days).toString().padLeft(2, '0');
  var sHH = (hours).toString().padLeft(2, '0');
  var sMM = (minutes).toString().padLeft(2, '0');
  var sSS = (seconds).toString().padLeft(2, '0');
  if (days == -1) {
    return '$sHH:$sMM:$sSS';
  }
  return '$sDD:$sHH:$sMM:$sSS';
}

class GiftButton extends StatelessWidget {
  GiftButton(this.unit);

  final UnitModel unit;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Gift',
      child: Material(
        child: InkWell(
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          child: Container(
            height: kButtonHeight,
            width: kButtonWidth,
            child: Logo(size: kButtonIconSize),
          ),
          onTap: () {
            showDialog(
              context: context,
              child: InfoDialog(
                title: 'Заберите лот даром, если\nне будет других желающих',
                description:
                    'Нажмите "хочу забрать",\n дождитесь окончания таймера',
              ),
            );
          },
        ),
      ),
    );
  }
}

class InfoDialog extends StatelessWidget {
  InfoDialog({
    this.icon,
    this.title,
    this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      children: <Widget>[
        (icon == null)
            ? Logo(size: kButtonIconSize)
            : Icon(
                icon,
                color: Colors.deepOrangeAccent,
                size: kButtonIconSize,
              ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            description,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 8),
          alignment: Alignment.center,
          child: Tooltip(
            message: 'Goto FAQ',
            child: Material(
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  Navigator.of(context)
                    ..pop()
                    ..pushNamed('/faq');
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Как забирать и отдавать лоты?',
                    style: TextStyle(
                      fontSize: kFontSize,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
                fontSize: kPriceFontSize,
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
                    actions: <Widget>[
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

// TODO: когда выбираю GMail: "getSlotFromBufferLocked: unknown buffer: 0xae738d40"

class ShareButton extends StatelessWidget {
  ShareButton(
    this.unit, {
    this.iconSize = kButtonIconSize,
  });

  final UnitModel unit;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Share',
      child: Material(
        child: InkWell(
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          child: Container(
            child: Icon(
              Icons.share,
              color: Colors.black.withOpacity(0.8),
              size: iconSize,
            ),
          ),
          onTap: _onTap,
        ),
      ),
    );
  }

  void _onTap() {
    share(unit);
  }
}

// TODO: реализовать ожидание для buildShortLink()
void share(UnitModel unit) async {
  final parameters = DynamicLinkParameters(
    uriPrefix: 'https://minsk8.page.link',
    link: Uri.parse('https://minsk8.example.com/unit?id=${unit.id}'),
    androidParameters: AndroidParameters(
      packageName: 'com.example.minsk8',
      minimumVersion: 1,
    ),
    dynamicLinkParametersOptions: DynamicLinkParametersOptions(
      shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
    ),
    // socialMetaTagParameters: SocialMetaTagParameters(
    //   title: 'Example of a Dynamic Link',
    //   description: 'This link works whether app is installed or not!',
    //   // TODO: The URL to an image related to this link. The image should be at least 300x200 px, and less than 300 KB.
    //   // imageUrl:
    // ),
    navigationInfoParameters: NavigationInfoParameters(
      forcedRedirectEnabled: false,
    ),
  );
  final shortLink = await parameters.buildShortLink();
  final url = shortLink.shortUrl;
  // print('${unit.id} $url');
  // TODO: [MVP] изменить тексты
  // ignore: unawaited_futures
  Share.share(
    'check out my website $url',
    subject: 'Look what I made!',
  );
}

class WishButton extends StatefulWidget {
  WishButton(
    this.unit, {
    this.iconSize = kButtonIconSize,
  });

  final UnitModel unit;
  final double iconSize;

  @override
  _WishButtonState createState() {
    return _WishButtonState();
  }
}

class _WishButtonState extends State<WishButton> {
  Timer _timer;
  final _animationDuration = const Duration(milliseconds: 1000);

  @override
  void dispose() {
    _disposeTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myWishes = Provider.of<MyWishesModel>(context);
    return Tooltip(
      message: 'Wish',
      child: Material(
        child: InkWell(
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          child: LikeButton(
            animationDuration: _animationDuration,
            isLiked: myWishes.has(widget.unit.id),
            likeBuilder: (bool isLiked) {
              if (isLiked) {
                return Icon(
                  Icons.favorite,
                  color: Colors.pinkAccent,
                  size: widget.iconSize,
                );
              }
              return Icon(
                Icons.favorite_border,
                color: Colors.black.withOpacity(0.8),
                size: widget.iconSize,
              );
            },
            likeCountPadding: null,
            likeCount: null, // unit.favorites,
            // countBuilder: (int count, bool isLiked, String text) {
            //   final color = isLiked ? Colors.pinkAccent : Colors.grey;
            //   Widget result;
            //   if (count == 0) {
            //     result = Text(
            //       "love",
            //       style: TextStyle(color: color, fontSize: kFontSize),
            //     );
            //   } else
            //     result = Text(
            //       count >= 1000
            //           ? (count / 1000).toStringAsFixed(1) + "k"
            //           : text,
            //       style: TextStyle(color: color, fontSize: kFontSize),
            //     );
            //   return result;
            // },
            // likeCountAnimationType: unit.favorites < 1000
            //     ? LikeCountAnimationType.part
            //     : LikeCountAnimationType.none,
            onTap: _onTap,
          ),
          onTap: () {},
        ),
      ),
    );
  }

  void _disposeTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<bool> _onTap(bool isLiked) async {
    if (_timer != null) {
      return isLiked;
    }
    _timer = Timer(isLiked ? Duration.zero : _animationDuration, () {
      _disposeTimer();
      final myWishes = Provider.of<MyWishesModel>(context, listen: false);
      _optimisticUpdateWish(
        myWishes,
        unit: widget.unit,
        value: !isLiked,
      );
    });
    return !isLiked;
  }
}

Future<void> _queue = Future.value();

void _optimisticUpdateWish(MyWishesModel myWishes,
    {UnitModel unit, bool value}) {
  final oldUpdatedAt = myWishes.updateWish(
    unitId: unit.id,
    value: value,
  );
  // final client = GraphQLProvider.of(context).value;
  final options = MutationOptions(
    documentNode: Mutations.upsertWish,
    variables: {
      'unit_id': unit.id,
      'value': value,
    },
    fetchPolicy: FetchPolicy.noCache,
  );
  _queue = _queue.then((_) {
    return client
        .mutate(options)
        .timeout(kGraphQLMutationTimeoutDuration)
        .then((QueryResult result) {
      if (result.hasException) {
        throw result.exception;
      }
      final json = result.data['insert_wish_one'];
      myWishes.updateWish(
        unitId: unit.id,
        value: value,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    });
  }).catchError((error) {
    debugPrint(error.toString());
    myWishes.updateWish(
      unitId: unit.id,
      value: oldUpdatedAt != null,
      updatedAt: oldUpdatedAt,
    );
    BotToast.showNotification(
      title: (_) => Text(
        value
            ? 'Не удалось сохранить желание для "${unit.text}"'
            : 'Не удалось удалить желание для "${unit.text}"',
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      trailing: (Function close) => FlatButton(
        child: Text(
          'ПОВТОРИТЬ',
          style: TextStyle(
            fontSize: kFontSize,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        onLongPress: () {}, // чтобы сократить время для splashColor
        onPressed: () {
          close();
          _optimisticUpdateWish(myWishes, unit: unit, value: value);
        },
      ),
    );
  });
}
