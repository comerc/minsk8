import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:minsk8/import.dart';

class ShowcaseScreen extends StatefulWidget {
  @override
  _ShowcaseScreenState createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  TuChongRepository listSourceRepository;
  @override
  void initState() {
    listSourceRepository = new TuChongRepository();
    super.initState();
  }

  @override
  void dispose() {
    listSourceRepository?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text("ListViewDemo"),
          ),
          Expanded(
            child: LoadingMoreList(
              ListConfig<TuChongItem>(
                itemBuilder: buildItem,
                sourceList: listSourceRepository,
//                    showGlowLeading: false,
//                    showGlowTrailing: false,
                padding: EdgeInsets.all(0.0),
                collectGarbage: (List<int> indexes) {
                  ///collectGarbage
                  indexes.forEach((index) {
                    final item = listSourceRepository[index];
                    if (item.hasImage) {
                      final provider = ExtendedNetworkImageProvider(
                        item.imageUrl,
                      );
                      provider.evict();
                    }
                  });
                },
                viewportBuilder: (int firstIndex, int lastIndex) {
                  print("viewport : [$firstIndex,$lastIndex]");
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
