import 'package:minsk8/import.dart';

class WishesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishes'),
      ),
      drawer: MainDrawer('/wishes'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
