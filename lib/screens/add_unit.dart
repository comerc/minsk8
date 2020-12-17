import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql/client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:minsk8/import.dart';

// TODO: прятать клавиатуру перед showDialog(), чтобы убрать анимацию диалога
// TODO: кнопка ГОТОВО прибита книзу на маленьких экранах?
// TODO: (баг) фокус на поле ввода > скролл до появления elevation > убрать клаву > elevation остаётся
// TODO: блок "задать минимальную ставку"

// TODO: идея, как можно реализовать showSnackBar
// extension Context on BuildContext {
//   void showCustomDialog(String text) {
//     showDialog(
//       context: this,
//       child: AlertDialog(title: Text(text)),
//     );
//   }
//   void push(Widget screen) {
//     Navigator.of(this).push(MaterialPageRoute(builder: (_) => screen));
//   }
//   void pop() {
//     Navigator.of(this).pop();
//   }
// }

// TODO: упразднить AddUnitTabIndex
class AddUnitTabIndex {
  AddUnitTabIndex({this.showcase = 0, this.underway = 0});

  final int showcase;
  final int underway;
}

class AddUnitScreen extends StatefulWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/add_unit',
      builder: (_) => this,
      fullscreenDialog: true,
    );
  }

  AddUnitScreen({this.kind, this.tabIndex});

  final KindValue kind;
  final AddUnitTabIndex tabIndex;

  @override
  _AddUnitScreenState createState() {
    return _AddUnitScreenState();
  }
}

class _AddUnitScreenState extends State<AddUnitScreen> {
  TextEditingController _textController;
  ImageSource _imageSource;
  final _images = <_ImageData>[];
  UrgentValue _urgent = UrgentValue.notUrgent;
  KindValue _kind;
  FocusNode _textFocusNode;
  Future<void> _uploadQueue = Future.value();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String get _text => _textController.value.text.trim();
  bool get _isValidText => _text.characters.length > 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_onAfterBuild);
    _textController = TextEditingController(text: '');
    _kind = widget.kind;
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
              SizedBox(
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
            rightText: getUrgentName(_urgent),
            onTap: _selectUrgent,
          ),
        ),
        Container(
          constraints: BoxConstraints(minHeight: 40),
          child: SelectButton(
            tooltip: 'Категория',
            text: getKindName(_kind),
            onTap: _selectKind,
          ),
        ),
        Container(
          constraints: BoxConstraints(minHeight: 40),
          child: SelectButton(
            tooltip: 'Местоположение',
            text: appState['MyUnitMap.address'] as String ?? 'Местоположение',
            onTap: _selectLocation,
          ),
        ),
        Spacer(),
        SizedBox(
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
    _showImageSourceDialog(context).then((ImageSource imageSource) {
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
              onPressed: () {
                navigator.pop();
              },
              child: Text('ОК'),
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
      navigator.pop(); // for showDialog "Загрузка..."
      await showDialog(
        context: context,
        child: AlertDialog(
          content: Text('Добавьте фотографию лота'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                navigator.pop();
              },
              child: Text('ОК'),
            ),
          ],
        ),
      );
      return;
    }
    final options = MutationOptions(
      document: addFragments(Mutations.insertUnit),
      variables: {
        'images':
            images.map((_ImageData element) => element.model.toJson()).toList(),
        'text': _text, // TODO: как защитить от атаки?
        'urgent': convertEnumToSnakeCase(_urgent),
        'kind': convertEnumToSnakeCase(_kind),
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
        .timeout(kGraphQLMutationTimeout)
        .then((QueryResult result) async {
      if (result.hasException) {
        throw result.exception;
      }
      isLoading = false;
      navigator.pop(); // for showDialog "Загрузка..."
      final unitData = result.data['insert_unit_one'] as Map<String, dynamic>;
      final newUnit = UnitModel.fromJson(unitData);
      final profile = Provider.of<ProfileModel>(context, listen: false);
      // TODO: когда будет loadMore для "Другие лоты участника", тут будет дублирование
      profile.member.units.insert(0, newUnit);
      _reloadShowcaseTab(_kind);
      _reloadShowcaseTab(MetaKindValue.recent);
      _reloadUnderwayModel();
      final value = await showDialog<bool>(
        context: context,
        child: _AddedUnitDialog(
          newUnit,
          needModerate: _kind == KindValue.service,
        ),
      );
      if (value ?? false) {
        final kind = await navigator.pushReplacement<KindValue, void>(
          KindsScreen().getRoute(),
        ); // as KindValue; // workaround for typecast
        if (kind == null) return;
        // TODO: когда закрывается KindsScreen, то видна витрина
        // ignore: unawaited_futures
        navigator.push(
          // HomeScreen.globalKey.currentContext, // hack, или: Navigator.of(context, rootNavigator: true)
          AddUnitScreen(
            kind: kind,
            tabIndex: widget.tabIndex,
          ).getRoute(),
        );
        return;
      }
      // ignore: unawaited_futures
      navigator.pushReplacement(
        UnitScreen(
          newUnit,
          member: profile.member,
        ).getRoute(),
      );
    }).catchError((error) {
      out(error);
      if (isLoading) {
        navigator.pop(); // for showDialog "Загрузка..."
      }
      final snackBar = SnackBar(
          content: Text('Не удалось загрузить лот, попробуйте ещё раз'));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    });
  }

  Widget _buildAddImageButton(int index) {
    final isExistIndex = _images.length > index;
    return _AddImageButton(
      index: index,
      hasIcon: _images.length == index,
      onTap: isExistIndex ? _handleDeleteImage : _handleAddImage,
      bytes: isExistIndex ? _images[index].bytes : null,
      uploadStatus: isExistIndex ? _images[index].uploadStatus : null,
    );
  }

  void _handleAddImage(int index) {
    if (_imageSource == null) {
      _showImageSourceDialog(context).then((ImageSource imageSource) {
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
      out(error);
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
    _uploadQueue = _uploadQueue.timeout(kImageUploadTimeout);
    _uploadQueue = _uploadQueue.catchError((error) {
      if (error is TimeoutException) {
        _cancelUploadImage(imageData);
        // если не получилось выполнить отмену, то ничего страшного
        // выставлен флал imageData.uploadStatus = _ImageUploadStatus.error
        // и по нему строится список images для загрузки в GraphQL
        imageData.uploadStatus = _ImageUploadStatus.error;
        if (mounted) setState(() {});
        final snackBar = SnackBar(
            content: Text('Не удалось загрузить картинку, попробуйте ещё раз'));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
      out(error);
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
        out('progress ${event.snapshot.bytesTransferred} / ${event.snapshot.totalByteCount}');
      }
      // TODO: добавить индикатор загрузки и кнопку отмены
      // TODO: отрабатывать тут StorageTaskEventType.failure и StorageTaskEventType.success
    });
    await imageData.uploadTask.onComplete;
    await streamSubscription.cancel();
    imageData.uploadTask = null;
    if (imageData.uploadStatus == _ImageUploadStatus.progress) {
      imageData.uploadStatus = null;
      if (mounted) setState(() {});
    }
    if (imageData.isCanceled) return;
    final downloadUrl = await storageReference.getDownloadURL() as String;
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
      out(error);
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
    _selectUrgentDialog(context, _urgent).then((UrgentValue value) {
      if (value == null) return;
      setState(() {
        _urgent = value;
      });
    });
  }

  void _selectKind() async {
    final kind = await navigator.push<KindValue>(
      KindsScreen(_kind).getRoute(),
    ); // as KindValue; // workaround for typecast
    if (kind == null) return;
    setState(() {
      _kind = kind;
    });
  }

  void _selectLocation() {
    navigator.push(MyUnitMapScreen().getRoute()).then((value) {
      if (value == null) return;
      setState(() {});
    });
  }

  Future<bool> _onWillPop() async {
    if (_images.isEmpty && !_isValidText) return true;
    final result = await showModalBottomSheet<bool>(
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
    final index = [...MetaKindValue.values, ...KindValue.values]
        .indexWhere((dynamic value) => value == kind);
    if (index == widget.tabIndex?.showcase) {
      HomeShowcase.pullToRefreshNotificationKey.currentState.show();
    } else if (!HomeShowcase.poolForReloadTabs.contains(index)) {
      HomeShowcase.poolForReloadTabs.add(index);
    }
  }

  void _reloadUnderwayModel() {
    final index = UnderwayValue.values
        .indexWhere((UnderwayValue value) => value == UnderwayValue.give);
    if (index == widget.tabIndex?.underway) {
      HomeUnderway.pullToRefreshNotificationKey.currentState.show();
    } else if (!HomeUnderway.poolForReloadTabs.contains(index)) {
      HomeUnderway.poolForReloadTabs.add(index);
    }
  }
}

enum _ImageUploadStatus { progress, error }

class _ImageData {
  _ImageData(this.bytes);

  final Uint8List bytes;
  StorageUploadTask uploadTask;
  _ImageUploadStatus uploadStatus = _ImageUploadStatus.progress;
  ImageModel model;
  bool isCanceled = false;
}

class _AddImageButton extends StatelessWidget {
  _AddImageButton({
    Key key,
    this.index,
    this.hasIcon,
    this.onTap,
    this.bytes,
    this.uploadStatus,
  }) : super(key: key);

  final int index;
  final bool hasIcon;
  final void Function(int) onTap;
  final Uint8List bytes;
  final _ImageUploadStatus uploadStatus;

  // TODO: по длинному тапу - редактирование фотографии (кроп, поворот, и т.д.)

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Добавить/удалить фотографию',
      child: Material(
        child: bytes == null
            // продублировал InkWell, чтобы не переопределять splashColor
            ? InkWell(
                onTap: _onTap,
                child: hasIcon
                    ? Icon(
                        FontAwesomeIcons.camera,
                        color: Colors.black.withOpacity(0.8),
                        size: kBigButtonIconSize,
                      )
                    : Container(),
              )
            : InkWell(
                splashColor: Colors.white.withOpacity(0.4),
                onTap: _onTap,
                child: Ink.image(
                  fit: BoxFit.cover,
                  image: ExtendedImage.memory(bytes).image,
                  child: uploadStatus == null
                      ? null
                      : Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Container(color: Colors.white.withOpacity(0.4)),
                            if (uploadStatus == _ImageUploadStatus.progress)
                              Center(
                                child: buildProgressIndicator(
                                  context,
                                  hasAnimatedColor: true,
                                ),
                              ),
                            if (uploadStatus == _ImageUploadStatus.error)
                              Center(
                                child: Icon(
                                  FontAwesomeIcons.solidTimesCircle,
                                  color: Colors.red,
                                  size: kBigButtonIconSize,
                                ),
                              ),
                          ],
                        ),
                ),
              ),
      ),
    );
  }

  void _onTap() {
    onTap(index);
  }
}

// TODO: применить ButtonBar для выравнивания кнопок?

class _AddedUnitDialog extends StatelessWidget {
  _AddedUnitDialog(this.unit, {this.needModerate = false});

  final UnitModel unit;
  final bool needModerate;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      children: <Widget>[
        Logo(size: kButtonIconSize),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            needModerate ? 'Лот успешно добавлен' : 'Ура! Ваш лот добавлен',
            textAlign: TextAlign.center,
            style: TextStyle(
              // fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            needModerate
                ? 'Мы Вам сообщим, когда лот пройдёт модерацию'
                : 'Победитель Вам напишет.\nСпасибо за доброе дело!',
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: needModerate ? 72 : 32,
            right: needModerate ? 72 : 32,
          ),
          child: Column(
            children: <Widget>[
              // TODO: FlatButton + ButtonTheme(minWidth: double.infinity)
              MaterialButton(
                minWidth: double.infinity,
                onLongPress: () {}, // чтобы сократить время для splashColor
                onPressed: () {
                  navigator.pop(true);
                },
                color: Colors.green,
                textColor: Colors.white,
                elevation: 0,
                highlightElevation: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.plus,
                      size: kButtonIconSize,
                    ),
                    SizedBox(width: 8),
                    Text('Добавьте ещё один лот'),
                  ],
                ),
              ),
              if (!needModerate)
                // TODO: OutlineButton + ButtonTheme(minWidth: double.infinity)
                MaterialButton(
                  minWidth: double.infinity,
                  onLongPress: () {}, // чтобы сократить время для splashColor
                  onPressed: () {
                    share(unit);
                  },
                  color: Colors.white,
                  textColor: Colors.green,
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: BorderSide(color: Colors.green)),
                  elevation: 0,
                  highlightElevation: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.share,
                        size: kButtonIconSize,
                      ),
                      SizedBox(width: 8),
                      Text('Поделитесь и получите бонус'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<ImageSource> _showImageSourceDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text('Что использовать?'),
      children: <Widget>[
        _ImageSourceUnit(
          icon: FontAwesomeIcons.camera,
          text: 'Камера',
          result: ImageSource.camera,
        ),
        _ImageSourceUnit(
          icon: FontAwesomeIcons.solidImages,
          text: 'Галерея',
          result: ImageSource.gallery,
        ),
      ],
    ),
  );
}

class _ImageSourceUnit extends StatelessWidget {
  _ImageSourceUnit({
    Key key,
    this.icon,
    this.text,
    this.result,
  }) : super(key: key);

  final IconData icon;
  final String text;
  final ImageSource result;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {}, // чтобы сократить время для splashColor
      child: SimpleDialogOption(
        onPressed: () {
          navigator.pop(result);
        },
        child: Row(
          children: <Widget>[
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
      ),
    );
  }
}

// TODO: CheckboxListTile

Future<UrgentValue> _selectUrgentDialog(
    BuildContext context, UrgentValue selected) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 32),
            Text(
              'Как срочно надо отдать?',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 16),
            ListBox(
              itemCount: UrgentValue.values.length,
              itemBuilder: (BuildContext context, int index) {
                final current = UrgentValue.values[index];
                return Material(
                  color: selected == current
                      ? Colors.grey.withOpacity(0.2)
                      : Colors.white,
                  child: InkWell(
                    onLongPress: () {}, // чтобы сократить время для splashColor
                    onTap: () {
                      navigator.pop(current);
                    },
                    child: ListTile(
                      title: Text(getUrgentName(current)),
                      subtitle: Text(getUrgentText(current)),
                      // selected: selected == current,
                      trailing: selected == current
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ),
                              ),
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.check,
                                color: Colors.red,
                                size: kButtonIconSize,
                              ),
                            )
                          : null,
                      dense: true,
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 8);
              },
            ),
            SizedBox(height: 32),
          ],
        ),
      );
    },
  );
}
