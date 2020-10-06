import 'package:minsk8/import.dart';

// TODO: добавить обработку ссылок
// TODO: добавить переносы (like hyphenator)
// https://github.com/flutter/flutter/issues/18443
// TODO: отображать оба формата: .html и .md

class ContentScreen extends StatefulWidget {
  ContentScreen();

  @override
  _ContentScreenState createState() {
    return _ContentScreenState();
  }
}

class _ContentScreenState extends State<ContentScreen> {
  bool _offstage = true;
  String _content;
  String _title;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_onAfterBuild);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExtendedAppBar(
        title: Text(_title ?? ''),
      ),
      body: _content == null
          ? Center(
              child: Text('Loading...'),
            )
          : SafeArea(
              // child: GestureDetector(
              //   onLongPress: () {}, // TODO: костыль для обхода бага
              //   child: WebView(
              //     initialUrl: 'about:blank',
              //     onWebViewCreated: (WebViewController webViewController) async {
              //       await webViewController.loadUrl(
              //         Uri.dataFromString(
              //           _content,
              //           mimeType: 'text/html',
              //           encoding: Encoding.getByName('utf-8'),
              //         ).toString(),
              //       );
              //     },
              //   ),
              // ),
              // child: Markdown(
              //   selectable: true,
              //   styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
              //   data: _content,
              // ),
              child: Offstage(
                offstage: _offstage,
                child: _MarkdownWrapper(
                  content: _content,
                  onAfterBuild: _handleAfterBuild,
                ),
              ),
            ),
    );
  }

  void _onAfterBuild(Duration timeStamp) {
    final modalRoute = ModalRoute.of(context);
    final filename = modalRoute.settings.name.substring(1) + '.md';
    _title = {
      'about.md': 'О проекте',
      'faq.md': 'Вопросы и ответы',
      'how_it_works.md': 'Как это работает?',
      'make_it_together.md': 'Сделаем это вместе!',
      'useful_tips.md': 'Полезные советы',
    }[filename];
    _loadContent(filename);
  }

  void _loadContent(String filename) async {
    final bundle = DefaultAssetBundle.of(context);
    final content = await bundle.loadString('assets/${filename}');
    if (mounted) {
      setState(() {
        _content = content;
      });
      return;
    }
    _content = content;
  }

  void _handleAfterBuild() {
    setState(() {
      _offstage = false;
    });
  }
}

class _MarkdownWrapper extends StatefulWidget {
  _MarkdownWrapper({this.content, this.onAfterBuild});

  final String content;
  final Function onAfterBuild;

  @override
  _MarkdownWrapperState createState() {
    return _MarkdownWrapperState();
  }
}

class _MarkdownWrapperState extends State<_MarkdownWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_onAfterBuild);
  }

  void _onAfterBuild(Duration timeStamp) {
    widget.onAfterBuild();
  }

  @override
  Widget build(BuildContext context) {
    return Markdown(
      selectable: true,
      styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
      data: widget.content,
    );
  }
}
