import 'package:flutter/material.dart';

class ListViewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ListView with Column'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        // mainAxisSize: MainAxisSize.min,
        children: [
          // Container(
          //   height: 40,
          //   child: Text('1234'),
          //   color: Colors.lightBlueAccent,
          // ),
          // Expanded(
          //   child: ListView.separated(
          //     // cacheExtent без shrinkWrap выполяет itemBuilder 11 раз вместо 14
          //     cacheExtent: 0,
          //     // shrinkWrap: true,
          //     itemCount: 100,
          //     itemBuilder: (BuildContext context, int index) {
          //       out(index.toString());
          //       return Container(
          //         child: Text('$index'),
          //         height: 40,
          //       );
          //     },
          //     separatorBuilder: (BuildContext context, int index) {
          //       return Container(
          //         color: Colors.grey.withOpacity(.4),
          //         height: 40,
          //       );
          //     },
          //   ),
          // ),
          // неправильно показывает сместившийся Glow
          // Container(
          //   height: 100,
          //   child: ListView(
          //     // shrinkWrap: true,
          //     // itemExtent: 40,
          //     children: List.generate(
          //       4,
          //       (index) {
          //         return Container(
          //           child: Text('$index'),
          //           height: 40,
          //           color: Colors.lime,
          //         );
          //       },
          //     ),
          //   ),
          // ),
          // Expanded(
          //   child: ListView(
          //     // shrinkWrap: true,
          //     children: ListTile.divideTiles(context: context, tiles: [
          //       ListTile(
          //         title: Text('Horse'),
          //       ),
          //       ListTile(
          //         title: Text('Cow'),
          //       ),
          //       ListTile(
          //         title: Text('Camel'),
          //       ),
          //       ListTile(
          //         title: Text('Sheep'),
          //       ),
          //       ListTile(
          //         title: Text('Goat'),
          //       ),
          //     ]).toList(),
          //   ),
          // ),
        ],
      ),
    );
  }
}
