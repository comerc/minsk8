import 'package:minsk8/import.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      drawer: MainDrawer('/notifications'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
