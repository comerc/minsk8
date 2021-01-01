// import 'package:flutter/material.dart';
// import 'package:pinch_zoom_image/pinch_zoom_image.dart';
// import 'package:transparent_image/transparent_image.dart';
// import 'package:minsk8/import.dart';

// class ImagePinchScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final arguments =
//         ModalRoute.of(context).settings.arguments as ImagePinchRouteArguments;
//     return SafeArea(
//       child: GestureDetector(
//         child: PinchZoomImage(
//           image: FadeInImage.memoryNetwork(
//             image: arguments.url,
//             placeholder: kTransparentImage,
//           ),
//           hideStatusBarWhileZooming: true,
//         ),
//         onTap: () {
//           navigator.pop();
//         },
//       ),
//     );
//   }
// }

// class ImagePinchRouteArguments {
//   final String url;

//   ImagePinchRouteArguments(this.url);
// }
