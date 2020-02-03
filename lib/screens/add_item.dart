import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

// TODO: item.text.trim()

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
                      AddImageButton(hasIcon: images.length == 0),
                      GridView.count(
                        mainAxisSpacing: gridSpacing,
                        crossAxisSpacing: gridSpacing,
                        crossAxisCount: 2,
                        children: [
                          AddImageButton(hasIcon: images.length == 1),
                          AddImageButton(hasIcon: images.length == 2),
                          AddImageButton(hasIcon: images.length == 3),
                          AddImageButton(hasIcon: images.length == 4),
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
              onTap: onTap,
            ),
          ),
          Container(
            constraints: BoxConstraints(minHeight: 40.0),
            child: SelectButton(
              tooltip: 'Категория',
              text: 'Техника',
              onTap: onTap,
            ),
          ),
          Container(
            constraints: BoxConstraints(minHeight: 40.0),
            child: SelectButton(
              tooltip: 'Адрес',
              text: 'Минск, проспект Победителей',
              onTap: onTap,
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
            child: ReadyButton(onTap: onTap),
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
      (value.isEmpty) ? "Please Enter Text" : null;

  onTap() {
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
}
