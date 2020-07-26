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
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      children: [
        (icon == null)
            ? Logo(size: kButtonIconSize)
            : Icon(
                icon,
                color: Colors.deepOrangeAccent,
                size: kButtonIconSize,
              ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            description,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 8),
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
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Как забирать и отдавать лоты?',
                    style: TextStyle(
                      fontSize: kFontSize,
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
