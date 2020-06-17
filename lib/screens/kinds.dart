import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class KindsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cells = 2;
    final rows = kinds.length ~/ cells + (kinds.length % cells > 0 ? 1 : 0);
    return Scaffold(
      appBar: AppBar(
        title: Text('Kinds'),
      ),
      drawer: MainDrawer('/kinds'),
      body: Column(
        children: [
          for (var row = 0; row < rows; row++)
            Row(
              children: [
                SizedBox(width: 8),
                for (var cell = 0; cell < cells; cell++) ...[
                  Expanded(
                    child: (row * cells + cell < kinds.length)
                        ? RaisedButton(
                            onPressed: null,
                            child: Text(kinds[row * cells + cell].name)
                            // Icon(Icons.aspect_ratio),
                            )
                        : Container(),
                  ),
                  SizedBox(width: 8)
                ],
              ],
            ),
        ],
      ),
    );
  }
}
