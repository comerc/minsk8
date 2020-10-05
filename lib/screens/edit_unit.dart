import 'package:minsk8/import.dart';

class EditUnitScreen extends StatelessWidget {
  EditUnitScreen(this.arguments);

  final EditUnitRouteArguments arguments;

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

class EditUnitRouteArguments {
  EditUnitRouteArguments(this.id);

  final int id;
}
