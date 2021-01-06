import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

// TODO: Вы получите Карму от забирающих и бонус +3 Кармы за первый отданный лот

class KindsScreen extends StatefulWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/kinds',
      builder: (_) => this,
      fullscreenDialog: true,
    );
  }

  KindsScreen([this.value]);

  final KindValue value;

  @override
  _KindsScreenState createState() => _KindsScreenState();
}

class _KindsScreenState extends State<KindsScreen> {
  final keys =
      List.generate(KindValue.values.length, (int index) => GlobalKey());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_onAfterBuild);
  }

  void _onAfterBuild(Duration timeStamp) async {
    final index = KindValue.values.indexOf(widget.value);
    if (index == -1) return;
    await Future.delayed(Duration.zero); // for ScrollBodyBuilder._onAfterBuild
    // ignore: unawaited_futures
    Scrollable.ensureVisible(keys[index].currentContext);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: проверить на IPad Retina и Samsung Note 12
    final width = MediaQuery.of(context).size.width;
    final isSmallWidth = width < kSmallWidth;
    final isMediumWidth = width < kMediumWidth;
    final isLargeWidth = width < kLargeWidth;
    final crossAxisCount = isSmallWidth
        ? 1
        : isMediumWidth
            ? 2
            : isLargeWidth
                ? 3
                : 4;
    return Scaffold(
      appBar: ExtendedAppBar(
        title: Text('Выберите категорию'),
        withModel: true,
      ),
      body: SafeArea(
        child: ScrollBodyBuilder(
          builder: (BuildContext context, ScrollController controller) {
            return GridView.count(
              controller: controller,
              shrinkWrap: true,
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 8,
              padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
              childAspectRatio: kGoldenRatio,
              children: List.generate(
                KindValue.values.length,
                (int index) => Container(
                  padding: EdgeInsets.only(top: 8),
                  key: keys[index],
                  child: _KindButton(
                    value: KindValue.values[index],
                    selectedValue: widget.value,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _KindButton extends StatelessWidget {
  _KindButton({this.value, this.selectedValue});

  final KindValue value;
  final KindValue selectedValue;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;
    return Tooltip(
      message: 'Выберите категорию',
      child: Material(
        elevation: kButtonElevation,
        color: isSelected ? Colors.red : Colors.white,
        child: InkWell(
          onTap: () {
            navigator.pop(value);
          },
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (isNewKind(value))
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
                    getKindName(value),
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
