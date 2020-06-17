import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class KindsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выберите категорию'),
      ),
      drawer: MainDrawer('/kinds'),
      body: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        padding: EdgeInsets.all(8),
        childAspectRatio: 1.63,
        children: List.generate(
          kinds.length,
          (index) => KindButton(kinds[index],
              isSelected: kinds[index].value == KindId.eat),
        ),
      ),
    );
  }
}
