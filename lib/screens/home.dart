import 'package:minsk8/import.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: MainDrawer('/home'),
      body: Center(
        child: Text('Hello world!'),
      ),
    );
  }
}
