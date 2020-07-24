import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

// TODO: скроллировать к выбранному элементу, если он вне видимости
// TODO: Вы получите Золотые от забирающих и бонус 3 Золотых за первый отданный лот

class KindsScreen extends StatelessWidget {
  KindsScreen(this.arguments);

  final KindsRouteArguments arguments;

  @override
  Widget build(BuildContext context) {
    // TODO: проверить на IPad Retina и Samsung Note 12
    final width = MediaQuery.of(context).size.width;
    final isSmallWidth = width < kSmallWidth;
    final isMediumWidth = width < kMediumWidth;
    final isLargeWidth = width < kLargeWidth;
    final crossAxisCount =
        isSmallWidth ? 1 : isMediumWidth ? 2 : isLargeWidth ? 3 : 4;
    return Scaffold(
      appBar: AppBar(
        title: Text('Выберите категорию'),
      ),
      body: GridView.count(
        crossAxisCount: crossAxisCount,
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
