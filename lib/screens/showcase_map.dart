import 'package:minsk8/import.dart';

class ShowcaseMapScreen extends StatelessWidget {
  @override
  Widget build(context) {
    Widget body = MapWidget(
      center: LatLng(
        appState['ShowcaseMap.center'][0] as double,
        appState['ShowcaseMap.center'][1] as double,
      ),
      zoom: appState['ShowcaseMap.zoom'] as double,
      saveModes: <MapSaveMode>[MapSaveMode.showcase],
    );
    return Scaffold(
      appBar: PlacesAppBar(),
      body: SafeArea(child: body),
      resizeToAvoidBottomInset: false,
    );
  }
}
