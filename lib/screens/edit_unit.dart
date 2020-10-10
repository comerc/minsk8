import 'package:minsk8/import.dart';

class EditUnitScreen extends StatelessWidget {
  PageRoute<T> route<T>() {
    return buildRoute<T>(
      '/edit_unit?id=${unit.id}',
      builder: (_) => this,
      fullscreenDialog: true,
    );
  }

  EditUnitScreen({this.unit});

  final UnitModel unit;

  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Text('xxx'),
    );
    return Scaffold(
      appBar: ExtendedAppBar(
        title: Text('Edit Unit'),
        withModel: true,
      ),
      drawer: MainDrawer('/edit_unit'),
      body: SafeArea(
        child: ScrollBody(child: child),
      ),
    );
  }
}
