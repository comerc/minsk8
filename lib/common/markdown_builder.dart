import 'package:build/build.dart';
import 'package:markdown/markdown.dart';

Builder markdownBuilder(_) => MarkdownBuilder();

class MarkdownBuilder implements Builder {
  @override
  void build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    final contents = await buildStep.readAsString(inputId);
    final markdownContents = markdownToHtml(contents);
    final outputId = inputId.changeExtension('.html');
    await buildStep.writeAsString(outputId, markdownContents);
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        '.md': <String>['.html']
      };
}
