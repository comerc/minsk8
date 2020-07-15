import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong/latlong.dart';
import 'package:minsk8/import.dart';

class StartMapScreen extends StatefulWidget {
  @override
  StartMapScreenState createState() {
    return StartMapScreenState();
  }
}

class StartMapScreenState extends State<StartMapScreen> {
  bool _isInfo = true;

  @override
  Widget build(context) {
    Widget body = MapWidget(
      center: LatLng(
        kDefaultMapCenter[0],
        kDefaultMapCenter[1],
      ),
      zoom: 8,
      saveModes: [MapSaveMode.showcase, MapSaveMode.myItem],
    );
    if (_isInfo) {
      body = buildMapInfo(
        'Укажите желаемое местоположение, чтобы смотреть лоты поблизости',
        child: body,
        onClose: () {
          setState(() {
            _isInfo = false;
          });
        },
      );
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: PlacesAppBar(),
        body: body,
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final result = await showModalBottomSheet(
      context: context,
      builder: (context) => buildModalBottomSheet(
        context,
        description: 'Вы очень близки к тому,\nчтобы начать пользоваться.',
      ),
    );
    // if enableDrag, result may be null
    if (result ?? false) {
      SystemNavigator.pop();
    }
    return false;
  }
}
