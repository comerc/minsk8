import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class ItemMapScreen extends StatelessWidget {
  ItemMapScreen(this.arguments);

  final ItemMapRouteArguments arguments;

  @override
  Widget build(BuildContext context) {
    final item = arguments.item;

    // return WillPopScope(
    //   onWillPop: _onWillPop,
    //   child:

    return Scaffold(
      appBar: AppBar(
        title: AddressText(item),
      ),
      body: MapWidget(
        center: item.location,
        zoom: 13,
        markerPoint: item.location,
      ),
      // ),
    );
  }

  // Future<bool> _onWillPop() async {
  //   return arguments.onWillPop(arguments.index);
  // }
}

class ItemMapRouteArguments {
  ItemMapRouteArguments(this.item
      // , {this.index, this.onWillPop}
      );

  final ItemModel item;
  // final int index;
  // final Function onWillPop;
}
