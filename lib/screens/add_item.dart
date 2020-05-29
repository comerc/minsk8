import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

// TODO: item.text.trim()
// TODO: прятать клавиатуру перед showDialog()

class AddItemScreen extends StatefulWidget {
  @override
  AddItemScreenState createState() {
    return AddItemScreenState();
  }
}

class AddItemScreenState extends State<AddItemScreen> {
  TextEditingController textController;

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  List images = [];
  ItemImageSource imageSource;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final panelChildWidth = size.width - 32.0; // for padding
    final gridSpacing = 8.0;
    final child = Form(
      key: formKey,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 16.0),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: (panelChildWidth - gridSpacing) / 2,
                  width: panelChildWidth,
                  child: GridView.count(
                    crossAxisSpacing: gridSpacing,
                    crossAxisCount: 2,
                    children: [
                      AddImageButton(
                          hasIcon: images.length == 0,
                          onTap: choiceImageSource),
                      GridView.count(
                        mainAxisSpacing: gridSpacing,
                        crossAxisSpacing: gridSpacing,
                        crossAxisCount: 2,
                        children: [
                          AddImageButton(
                              hasIcon: images.length == 1,
                              onTap: handleAddImage),
                          AddImageButton(
                              hasIcon: images.length == 2,
                              onTap: handleAddImage),
                          AddImageButton(
                              hasIcon: images.length == 3,
                              onTap: handleAddImage),
                          AddImageButton(
                              hasIcon: images.length == 4,
                              onTap: handleAddImage),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.white,
            child: TextFormField(
              autofocus: true,
              enableSuggestions: false,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: textController,
              validator: validateText,
              decoration: InputDecoration(
                hintText: 'Часы Casio. Рабочие.',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(minHeight: 40.0),
            child: SelectButton(
              tooltip: 'Как срочно надо отдать?',
              text: 'Совсем не срочно',
              onTap: handleAddItem,
            ),
          ),
          Container(
            constraints: BoxConstraints(minHeight: 40.0),
            child: SelectButton(
              tooltip: 'Категория',
              text: 'Техника',
              onTap: handleAddItem,
            ),
          ),
          Container(
            constraints: BoxConstraints(minHeight: 40.0),
            child: SelectButton(
              tooltip: 'Адрес',
              text: 'Минск, проспект Победителей',
              onTap: handleAddItem,
            ),
          ),
          Spacer(),
          Container(
            width: 100,
            height: 100,
            color: Colors.green,
            child: Container(),
          ),
          Container(
            height: kBigButtonHeight,
            width: panelChildWidth,
            child: ReadyButton(onTap: handleAddItem),
          ),
          SizedBox(
            height: 16.0,
          ),
        ],
      ),
    );
    // Expanding content to fit the viewport
    final body = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: child,
            ),
          ),
        );
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Что отдаёте?'),
      ),
      // drawer: MainDrawer('/add_item'),
      body: body,
    );
  }

  String validateText(String value) =>
      (value.isEmpty) ? 'Please Enter Text' : null;

  void handleAddItem() {
    if (isLoading) {
      return;
    }
    if (images.length == 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Добавьте фотографию лота'),
            actions: [
              FlatButton(
                child: Text('ОК'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
    if (!formKey.currentState.validate()) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      // Navigator.pushReplacementNamed(
      //   context,
      // );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  handleAddImage() {}

  Future<void> choiceImageSource() async {
    final result = await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Что использовать?'),
        children: [
          _DialogItemImageSource(
            icon: FontAwesomeIcons.camera,
            text: 'Камера',
            result: ItemImageSource.camera,
          ),
          _DialogItemImageSource(
            icon: FontAwesomeIcons.solidImages,
            text: 'Галерея',
            result: ItemImageSource.gallery,
          ),
        ],
      ),
    );
    if (result != null) {
      print(result);
      imageSource = result;
    }
  }
}

enum ItemImageSource { camera, gallery }

class _DialogItemImageSource extends StatelessWidget {
  _DialogItemImageSource({
    Key key,
    this.icon,
    this.text,
    this.result,
  }) : super(key: key);

  final IconData icon;
  final String text;
  final ItemImageSource result;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: () {
        Navigator.of(context).pop(result);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.black.withOpacity(0.8),
            size: kBigButtonIconSize,
          ),
          Flexible(
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 16),
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}
