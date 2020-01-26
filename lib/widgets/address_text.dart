import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

class AddressText extends StatelessWidget {
  AddressText(this.item);

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    String text = item.address == null ? '' : item.address;
    final distance = Provider.of<DistanceModel>(context);
    if (distance.value != null) {
      text = text == '' ? distance.value : '$text — ${distance.value}';
    }
    return Text(text);
  }
}
