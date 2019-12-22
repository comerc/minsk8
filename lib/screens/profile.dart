import 'package:minsk8/import.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      drawer: MainDrawer('/profile'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
