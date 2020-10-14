import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

// TODO: [MVP] скроллировать к выбранному элементу, если он вне видимости
// TODO: Вы получите Карму от забирающих и бонус +3 Кармы за первый отданный лот

class KindsScreen extends StatelessWidget {
  PageRoute<T> route<T>() {
    return buildRoute<T>(
      '/kinds',
      builder: (_) => this,
      fullscreenDialog: true,
    );
  }

  KindsScreen([this.value]);

  final KindValue value;

  @override
  Widget build(BuildContext context) {
    // TODO: проверить на IPad Retina и Samsung Note 12
    final width = MediaQuery.of(context).size.width;
    final isSmallWidth = width < kSmallWidth;
    final isMediumWidth = width < kMediumWidth;
    final isLargeWidth = width < kLargeWidth;
    final crossAxisCount =
        isSmallWidth ? 1 : isMediumWidth ? 2 : isLargeWidth ? 3 : 4;
    final child = GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      padding: EdgeInsets.all(8),
      childAspectRatio: kGoldenRatio,
      children: List.generate(
        kKinds.length,
        (int index) => _KindButton(
          kKinds[index],
          isSelected: kKinds[index].value == value,
        ),
      ),
    );
    return Scaffold(
      appBar: ExtendedAppBar(
        title: Text('Выберите категорию'),
        withModel: true,
      ),
      body: SafeArea(
        child: ScrollBody(
          withIntrinsicHeight: false,
          child: child,
        ),
      ),
    );
  }
}

class _KindButton extends StatelessWidget {
  _KindButton(this.model, {this.isSelected});

  final KindModel model;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Выберите категорию',
      child: Material(
        elevation: kButtonElevation,
        color: isSelected ? Colors.red : Colors.white,
        child: InkWell(
          onTap: () {
            navigator.pop(model.value);
          },
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (model.isNew ?? false)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    color: Colors.red,
                    child: Text(
                      'новое',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // TODO: поменять иконки для категорий
                  Logo(
                    size: kBigButtonIconSize,
                    hasShaderMask: !isSelected,
                  ),
                  SizedBox(height: 8),
                  Text(
                    model.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Colors.black.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
