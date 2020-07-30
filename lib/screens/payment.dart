import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

const Duration _kDuration = Duration(milliseconds: 200);

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

  @override
  void initState() {
    super.initState();
    _activeIndex = 1;
  }

  final _steps = {
    '1': 'd1',
    '2': 'd2',
    '3': 'd3',
    '4': 'd4',
  }.entries.toList();

  var _change = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final listViewPadding = 16.0;
    final separatorSize = 4.0;

    final commonSize =
        (size.width - listViewPadding * 2 - separatorSize * 2) / 3;
    final activeSize = commonSize * 1.15;
    final shadowSize = (commonSize * 3 - activeSize) / 2;

    return Scaffold(
      appBar: AppBar(
        title: Text('Получить Карму'),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        color: Colors.white,
        child: Column(
          children: <Widget>[
            SizedBox(height: 16),
            Container(
              height: activeSize / kGoldenRatio,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: listViewPadding),
                scrollDirection: Axis.horizontal,
                itemCount: _steps.length,
                itemBuilder: (BuildContext context, int index) {
                  final isActive = index == _activeIndex;
                  return AnimatedContainer(
                    duration: _kDuration,
                    alignment: Alignment.center,
                    width: isActive ? activeSize : shadowSize,
                    child: GestureDetector(
                      onTap: () {
                        setState(
                          () {
                            _activeIndex = index;
                            _change = !_change;
                          },
                        );
                      },
                      child: AnimatedContainer(
                        duration: _kDuration,
                        height: isActive
                            ? activeSize / kGoldenRatio
                            : shadowSize / kGoldenRatio,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            Flexible(
                              child: Center(
                                  child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    '${kPaymentSteps[index]}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black.withOpacity(0.8),
                                    ),
                                  ),
                                  Text(
                                    'Кармы',
                                    style: TextStyle(
                                      fontSize: kFontSize,
                                    ),
                                  ),
                                ],
                              )),
                            ),
                            Flexible(
                              child: Container(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(width: separatorSize);
                },
              ),
            ),
            SizedBox(height: 16),

            // Expanded(
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: <Widget>[
            //       // _Logo(),
            //       // _Title(),
            //       // _Menu(),
            //     ],
            //   ),
            // ),
            // FlatButton(
            //   child: Text(
            //     'КАК ЭТО РАБОТАЕТ',
            //     style: TextStyle(
            //       fontSize: kMyFontSize,
            //       color: Colors.black.withOpacity(0.6),
            //     ),
            //   ),
            //   onLongPress: () {}, // чтобы сократить время для splashColor
            //   onPressed: () {
            //     Navigator.of(context).pushNamed('/how_it_works');
            //   },
            // ),
            // OutlineButton(
            //   child: Text('Не получается оплатить'),
            //   onLongPress: () {}, // чтобы сократить время для splashColor
            //   onPressed: () {
            //     launchFeedback(context, subject: 'Сообщить о проблеме');
            //   },
            //   textColor: Colors.green,
            // ),
            Container(
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _PaymentButton(),
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
                Navigator.of(context).pushNamed('/how_it_works');
              },
              textColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentButton extends StatefulWidget {
  _PaymentButton({this.child});

  final Widget child;

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
            onPressed: () {
              // TODO: подключить оплату
              // huawei_iap
              // in_app_purchase
              // purchases-flutter
            },
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
              // color: Colors.red,
              child: Text(
                'ПОЛУЧИТЬ',
                style: TextStyle(
                  // fontSize: kMyFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// class _Step extends StatefulWidget {
//   _Step({this.alignment, this.reverse});

//   final AlignmentGeometry alignment;
//   final bool reverse;

//   @override
//   _StepState createState() => _StepState();
// }

// class _StepState extends State<_Step> with SingleTickerProviderStateMixin {
//   AnimationController _controller;
//   Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 2),
//     );
//     final curvedAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInCubic,
//     );
//     // _animation = Tween<double>(begin: 1, end: 1.2).animate(curvedAnimation);
//     if (widget.reverse) {
//       _controller.reverse();
//     } else {
//       _controller.forward();
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer();

//   }
// }
