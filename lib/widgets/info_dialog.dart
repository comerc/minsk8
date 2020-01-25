import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class InfoDialog extends StatelessWidget {
  InfoDialog({
    this.icon,
    this.title,
    this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      children: [
        Icon(
          icon,
          color: Colors.deepOrangeAccent,
          size: kButtonIconSize,
        ),
        Container(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            description,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 8.0),
          alignment: Alignment.center,
          child: Tooltip(
            message: 'Goto FAQ',
            child: Material(
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  Navigator.of(context)
                    ..pop()
                    ..pushNamed('/faq');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'Как забирать и отдавать лоты?',
                    style: TextStyle(
                      fontSize: 12.0,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
