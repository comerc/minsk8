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
// TODO: кнопка ГОТОВО прибита книзу на маленьких экранах?
// TODO: (баг) фокус на поле ввода > скролл до появления elevation > убрать клаву > elevation остаётся

enum ImageUploadStatus { progress, error }

class AddUnitScreen extends StatefulWidget {
  AddUnitScreen(this.arguments);

  final AddUnitRouteArguments arguments;

  @override
  _AddUnitScreenState createState() {
    return _AddUnitScreenState();
  }
}

class _AddUnitScreenState extends State<AddUnitScreen> {
  TextEditingController _textController;
  ImageSource _imageSource;
  final _images = <_ImageData>[];
  UrgentStatus _urgent = UrgentStatus.not_urgent;
  KindValue _kind;
  FocusNode _textFocusNode;
  Future<void> _uploadQueue = Future.value();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String get _urgentName =>
      kUrgents
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
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: (panelChildWidth - gridSpacing) / 2,
                width: panelChildWidth,
                child: GridView.count(
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: gridSpacing,
                  crossAxisCount: 2,
                  children: <Widget>[
                    _buildAddImageButton(0),
                    GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      mainAxisSpacing: gridSpacing,
                      crossAxisSpacing: gridSpacing,
                      crossAxisCount: 2,
                      children: List.generate(
                        4,
                        (int index) => _buildAddImageButton(index + 1),
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
            text: kKinds
                .firstWhere((KindModel element) => element.value == _kind)
                .name,
            onTap: _selectKind,
          ),
        ),
        Container(
          constraints: BoxConstraints(minHeight: 40),
          child: SelectButton(
            tooltip: 'Местоположение',
            text: appState['MyUnitMap.address'] ?? 'Местоположение',
            onTap: _selectLocation,
          ),
        ),
        Spacer(),
        Container(
          height: kBigButtonHeight,
          width: panelChildWidth,
          child: ReadyButton(onTap: _handleAddUnit),
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: ExtendedAppBar(
          title: Text('Что отдаёте?'),
          actions: <Widget>[
            IconButton(
              tooltip: 'Подтвердить',
              icon: Icon(Icons.check),
              onPressed: _handleAddUnit,
            ),
          ],
          withModel: true,
        ),
        body: SafeArea(
          child: ScrollBody(child: child),
        ),
        // resizeToAvoidBottomInset: false,
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

  void _handleAddUnit() async {
    if (!_isValidText) {
      await showDialog(
        context: context,
        child: AlertDialog(
          content: Text('Опишите лот: что это, состояние, размер...'),
          actions: <Widget>[
            FlatButton(
              child: Text('ОК'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
      _textFocusNode.requestFocus();
      return;
    }
    var isLoading = true;
    // ignore: unawaited_futures
    showDialog(
      context: context,
      barrierDismissible: false, // TODO: как отменить загрузку?
      child: AlertDialog(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            buildProgressIndicator(context),
            SizedBox(width: 16),
            Text('Загрузка...'),
          ],
        ),
      ),
    );
    await _uploadQueue;
    final images = _images.where((value) => value.uploadStatus == null);
    if (images.isEmpty) {
      Navigator.of(context).pop(); // for showDialog "Загрузка..."
      await showDialog(
        context: context,
        child: AlertDialog(
          content: Text('Добавьте фотографию лота'),
          actions: <Widget>[
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
    final client = GraphQLProvider.of(context).value;
    final options = MutationOptions(
      documentNode: Mutations.insertUnit,
      variables: {
        'images':
            images.map((_ImageData element) => element.model.toJson()).toList(),
        'text': _text, // TODO: как защитить от атаки?
        'urgent': EnumToString.parse(_urgent),
        'kind': EnumToString.parse(_kind),
        'location': {
          'type': 'Point',
          'coordinates': appState['MyUnitMap.center'],
        },
        'address': appState['MyUnitMap.address'],
      },
      fetchPolicy: FetchPolicy.noCache,
    );
    // ignore: unawaited_futures
    client
        .mutate(options)
        .timeout(kGraphQLMutationTimeoutDuration)
        .then((QueryResult result) async {
      if (result.hasException) {
        throw result.exception;
      }
      isLoading = false;
      Navigator.of(context).pop(); // for showDialog "Загрузка..."
      final unitData = result.data['insert_unit_one'];
      final newUnit = UnitModel.fromJson(unitData);
      final profile = Provider.of<ProfileModel>(context, listen: false);
      profile.member.units.insert(0, newUnit);
      _reloadShowcaseTab(_kind);
      _reloadShowcaseTab(MetaKindValue.recent);
      _reloadUnderwayModel();
      final value = await showDialog(
        context: context,
        child: AddedUnitDialog(
          newUnit,
          needModerate: _kind == KindValue.service,
        ),
      );
      if (value ?? false) {
        final kind = await Navigator.of(context).pushReplacementNamed('/kinds');
        if (kind == null) return;
        // ignore: unawaited_futures
        Navigator.pushNamed(
          HomeScreen.globalKey.currentContext, // hack
          '/add_unit',
          arguments: AddUnitRouteArguments(
            kind: kind,
            tabIndex: widget.arguments.tabIndex,
          ),
        );
        return;
      }
      // ignore: unawaited_futures
      Navigator.of(context).pushReplacementNamed(
        '/unit',
        arguments: UnitRouteArguments(
          newUnit,
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
      _scaffoldKey.currentState.showSnackBar(snackBar);
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
    _uploadQueue = _uploadQueue.timeout(kImageUploadTimeoutDuration);
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
        _scaffoldKey.currentState.showSnackBar(snackBar);
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
      // TODO: отрабатывать тут StorageTaskEventType.failure и StorageTaskEventType.success
    });
    await imageData.uploadTask.onComplete;
    await streamSubscription.cancel();
    imageData.uploadTask = null;
    if (imageData.uploadStatus == ImageUploadStatus.progress) {
      imageData.uploadStatus = null;
      if (mounted) setState(() {});
    }
    if (imageData.isCanceled) return;
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
    imageData.isCanceled = true;
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
      '/my_unit_map',
    ).then((value) {
      if (value == null) return;
      setState(() {});
    });
  }

  Future<bool> _onWillPop() async {
    if (_images.isEmpty && !_isValidText) return true;
    final result = await showModalBottomSheet(
      context: context,
      builder: (context) => buildModalBottomSheet(
        context,
        description: 'Вы очень близки к тому,\nчтобы отдать этот лот.',
      ),
    );
    // if enableDrag, result may be null
    return result ?? false;
  }

  void _reloadShowcaseTab(kind) {
    final index =
        kAllKinds.indexWhere((EnumModel element) => element.value == kind);
    if (index == widget.arguments.tabIndex?.showcase) {
      HomeShowcase.pullToRefreshNotificationKey.currentState.show();
    } else if (!HomeShowcase.poolForReloadTabs.contains(index)) {
      HomeShowcase.poolForReloadTabs.add(index);
    }
  }

  void _reloadUnderwayModel() {
    final index = UnderwayValue.values
        .indexWhere((UnderwayValue element) => element == UnderwayValue.give);
    if (index == widget.arguments.tabIndex?.underway) {
      HomeUnderway.pullToRefreshNotificationKey.currentState.show();
    } else if (!HomeUnderway.poolForReloadTabs.contains(index)) {
      HomeUnderway.poolForReloadTabs.add(index);
    }
  }
}

class AddUnitRouteArguments {
  AddUnitRouteArguments({this.kind, this.tabIndex});

  final KindValue kind;
  final AddUnitRouteArgumentsTabIndex tabIndex;
}

class AddUnitRouteArgumentsTabIndex {
  AddUnitRouteArgumentsTabIndex({this.showcase = 0, this.underway = 0});

  final int showcase;
  final int underway;
}

class _ImageData {
  _ImageData(this.bytes);

  final Uint8List bytes;
  StorageUploadTask uploadTask;
  ImageUploadStatus uploadStatus = ImageUploadStatus.progress;
  ImageModel model;
  bool isCanceled = false;
}
