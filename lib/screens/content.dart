import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:minsk8/import.dart';

// TODO: добавить обработку ссылок
// TODO: добавить переносы (like hyphenator)
// https://github.com/flutter/flutter/issues/18443
// TODO: ощутимо тормозит, замирает при парсинге markdown
// https://github.com/flutter/flutter_markdown/issues/84
// TODO: отображать оба формата: .html и .md

class ContentScreen extends StatefulWidget {
  ContentScreen(this.filename, {this.title});

  final String filename;
  final String title;

  @override
  _ContentScreenState createState() {
    return _ContentScreenState();
  }
}

class _ContentScreenState extends State<ContentScreen> {
  String _content = '';

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: GestureDetector(
          onLongPress: () {}, // TODO: костыль для обхода бага
          child: WebView(
            initialUrl: 'about:blank',
            onWebViewCreated: (WebViewController webViewController) async {
              await webViewController.loadUrl(
                Uri.dataFromString(
                  _content,
                  mimeType: 'text/html',
                  encoding: Encoding.getByName('utf-8'),
                ).toString(),
              );
            },
          ),
        ),
        // child: Markdown(
        //   selectable: true,
        //   styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
        //   data: _content,
        // ),
      ),
    );
  }

  void _loadContent() async {
    final bundle = DefaultAssetBundle.of(context);
    final content = await bundle.loadString('assets/${widget.filename}');
    if (mounted) {
      setState(() {
        _content = content;
      });
      return;
    }
    _content = content;
  }
}
