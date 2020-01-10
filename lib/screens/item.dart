import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:minsk8/import.dart';

// TODO: Geolocator().distanceBetween()
// double distanceInMeters = await Geolocator().distanceBetween(52.2165157, 6.9437819, 52.3546274, 4.8285838);

// class ItemScreen extends StatefulWidget {
//   @override
//   _ItemScreenState createState() {
//     return _ItemScreenState();
//   }
// }

// class _ItemScreenState extends State<ItemScreen> {

class ItemScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context).settings.arguments as ItemRouteArguments;
    final item = arguments.item;
    return Scaffold(
      appBar: AppBar(
        title: Text('Завершено'),
        centerTitle: true,
        backgroundColor: Colors.pink.withOpacity(0.8),
        actions: [
          IconButton(
            icon: Icon(Icons.account_box),
            onPressed: () {},
          )
        ],
      ),
      body: SlidingUpPanel(
        body: Column(
          children: [
            SizedBox(
              height: 16.0,
            ),
            CarouselSlider(
              height: 400.0,
              autoPlay: item.images.length > 1,
              enableInfiniteScroll: item.images.length > 1,
              pauseAutoPlayOnTouch: Duration(seconds: 10),
              enlargeCenterPage: true,
              items: List.generate(item.images.length, (index) {
                final image = item.images[index];
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      child: ItemImage(
                        image.getDummyUrl(item.id),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                );
              }),
            ),
            Center(
              child: Text(item.text),
            ),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.0),
          topRight: Radius.circular(18.0),
        ),
        // parallaxEnabled: true,
        // parallaxOffset: .8,
        maxHeight: 800,
        panel: Column(
          children: [
            SizedBox(
              height: 12.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
              ],
            ),
            SizedBox(
              height: 18.0,
            ),
            Center(
              child: Text("This is the sliding Widget"),
            ),
            SizedBox(
              height: 500.0,
            ),
            Center(
              child: Text("This is the sliding Widget"),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemRouteArguments {
  final ItemModel item;

  ItemRouteArguments(this.item);
}
