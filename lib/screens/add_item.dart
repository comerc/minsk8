import 'dart:typed_data';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minsk8/import.dart';

// TODO: item.text.trim()
// TODO: прятать клавиатуру перед showDialog(), чтобы убрать анимацию диалога

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() {
    return _AddItemScreenState();
  }
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _textController;
  // bool isLoading = false;
  List<Uint8List> _images = [];
  ImageSource _imageSource;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_onAfterBuild);
    _textController = TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final panelChildWidth = size.width - 32.0; // for padding
    final gridSpacing = 8.0;
    final child = Form(
      key: _formKey,
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
                      _buildAddImageButton(0),
                      GridView.count(
                        mainAxisSpacing: gridSpacing,
                        crossAxisSpacing: gridSpacing,
                        crossAxisCount: 2,
                        children: List.generate(
                          4,
                          (i) => _buildAddImageButton(i + 1),
                        ),
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
              autofocus: false,
              enableSuggestions: false,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _textController,
              validator: _validateText,
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
              onTap: _handleAddItem,
            ),
          ),
          Container(
            constraints: BoxConstraints(minHeight: 40.0),
            child: SelectButton(
              tooltip: 'Категория',
              text: 'Техника',
              onTap: _handleAddItem,
            ),
          ),
          Container(
            constraints: BoxConstraints(minHeight: 40.0),
            child: SelectButton(
              tooltip: 'Адрес',
              text: 'Минск, проспект Победителей',
              onTap: _handleAddItem,
            ),
          ),
          Spacer(),
          Container(
            width: 100,
            height: 100,
            color: Colors.green,
            child: Spacer(),
          ),
          Container(
            height: kBigButtonHeight,
            width: panelChildWidth,
            child: ReadyButton(onTap: _handleAddItem),
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

  void _onAfterBuild(Duration timeStamp) {
    _choiceImageSource();
  }

  String _validateText(String value) =>
      (value.isEmpty) ? 'Please Enter Text' : null;

  void _handleAddItem() {
    // if (isLoading) {
    //   return;
    // }
    if (_images.length == 0) {
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
    if (!_formKey.currentState.validate()) {
      return;
    }
    // setState(() {
    //   isLoading = true;
    // });
    try {
      // Navigator.pushReplacementNamed(
      //   context,
      // );
    } catch (e) {
      // setState(() {
      //   isLoading = false;
      // });
      print(e);
    }
  }

  Widget _buildAddImageButton(int index) {
    return AddImageButton(
      index: index,
      hasIcon: _images.length == index,
      onTap: _images.length > index ? _handleDeleteImage : _handleAddImage,
      image: _images.length > index ? _images[index] : null,
    );
  }

  void _handleAddImage(int index) {
    if (_imageSource == null) {
      _choiceImageSource().then((_) {
        if (_imageSource == null) return;
        getImage(index);
      });
      return;
    }
    getImage(index);
  }

  void _handleDeleteImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _choiceImageSource() async {
    final ImageSource result = await showImageSourceDialog(context);
    if (result == null) return;
    _imageSource = result;
  }

  Future<void> getImage(int index) async {
    final picker = ImagePicker();
    PickedFile pickedFile = await picker.getImage(source: _imageSource);
    if (pickedFile == null) return;
    Uint8List image = await pickedFile.readAsBytes();
    setState(() {
      if (index < _images.length) {
        _images.removeAt(index);
        _images.insert(index, image);
      } else {
        _images.add(image);
      }
    });
  }
}
