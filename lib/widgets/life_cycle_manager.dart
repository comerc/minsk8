import 'package:flutter/material.dart';

class LifeCycleManager extends StatefulWidget {
  LifeCycleManager({Key key, this.child, this.onInitState, this.onDispose})
      : super(key: key);

  final Widget child;
  final VoidCallback onInitState;
  final VoidCallback onDispose;

  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  // List<StoppableService> services = [
  //   locator<LocationService>(),
  // ];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    widget.onInitState();
  }

  @override
  void dispose() {
    widget.onDispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // print('lyfecycle state = $state');
    // services.forEach((service) {
    //   if (state == AppLifecycleState.resumed) {
    //     service.start();
    //   } else {
    //     service.stop();
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

abstract class StoppableService {
  bool _serviceStoped = false;
  bool get serviceStopped => _serviceStoped;

  @mustCallSuper
  void stop() {
    _serviceStoped = true;
  }

  @mustCallSuper
  void start() {
    _serviceStoped = false;
  }
}

class LocationService extends StoppableService {
  @override
  void start() {
    super.start();
    // start subscription again
  }

  @override
  void stop() {
    super.stop();
    // cancel stream subscription
  }
}
