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
