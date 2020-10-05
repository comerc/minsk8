import 'package:minsk8/import.dart';

class Content extends StatefulWidget {
  Content({this.filename});

  final String filename;

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  String _content = '';
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return Text('...');
    }
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
      data: _content,
    );
  }

  void _loadContent() async {
    final bundle = DefaultAssetBundle.of(context);
    // TODO: найти либу для типографики
    final content = await bundle.loadString('assets/${widget.filename}');
    if (mounted) {
      setState(() {
        _content = content;
        _isLoaded = true;
      });
      return;
    }
    _content = content;
    _isLoaded = true;
  }
}
