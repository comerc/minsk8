import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:extended_image/extended_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:minsk8/import.dart';

// TODO: Geolocator().distanceBetween()
// double distanceInMeters = await Geolocator().distanceBetween(52.2165157, 6.9437819, 52.3546274, 4.8285838);

class ItemScreen extends StatefulWidget {
  @override
  _ItemScreenState createState() {
    return _ItemScreenState();
  }
}

class _ItemScreenState extends State<ItemScreen> {
  var _isCarouselSlider = true;
  var _isHero = true;
  // var _isZoomHero = false;
  // var _zoomTag = '';

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context).settings.arguments as ItemRouteArguments;
    final item = arguments.item;
    final tag = arguments.tag;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
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
              Stack(
                children: [
                  if (tag != null && _isHero)
                    Center(
                      child: SizedBox(
                        height: ItemCarouselSliderSettings.height,
                        width: MediaQuery.of(context).size.width *
                                ItemCarouselSliderSettings.viewportFraction -
                            ItemCarouselSliderSettings.margin * 2,
                        child: Hero(
                          tag: tag,
                          child: ExtendedImage.network(
                            item.images[0].getDummyUrl(item.id),
                            fit: BoxFit.cover,
                            enableLoadState: false,
                          ),
                          flightShuttleBuilder: (
                            BuildContext flightContext,
                            Animation<double> animation,
                            HeroFlightDirection flightDirection,
                            BuildContext fromHeroContext,
                            BuildContext toHeroContext,
                          ) {
                            animation.addListener(() {
                              if (animation.status ==
                                  AnimationStatus.completed) {
                                setState(() {
                                  _isHero = false;
                                });
                              }
                            });
                            final Hero hero =
                                flightDirection == HeroFlightDirection.pop
                                    ? fromHeroContext.widget
                                    : toHeroContext.widget;
                            return hero.child;
                          },
                        ),
                      ),
                    ),
                  if (_isCarouselSlider)
                    CarouselSlider(
                      height: 400.0,
                      autoPlay: item.images.length > 1,
                      enableInfiniteScroll: item.images.length > 1,
                      pauseAutoPlayOnTouch: Duration(seconds: 10),
                      enlargeCenterPage: true,
                      viewportFraction:
                          ItemCarouselSliderSettings.viewportFraction,
                      items: List.generate(item.images.length, (index) {
                        return Builder(
                          builder: (BuildContext context) {
                            return GestureDetector(
                              onTap: () {
                                // TODO: выключать autoPlay, пока zoom
                                Navigator.pushNamed(
                                  context,
                                  '/image_zoom',
                                  arguments: ImageZoomRouteArguments(item,
                                      tag: '$tag-$index', index: index),
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        ItemCarouselSliderSettings.margin),
                                child: ExtendedImage.network(
                                  item.images[index].getDummyUrl(item.id),
                                  fit: BoxFit.cover,
                                  loadStateChanged: loadStateChanged,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                ],
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
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    setState(() {
      _isHero = true;
      _isCarouselSlider = false;
    });
    return true;
  }
}

class ItemRouteArguments {
  final ItemModel item;
  final String tag;

  ItemRouteArguments(this.item, {this.tag});
}

class ItemCarouselSliderSettings {
  static const margin = 8.0;
  static const viewportFraction = 0.8;
  static const height = 400.0;
}
