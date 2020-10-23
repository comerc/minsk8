// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minsk8/import.dart';

void main() {
  group('MySplashScreen', () {
    test('has a route', () {
      expect(MySplashScreen().getRoute(), isA<Route>());
    });

    testWidgets('renders bloc image', (tester) async {
      await tester.pumpWidget(MaterialApp(home: MySplashScreen()));
      expect(find.byKey(const Key('splash_bloc_image')), findsOneWidget);
    });
  });
}
