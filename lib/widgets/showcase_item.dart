import 'package:minsk8/import.dart';
import 'package:extended_image/extended_image.dart';
// import "package:transparent_image/transparent_image.dart";

Widget buildShowcaseItem(BuildContext context, TuChongItem item, int index) {
  final double fontSize = 12.0;
  // print(item.avatarUrl);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      _buildImage(context, item, index, fontSize),
      SizedBox(
        height: 5.0,
      ),
      _buildTags(item, fontSize),
      SizedBox(
        height: 5.0,
      ),
      _buildBottomWidget(item),
    ],
  );
}

Widget _buildImage(
    BuildContext context, TuChongItem item, int index, fontSize) {
  return AspectRatio(
    aspectRatio: item.imageSize.width / item.imageSize.height,
    child: Stack(
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
          border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.0),
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          loadStateChanged: (value) {
            if (value.extendedImageLoadState == LoadState.loading) {
              return Container(
                alignment: Alignment.center,
                color: Colors.grey.withOpacity(0.8),
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor:
                      AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                ),
              );
            }
            return null;
          },
        ),
        Positioned(
          top: 5.0,
          right: 5.0,
          child: Container(
            padding: EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.6),
              border:
                  Border.all(color: Colors.grey.withOpacity(0.4), width: 1.0),
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            child: Text(
              "${index + 1}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSize, color: Colors.white),
            ),
          ),
        )
      ],
    ),
  );
}

Widget _buildTags(TuChongItem item, double fontSize) {
  return Wrap(
    runSpacing: 5.0,
    spacing: 5.0,
    children: item.tags.map<Widget>((tag) {
      final color = item.tagColors[item.tags.indexOf(tag)];
      return Container(
        padding: EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.0),
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Text(
          tag,
          textAlign: TextAlign.start,
          style: TextStyle(
              fontSize: fontSize,
              color:
                  color.computeLuminance() < 0.5 ? Colors.white : Colors.black),
        ),
      );
    }).toList(),
  );
}

Widget _buildBottomWidget(TuChongItem item) {
  final fontSize = 12.0;
  return Row(
    children: <Widget>[
      ExtendedImage.network(
        item.avatarUrl,
        width: 25.0,
        height: 25.0,
        shape: BoxShape.circle,
        //enableLoadState: false,
        border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.0),
        // loadStateChanged: (state) {
        //   if (state.extendedImageLoadState == LoadState.completed) {
        //     return null;
        //   }
        //   return Image.asset("assets/avatar.jpeg");
        // },
      ),
      Expanded(
        child: SizedBox.shrink(),
        // child: Container(height: 20, color: Colors.red),
      ),
      Row(
        children: <Widget>[
          Icon(
            Icons.comment,
            color: Colors.amberAccent,
            size: 18.0,
          ),
          SizedBox(
            width: 3.0,
          ),
          Text(
            item.comments.toString(),
            style: TextStyle(color: Colors.black, fontSize: fontSize),
          )
        ],
      ),
      SizedBox(
        width: 3.0,
      ),
      buildLike(item, fontSize),
      // Container(
      //   child: Text(content),
      // ),
    ],
  );
}
