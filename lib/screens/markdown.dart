import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:minsk8/import.dart';

// TODO: добавить обработку ссылок
// TODO: добавить переносы (like hyphenator)
// https://github.com/flutter/flutter/issues/18443

class MarkdownScreen extends StatefulWidget {
  MarkdownScreen(this.filename, {this.title});

  final String filename;
  final String title;

  @override
  _MarkdownScreenState createState() {
    return _MarkdownScreenState();
  }
}

class _MarkdownScreenState extends State<MarkdownScreen> {
  String _content = '';

  @override
  void initState() {
    super.initState();
    loadAsset(context, widget.filename).then((content) {
      if (mounted) {
        setState(() {
          _content = content;
        });
        return;
      }
      _content = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Markdown(
          selectable: true,
          styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
          data: _content,
        ),
      ),
    );
  }
}
