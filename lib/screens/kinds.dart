import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

// TODO: скроллировать к выбранному элементу, если он вне видимости

class KindsScreen extends StatelessWidget {
  KindsScreen(this.arguments);

  final KindsRouteArguments arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выберите категорию'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        padding: EdgeInsets.all(8),
        childAspectRatio: kGoldenRatio,
        children: List.generate(
          kinds.length,
          (index) => KindButton(
            kinds[index],
            isSelected: kinds[index].value == arguments?.value,
          ),
        ),
      ),
    );
  }
}

class KindsRouteArguments {
  KindsRouteArguments(this.value);

  final KindValue value;
}
