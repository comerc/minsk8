import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class ItemMapScreen extends StatelessWidget {
  ItemMapScreen(this.arguments);

  final ItemMapRouteArguments arguments;

  @override
  Widget build(BuildContext context) {
    final item = arguments.item;
    return Scaffold(
      appBar: AppBar(
        title: AddressText(item),
      ),
      body: MapWidget(
        center: item.location,
        zoom: 13,
        markerPoint: item.location,
      ),
    );
  }
}

class ItemMapRouteArguments {
  ItemMapRouteArguments(this.item);

  final ItemModel item;
}
