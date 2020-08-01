import 'package:build/build.dart';
import 'package:markdown/markdown.dart';

Builder markdownBuilder(_) => MarkdownBuilder();

class MarkdownBuilder implements Builder {
  @override
  void build(BuildStep buildStep) async {
    var inputId = buildStep.inputId;
    var contents = await buildStep.readAsString(inputId);
    var markdownContents = markdownToHtml(contents);
    var outputId = inputId.changeExtension('.html');
    print(outputId);
    await buildStep.writeAsString(outputId, markdownContents);
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        '.md': ['.html']
      };
}
