import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:minsk8/import.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      drawer: MainDrawer('/login'),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Center(
            // https://github.com/flutter/flutter_markdown/issues/237
            // child: MarkdownBody(data: html2md.convert('W<em>or</em>d')),
            child: MarkdownBody(data: html2md.convert('<em>Word</em>')),
          ),
        ],
      ),
    );
  }
}
