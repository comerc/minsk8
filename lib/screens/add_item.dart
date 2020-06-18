import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minsk8/import.dart';

// TODO: item.text.trim()
// TODO: прятать клавиатуру перед showDialog(), чтобы убрать анимацию диалога

class AddItemScreen extends StatefulWidget {
  AddItemScreen(this.arguments);

  final AddItemRouteArguments arguments;

  @override
  _AddItemScreenState createState() {
    return _AddItemScreenState();
  }
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _textController;
  // bool isLoading = false;
  bool _isSubmited = false;
  List<Uint8List> _images = [];
  ImageSource _imageSource;
  UrgentStatus _urgent = UrgentStatus.not_urgent;
  KindId _kind;

  String get urgentName =>
      urgents
          .firstWhere((UrgentModel element) => element.value == _urgent,
              orElse: () => null)
          ?.name ??
      '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_onAfterBuild);
    _textController = TextEditingController(text: '');
    _kind = widget.arguments.kind;
  }

  @override
  void dispose() {
    _textController.dispose(); // TODO: оно тут точно надо?
    super.dispose();
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
            padding: EdgeInsets.only(top: 16),
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
            padding: EdgeInsets.all(16),
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
            constraints: BoxConstraints(minHeight: 40),
            child: SelectButton(
              tooltip: 'Как срочно надо отдать?',
              text: 'Срочно?',
              rightText: urgentName,
              onTap: _selectUrgent,
            ),
          ),
          Container(
            constraints: BoxConstraints(minHeight: 40),
            child: SelectButton(
              tooltip: 'Категория',
              text: kinds.firstWhere((element) => element.value == _kind).name,
              onTap: _selectKind,
            ),
          ),
          Container(
            constraints: BoxConstraints(minHeight: 40),
            child: SelectButton(
              tooltip: 'Местоположение',
              text: appState['location'] ?? 'Местоположение',
              onTap: _selectLocation,
            ),
          ),
          Spacer(),
          Container(
            height: kBigButtonHeight,
            width: panelChildWidth,
            child: ReadyButton(onTap: _handleAddItem),
          ),
          SizedBox(
            height: 16,
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Что отдаёте?'),
        ),
        body: body,
      ),
    );
  }

  void _onAfterBuild(Duration timeStamp) {
    showImageSourceDialog(context).then((ImageSource imageSource) {
      if (imageSource == null) return;
      _getImage(0, imageSource).then((bool result) {
        if (!result) return;
        _imageSource = imageSource;
      });
    });
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
      showImageSourceDialog(context).then((ImageSource imageSource) {
        if (imageSource == null) return;
        _getImage(index, imageSource).then((bool result) {
          if (!result) return;
          _imageSource = imageSource;
        });
      });
      return;
    }
    _getImage(index, _imageSource);
  }

  void _handleDeleteImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<bool> _getImage(int index, ImageSource imageSource) async {
    final picker = ImagePicker();
    PickedFile pickedFile;
    try {
      pickedFile = await picker.getImage(source: imageSource);
    } catch (error) {
      debugPrint(error.toString());
    }
    if (pickedFile == null) {
      return false;
    }
    final image = await pickedFile.readAsBytes();
    setState(() {
      if (index < _images.length) {
        _images.removeAt(index);
        _images.insert(index, image);
      } else {
        _images.add(image);
      }
    });
    return true;
  }

  void _selectUrgent() {
    selectUrgentDialog(context, _urgent).then((UrgentStatus value) {
      if (value == null) return;
      setState(() {
        _urgent = value;
      });
    });
  }

  void _selectKind() {
    Navigator.pushNamed(
      context,
      '/kinds',
      arguments: KindsRouteArguments(_kind),
    ).then((kind) {
      if (kind == null) return;
      setState(() {
        _kind = kind;
      });
    });
  }

  void _selectLocation() {
    Navigator.pushNamed(
      context,
      '/my_item_map',
    ).then((value) {
      if (value == null) return;
      setState(() {});
    });
  }

  Future<bool> _onWillPop() async {
    if (_isSubmited) return true;
    if (_images.length == 0 && _textController.value.text.trim().length < 6)
      return true;
    final result = await showCancelItemDialog(context);
    return result ?? false; // if enableDrag, result may be null
  }
}

class AddItemRouteArguments {
  AddItemRouteArguments({this.kind});

  final KindId kind;
}
