import 'package:minsk8/import.dart';

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start'),
      ),
      drawer: MainDrawer('/start'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
