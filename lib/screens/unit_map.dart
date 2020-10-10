import 'package:minsk8/import.dart';

class UnitMapScreen extends StatelessWidget {
  PageRoute<T> route<T>() {
    return buildRoute<T>(
      '/unit_map',
      builder: (_) => this,
      fullscreenDialog: true,
    );
  }

  UnitMapScreen(this.unit);

  final UnitModel unit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: добавить аватарку и описание лота
      // TODO: отображать адрес в инфо-боксе
      appBar: ExtendedAppBar(
        title: _AddressText(unit),
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

// TODO: выбросить после отказа использования в UnitMapScreen

class _AddressText extends StatelessWidget {
  _AddressText(this.unit);

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
