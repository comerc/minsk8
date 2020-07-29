import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class UnitMapScreen extends StatelessWidget {
  UnitMapScreen(this.arguments);

  final UnitMapRouteArguments arguments;

  @override
  Widget build(BuildContext context) {
    final unit = arguments.unit;
    return Scaffold(
      // TODO: добавить аватарку и описание лота
      // TODO: отображать адрес в инфо-боксе
      appBar: AppBar(
        title: AddressText(unit),
      ),
      body: MapWidget(
        center: unit.location,
        zoom: 13, // TODO: или сохранять, какой выбрал участник?
        markerPoint: unit.location,
      ),
    );
  }
}

class UnitMapRouteArguments {
  UnitMapRouteArguments(this.unit);

  final UnitModel unit;
}
