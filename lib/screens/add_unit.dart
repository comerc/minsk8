import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql/client.dart';
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

// TODO: перенести SelectField из pet_finder в minsk8,
// когда сделают ScrollablePositionedList.shrinkWrap
// https://github.com/google/flutter.widgets/issues/52
// а пока применил SingleChildScrollView + ListBox + Scrollable.ensureVisible

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
  UrgentValue _urgent = UrgentValue.notUrgent;
  KindValue _kind;
  FocusNode _textFocusNode;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String get _text => _textController.value.text.trim();
  bool get _isValidText => _text.characters.length > 3;
  final _imagesFieldKey = GlobalKey<ImagesFieldState>();

  @override
  void initState() {
    super.initState();
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
        SizedBox(height: 16),
        SizedBox(
          height: (panelChildWidth - gridSpacing) / 2,
          width: panelChildWidth,
          child: ImagesField(
            key: _imagesFieldKey,
            gridSpacing: gridSpacing,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
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
        SizedBox(height: 16),
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: ScrollBody(child: child),
        ),
        // resizeToAvoidBottomInset: false,
      ),
    );
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
            ExtendedProgressIndicator(),
            SizedBox(width: 16),
            Text('Загрузка...'),
          ],
        ),
      ),
    );
    final images = await _imagesFieldKey.currentState.value;
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
    // TODO: await getBloc<ProfileCubit>(context).addUnit(DAO);
    final options = MutationOptions(
      document: addFragments(Mutations.insertUnit),
      variables: {
        'images': images.map((ImageModel image) => image.toJson()).toList(),
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
      await getBloc<ProfileCubit>(context).addUnitLocaly(newUnit);
      // TODO: когда будет loadMore для "Другие лоты участника", тут будет дублирование
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
      final profile = getBloc<ProfileCubit>(context).state.profile;
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
    if (_imagesFieldKey.currentState.isEmpty && !_isValidText) return true;
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

Future<UrgentValue> _selectUrgentDialog(
    BuildContext context, UrgentValue selected) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return _UrgentDialog(selected: selected);
    },
  );
}

class _UrgentDialog extends StatefulWidget {
  const _UrgentDialog({this.selected});

  final UrgentValue selected;

  @override
  _UrgentDialogState createState() => _UrgentDialogState();
}

class _UrgentDialogState extends State<_UrgentDialog> {
  final keys =
      List.generate(UrgentValue.values.length, (int index) => GlobalKey());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_onAfterBuild);
  }

  void _onAfterBuild(Duration timeStamp) {
    final index = UrgentValue.values.indexOf(widget.selected);
    if (index == -1) return;
    Scrollable.ensureVisible(keys[index].currentContext);
  }

  @override
  Widget build(BuildContext context) {
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
          Flexible(
            child: SingleChildScrollView(
              child: ListBox(
                itemCount: UrgentValue.values.length,
                itemBuilder: (BuildContext context, int index) {
                  // TODO: CheckboxListTile
                  final current = UrgentValue.values[index];
                  return Material(
                    color: widget.selected == current
                        ? Colors.grey.withOpacity(0.2)
                        : Colors.white,
                    child: InkWell(
                      onLongPress:
                          () {}, // чтобы сократить время для splashColor
                      onTap: () {
                        navigator.pop(current);
                      },
                      child: ListTile(
                        key: keys[index],
                        title: Text(getUrgentName(current)),
                        subtitle: Text(getUrgentText(current)),
                        // selected: widget.selected == current,
                        trailing: widget.selected == current
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
            ),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}
