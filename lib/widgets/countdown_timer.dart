import 'dart:async';
import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class CountdownTimer extends StatefulWidget {
  CountdownTimer({
    this.endTime,
    this.builder,
    this.onClose,
  });

  final int endTime; // millisecondsSinceEpoch
  final Widget Function(BuildContext context, int seconds) builder;
  final Function onClose;

  @override
  _CountDownState createState() => _CountDownState();

  static int getSeconds(int endTime) {
    return Duration(
      milliseconds: (endTime - DateTime.now().millisecondsSinceEpoch),
    ).inSeconds;
  }
}

class _CountDownState extends State<CountdownTimer> {
  int _seconds;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    if (widget.endTime == null) return;
    _seconds = CountdownTimer.getSeconds(widget.endTime);
    if (_seconds < 1) return;
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (_seconds == 1 && widget.onClose != null) {
        widget.onClose();
        disposeTimer();
        return;
      }
      setState(
        () {
          if (_seconds < 1) {
            disposeTimer();
          } else {
            _seconds--;
          }
        },
      );
    });
  }

  @override
  void dispose() {
    disposeTimer();
    super.dispose();
  }

  disposeTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Widget build(BuildContext context) {
    return widget.builder(context, _seconds);
  }
}

String formatDDHHMMSS(int seconds) {
  int days, hours, minutes = 0;
  if (seconds >= 86400) {
    days = (seconds / 86400).floor();
    seconds -= days * 86400;
  } else {
    // if days = -1 => Don't show;
    days = -1;
  }
  if (seconds >= 3600) {
    hours = (seconds / 3600).floor();
    seconds -= hours * 3600;
  } else {
    // hours = days == -1 ? -1 : 0;
    hours = 0;
  }
  if (seconds >= 60) {
    minutes = (seconds / 60).floor();
    seconds -= minutes * 60;
  } else {
    // minutes = hours == -1 ? -1 : 0;
    minutes = 0;
  }
  String sDD = (days).toString().padLeft(2, '0');
  String sHH = (hours).toString().padLeft(2, '0');
  String sMM = (minutes).toString().padLeft(2, '0');
  String sSS = (seconds).toString().padLeft(2, '0');
  if (days == -1) {
    return "$sHH:$sMM:$sSS";
  }
  return "$sDD:$sHH:$sMM:$sSS";
}
