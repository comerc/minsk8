import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
// import "package:transparent_image/transparent_image.dart";
import 'package:minsk8/import.dart';

Widget buildShowcaseItem(BuildContext context, TuChongItem item, int index) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      _buildImage(context, item, index),
      // SizedBox(
      //   height: 5.0,
      // ),
      // _buildTags(item),
      SizedBox(
        height: 5.0,
      ),
      _buildBottom(item),
      SizedBox(
        height: 15.0,
      ),
    ],
  );
}

Widget _buildImage(BuildContext context, TuChongItem item, int index) {
  final itemEndTime = DateTime.now().millisecondsSinceEpoch +
      // 1000 * 60 * 60 * 24 * 1 +
      1000 * 10;
  return AspectRatio(
    aspectRatio: item.imageSize.width / item.imageSize.height,
    child: ClipRRect(
      borderRadius: BorderRadius.all(kImageBorderRadius),
      child: Stack(
        // fit: StackFit.expand,
        children: <Widget>[
          // FadeInImage.memoryNetwork(
          //   width: item.imageSize.width,
          //   height: item.imageSize.height,
          //   image: item.imageUrl,
          //   fit: BoxFit.cover,
          //   placeholder: kTransparentImage,
          // ),
          ExtendedImage.network(
            item.imageUrl,
            shape: BoxShape.rectangle,
            // border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.0),
            borderRadius: BorderRadius.all(
              kImageBorderRadius,
            ),
            loadStateChanged: (value) {
              if (value.extendedImageLoadState != LoadState.loading)
                return null;
              return Container(
                alignment: Alignment.center,
                color: Colors.grey.withOpacity(0.3),
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor:
                      AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                ),
              );
            },
          ),
          _buildText(item.title == '' ? item.content : item.title),
          _buildCountdownTimer(itemEndTime),
          // Positioned(
          //   top: 5.0,
          //   right: 5.0,
          //   child: Container(
          //     padding: EdgeInsets.all(3.0),
          //     decoration: BoxDecoration(
          //       // color: Colors.grey.withOpacity(0.6),
          //       color: Colors.white,
          //       border: Border.all(
          //         color: Colors.grey.withOpacity(0.4),
          //         width: 1.0,
          //       ),
          //       borderRadius: BorderRadius.all(
          //         Radius.circular(5.0),
          //       ),
          //     ),
          //     child: Text(
          //       "+${index + 1}",
          //       textAlign: TextAlign.center,
          //       style: TextStyle(
          //         fontSize: kFontSize * 1.6,
          //         color: Colors.orange,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    ),
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
          fontSize: 23,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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
        borderRadius: BorderRadius.only(
          topLeft: kImageBorderRadius,
          bottomRight: kImageBorderRadius,
        ),
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

Widget _buildBottom(TuChongItem item) {
  return Row(
    children: <Widget>[
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
      buildPrice(item),
      Expanded(
        child: Container(),
      ),
      buildShare(item),
      buildLike(item),
    ],
  );
}
