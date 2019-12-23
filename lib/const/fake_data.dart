import 'package:flutter/material.dart';

class Item {
  final int id;
  final String name;
  final int kindId;

  Item(this.id, this.name, {this.kindId});

  imageUrl(size) {
    return 'https://picsum.photos/$size?image=$id';
  }
}

final items = [
  Item(1, 'One', kindId: 1),
  Item(2, 'Two', kindId: 2),
  Item(3, 'Three', kindId: 3),
  Item(4, 'Four', kindId: 4),
  Item(5, 'Five', kindId: 1),
  Item(6, 'Six', kindId: 1),
  Item(7, 'Seven', kindId: 2),
];

// enum KindIds { car, transit, bike, bus }

class Kind {
  final int id;
  final String name;
  final IconData icon;
  Kind(this.id, this.name, this.icon);
}

final kinds = [
  Kind(1, 'Car', Icons.directions_car),
  Kind(2, 'Transit', Icons.directions_transit),
  Kind(3, 'Bike', Icons.directions_bike),
  Kind(4, 'Bus', Icons.directions_bus),
];
