import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

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
