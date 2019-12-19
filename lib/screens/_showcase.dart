// import 'package:flutter/material.dart';
// import 'package:minsk8/import.dart';

// class ShowcaseScreen extends StatefulWidget {
//   @override
//   _ShowcaseScreenState createState() => _ShowcaseScreenState();
// }

// class _ShowcaseScreenState extends State<ShowcaseScreen>
//     with TickerProviderStateMixin {
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: kinds.length,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Showcase'),
//           bottom: TabBar(
//             tabs: kinds
//                 .map((kind) => Tab(
//                       text: kind.name,
//                       icon: Icon(kind.icon),
//                     ))
//                 .toList(),
//           ),
//         ),
//         drawer: MainDrawer('/showcase'),
//         body: ListView.builder(
//           itemCount: items.length,
//           itemBuilder: (BuildContext context, int index) {
//             return ShowcaseCard(index);
//           },
//         ),
//       ),
//     );
//   }
// }
