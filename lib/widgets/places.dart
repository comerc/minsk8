import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:http_client_helper/http_client_helper.dart';

class Places extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
      textFieldConfiguration: TextFieldConfiguration(
        decoration: InputDecoration(
          labelText: 'Адрес',
          border: OutlineInputBorder(),
        ),
      ),
      suggestionsCallback: (pattern) async {
        final s = pattern?.trim();
        if (s == null || s == '' || s.length < 4) return null;
        final data = await _request(s);
        return data['hits'] as List;
      },
      itemBuilder: (context, suggestion) {
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
      onSuggestionSelected: (suggestion) {
        print(suggestion['_geoloc']);
      },
      noItemsFoundBuilder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Ничего не найдено',
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
        );
      },
      errorBuilder: (BuildContext context, Object error) {
        return Container(
          padding: EdgeInsets.all(8.0),
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
