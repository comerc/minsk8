import 'package:minsk8/import.dart';

class KindsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kinds'),
      ),
      drawer: MainDrawer('/kinds'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
