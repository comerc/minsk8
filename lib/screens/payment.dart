import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() {
    return _PaymentScreenState();
  }
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
// class PaymentScreen extends StatelessWidget {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Получить Карму'),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        color: Colors.white,
        child: Column(
          children: <Widget>[
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
