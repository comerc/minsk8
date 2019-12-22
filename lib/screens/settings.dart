import 'package:minsk8/import.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      drawer: MainDrawer('/settings'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
