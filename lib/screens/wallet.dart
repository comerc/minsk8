import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class WalletScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
      ),
      drawer: MainDrawer('/wallet'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
