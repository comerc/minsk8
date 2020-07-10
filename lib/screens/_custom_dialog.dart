import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class CustomDialogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        showDialog<void>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return new Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: new Container(
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.purple,
                    child: new Column(
                      children: <Widget>[
                        new Text(
                          'custom dialog text',
                          style: new TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        );

        // showGeneralDialog(
        //   barrierColor: Colors.black.withOpacity(0.5),
        //   transitionBuilder: (context, a1, a2, widget) {
        //     return Transform.scale(
        //       scale: a1.value,
        //       child: Opacity(
        //         opacity: a1.value,
        //         child: AlertDialog(
        //           shape: OutlineInputBorder(
        //               borderRadius: BorderRadius.circular(16.0)),
        //           title: Text('Hello!!'),
        //           content: Text('How are you?'),
        //         ),
        //       ),
        //     );
        //   },
        //   transitionDuration: Duration(milliseconds: 200),
        //   barrierDismissible: true,
        //   barrierLabel: '',
        //   context: context,
        //   pageBuilder: (context, a1, a2) {
        //     // https://stackoverflow.com/questions/57034088/flutter-adding-more-options-for-dialogs
        //     // return SafeArea(child: FloatingDialog());
        //   },
        // );
      }),
      appBar: AppBar(
        title: Text('Custom Dialog'),
      ),
      drawer: MainDrawer('/_custom_dialog'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}

// return showDialog<void>(
//       barrierDismissible: true,
//       context: context,
//       builder: (BuildContext context) {
//         return new Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.all(0),
//               child: new Container(
//                 height: 100,
//                 width: MediaQuery.of(context).size.width,
//                 color: Colors.purple,
//                 child: new Column(
//                   children: <Widget>[
//                     new Text(
//                       'custom dialog text',
//                       style: new TextStyle(
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           ],
//         );
//       },
//     );

// https://stackoverflow.com/questions/52408610/flutter-custom-animated-dialog
// FunkyOverlay
