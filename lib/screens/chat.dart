import 'package:minsk8/import.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      drawer: MainDrawer('/chat'),
      body: Center(
        child: Text('xxx'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: buildAddButton(context),
      bottomNavigationBar: NavigationBar('/chat'),
    );
  }
}

class ChatRouteArguments {
  final int userId;

  ChatRouteArguments(this.userId);
}
