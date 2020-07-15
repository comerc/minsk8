import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:extended_image/extended_image.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:characters/characters.dart';
import 'package:minsk8/import.dart';

// TODO: прятать клавиатуру перед showDialog(), чтобы убрать анимацию диалога
// TODO: прикрутить characters для выяснения размера введенного текста

enum ImageUploadStatus { progress, error }

class AddItemScreen extends StatefulWidget {
  AddItemScreen(this.arguments);

  final AddItemRouteArguments arguments;

  @override
  _AddItemScreenState createState() {
    return _AddItemScreenState();
  }
}

class _AddItemScreenState extends State<AddItemScreen> {
  TextEditingController _textController;
  ImageSource _imageSource;
  List<_ImageData> _images = [];
  UrgentStatus _urgent = UrgentStatus.not_urgent;
  KindValue _kind;
  FocusNode _textFocusNode;
  Future<void> _uploadQueue = Future.value();

  String get _urgentName =>
      urgents
          .firstWhere((UrgentModel element) => element.value == _urgent,
              orElse: () => null)
          ?.name ??
      '';
  String get _text => _textController.value.text.trim();
  bool get _isValidText => _text.characters.length > 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_onAfterBuild);
    _textController = TextEditingController(text: '');
    _kind = widget.arguments.kind;
    _textFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final panelChildWidth = size.width - 32.0; // for padding
    final gridSpacing = 8.0;
    final child = Column(
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
                        (index) => _buildAddImageButton(index + 1),
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
          child: TextField(
            autofocus: false,
            enableSuggestions: false,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: _textController,
            focusNode: _textFocusNode,
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
            rightText: _urgentName,
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
            text: appState['MyItemMap.address'] ?? 'Местоположение',
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
          actions: [
            IconButton(
              tooltip: 'Подтвердить',
              icon: Icon(Icons.check),
              onPressed: _handleAddItem,
            ),
          ],
        ),
        body: body,
      ),
    );
  }

  void _onAfterBuild(Duration timeStamp) {
    showImageSourceDialog(context).then((ImageSource imageSource) {
      if (imageSource == null) return;
      _pickImage(0, imageSource).then((bool result) {
        if (!result) return;
        _imageSource = imageSource;
      });
    });
  }

  void _handleAddItem() async {
    if (!_isValidText) {
      showDialog(
        context: context,
        child: AlertDialog(
          content: Text('Опишите лот: что это, состояние, размер...'),
          actions: [
            FlatButton(
              child: Text('ОК'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ).then((_) {
        _textFocusNode.requestFocus();
      });
      return;
    }
    bool isLoading = true;
    showDialog(
      context: context,
      barrierDismissible: false, // TODO: как отменить загрузку?
      child: AlertDialog(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildProgressIndicator(context),
            SizedBox(width: 16),
            Text('Загрузка...'),
          ],
        ),
      ),
    );
    await _uploadQueue;
    final images = _images.where((value) => value.uploadStatus == null);
    if (images.length == 0) {
      Navigator.of(context).pop(); // for showDialog "Загрузка..."
      showDialog(
        context: context,
        child: AlertDialog(
          content: Text('Добавьте фотографию лота'),
          actions: [
            FlatButton(
              child: Text('ОК'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
      return;
    }
    final GraphQLClient client = GraphQLProvider.of(context).value;
    final options = MutationOptions(
      documentNode: Mutations.insertItem,
      variables: {
        'images': images.map((element) => element.model.toJson()).toList(),
        'text': _text, // TODO: как защитить от атаки?
        'urgent': EnumToString.parse(_urgent),
        'kind': EnumToString.parse(_kind),
        'location': {
          'type': 'Point',
          'coordinates': appState['MyItemMap.center'],
        },
        'address': appState['MyItemMap.address'],
      },
      fetchPolicy: FetchPolicy.noCache,
    );
    client
        .mutate(options)
        // TODO: если таймаут, то фокус на поле ввода и клавиатура - не хочу
        // .timeout(Duration(milliseconds: 100))
        .timeout(Duration(seconds: kGraphQLMutationTimeout))
        .then((QueryResult result) async {
      if (result.hasException) {
        throw result.exception;
      }
      isLoading = false;
      Navigator.of(context).pop(); // for showDialog "Загрузка..."
      final itemData = result.data['insert_item_one'];
      final newItem = ItemModel.fromJson(itemData);
      final profile = Provider.of<ProfileModel>(context, listen: false);
      profile.member.items.insert(0, newItem);
      _reloadShowcaseTab(_kind);
      _reloadShowcaseTab(MetaKindValue.recent);
      _reloadUnderwayModel();
      final value = await showDialog(
        context: context,
        child: AddedItemDialog(
          newItem,
          needModerate: _kind == KindValue.service,
        ),
      );
      if (value ?? false) {
        final kind = await Navigator.of(context).pushReplacementNamed('/kinds');
        if (kind == null) return;
        Navigator.pushNamed(
          HomeScreen.globalKey.currentContext, // hack
          '/add_item',
          arguments: AddItemRouteArguments(
            kind: kind,
            tabIndex: widget.arguments.tabIndex,
          ),
        );
        return;
      }
      Navigator.of(context).pushReplacementNamed(
        '/item',
        arguments: ItemRouteArguments(
          newItem,
          member: profile.member,
        ),
      );
    }).catchError((error) {
      debugPrint(error.toString());
      if (isLoading) {
        Navigator.of(context).pop(); // for showDialog "Загрузка..."
      }
      final snackBar = SnackBar(
          content: Text('Не удалось загрузить лот, попробуйте ещё раз'));
      Scaffold.of(context).showSnackBar(snackBar);
    });
  }

  Widget _buildAddImageButton(int index) {
    final isExistIndex = _images.length > index;
    return AddImageButton(
      index: index,
      hasIcon: _images.length == index,
      onTap: isExistIndex ? _handleDeleteImage : _handleAddImage,
      bytes: isExistIndex ? _images[index].bytes : null,
      uploadStatus: isExistIndex ? _images[index].uploadStatus : null,
    );
  }

  void _handleAddImage(int index) {
    if (_imageSource == null) {
      showImageSourceDialog(context).then((ImageSource imageSource) {
        if (imageSource == null) return;
        _pickImage(index, imageSource).then((bool result) {
          if (!result) return;
          _imageSource = imageSource;
        });
      });
      return;
    }
    _pickImage(index, _imageSource);
  }

  void _handleDeleteImage(int index) {
    _cancelUploadImage(_images[index]);
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<bool> _pickImage(int index, ImageSource imageSource) async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.getImage(source: imageSource).catchError((error) {
      debugPrint(error.toString());
    });
    if (pickedFile == null) return false;
    final bytes = await pickedFile.readAsBytes();
    final imageData = _ImageData(bytes);
    setState(() {
      if (index < _images.length) {
        _images.removeAt(index);
        _images.insert(index, imageData);
      } else {
        _images.add(imageData);
      }
    });
    _uploadQueue = _uploadQueue.then((_) => _uploadImage(imageData));
    _uploadQueue = _uploadQueue.timeout(Duration(seconds: kImageUploadTimeout));
    _uploadQueue = _uploadQueue.catchError((error) {
      if (error is TimeoutException) {
        _cancelUploadImage(imageData);
        // если не получилось выполнить отмену, то ничего страшного
        // выставлен флал imageData.uploadStatus = ImageUploadStatus.error
        // и по нему строится список images для загрузки в GraphQL
        imageData.uploadStatus = ImageUploadStatus.error;
        if (mounted) setState(() {});
        final snackBar = SnackBar(
            content:
                Text('Не удалось загрузить фотографию, попробуйте ещё раз'));
        Scaffold.of(context).showSnackBar(snackBar);
      }
      debugPrint(error.toString());
    });
    return true;
  }

  Future<void> _uploadImage(_ImageData imageData) async {
    // final completer = Completer<void>();
    // // TODO: FirebaseStorage ругается "no auth token for request"
    // final storage =
    //     // FirebaseStorage.instance;
    //     FirebaseStorage(storageBucket: kStorageBucket);
    // final filePath = 'images/${DateTime.now()} ${Uuid().v4()}.png';
    // // TODO: оптимизировать размер данных картинок перед выгрузкой
    // final uploadTask = storage.ref().child(filePath).putData(bytes);
    // final streamSubscription = uploadTask.events.listen((event) async {
    //   // TODO: if (event.type == StorageTaskEventType.progress)
    //   if (event.type != StorageTaskEventType.success) return;
    //   final downloadUrl = await event.snapshot.ref.getDownloadURL();
    //   final image = ExtendedImage.memory(bytes);
    //   final size = await _calculateImageDimension(image);
    //   imageData.model = ImageModel(
    //     url: downloadUrl,
    //     width: size.width,
    //     height: size.height,
    //   );
    //   await Future.delayed(Duration(seconds: 10));
    //   completer.complete();
    // });
    // await uploadTask.onComplete;
    // streamSubscription.cancel();
    // await completer.future;
    final filePath = 'images/${DateTime.now()} ${Uuid().v4()}.png';
    final storageReference = FirebaseStorage.instance.ref().child(filePath);
    imageData.uploadTask = storageReference.putData(imageData.bytes);
    final streamSubscription =
        imageData.uploadTask.events.listen((event) async {
      if (event.type == StorageTaskEventType.progress) {
        print(
            'progress ${event.snapshot.bytesTransferred} / ${event.snapshot.totalByteCount}');
      }
      // TODO: добавить индикатор загрузки и кнопку отмены
    });
    // await Future.delayed(Duration(seconds: 5));
    await imageData.uploadTask.onComplete;
    if (imageData.uploadStatus == ImageUploadStatus.progress) {
      imageData.uploadStatus = null;
      if (mounted) setState(() {});
    }
    await streamSubscription.cancel();
    final isCanceled = imageData.uploadTask.isCanceled;
    imageData.uploadTask = null;
    if (isCanceled) return;
    final downloadUrl = await storageReference.getDownloadURL();
    final image = ExtendedImage.memory(imageData.bytes);
    final size = await _calculateImageDimension(image);
    imageData.model = ImageModel(
      url: downloadUrl,
      width: size.width,
      height: size.height,
    );
  }

  void _cancelUploadImage(_ImageData imageData) {
    try {
      if (imageData.uploadTask == null ||
          imageData.uploadTask.isComplete ||
          imageData.uploadTask.isCanceled) return;
      // если сразу вызвать снаружи, то падает - обернул в try-catch
      imageData.uploadTask.cancel();
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<SizeInt> _calculateImageDimension(ExtendedImage image) {
    final completer = Completer<SizeInt>();
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          final myImage = image.image;
          final size = SizeInt(myImage.width, myImage.height);
          completer.complete(size);
        },
      ),
    );
    return completer.future;
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
    if (_images.length == 0 && !_isValidText) return true;
    final result = await showModalBottomSheet(
      context: context,
      builder: (context) => buildModalBottomSheet(
        context,
        description: 'Вы очень близки к тому,\nчтобы отдать эту вещь.',
      ),
    );
    // if enableDrag, result may be null
    return result ?? false;
  }

  void _reloadShowcaseTab(kind) {
    final index = allKinds.indexWhere((element) => element.value == kind);
    if (index == widget.arguments.tabIndex?.showcase) {
      ShowcasePage.pullToRefreshNotificationKey.currentState.show();
    } else if (!ShowcasePage.poolForReloadTabs.contains(index)) {
      ShowcasePage.poolForReloadTabs.add(index);
    }
  }

  void _reloadUnderwayModel() {
    final index = UnderwayValue.values
        .indexWhere((element) => element == UnderwayValue.give);
    if (index == widget.arguments.tabIndex?.underway) {
      UnderwayPage.pullToRefreshNotificationKey.currentState.show();
    } else if (!UnderwayPage.poolForReloadTabs.contains(index)) {
      UnderwayPage.poolForReloadTabs.add(index);
    }
  }
}

class AddItemRouteArguments {
  AddItemRouteArguments({this.kind, this.tabIndex});

  final KindValue kind;
  final AddItemRouteArgumentsTabIndex tabIndex;
}

class AddItemRouteArgumentsTabIndex {
  AddItemRouteArgumentsTabIndex({this.showcase = 0, this.underway = 0});

  final int showcase;
  final int underway;
}

class _ImageData {
  _ImageData(this.bytes);

  final Uint8List bytes;
  StorageUploadTask uploadTask;
  ImageUploadStatus uploadStatus = ImageUploadStatus.progress;
  ImageModel model;
}
