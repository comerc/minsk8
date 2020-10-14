import 'package:minsk8/import.dart';

// TODO: добавить обработку ссылок
// TODO: добавить переносы (like hyphenator)
// https://github.com/flutter/flutter/issues/18443
// TODO: отображать оба формата: .html и .md
// TODO: найти либу для типографики

class ContentScreen extends StatelessWidget {
  PageRoute<T> route<T>() {
    return buildRoute<T>(
      '/$filename',
      builder: (_) => this,
    );
  }

  ContentScreen(this.filename)
      : title = {
          'about.md': 'О проекте',
          'faq.md': 'Вопросы и ответы',
          'how_it_works.md': 'Как это работает?',
          'make_it_together.md': 'Сделаем это вместе!',
          'useful_tips.md': 'Полезные советы',
        }[filename];

  final String filename;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExtendedAppBar(
        title: Text(title),
      ),
      body: SafeArea(
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
        child: Content(
          filename,
          buildLoading: () {
            return Center(
              child: Text('Loading...'),
            );
          },
          buildMarkdown: (String content) {
            return Markdown(
              selectable: true,
              styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
              data: content,
            );
          },
        ),
      ),
    );
  }
}

class _AfterBuildWrapper extends StatefulWidget {
  _AfterBuildWrapper({this.child, this.onAfterBuild});

  final Widget child;
  final Function onAfterBuild;

  @override
  _AfterBuildWrapperState createState() {
    return _AfterBuildWrapperState();
  }
}

class _AfterBuildWrapperState extends State<_AfterBuildWrapper> {
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
    return widget.child;
  }
}

class Content extends StatefulWidget {
  Content(this.filename, {this.buildLoading, this.buildMarkdown});

  final String filename;
  final Widget Function() buildLoading;
  final Markdown Function(String) buildMarkdown;

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  bool _offstage = true;
  String _content;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  Widget build(BuildContext context) {
    if (_content == null) {
      return widget.buildLoading == null
          ? buildDefaultLoading()
          : widget.buildLoading();
    }
    return Offstage(
      offstage: _offstage,
      child: _AfterBuildWrapper(
        onAfterBuild: _handleAfterBuild,
        child: widget.buildMarkdown == null
            ? buildDefaultMarkdown(_content)
            : widget.buildMarkdown(_content),
      ),
    );
  }

  Widget buildDefaultLoading() {
    return Text('...');
  }

  Markdown buildDefaultMarkdown(String content) {
    return Markdown(
      styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
      styleSheet: MarkdownStyleSheet(
        strong: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black.withOpacity(0.8),
        ),
      ),
      shrinkWrap: true,
      padding: null,
      data: content,
    );
  }

  void _loadContent() async {
    final bundle = DefaultAssetBundle.of(context);
    final content = await bundle.loadString('assets/${widget.filename}') ?? '';
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
