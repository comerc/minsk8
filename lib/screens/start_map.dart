import 'package:minsk8/import.dart';

class StartMapScreen extends StatefulWidget {
  @override
  _StartMapScreenState createState() {
    return _StartMapScreenState();
  }
}

class _StartMapScreenState extends State<StartMapScreen> {
  bool _isInfo = true;

  @override
  Widget build(context) {
    Widget body = MapWidget(
      center: LatLng(
        kDefaultMapCenter[0],
        kDefaultMapCenter[1],
      ),
      zoom: 8,
      saveModes: <MapSaveMode>[MapSaveMode.showcase, MapSaveMode.myUnit],
    );
    if (_isInfo) {
      body = MapInfo(
        text: 'Укажите желаемое местоположение, чтобы смотреть лоты поблизости',
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
        body: SafeArea(child: body),
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => buildModalBottomSheet(
        context,
        description: 'Вы очень близки к тому,\nчтобы начать пользоваться.',
      ),
    );
    // if enableDrag, result may be null
    if (result ?? false) {
      // ignore: unawaited_futures
      SystemNavigator.pop();
    }
    return false;
  }
}
