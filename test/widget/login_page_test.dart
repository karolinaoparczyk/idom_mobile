import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';
import 'package:idom/pages/setup/sign_in.dart';

class MockApi extends Mock implements Api {}

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  /// tests if signs in with empty email or password
  testWidgets('email or password is empty, does not sign in',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    SignIn page = SignIn(
        storage: mockSecureStorage, isFromSignUp: false, testApi: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    await tester.tap(find.byKey(Key('Zaloguj')));

    verifyNever(mockApi.signIn('', ''));
  });

  /// tests if signed in with valid email and password
  testWidgets('email and password non-empty, success sign in',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    var userApi = {
      "id": 1,
      "username": "user1",
      "email": "user@email.pl",
      "telephone": "+48765677655",
      "sms_notifications": true,
      "app_notifications": true,
      "is_staff": false,
      "is_active": true,
    };
    when(mockApi.getUser('user1'))
        .thenAnswer((_) async => Future.value([jsonEncode(userApi), 200]));
    List<dynamic> res = [
      '"token": "wertyuiopasdfghjklzxcvbnmwertyuiopasdf"',
      200
    ];
    when(mockApi.signIn('username', 'password'))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    SignIn page = SignIn(
        storage: mockSecureStorage, isFromSignUp: false, testApi: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder passwordField = find.byKey(Key('password'));
    await tester.enterText(passwordField, 'password');

    await tester.tap(find.byKey(Key('Zaloguj')));

    verify(await mockApi.signIn('username', 'password')).called(1);
  });

  /// tests if does not sign in with invalid email or password
  testWidgets('email and password non-empty, error sign in',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    bool isSignedIn = false;
    List<dynamic> res = ['Wrong credentials', 400];
    when(mockApi.signIn('email@mail.com', 'password'))
        .thenAnswer((_) => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    SignIn page = SignIn(
        storage: mockSecureStorage, isFromSignUp: false, testApi: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, 'email@mail.com');

    Finder passwordField = find.byKey(Key('password'));
    await tester.enterText(passwordField, 'password');

    await tester.tap(find.byKey(Key('Zaloguj się')));

    verify(mockApi.signIn('email@mail.com', 'password')).called(1);
    expect(isSignedIn, false);
  });
}
