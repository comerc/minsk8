// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:extended_image/extended_image.dart';
import 'package:intl/intl.dart';

bool get isInDebugMode {
  // Assume you're in production mode.
  bool inDebugMode = false;

  // Assert expressions are only evaluated during development. They are ignored
  // in production. Therefore, this code only sets `inDebugMode` to true
  // in a development environment.
  assert(inDebugMode = true);

  // or
  // inDebugMode = kReleaseMode != null;

  return inDebugMode;
}

/// boilerplate `result.loading` and `result.hasException` handling
///
/// ```dart
/// if (result.hasException) {
///   return Text(result.exception.toString());
/// }
/// if (result.loading) {
///   return const Center(
///     child: CircularProgressIndicator(),
///   );
/// }
/// ```
QueryBuilder withGenericHandling(QueryBuilder builder) {
  return (result, {fetchMore, refetch}) {
    if (result.hasException) {
      return Text(result.exception.toString());
    }
    if (result.loading && result.data == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (result.data == null && !result.hasException) {
      return Text(
          'Both data and errors are null, this is a known bug after refactoring');
    }
    return builder(result, fetchMore: fetchMore, refetch: refetch);
  };
}

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

Widget loadStateChanged(ExtendedImageState state) {
  if (state.extendedImageLoadState != LoadState.loading) return null;
  return Builder(builder: (BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.grey.withOpacity(0.3),
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
      ),
    );
  });
}

Future<String> loadAsset(BuildContext context, String filename) async {
  return await DefaultAssetBundle.of(context).loadString('assets/$filename');
}

String getOperationExceptionToString(OperationException operationException) {
  var text = operationException.toString();
  if (operationException.clientException != null) {
    var clientException = operationException.clientException;
    if (clientException is CacheMissException) {
      final exception = clientException;
      text = '${exception.message}';
    } else if (clientException is NormalizationException) {
      final exception = clientException;
      text =
          '${exception.message} ${exception.overflowError} ${exception.value}';
    } else if (clientException is ClientException) {
      final exception = clientException;
      text = '${exception.message}';
    }
  }
  return text;
}

String gold(int howMany) => Intl.plural(
      howMany,
      name: 'gold',
      args: [howMany],
      one: '$howMany золотой',
      other: '$howMany золотых',
      locale: 'ru',
    );
