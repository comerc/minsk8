import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:minsk8/import.dart';

class ShowcaseItem extends StatelessWidget {
  final ItemModel item;
  final int index;
  final String tag;

  ShowcaseItem({
    Key key,
    this.item,
    this.index,
    this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
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
            Navigator.pushNamed(
              context,
              '/item',
              arguments: ItemRouteArguments(item, tag: tag),
            );
          },
          child: Hero(
            tag: tag,
            child: _buildImage(),
          ),
        ),
        // SizedBox(
        //   height: 5.0,
        // ),
        // _buildTags(item),
        // SizedBox(
        //   height: 5.0,
        // ),
        _buildBottom(),
        // SizedBox(
        //   height: 8.0,
        // ),
      ],
    );
  }

  Widget _buildImage() {
    // final itemEndTime = DateTime.now().millisecondsSinceEpoch +
    //     // 1000 * 60 * 60 * 24 * 1 +
    //     1000 * 10;
    final image = item.images[0];
    return AspectRatio(
      aspectRatio: image.width / image.height,
      child:
          // ClipRRect(
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          // child:
          Stack(
        fit: StackFit.expand,
        children: [
          ExtendedImage.network(
            image.getDummyUrl(item.id),
            fit: BoxFit.fill,
            // shape: BoxShape.rectangle,
            // border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.0),
            // borderRadius: BorderRadius.all(kImageBorderRadius),
            loadStateChanged: loadStateChanged,
          ),
          _buildText(item.text),
          if (item.expiresAt != null)
            _buildCountdownTimer(item.expiresAt.millisecondsSinceEpoch),
          // _buildTopRightLabel(item.images.length.toString()),
        ],
      ),
    );
  }

  Widget _buildBottom() {
    return Row(
      children: [
        // ExtendedImage.network(
        //   item.avatarUrl,
        //   width: 25.0,
        //   height: 25.0,
        //   shape: BoxShape.circle,
        //   //enableLoadState: false,
        //   border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.0),
        //   // loadStateChanged: (state) {
        //   //   if (state.extendedImageLoadState == LoadState.completed) {
        //   //     return null;
        //   //   }
        //   //   return Image.asset("assets/avatar.jpeg");
        //   // },
        // ),
        // SizedBox(
        //   width: 16.3,
        // ),
        Price(item),
        Expanded(
          child: Container(),
        ),
        Share(item),
        Wish(item),
      ],
    );
  }

  Widget _buildText(String text) {
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
          left: 8.0,
          top: 32.0,
          right: 8.0,
          bottom: 8.0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  _buildCountdownTimer(int endTime) {
    return Positioned(
      top: 0,
      left: 0,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.pink.withOpacity(0.8),
          // border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.0),
          // borderRadius: BorderRadius.all(Radius.circular(6.5)),
          // borderRadius: BorderRadius.only(
          //   // topLeft: kImageBorderRadius,
          //   bottomRight: kImageBorderRadius,
          // ),
        ),
        child: CountdownTimer(
          endTime: endTime,
          builder: (context, seconds) => Text(
            seconds < 1 ? 'Завершено' : formatDDHHMMSS(seconds),
            style: TextStyle(
              fontSize: kFontSize,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

// Widget _buildTags(TuChongItem item) {
//   return Wrap(
//     runSpacing: 5.0,
//     spacing: 5.0,
//     children: item.tags.map<Widget>((tag) {
//       final color = item.tagColors[item.tags.indexOf(tag)];
//       return Container(
//         padding: EdgeInsets.all(3.0),
//         decoration: BoxDecoration(
//           color: color,
//           border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.0),
//           borderRadius: BorderRadius.all(
//             Radius.circular(5.0),
//           ),
//         ),
//         child: Text(
//           tag,
//           textAlign: TextAlign.start,
//           style: TextStyle(
//               fontSize: fontSize,
//               color:
//                   color.computeLuminance() < 0.5 ? Colors.white : Colors.black),
//         ),
//       );
//     }).toList(),
//   );
// }

  Widget _buildTopRightLabel(String data) {
    return Positioned(
      top: 5.0,
      right: 5.0,
      child: Container(
        padding: EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          // color: Colors.grey.withOpacity(0.6),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.withOpacity(0.4),
            width: 1.0,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Text(
          data,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: kFontSize * 1.6,
            color: Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
