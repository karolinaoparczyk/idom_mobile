import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/pages/drivers/edit_driver.dart';
import 'package:idom/pages/drivers/new_driver.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';

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

  /// tests if adds driver
  testWidgets('adds driver', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addDriver('name', 'clicker')).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "201"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewDriver page = NewDriver(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');
    expect(find.text("Dodaj sterownik"), findsOneWidget);
    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("Kategoria"), findsOneWidget);

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Wybierz kategorię"), findsOneWidget);
    expect(find.text("Anuluj"), findsOneWidget);
    expect(find.text("przycisk"), findsOneWidget);
    expect(find.text("pilot"), findsOneWidget);
    expect(find.text("żarówka"), findsOneWidget);
    await tester.tap(find.text("przycisk").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('saveDriverButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.addDriver('name', 'clicker')).called(1);
  });

  /// tests if adds bulb
  testWidgets('adds bulb', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addDriver('name', 'bulb'))
        .thenAnswer((_) async => Future.value({
              "body": jsonEncode({
                "id": 1,
                "name": "driver1",
                "category": "roller_blind",
                "ipAddress": "111.111.11.11",
                "data": true
              }),
              "statusCode": "201"
            }));
    when(mockApi.addIpAddress(1, '111.222.33.44'))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewDriver page = NewDriver(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("żarówka").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder ipField = find.byKey(Key('ipAddress'));
    await tester.enterText(ipField, '111.222.33.44');

    await tester.tap(find.byKey(Key('saveDriverButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.addDriver('name', 'bulb')).called(1);
    verify(await mockApi.addIpAddress(1, '111.222.33.44')).called(1);
  });

  /// tests if adds bulb, ip invalid error, goes to edit and saves
  testWidgets('adds bulb, ip invalid error, goes to edit and saves',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addDriver('name', 'bulb'))
        .thenAnswer((_) async => Future.value({
              "body": jsonEncode({
                "id": 1,
                "name": "name",
                "category": "bulb",
                "ipAddress": "111.222.33.44",
                "data": null
              }),
              "statusCode": "201"
            }));
    when(mockApi.addIpAddress(1, '111.222.33.44'))
        .thenAnswer((_) async => Future.value(400));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewDriver page = NewDriver(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("żarówka").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("Adres IP"), findsOneWidget);

    Finder ipField = find.byKey(Key('ipAddress'));
    await tester.enterText(ipField, '111.222.33.44');

    await tester.tap(find.byKey(Key('saveDriverButton')));
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.addDriver('name', 'bulb')).called(1);
    verify(await mockApi.addIpAddress(1, '111.222.33.44')).called(1);

    expect(find.byType(EditDriver), findsOneWidget);
    expect(
        find.text(
            "Podczas dodawania żarówki nie udało się zapisać adresu IP. Spróbuj ponownie."),
        findsOneWidget);

    expect(find.text("Adres IP"), findsOneWidget);

    ipField = find.byKey(Key('ipAddress'));
    await tester.enterText(ipField, '222.333.44.55');
    when(mockApi.addIpAddress(1, '222.333.44.55'))
        .thenAnswer((_) async => Future.value(200));

    await tester.tap(find.byKey(Key('editDriverButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verifyNever(await mockApi.addDriver('name', 'bulb'));
    verify(await mockApi.addIpAddress(1, '222.333.44.55')).called(1);
  });

  /// tests if does not adds driver when empty body
  testWidgets('does not adds driver when empty body',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addDriver(null, null)).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "201"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewDriver page = NewDriver(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, '');
    await tester.tap(find.byKey(Key('saveDriverButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Pole wymagane"), findsNWidgets(2));

    verifyNever(await mockApi.addDriver(null, null));
  });

  /// tests if does not adds driver when api error
  testWidgets('does not adds driver when api error',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addDriver('name', 'clicker')).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "404"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewDriver page = NewDriver(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');
    expect(find.text("Dodaj sterownik"), findsOneWidget);
    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("Kategoria"), findsOneWidget);

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Wybierz kategorię"), findsOneWidget);
    expect(find.text("Anuluj"), findsOneWidget);
    expect(find.text("przycisk"), findsOneWidget);
    expect(find.text("pilot"), findsOneWidget);
    expect(find.text("żarówka"), findsOneWidget);
    await tester.tap(find.text("przycisk").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('saveDriverButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(
        find.text("Dodawanie sterownika nie powiodło się. Spróbuj ponownie."),
        findsOneWidget);

    verify(await mockApi.addDriver('name', 'clicker')).called(1);
  });

  /// tests if does not adds driver when already exists
  testWidgets('does not adds driver when already exists',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addDriver('name', 'clicker')).thenAnswer((_) async =>
        Future.value({
          "body": "Driver with provided name already exists",
          "statusCode": "404"
        }));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewDriver page = NewDriver(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');
    expect(find.text("Dodaj sterownik"), findsOneWidget);
    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("Kategoria"), findsOneWidget);

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Wybierz kategorię"), findsOneWidget);
    expect(find.text("Anuluj"), findsOneWidget);
    expect(find.text("przycisk"), findsOneWidget);
    expect(find.text("pilot"), findsOneWidget);
    expect(find.text("żarówka"), findsOneWidget);
    expect(find.text("rolety"), findsOneWidget);
    await tester.tap(find.text("przycisk").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('saveDriverButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(
        find.text("Sterownik o podanej nazwie już istnieje."), findsOneWidget);

    verify(await mockApi.addDriver('name', 'clicker')).called(1);
  });

  /// tests if adds driver, english
  testWidgets('english adds driver', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addDriver('name', 'clicker')).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "201"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewDriver page = NewDriver(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');
    expect(find.text("Create driver"), findsOneWidget);
    expect(find.text("General"), findsOneWidget);
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("Category"), findsOneWidget);

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Select a category"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);
    expect(find.text("clicker"), findsOneWidget);
    expect(find.text("remote control"), findsOneWidget);
    expect(find.text("bulb"), findsOneWidget);
    await tester.tap(find.text("clicker").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('saveDriverButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.addDriver('name', 'clicker')).called(1);
  });

  /// tests if does not adds driver when empty body, english
  testWidgets('english does not adds driver when empty body',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addDriver(null, null)).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "201"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewDriver page = NewDriver(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, '');
    await tester.tap(find.byKey(Key('saveDriverButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Required field"), findsNWidgets(2));

    verifyNever(await mockApi.addDriver(null, null));
  });

  /// tests if does not adds driver when api error, english
  testWidgets('english does not adds driver when api error',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addDriver('name', 'clicker')).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "404"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewDriver page = NewDriver(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');
    expect(find.text("Create driver"), findsOneWidget);
    expect(find.text("General"), findsOneWidget);
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("Category"), findsOneWidget);

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Select a category"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);
    expect(find.text("clicker"), findsOneWidget);
    expect(find.text("remote control"), findsOneWidget);
    expect(find.text("bulb"), findsOneWidget);
    expect(find.text("blinds"), findsOneWidget);
    await tester.tap(find.text("clicker").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('saveDriverButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Creating driver failed. Try again."), findsOneWidget);

    verify(await mockApi.addDriver('name', 'clicker')).called(1);
  });

  /// tests if does not adds driver when already exists, english
  testWidgets('english does not adds driver when already exists',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addDriver('name', 'clicker')).thenAnswer((_) async =>
        Future.value({
          "body": "Driver with provided name already exists",
          "statusCode": "404"
        }));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewDriver page = NewDriver(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("clicker").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('saveDriverButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("A driver with the given name already exists."),
        findsOneWidget);

    verify(await mockApi.addDriver('name', 'clicker')).called(1);
  });

  /// tests if adds bulb, ip invalid error, goes to edit and saves, english
  testWidgets('english adds bulb, ip invalid error, goes to edit and saves',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addDriver('name', 'bulb'))
        .thenAnswer((_) async => Future.value({
              "body": jsonEncode({
                "id": 1,
                "name": "name",
                "category": "bulb",
                "ipAddress": "111.222.33.44",
                "data": null
              }),
              "statusCode": "201"
            }));
    when(mockApi.addIpAddress(1, '111.222.33.44'))
        .thenAnswer((_) async => Future.value(400));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewDriver page = NewDriver(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("bulb").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("IP address"), findsOneWidget);

    Finder ipField = find.byKey(Key('ipAddress'));
    await tester.enterText(ipField, '111.222.33.44');

    await tester.tap(find.byKey(Key('saveDriverButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.addDriver('name', 'bulb')).called(1);
    verify(await mockApi.addIpAddress(1, '111.222.33.44')).called(1);

    expect(find.byType(EditDriver), findsOneWidget);
    expect(
        find.text(
            "IP address could not be saved while adding bulb. Try again."),
        findsOneWidget);

    expect(find.text("IP address"), findsOneWidget);

    ipField = find.byKey(Key('ipAddress'));
    await tester.enterText(ipField, '222.333.44.55');
    when(mockApi.addIpAddress(1, '222.333.44.55'))
        .thenAnswer((_) async => Future.value(200));

    await tester.tap(find.byKey(Key('editDriverButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verifyNever(await mockApi.addDriver('name', 'bulb'));
    verify(await mockApi.addIpAddress(1, '222.333.44.55')).called(1);
  });
}
