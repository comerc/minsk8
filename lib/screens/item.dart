import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import "package:transparent_image/transparent_image.dart";
import 'package:minsk8/import.dart';

// TODO: тут будет слайдер по картинкам одного товара

// TODO: Geolocator().distanceBetween()
// double distanceInMeters = await Geolocator().distanceBetween(52.2165157, 6.9437819, 52.3546274, 4.8285838);

class ItemScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context).settings.arguments as ItemRouteArguments;

    return Text('${arguments.id}');
    // final item = items[arguments.id];
    // final imageUrl = item.imageUrl(1000);
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('Item ${item.name}'),
    //   ),
    //   body: SafeArea(
    //     child: Column(
    //       children: <Widget>[
    //         Expanded(
    //           child: GestureDetector(
    //             onTap: () {
    //               Navigator.pushNamed(
    //                 context,
    //                 '/image_pinch',
    //                 arguments: ImagePinchRouteArguments(imageUrl),
    //               );
    //             },
    //             child: FadeInImage.memoryNetwork(
    //               image: imageUrl,
    //               placeholder: kTransparentImage,
    //             ),
    //           ),
    //         )
    //       ],
    //     ),
    //   ),
    // );
  }
}

class ItemRouteArguments {
  final int id;

  ItemRouteArguments(this.id);
}
