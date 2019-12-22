import 'package:minsk8/import.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      drawer: MainDrawer('/sign_up'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
