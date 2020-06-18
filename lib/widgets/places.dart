import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:http_client_helper/http_client_helper.dart';

// TODO: типизировать suggestion через json_serializable
// TODO: добавить копирайт algolia и osm

class Places extends StatefulWidget {
  Places({this.formFieldKey, this.onSuggestionSelected});

  final Key formFieldKey;
  // TODO: SuggestionSelectionCallback<suggestionModel>
  final SuggestionSelectionCallback onSuggestionSelected;

  @override
  _PlacesState createState() {
    return _PlacesState();
  }
}

class _PlacesState extends State<Places> {
  bool _isLoading = false;
  final TextEditingController _typeAheadController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField(
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
          await Future.delayed(const Duration(seconds: 1));
          final data = await _request(s);
          return data['hits'] as List;
        } finally {
          _isLoading = false;
        }
      },
      loadingBuilder: (BuildContext context) {
        // устраняет паразитное мигание при передачи фокуса
        if (!_isLoading) return null;
        return Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: CircularProgressIndicator(),
          ),
        );
      },
      itemBuilder: (BuildContext context, suggestion) {
        String title = '';
        final subtitles = <String>[];
        try {
          title = html2md.convert(
              suggestion['_highlightResult']['locale_names'][0]['value']);
          if (suggestion['_highlightResult']['city'] != null)
            subtitles.add(suggestion['_highlightResult']['city'][0]['value']);
          if (suggestion['_highlightResult']['administrative'] != null)
            subtitles.add(
                suggestion['_highlightResult']['administrative'][0]['value']);
          subtitles.add(suggestion['_highlightResult']['country']['value']);
        } catch (e) {
          debugPrint('$e');
        }
        return ListTile(
          leading: Icon(Icons.location_on),
          title: MarkdownBody(data: title),
          subtitle: Text(subtitles.join(', ')),
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

  Future<Map> _request(String pattern) async {
    final cancellationToken = CancellationToken();
    String msg = '';
    final url = 'https://places-dsn.algolia.net/1/places/query';
    // TODO: вынести в .env
    final headers = {
      'X-Algolia-Application-Id': 'plD5UEJUGJYT',
      'X-Algolia-API-Key': '9b9648b0686c2260c39538a17342a285',
    };
    final data = {
      "query": pattern,
      "language": "ru",
      "countries": "ru,by",
      "type": "address",
      "hitsPerPage": 10,
      // "aroundLatLng": "53.90234,27.561901",
      "aroundLatLngViaIP": false,
      // "aroundRadius": 4000
    };
    try {
      final response = await HttpClientHelper.post(url,
          body: jsonEncode(data),
          headers: headers,
          cancelToken: cancellationToken,
          // timeRetry: Duration(milliseconds: 100),
          // retries: 3,
          timeLimit: Duration(seconds: 5));
      final result = jsonDecode(response.body);
      return result;
    } on TimeoutException catch (_) {
      msg = 'TimeoutException';
    } on OperationCanceledError catch (_) {
      msg = 'cancel';
    } catch (e) {
      msg = '$e';
    }
    debugPrint(msg);
    return null;
  }
}
