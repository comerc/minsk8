import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class Underway extends StatefulWidget {
  @override
  _UnderwayState createState() => _UnderwayState();
}

class _UnderwayState extends State<Underway> {
// class Underway extends StatelessWidget {

  @override
  void initState() {
    super.initState();
    // print('Underway initState');
  }

  @override
  void dispose() {
    // print('Underway dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('underway'),
    );
  }
}
