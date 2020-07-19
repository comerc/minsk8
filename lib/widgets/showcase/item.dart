import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:minsk8/import.dart';

class ShowcaseItem extends StatefulWidget {
  ShowcaseItem({
    Key key,
    this.item,
    this.tabIndex,
    this.isCover,
  }) : super(key: key);

  final ItemModel item;
  final int tabIndex;
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
      children: [
        _buildImage(),
        _buildBottom(),
      ],
    );
  }

  Widget _buildImage() {
    final item = widget.item;
    final isCover = widget.isCover;
    final tabIndex = widget.tabIndex;
    final image = item.images[0];
    return Material(
      child: InkWell(
        onTap: () {
          // Navigator.of(context).push(PageRouteBuilder(
          //   settings: RouteSettings(
          //     arguments: ItemRouteArguments(item, tag: tag),
          //   ),
          //   pageBuilder: (context, animation, secondaryAnimation) =>
          //       ItemScreen(),
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
            '/item',
            arguments: ItemRouteArguments(
              item,
              member: item.member,
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
          aspectRatio: isCover ? 1 : image.width / image.height,
          child: Hero(
            tag:
                '${HomeScreen.globalKey.currentState.tabIndex}-${tabIndex}-${item.id}',
            child: Ink.image(
              fit: isCover ? BoxFit.cover : BoxFit.contain,
              image: ExtendedImage.network(
                image.getDummyUrl(item.id),
                // shape: BoxShape.rectangle,
                // border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1),
                // borderRadius: BorderRadius.all(kImageBorderRadius),
                loadStateChanged: loadStateChanged,
              ).image,
              child: Stack(
                // fit: StackFit.expand,
                children: [
                  _buildText(),
                  if (item.isBlockedOrLocalDeleted)
                    _buildStatus(
                      'Заблокировано',
                      isClosed: true,
                    )
                  else if (item.transferredAt != null)
                    _buildStatus(
                      'Забрали',
                      isClosed: true,
                    )
                  else if (item.win != null)
                    _buildStatus(
                      'Завершено',
                      isClosed: true,
                    )
                  else if (item.expiresAt != null)
                    CountdownTimer(
                      endTime: item.expiresAt.millisecondsSinceEpoch,
                      builder: (BuildContext context, int seconds) {
                        return _buildStatus(
                          seconds < 1 ? 'Завершено' : formatDDHHMMSS(seconds),
                          isClosed: seconds < 1,
                        );
                      },
                    )
                  else if (item.urgent != UrgentStatus.none)
                    _buildStatus(
                      urgents
                          .firstWhere(
                              (urgentModel) => urgentModel.value == item.urgent)
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
    final item = widget.item;
    if (!_isBottom) {
      return SizedBox(
        height: kButtonHeight,
      );
    }
    return Row(
      children: [
        item.price == null ? GiftButton(item) : PriceButton(item),
        Spacer(),
        SizedBox(
          width: kButtonWidth,
          height: kButtonHeight,
          child: ShareButton(item),
        ),
        SizedBox(
          width: kButtonWidth,
          height: kButtonHeight,
          child: WishButton(item),
        ),
      ],
    );
  }

  Widget _buildText() {
    final text = widget.item.text;
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
            colors: [
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
