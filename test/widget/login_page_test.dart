import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';
import 'package:idom/pages/setup/sign_in.dart';

class MockApi extends Mock implements Api {}

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  Widget makePolishTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  Widget makeEnglishTestableWidget({Widget child}) {
    return MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en', "UK"),
          Locale('pl', "PL"),
        ],
        localeListResolutionCallback: (locales, supportedLocales) {
          return Locale('en', "UK");
        },
        home: I18n(child: child));
  }

  /// tests if signs in with empty email or password
  testWidgets('email or password is empty, does not sign in',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    SignIn page = SignIn(
        storage: mockSecureStorage, isFromSignUp: false, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    expect(find.text("Nazwa użytkownika"), findsOneWidget);
    expect(find.text("Hasło"), findsOneWidget);
    await tester.tap(find.byKey(Key('Zaloguj')));
    await tester.pumpAndSettle();

    expect(find.text("Pole wymagane"), findsNWidgets(2));
    verifyNever(mockApi.signIn('', ''));
  });

  /// tests if signed in with valid email and password
  testWidgets('email and password non-empty, success sign in',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, dynamic> userApi = {
      "id": 1,
      "username": "username",
      "email": "user@email.pl",
      "telephone": "+48765677655",
      "sms_notifications": true,
      "is_staff": false,
      "is_active": true,
    };
    when(mockApi.getUser('username',
            userToken: "\"wertyuiopasdfghjklzxcvbnmwertyuiopasdf\""))
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

    await tester.pumpWidget(makePolishTestableWidget(child: page));

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
    List<dynamic> res = ['Wrong credentials', 400];
    when(mockApi.signIn('email@mail.com', 'password'))
        .thenAnswer((_) => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    SignIn page = SignIn(
        storage: mockSecureStorage, isFromSignUp: false, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'email@mail.com');

    Finder passwordField = find.byKey(Key('password'));
    await tester.enterText(passwordField, 'password');

    await tester.tap(find.byKey(Key('Zaloguj')));
    await tester.pumpAndSettle();

    expect(
        find.text(
            "Błąd logowania. Błędne hasło lub konto z podanym loginem nie istnieje."),
        findsOneWidget);
    verify(mockApi.signIn('email@mail.com', 'password')).called(1);
  });

  /// tests if signs in with empty email or password, english
  testWidgets('english email or password is empty, does not sign in',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    SignIn page = SignIn(
        storage: mockSecureStorage, isFromSignUp: false, testApi: mockApi);

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));

    expect(find.text("Username"), findsOneWidget);
    expect(find.text("Password"), findsOneWidget);
    await tester.tap(find.byKey(Key('Sign in')));
    await tester.pumpAndSettle();

    expect(find.text("Required field"), findsNWidgets(2));
    verifyNever(mockApi.signIn('', ''));
  });

  /// tests if does not sign in with invalid email or password, english
  testWidgets('english email and password non-empty, error sign in',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<dynamic> res = ['Wrong credentials', 400];
    when(mockApi.signIn('email@mail.com', 'password'))
        .thenAnswer((_) => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    SignIn page = SignIn(
        storage: mockSecureStorage, isFromSignUp: false, testApi: mockApi);

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'email@mail.com');

    Finder passwordField = find.byKey(Key('password'));
    await tester.enterText(passwordField, 'password');

    await tester.tap(find.byKey(Key('Sign in')));
    await tester.pumpAndSettle();

    expect(
        find.text(
            "Login error. Wrong password or account with the given login does not exist."),
        findsOneWidget);
    verify(mockApi.signIn('email@mail.com', 'password')).called(1);
  });
}
