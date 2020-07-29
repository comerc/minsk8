import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:minsk8/import.dart';

var _hasMore = true;

class LoadDataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Load Data'),
      ),
      drawer: MainDrawer('/_load_data'),
      body: Center(
        child: Query(
          options: QueryOptions(
            documentNode: Queries.getUnits,
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
              //   itemCount: result.data['units'].length,
              //   itemBuilder: (BuildContext context, int index) {
              //     final unit = UnitModel.fromJson(result.data['units'][index]);
              //     return Container(
              //       child: Center(child: Text('${unit.id}\n${unit.text}')),
              //     );
              //   },
              //   separatorBuilder: (BuildContext context, int index) =>
              //       const Divider(),
              // );

              final minusOne = _hasMore ? 1 : 0;
              final length = result.data['units'].length;
              return Container(
                child: ListView(
                  children: <Widget>[
                    ...List.generate(
                        length > 0 ? length - minusOne : 0,
                        (index) => _buildUnit(result.loading,
                            UnitModel.fromJson(result.data['units'][index]))),
                    // for (var index = 0;
                    //     index < length - minusOne;
                    //     index++)
                    //   _buildUnit(result.loading,
                    //       UnitModel.fromJson(result.data['units'][index])),
                    if (result.loading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          buildProgressIndicator(context),
                        ],
                      ),
                    if (_hasMore)
                      RaisedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
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

                          final index = result.data['units'].length - 1;
                          final nextUnit =
                              UnitModel.fromJson(result.data['units'][index]);
                          fetchMore(
                            FetchMoreOptions(
                              variables: {
                                'next_created_at':
                                    nextUnit.createdAt.toUtc().toIso8601String()
                              },
                              updateQuery: (
                                previousResultData,
                                fetchMoreResultData,
                              ) {
                                final previousUnits =
                                    previousResultData['units'] as List;
                                previousUnits.removeLast();
                                final fetchMoreUnits =
                                    fetchMoreResultData['units'] as List;
                                _hasMore =
                                    fetchMoreUnits.length == kGraphQLUnitsLimit;
                                return {
                                  'units': [
                                    ...previousUnits,
                                    ...fetchMoreUnits,
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

  Widget _buildUnit(bool isLoading, UnitModel unit) {
    // print('$isLoading - ${unit.id}');
    return ListTile(
      title: Text(unit.text),
      subtitle: Text(unit.id),
    );
  }
}
