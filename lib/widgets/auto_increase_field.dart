import 'dart:math';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:minsk8/import.dart';

const Duration _kExpand = Duration(milliseconds: 200);

class AutoIncreaseField extends StatefulWidget {
  AutoIncreaseField({Key key, this.price, this.balance}) : super(key: key);

  final int price;
  final int balance;

  @override
  AutoIncreaseFieldState createState() {
    return AutoIncreaseFieldState();
  }
}

class AutoIncreaseFieldState extends State<AutoIncreaseField>
    with TickerProviderStateMixin {
  FixedExtentScrollController _controller;
  bool _isExpanded = false;
  int get _minValue => widget.price == null ? 2 : widget.price + 3;
  int _currentValue;

  int get currentValue => _currentValue;

  final _values = kPaymentSteps
      .map<int>(
        (PaymentStepModel element) => element.amount,
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _currentValue = _minValue + 10;
    _controller = FixedExtentScrollController(initialItem: _currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final needValue = max(0, _currentValue - widget.balance);
    final step = getNearestStep(_values, needValue);
    final header = Tooltip(
      message:
          _isExpanded ? 'Выключить автоповышение' : 'Включить автоповышение',
      child: SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(
          'Автоповышение ставки',
          // такой же стиль для 'Самовывоз'
          style: TextStyle(
            color: Colors.black.withOpacity(0.8),
          ),
        ),
        value: _isExpanded,
        onChanged: (bool value) {
          setState(() {
            _isExpanded = value;
            if (!_isExpanded) {
              // stop
              _controller.jumpToItem(_controller.selectedItem);
            }
          });
        },
      ),
    );
    final message = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 0), // TODO: убрать hack
          child: Text(
            'У Вас только ${getPluralKarma(widget.balance)}. Получите\u00A0ещё, чтобы установить желаемый максимум.',
            style: TextStyle(
              fontSize: kFontSize,
              color: Colors.red,
            ),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        FlatButton(
          child: Text('ПОЛУЧИТЬ ${getPluralKarma(step).toUpperCase()}'),
          onLongPress: () {}, // чтобы сократить время для splashColor
          onPressed: () {
            print(step);
            // TODO: [MVP] переход к оплате
            // Navigator.of(context).pop(true);
          },
          color: Colors.green,
          textColor: Colors.white,
        ),
      ],
    );
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 0), // TODO: убрать hack
          child: Text(
            'Ставка будет повышаться автоматически на\u00A0+${getPluralKarma(1)} до\u00A0заданного максимума:',
            style: TextStyle(
              fontSize: kFontSize,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ),
        SizedBox(height: 8),
        Container(
          color: Colors.yellow.withOpacity(0.5),
          height: kButtonHeight,
          child: GlowNotificationWidget(
            ExtendedListWheelScrollView(
              scrollDirection: Axis.horizontal,
              itemExtent: kButtonHeight * kGoldenRatio,
              useMagnifier: true,
              magnification: kGoldenRatio,
              onSelectedItemChanged: (int index) {
                setState(() {
                  _currentValue = index;
                });
              },
              controller: _controller,
              minIndex: _minValue,
              maxIndex: 999999,
              builder: (BuildContext context, int index) {
                return Center(
                  child: Text(
                    index.toString(),
                    style: TextStyle(
                      fontSize: kPriceFontSize / kGoldenRatio,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        _buildAnimatedSize(
          needValue > 0 ? message : Container(),
        ),
        SizedBox(height: 16),
      ],
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        header,
        _buildAnimatedSize(
          Offstage(
            child: body,
            offstage: !_isExpanded,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedSize(Widget child) {
    return AnimatedSize(
      child: child,
      alignment: Alignment.topCenter,
      duration: _kExpand,
      reverseDuration: _kExpand,
      vsync: this,
    );
  }
}
