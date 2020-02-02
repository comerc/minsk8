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
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final child = Form(
      key: formKey,
      child: Column(
        children: [
          SizedBox(
            height: 16.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: Colors.grey,
                height: (panelChildWidth - gridSpacing) / 2,
                width: panelChildWidth,
                child: GridView.count(
                  crossAxisSpacing: gridSpacing,
                  crossAxisCount: 2,
                  children: [
                    Container(color: Colors.red),
                    GridView.count(
                      mainAxisSpacing: gridSpacing,
                      crossAxisSpacing: gridSpacing,
                      crossAxisCount: 2,
                      children: [
                        Container(color: Colors.red),
                        Container(color: Colors.red),
                        Container(color: Colors.red),
                        Container(color: Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            width: 100,
            height: 100,
            color: Colors.green,
            child: Container(),
          ),
          TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: textController,
            validator: validateText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          Expanded(
            child: Container(),
          ),
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
