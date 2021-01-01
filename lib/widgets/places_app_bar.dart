import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http_client_helper/http_client_helper.dart';
import 'package:latlong/latlong.dart';
import 'package:recursive_regex/recursive_regex.dart';
import 'package:minsk8/import.dart';

class PlacesAppBar extends StatefulWidget implements PreferredSizeWidget {
  PlacesAppBar() : preferredSize = Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize;

  @override
  _PlacesAppBarState createState() {
    return _PlacesAppBarState();
  }
}

class _PlacesAppBarState extends State<PlacesAppBar> {
  bool _isPlaces = false;
  final _formFieldKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    return _isPlaces
        ? ExtendedAppBar(
            isForeground: true,
            leading: IconButton(
              tooltip: 'Назад',
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black.withOpacity(0.8),
              ),
              onPressed: () {
                setState(() {
                  _isPlaces = false;
                });
              },
            ),
            title: _Places(
                formFieldKey: _formFieldKey,
                onSuggestionSelected: _onSuggestionSelected),
            actions: <Widget>[
              IconButton(
                tooltip: 'Отменить',
                icon: Icon(
                  Icons.close,
                  color: Colors.black.withOpacity(0.8),
                ),
                onPressed: () {
                  _formFieldKey.currentState.reset();
                },
              )
            ],
          )
        : ExtendedAppBar(
            title: Text('Местоположение'),
            actions: <Widget>[
              IconButton(
                tooltip: 'Искать',
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _isPlaces = true;
                  });
                },
              ),
            ],
          );
  }

  void _onSuggestionSelected(suggestion) {
    MapWidget.globalKey.currentState.animatedMapMove(
      destCenter: LatLng(
        suggestion['_geoloc']['lat'] as double,
        suggestion['_geoloc']['lng'] as double,
      ),
      destZoom: 13,
    );
    setState(() {
      _isPlaces = false;
    });
  }
}

// TODO: типизировать suggestion через json_serializable
// TODO: [MVP] добавить копирайт algolia и osm

class _Places extends StatefulWidget {
  _Places({this.formFieldKey, this.onSuggestionSelected});

  final Key formFieldKey;
  // TODO: SuggestionSelectionCallback<suggestionModel>
  final SuggestionSelectionCallback onSuggestionSelected;

  @override
  _PlacesState createState() {
    return _PlacesState();
  }
}

class _PlacesState extends State<_Places> {
  bool _isLoading = false;
  final TextEditingController _typeAheadController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField<Map<String, dynamic>>(
      key: widget.formFieldKey,
      textFieldConfiguration: TextFieldConfiguration(
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Улица...',
          contentPadding: EdgeInsets.only(left: 8, right: 8),
          border: InputBorder.none,
        ),
        controller: _typeAheadController,
      ),
      suggestionsCallback: (String pattern) async {
        final s = pattern?.trim();
        if (s == null || s == '' || s.length < 4) return null;
        _isLoading = true;
        try {
          await Future.delayed(Duration(seconds: 1));
          final data = await _request(s);
          final result = data['hits'] as List;
          return result.cast<Map<String, dynamic>>();
        } finally {
          _isLoading = false;
        }
      },
      loadingBuilder: (BuildContext context) {
        // TODO: https://github.com/AbdulRahmanAlHamali/flutter_typeahead/issues/208
        // устраняет паразитное мигание при передаче фокуса
        if (!_isLoading) return null;
        return Align(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: ExtendedProgressIndicator(),
          ),
        );
      },
      itemBuilder: (BuildContext context, Map<String, dynamic> suggestion) {
        var title = '';
        final subtitles = <String>[];
        try {
          final source = suggestion['_highlightResult'];
          title = source['locale_names'][0]['value'] as String;
          if (source['city'] != null) {
            subtitles.add(source['city'][0]['value'] as String);
          }
          if (source['administrative'] != null) {
            subtitles.add(source['administrative'][0]['value'] as String);
          }
          subtitles.add(source['country']['value'] as String);
          // final source = suggestion;
          // title = source['locale_names'][0];
          // if (source['city'] != null) subtitles.add(source['city'][0]);
          // if (source['administrative'] != null)
          //   subtitles.add(source['administrative'][0]);
          // subtitles.add(source['country']['value']);
        } catch (error) {
          out(error);
        }
        return GestureDetector(
          onLongPress: () {}, // чтобы сократить время для splashColor
          child: ListTile(
            leading: Container(
              padding:
                  EdgeInsets.only(left: kMinLeadingWidth - kBigButtonIconSize),
              child: Icon(Icons.location_on, size: kBigButtonIconSize),
            ),
            // leading: Icon(Icons.location_on, size: kBigButtonIconSize),
            title: _Highlight(title),
            subtitle: _Highlight(subtitles.join(', ')),
          ),
        );
      },
      onSuggestionSelected: widget.onSuggestionSelected,
      noItemsFoundBuilder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            'Ничего не найдено',
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
        );
      },
      errorBuilder: (BuildContext context, Object error) {
        return Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            '$error',
            style: TextStyle(color: Theme.of(context).errorColor),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _request(String pattern) async {
    final cancellationToken = CancellationToken();
    final url = 'https://places-dsn.algolia.net/1/places/query';
    // TODO: вынести в .env
    final headers = {
      'X-Algolia-Application-Id': 'plD5UEJUGJYT',
      'X-Algolia-API-Key': '9b9648b0686c2260c39538a17342a285',
    };
    // TODO: locale autodetect?
    final data = {
      'query': pattern,
      'language': 'ru',
      'countries': 'ru,by',
      'type': 'address',
      'hitsPerPage': 10,
      // 'aroundLatLng': '53.90234,27.561901',
      'aroundLatLngViaIP': false,
      // 'aroundRadius': 4000
    };
    try {
      final response = await HttpClientHelper.post(url,
          body: jsonEncode(data),
          headers: headers,
          cancelToken: cancellationToken,
          // timeRetry: Duration(milliseconds: 100),
          // retries: 3,
          timeLimit: Duration(seconds: 5));
      final result = jsonDecode(response.body) as Map<String, dynamic>;
      return result;
    } on TimeoutException catch (_) {
      out('TimeoutException');
      // } on OperationCanceledError catch (_) {
      //   out('cancel');
    } catch (error) {
      out(error);
    }
    return null;
  }

  // альтернатива https://github.com/flutter/flutter_markdown/issues/237
  // Widget _highlight(String data) {
  //   return MarkdownBody(
  //       data: html2md.convert(data, styleOptions: {'emDelimiter': '*'}));
  // }
}

class _Highlight extends StatelessWidget {
  _Highlight(this.data);

  final String data;

  @override
  Widget build(BuildContext context) {
    final regex = RecursiveRegex(
      startDelimiter: RegExp(r'<em>'),
      endDelimiter: RegExp(r'</em>'),
      global: true,
      captureGroupName: 'em',
    );
    final matches = regex.allMatches(data) ?? [];
    final out = <InlineSpan>[];
    var start = 0;
    for (final match in matches) {
      if (match.start > 0) {
        out.add(TextSpan(text: data.substring(start, match.start)));
      }
      start = match.end;
      out.add(TextSpan(
        text: match.namedGroup('em'),
        style: DefaultTextStyle.of(context).style.copyWith(
              // fontWeight: FontWeight.w600,
              // color: Colors.black.withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
      ));
    }
    if (start < data.length) {
      out.add(TextSpan(text: data.substring(start, data.length)));
    }
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: out.toList(),
      ),
    );
  }
}
