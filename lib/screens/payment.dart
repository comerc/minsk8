import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Center(
        child: buildProgressIndicator(
          context,
          hasAnimatedColor: true,
        ),
      ),
    );
  }
}
