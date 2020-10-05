import 'package:minsk8/import.dart';

// TODO: как сделать splash для элемента списка LedgerScreen и пункта меню UnitScreen?

class Avatar extends StatelessWidget {
  Avatar(this.url, {this.radius = 20, this.elevation = 0, this.child});

  final String url;
  final double radius;
  final double elevation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Material(
        elevation: elevation,
        type: MaterialType.circle,
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: Ink.image(
          fit: BoxFit.cover,
          image: ExtendedImage.network(
            url,
            loadStateChanged: loadStateChanged,
          ).image,
          child: child,
        ),
      ),
    );
  }
}
