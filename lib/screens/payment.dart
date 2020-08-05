import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

// TODO: добавить подпись "выгода"

const _kDuration = Duration(milliseconds: 400);
const _kCurve = Curves.fastOutSlowIn;

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() {
    return _PaymentScreenState();
  }
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
// class PaymentScreen extends StatelessWidget {

  int _activeIndex;
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _activeIndex = 1;
    assert(_activeIndex == 1);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLargeWidth = width < kLargeWidth;
    final listViewPadding = 16.0;
    final separatorWidth = 4.0;
    final lengthInScreen = isLargeWidth ? 3 : 4;
    final commonWidth =
        (width - listViewPadding * 2 - separatorWidth * (lengthInScreen - 1)) /
            lengthInScreen;
    final activeWidth = commonWidth * 1.15;
    final shadowWidth =
        (commonWidth * lengthInScreen - activeWidth) / (lengthInScreen - 1);
    final borderWidth = 1.0;
    final shadowHeight = (shadowWidth / 2) * kGoldenRatio;
    final shadowHeaderHeight = shadowHeight * kGoldenRatio - shadowHeight;
    final shadowFooterHeight = shadowHeight - shadowHeaderHeight;
    final activeHeight = (activeWidth / 2) * kGoldenRatio;
    final activeHeaderHeight = activeHeight / 2;
    final activeFooterHeight = activeHeight - activeHeaderHeight;
    final shadowDiscontHeight = 16.0;
    final priceBottomPadding = 6.0;
    final borderOpacity = 0.3;
    final activeDiscontHeight = 33.0;
    final activeDiscountPadding = 10.0;
    final child = Container(
      alignment: Alignment.topCenter,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 16),
                Logo(),
                SizedBox(height: 48),
                Text(
                  'Получите Карму\nза поддержку проекта',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 8),
                FlatButton(
                  child: Text(
                    'Вместе мы сделаем мир лучше',
                    style: TextStyle(
                      fontSize: kFontSize,
                      fontWeight: FontWeight.normal,
                      // color: Colors.black.withOpacity(0.6),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onLongPress: () {}, // чтобы сократить время для splashColor
                  onPressed: () {
                    Navigator.of(context).pushNamed('/make_it_together');
                  },
                  textColor: Colors.black.withOpacity(0.6),
                ),
                SizedBox(height: 8),
                Container(
                  height: activeHeight,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: listViewPadding),
                    scrollDirection: Axis.horizontal,
                    controller: _controller,
                    itemCount: kPaymentSteps.length,
                    itemBuilder: (BuildContext context, int index) {
                      final isActive = index == _activeIndex;
                      final paymentStep = kPaymentSteps[index];
                      final pilotOnePrice =
                          kPaymentSteps[0].price / kPaymentSteps[0].amount;
                      final currentOnePrice = kPaymentSteps[index].price /
                          kPaymentSteps[index].amount;
                      final discount =
                          (100 - (currentOnePrice / pilotOnePrice) * 100)
                              .floor();
                      return Center(
                        child: AnimatedContainer(
                          duration: _kDuration,
                          curve: _kCurve,
                          width: isActive ? activeWidth : shadowWidth,
                          height: isActive ? activeHeight : shadowHeight,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                            child: Stack(
                              children: <Widget>[
                                AnimatedOpacity(
                                  duration: _kDuration,
                                  curve: _kCurve,
                                  opacity: isActive ? borderOpacity : 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: borderWidth,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.bottomCenter,
                                  padding: EdgeInsets.only(
                                      bottom: priceBottomPadding),
                                  child: Text(
                                    '${paymentStep.price} \$',
                                    style: TextStyle(
                                      fontSize: kFontSize,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    AnimatedContainer(
                                      duration: _kDuration,
                                      curve: _kCurve,
                                      height: isActive
                                          ? activeHeaderHeight
                                          : shadowHeaderHeight,
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            '${paymentStep.amount}',
                                            style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  Colors.black.withOpacity(0.8),
                                            ),
                                          ),
                                          Text(
                                            'Кармы',
                                            style: TextStyle(
                                              fontSize: kFontSize,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (index != 0)
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: <Color>[
                                              Colors.deepOrange,
                                              Colors.yellow
                                            ],
                                            tileMode: TileMode.mirror,
                                            begin: Alignment.topLeft,
                                            end: Alignment(0.8, 1.2),
                                          ),
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            AnimatedPadding(
                                              duration: _kDuration,
                                              curve: _kCurve,
                                              padding: EdgeInsets.only(
                                                  top: isActive
                                                      ? activeDiscountPadding
                                                      : 0),
                                              child: AnimatedContainer(
                                                duration: _kDuration,
                                                curve: _kCurve,
                                                height: isActive
                                                    ? activeDiscontHeight -
                                                        activeDiscountPadding
                                                    : shadowDiscontHeight,
                                                child: FittedBox(
                                                  child: Text(
                                                    '+ $discount%',
                                                    style: TextStyle(
                                                      fontSize: kFontSize,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            ClipRect(
                                              child: ExtendedAnimatedAlign(
                                                duration: _kDuration,
                                                curve: _kCurve,
                                                alignment: Alignment.topCenter,
                                                heightFactor: isActive ? 1 : 0,
                                                child: AnimatedContainer(
                                                  duration: _kDuration,
                                                  curve: _kCurve,
                                                  height: isActive
                                                      ? activeFooterHeight -
                                                          activeDiscontHeight
                                                      : shadowFooterHeight -
                                                          shadowDiscontHeight,
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  padding: EdgeInsets.only(
                                                      bottom:
                                                          priceBottomPadding),
                                                  child: Text(
                                                    '${paymentStep.price} \$',
                                                    style: TextStyle(
                                                      fontSize: kFontSize,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                AnimatedOpacity(
                                  duration: _kDuration,
                                  curve: _kCurve,
                                  opacity: isActive ? 0 : borderOpacity,
                                  child: Container(color: Colors.grey),
                                ),
                                Tooltip(
                                  message: _activeIndex == index
                                      ? 'Получить'
                                      : 'Выбрать',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        if (_activeIndex == index) {
                                          _handlePayment();
                                          return;
                                        }
                                        setState(
                                          () {
                                            _activeIndex = index;
                                            // иначе надо переделать позиционирование
                                            assert(kPaymentSteps.length == 4);
                                            _controller.animateTo(
                                              _activeIndex <
                                                      kPaymentSteps.length / 2
                                                  ? 0
                                                  : _controller
                                                      .position.maxScrollExtent,
                                              duration: _kDuration,
                                              curve: Curves.linear,
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(width: separatorWidth);
                    },
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          Container(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _PaymentButton(onTap: _handlePayment),
                OutlineButton(
                  child: Text('НЕТ, СПАСИБО'),
                  onLongPress: () {}, // чтобы сократить время для splashColor
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  textColor: Colors.black.withOpacity(0.8),
                ),
              ],
            ),
          ),
          FlatButton(
            child: Text(
              'Не получается оплатить',
              style: TextStyle(
                fontSize: kFontSize,
                fontWeight: FontWeight.normal,
                color: Colors.red,
                decoration: TextDecoration.underline,
              ),
            ),
            onLongPress: () {}, // чтобы сократить время для splashColor
            onPressed: () {
              launchFeedback(context, subject: 'Не получается оплатить');
            },
            textColor: Colors.red,
          ),
        ],
      ),
    );
    return Scaffold(
      body: buildScrollBody(child),
    );
  }

  void _handlePayment() {
    print(_activeIndex);
    // TODO: подключить оплату
    // huawei_iap
    // in_app_purchase
    // purchases-flutter
  }
}

class _PaymentButton extends StatefulWidget {
  _PaymentButton({this.onTap});

  final Function onTap;

  @override
  _PaymentButtonState createState() => _PaymentButtonState();
}

class _PaymentButtonState extends State<_PaymentButton>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInCubic,
    );
    _animation = Tween<double>(begin: 1, end: 1.2).animate(curvedAnimation);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ScaleTransition(
          scale: _animation,
          child: FlatButton(
            child: Container(),
            onLongPress: () {}, // чтобы сократить время для splashColor
            onPressed: widget.onTap,
            color: Colors.green,
            textColor: Colors.white,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              alignment: Alignment.center,
              child: Container(
                child: Text(
                  'ДА, ПОЛУЧИТЬ',
                  style: TextStyle(
                    fontSize: kButtonFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
