import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

class InfoDialog extends StatelessWidget {
  InfoDialog({
    this.title,
    this.description,
    this.footer,
  });

  final String title, description, footer;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(8.0),
      children: [
        SizedBox(height: 8.0),
        Icon(
          FontAwesomeIcons.gift,
          color: Colors.deepOrangeAccent,
          size: kButtonIconSize,
        ),
        SizedBox(height: 16.0),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.0),
        Text(
          description,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.0),
        Container(
          alignment: Alignment.center,
          child: GestureDetector(
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
              color: Colors.white,
              child: Text(
                'Как забирать лоты?',
                style: TextStyle(
                  fontSize: 12.0,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
