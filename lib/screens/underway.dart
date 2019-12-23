import 'package:minsk8/import.dart';

class UnderwayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Underway'),
      ),
      drawer: MainDrawer('/underway'),
      body: Center(
        child: Text('xxx'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: buildAddButton(context),
      bottomNavigationBar: NavigationBar('/underway'),
    );
  }
}
