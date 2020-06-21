import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:minsk8/import.dart';

var hasMore = true;

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        final imageModel0 = ImageModel(
            height: 1755,
            width: 1260,
            url:
                "https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9");
        final imageModel1 = ImageModel(
          height: 4032,
          width: 3024,
          url: "https://images.unsplash.com/photo-1517423568366-8b83523034fd",
        );
        final images = [imageModel0.toJson(), imageModel1.toJson()];
        final location = {
          'type': 'Point',
          'coordinates': [53.92, 27.58]
        };
        final GraphQLClient client = GraphQLProvider.of(context).value;
        final options = MutationOptions(
          documentNode: Mutations.insertItem,
          variables: {
            'images': images,
            'text': '4321',
            'urgent': EnumToString.parse(UrgentStatus.urgent),
            'kind': EnumToString.parse(KindId.other),
            'location': location,
            'address': 'Ждановичи, Парковая',
          },
          fetchPolicy: FetchPolicy.noCache,
        );
        client.mutate(options).then((QueryResult result) {
          if (result.hasException) {
            throw result.exception;
          }
          final item = ItemModel.fromJson(result.data['insert_item_one']);
          print(item.id);
        }).catchError((error) {
          print(error);
        });
      }),
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: MainDrawer('/home'),
      body: Center(
        child: Query(
          options: QueryOptions(
            documentNode: Queries.getItems,
            variables: {
              'next_created_at': '2100-01-01',
            },
          ),
          builder: withGenericHandling(
            (
              QueryResult result, {
              Refetch refetch,
              FetchMore fetchMore,
            }) {
              // if (result.loading) {
              //   return Center(
              //     child: buildProgressIndicator(context),
              //   );
              // }
              // return ListView.separated(
              //   padding: const EdgeInsets.all(8),
              //   itemCount: result.data['items'].length,
              //   itemBuilder: (BuildContext context, int index) {
              //     final item = ItemModel.fromJson(result.data['items'][index]);
              //     return Container(
              //       child: Center(child: Text('${item.id}\n${item.text}')),
              //     );
              //   },
              //   separatorBuilder: (BuildContext context, int index) =>
              //       const Divider(),
              // );

              final minusOne = hasMore ? 1 : 0;
              final length = result.data['items'].length;
              return Container(
                child: ListView(
                  children: [
                    ...List.generate(
                        length > 0 ? length - minusOne : 0,
                        (index) => _buildItem(result.loading,
                            ItemModel.fromJson(result.data['items'][index]))),
                    // for (var index = 0;
                    //     index < length - minusOne;
                    //     index++)
                    //   _buildItem(result.loading,
                    //       ItemModel.fromJson(result.data['items'][index])),
                    if (result.loading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildProgressIndicator(context),
                        ],
                      ),
                    if (hasMore)
                      RaisedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Load More'),
                          ],
                        ),
                        onPressed: () {
                          // final client = GraphQLProvider.of(context)?.value;

                          // return GraphQLConsumer(
                          //     builder: (GraphQLClient client) {
                          //       // do something with the client

                          //       return Container(
                          //         child: Text('Hello world'),
                          //       );
                          //     },

                          final index = result.data['items'].length - 1;
                          final nextItem =
                              ItemModel.fromJson(result.data['items'][index]);
                          fetchMore(
                            FetchMoreOptions(
                              variables: {
                                'next_created_at':
                                    nextItem.createdAt.toUtc().toIso8601String()
                              },
                              updateQuery: (
                                previousResultData,
                                fetchMoreResultData,
                              ) {
                                final previousItems =
                                    previousResultData['items'] as List;
                                previousItems.removeLast();
                                final fetchMoreItems =
                                    fetchMoreResultData['items'] as List;
                                hasMore =
                                    fetchMoreItems.length == kGraphQLItemsLimit;
                                return {
                                  'items': [
                                    ...previousItems,
                                    ...fetchMoreItems,
                                  ]
                                };
                              },
                            ),
                          );
                        },
                      )
                  ],
                ),
              );

              // return Text('Hello world!');
              // (result.loading)
              //     ? Center(
              //         child: buildProgressIndicator(context),
              //       )
              //     : RaisedButton(
              //         onPressed: () {
              //           fetchMore(
              //             FetchMoreOptions(
              //               variables: {'page': nextPage},
              //               updateQuery: (existing, newReviews) => ({
              //                 'reviews': {
              //                   'page': newReviews['reviews']['page'],
              //                   'reviews': [
              //                     ...existing['reviews']['reviews'],
              //                     ...newReviews['reviews']['reviews']
              //                   ],
              //                 }
              //               }),
              //             ),
              //           );
              //         },
              //         child: Text('LOAD PAGE $nextPage'),
              //       ),
            },
          ),
        ),
      ),
    );
  }

  _buildItem(bool isLoading, ItemModel item) {
    // print('$isLoading - ${item.id}');
    return ListTile(
      title: Text(item.text),
      subtitle: Text(item.id),
    );
  }
}
