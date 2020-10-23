// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:minsk8/import.dart';

void main() {
  group('User', () {
    const id = 'mock-id';
    const email = 'mock-email';

    test('throws AssertionError when email is null', () {
      expect(
        () => UserModel(email: null, id: id, name: null, photo: null),
        throwsAssertionError,
      );
    });

    test('throws AssertionError when id is null', () {
      expect(
        () => UserModel(email: email, id: null, name: null, photo: null),
        throwsAssertionError,
      );
    });

    test('uses value equality', () {
      expect(
        UserModel(email: email, id: id, name: null, photo: null),
        UserModel(email: email, id: id, name: null, photo: null),
      );
    });
  });
}
