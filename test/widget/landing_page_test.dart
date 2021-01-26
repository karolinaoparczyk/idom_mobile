import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/pages/home.dart';
import 'package:idom/pages/logotype_widget.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';
import 'package:idom/pages/sensors/sensors.dart';

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

  /// tests if goes to logotype widget if  does not know if user is logged in
  testWidgets('goes to logotype widget if  does not know if user is logged in',
      (WidgetTester tester) async {
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    when(mockSecureStorage.getIsLoggedIn())
        .thenAnswer((_) async => Future.value(null));

    Home page = Home(testStorage: mockSecureStorage);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("IDOM"), findsOneWidget);
    expect(
        find.text("TWÓJ INTELIGENTNY DOM\nW JEDNYM MIEJSCU"), findsOneWidget);
    expect(find.text("Trwa ładowanie..."), findsOneWidget);
    expect(find.byType(LogotypeWidget), findsOneWidget);
  });

  /// tests if goes to front page if not logged in
  testWidgets('goes to front page if not logged in',
      (WidgetTester tester) async {
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    when(mockSecureStorage.getIsLoggedIn())
        .thenAnswer((_) async => Future.value("false"));

    Home page = Home(testStorage: mockSecureStorage);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("IDOM"), findsOneWidget);
    expect(
        find.text("TWÓJ INTELIGENTNY DOM\nW JEDNYM MIEJSCU"), findsOneWidget);
    expect(find.text("Edytuj adres serwera"), findsOneWidget);
    expect(find.text("Zaloguj"), findsOneWidget);
    expect(find.text("Zarejestruj"), findsOneWidget);
    expect(find.text("Zapomniałeś/aś hasła?"), findsOneWidget);
    expect(find.byType(Front), findsOneWidget);
  });

  /// tests if goes to sensors if logged in
  testWidgets('goes to sensors if logged in', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    when(mockSecureStorage.getIsLoggedIn())
        .thenAnswer((_) async => Future.value("true"));

    List<Map<String, dynamic>> sensors = [];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

    Home page = Home(testStorage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.byType(Sensors), findsOneWidget);
  });


  /// tests if goes to logotype widget if  does not know if user is logged in, english
  testWidgets('english goes to logotype widget if  does not know if user is logged in',
          (WidgetTester tester) async {
        MockSecureStorage mockSecureStorage = MockSecureStorage();

        when(mockSecureStorage.getIsLoggedIn())
            .thenAnswer((_) async => Future.value(null));

        Home page = Home(testStorage: mockSecureStorage);

        await tester.pumpWidget(makeEnglishTestableWidget(child: page));
        await tester.pumpAndSettle();

        expect(find.text("IDOM"), findsOneWidget);
        expect(
            find.text("YOUR SMART HOUSE\nIN ONE PLACE"), findsOneWidget);
        expect(find.text("Loading..."), findsOneWidget);
        expect(find.byType(LogotypeWidget), findsOneWidget);
      });

  /// tests if goes to front page if not logged in, english
  testWidgets('english goes to front page if not logged in',
          (WidgetTester tester) async {
        MockSecureStorage mockSecureStorage = MockSecureStorage();

        when(mockSecureStorage.getIsLoggedIn())
            .thenAnswer((_) async => Future.value("false"));

        Home page = Home(testStorage: mockSecureStorage);

        await tester.pumpWidget(makeEnglishTestableWidget(child: page));
        await tester.pumpAndSettle();

        expect(find.text("IDOM"), findsOneWidget);
        expect(
            find.text("YOUR SMART HOUSE\nIN ONE PLACE"), findsOneWidget);
        expect(find.text("Edit server address"), findsOneWidget);
        expect(find.text("Sign in"), findsOneWidget);
        expect(find.text("Sign up"), findsOneWidget);
        expect(find.text("Forgot password?"), findsOneWidget);
        expect(find.byType(Front), findsOneWidget);
      });
}
