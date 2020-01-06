import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:minsk8/import.dart';

var hasMore = true;

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: MainDrawer('/home'),
      body: Center(
        child: Query(
          options: QueryOptions(
            documentNode: Queries.getItems,
            variables: {
              'next_created_at': '1970-01-01',
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
              //     child: CircularProgressIndicator(),
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
              return Container(
                child: ListView(
                  children: [
                    for (var index = 0;
                        index < result.data['items'].length - minusOne;
                        index++)
                      _buildItem(result.loading,
                          ItemModel.fromJson(result.data['items'][index])),
                    if (result.loading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                        ],
                      ),
                    if (hasMore)
                      RaisedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Load More"),
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
              //         child: CircularProgressIndicator(),
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
