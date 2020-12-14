import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:extended_image/extended_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minsk8/import.dart';

bool get isInDebugMode {
  // Assume you're in production mode.
  var inDebugMode = false;

  // Assert expressions are only evaluated during development. They are ignored
  // in production. Therefore, this code only sets `inDebugMode` to true
  // in a development environment.
  assert(inDebugMode = true);

  // or
  // inDebugMode = kReleaseMode != null;

  return inDebugMode;
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
      child: buildProgressIndicator(context),
    );
  });
}

// legacy code - graphql 3.1.0
// String getOperationExceptionToString(OperationException operationException) {
//   var text = operationException.toString();
//   if (operationException.clientException != null) {
//     final clientException = operationException.clientException;
//     if (clientException is CacheMissException) {
//       final exception = clientException;
//       text = exception.message;
//     } else if (clientException is NormalizationException) {
//       final exception = clientException;
//       text =
//           '${exception.message} ${exception.overflowError} ${exception.value}';
//     } else if (clientException is ClientException) {
//       final exception = clientException;
//       text = exception.message;
//     }
//   }
//   return text;
// }

// заменил Gold на Karma
// String getPluralCoin(int howMany) => Intl.plural(
//       howMany,
//       name: 'coin',
//       args: [howMany],
//       one: '$howMany Монета',
//       other: '$howMany Монеты',
//       many: '$howMany Монет',
//       zero: 'Нет Монет',
//       locale: 'ru',
//     ).replaceAll(' ', '\u00A0');

// String getPluralGold(int howMany) => Intl.plural(
//       howMany,
//       name: 'gold',
//       args: [howMany],
//       one: '$howMany Золотой',
//       other: '$howMany Золотых',
//       zero: 'Нет Золотых',
//       locale: 'ru',
//     ).replaceAll(' ', '\u00A0');

// String getPluralKarma(int howMany) => Intl.plural(
//       howMany,
//       name: 'karma',
//       args: [howMany],
//       one: '$howMany Карма',
//       other: '$howMany Кармы',
//       many: '$howMany Карм',
//       zero: 'Нет Кармы',
//       locale: 'ru',
//     ).replaceAll(' ', '\u00A0');

String getPluralKarma(int howMany) => '$howMany\u00A0Кармы';

class SizeInt {
  SizeInt(this.width, this.height);

  final int width;
  final int height;
}

String interpolate(String string, {Map<String, dynamic> params = const {}}) {
  var result = string;
  for (final entry in params.entries) {
    result = result.replaceAll('{{${entry.key}}}', '${entry.value}');
  }
  return result;
}

int getWantLimit(int balance) {
  return (balance >= kMaxWantBalance)
      ? kMaxWantLimit
      : balance + (kMaxWantLimit - kMaxWantBalance);
}

int getNearestStep(List<int> steps, int value) {
  return steps.firstWhere((int element) => element >= value,
      orElse: () => steps.last);
}

String getMemberId(BuildContext context) {
  // TODO: singleton
  final profile = Provider.of<ProfileModel>(context, listen: false);
  return profile.member.id;
}

void launchFeedback({
  String subject,
  String body = '',
}) async {
  final emailUri = Uri(
    scheme: 'mailto',
    path: kSupportEmail,
    queryParameters: {
      'subject': subject,
      'body': body,
    },
  );
  final emailUrl = emailUri.toString();
  if (await canLaunch(emailUrl)) {
    await launch(emailUrl);
    // TODO: реализовать сайт для webUrl
    // } else if (await canLaunch(webUrl)) {
    //   await launch(webUrl);
  } else {
    throw 'Could not launch $emailUrl';
  }
}

double getMagicHeight(double width) {
  return (width / 2) * kGoldenRatio;
}

// Map<String, dynamic> parseJwt(String token) {
//   final parts = token.split('.');
//   if (parts.length != 3) {
//     throw Exception('invalid token');
//   }
//   final payload = _decodeBase64(parts[1]);
//   final payloadMap = json.decode(payload);
//   if (payloadMap is! Map<String, dynamic>) {
//     throw Exception('invalid payload');
//   }
//   return payloadMap;
// }

// String _decodeBase64(String str) {
//   var output = str.replaceAll('-', '+').replaceAll('_', '/');
//   switch (output.length % 4) {
//     case 0:
//       break;
//     case 2:
//       output += '==';
//       break;
//     case 3:
//       output += '=';
//       break;
//     default:
//       throw Exception('Illegal base64url string!"');
//   }
//   return utf8.decode(base64Url.decode(output));
// }

// variant from auth0.com
Map<String, dynamic> parseIdToken(String idToken) {
  final parts = idToken.split(r'.');
  assert(parts.length == 3);
  return jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))))
      as Map<String, dynamic>;
}

// T tryCatch<T>(T Function() f) {
//   try {
//     return f?.call();
//   } catch (e, stack) {
//     out('$e');
//     out('$stack');
//     return null;
//   }
// }

// T asT<T>(dynamic value) {
//   if (value is T) {
//     return value;
//   }
//   if (value != null) {
//     final valueS = value.toString();
//     if (0 is T) {
//       return int.tryParse(valueS) as T;
//     } else if (0.0 is T) {
//       return double.tryParse(valueS) as T;
//     } else if ('' is T) {
//       return valueS as T;
//     } else if (false is T) {
//       if (valueS == '0' || valueS == '1') {
//         return (valueS == '1') as T;
//       }
//       return bool.fromEnvironment(value.toString()) as T;
//     }
//   }
//   return null;
// }

String getDisplayDate(DateTime now, DateTime dateTime) {
  final formattedString = dateTime.toIso8601String().substring(0, 10);
  final date = DateTime.parse(formattedString);
  final difference = DateTime(date.year, date.month, date.day)
      .difference(DateTime(now.year, now.month, now.day))
      .inDays
      .abs();
  final humanDays = [
    'Сегодня',
    'Вчера',
    'Позавчера',
    '3 дня назад',
    '4 дня назад',
    '5 дней назад',
    '6 дней назад',
    'Неделю назад',
  ];
  return (humanDays.length > difference)
      ? humanDays[difference]
      : DateFormat.yMMMMd('ru_RU').format(date);
}

// TODO: add Sentry or Firebase "Bug-Log"?
void out(dynamic value) {
  if (isInDebugMode) debugPrint('$value');
}

String convertEnumToSnakeCase(dynamic value) {
  return ReCase(EnumToString.parse(value)).snakeCase;
}

T getBloc<T extends Cubit<Object>>(BuildContext context) =>
    BlocProvider.of<T>(context);

T getRepository<T>(BuildContext context) => RepositoryProvider.of<T>(context);
