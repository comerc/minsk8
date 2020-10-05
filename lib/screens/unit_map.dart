import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      appBar: ExtendedAppBar(
        title: AddressText(unit),
      ),
      body: SafeArea(
        child: MapWidget(
          center: unit.location,
          zoom: 13, // TODO: или сохранять, какой выбрал участник?
          markerPoint: unit.location,
        ),
      ),
    );
  }
}

class UnitMapRouteArguments {
  UnitMapRouteArguments(this.unit);

  final UnitModel unit;
}

// TODO: выбросить после отказа использования в UnitMapScreen

class AddressText extends StatelessWidget {
  AddressText(this.unit);

  final UnitModel unit;

  @override
  Widget build(BuildContext context) {
    var text = unit.address ?? '';
    final distance = Provider.of<DistanceModel>(context);
    if (distance.value != null) {
      text = text == '' ? distance.value : '${distance.value} — $text';
    }
    return Text(text);
  }
}
