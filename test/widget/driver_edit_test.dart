import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/drivers/edit_driver.dart';
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

  /// tests if edits driver
  testWidgets('edits driver', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "clicker",
        ipAddress: "111.111.11.11",
        data: null);
    when(mockApi.editDriver(1, 'newname', "bulb")).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditDriver page = EditDriver(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');
    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("Kategoria"), findsOneWidget);

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Wybierz kategorię"), findsOneWidget);
    expect(find.text("Anuluj"), findsOneWidget);
    expect(find.text("naduszacz"), findsNWidgets(2));
    expect(find.text("pilot"), findsOneWidget);
    expect(find.text("rolety"), findsOneWidget);
    await tester.tap(find.text("żarówka").last);
    await tester.tap(find.text("żarówka").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editDriverButton')));
    await tester.pumpAndSettle();
    expect(find.text("Potwierdź"), findsOneWidget);
    expect(find.text("Czy na pewno zapisać zmiany?"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editDriver(1, 'newname', "bulb")).called(1);
  });

  /// tests if does not edit driver when api error
  testWidgets('does not edit driver when api error',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "clicker",
        ipAddress: "111.111.11.11",
        data: null);
    when(mockApi.editDriver(1, 'newname', "bulb")).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "404"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditDriver page = EditDriver(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');
    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("Kategoria"), findsOneWidget);

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Wybierz kategorię"), findsOneWidget);
    expect(find.text("Anuluj"), findsOneWidget);
    expect(find.text("naduszacz"), findsNWidgets(2));
    expect(find.text("pilot"), findsOneWidget);
    expect(find.text("żarówka"), findsOneWidget);
    await tester.tap(find.text("żarówka").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editDriverButton')));
    await tester.pumpAndSettle();
    expect(find.text("Potwierdź"), findsOneWidget);
    expect(find.text("Czy na pewno zapisać zmiany?"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Edycja sterownika nie powiodła się. Spróbuj ponownie."),
        findsOneWidget);
    verify(await mockApi.editDriver(1, 'newname', "bulb")).called(1);
  });

  /// tests if does not edit driver when driver exists
  testWidgets('does not edit driver when driver exists',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "clicker",
        ipAddress: "111.111.11.11",
        data: null);
    when(mockApi.editDriver(1, 'newname', "bulb")).thenAnswer((_) async =>
        Future.value({
          "body": "Driver with provided name already exists",
          "statusCode": "404"
        }));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditDriver page = EditDriver(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');
    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("Kategoria"), findsOneWidget);

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Wybierz kategorię"), findsOneWidget);
    expect(find.text("Anuluj"), findsOneWidget);
    expect(find.text("naduszacz"), findsNWidgets(2));
    expect(find.text("pilot"), findsOneWidget);
    expect(find.text("żarówka"), findsOneWidget);
    await tester.tap(find.text("żarówka").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editDriverButton')));
    await tester.pumpAndSettle();
    expect(find.text("Potwierdź"), findsOneWidget);
    expect(find.text("Czy na pewno zapisać zmiany?"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(
        find.text("Sterownik o podanej nazwie już istnieje."), findsOneWidget);
    verify(await mockApi.editDriver(1, 'newname', "bulb")).called(1);
  });

  /// tests if does not edit driver when empty name
  testWidgets('edits driver when empty name', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "clicker",
        ipAddress: "111.111.11.11",
        data: null);
    when(mockApi.editDriver(1, null, "clicker")).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditDriver page = EditDriver(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, '');
    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("Kategoria"), findsOneWidget);

    await tester.tap(find.byKey(Key('editDriverButton')));
    await tester.pumpAndSettle();
    expect(find.text("Pole wymagane"), findsOneWidget);
    verifyNever(await mockApi.editDriver(1, null, "clicker"));
  });

  /// tests if edits driver, english
  testWidgets('english edits driver', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "clicker",
        ipAddress: "111.111.11.11",
        data: null);
    when(mockApi.editDriver(1, 'newname', "bulb")).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditDriver page = EditDriver(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');
    expect(find.text("General"), findsOneWidget);
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("Category"), findsOneWidget);

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Select a category"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);
    expect(find.text("clicker"), findsNWidgets(2));
    expect(find.text("remote control"), findsOneWidget);
    expect(find.text("bulb"), findsOneWidget);
    await tester.tap(find.text("bulb").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editDriverButton')));
    await tester.pumpAndSettle();
    expect(find.text("Confirm"), findsOneWidget);
    expect(find.text("Are you sure you want to save the changes?"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editDriver(1, 'newname', "bulb")).called(1);
  });

  /// tests if does not edit driver when api error, english
  testWidgets('english, does not edit driver when api error',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "clicker",
        ipAddress: "111.111.11.11",
        data: null);
    when(mockApi.editDriver(1, 'newname', "bulb")).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "404"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditDriver page = EditDriver(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');
    expect(find.text("General"), findsOneWidget);
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("Category"), findsOneWidget);

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Select a category"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);
    expect(find.text("clicker"), findsNWidgets(2));
    expect(find.text("remote control"), findsOneWidget);
    expect(find.text("bulb"), findsOneWidget);
    await tester.tap(find.text("bulb").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editDriverButton')));
    await tester.pumpAndSettle();
    expect(find.text("Confirm"), findsOneWidget);
    expect(find.text("Are you sure you want to save the changes?"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Editing driver failed. Try again."),
        findsOneWidget);
    verify(await mockApi.editDriver(1, 'newname', "bulb")).called(1);
  });

  /// tests if does not edit driver when driver exists, english
  testWidgets('english does not edit driver when driver exists',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "clicker",
        ipAddress: "111.111.11.11",
        data: null);
    when(mockApi.editDriver(1, 'newname', "bulb")).thenAnswer((_) async =>
        Future.value({
          "body": "Driver with provided name already exists",
          "statusCode": "404"
        }));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditDriver page = EditDriver(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');
    expect(find.text("General"), findsOneWidget);
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("Category"), findsOneWidget);

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Select a category"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);
    expect(find.text("clicker"), findsNWidgets(2));
    expect(find.text("remote control"), findsOneWidget);
    expect(find.text("bulb"), findsOneWidget);
    expect(find.text("blinds"), findsOneWidget);
    await tester.tap(find.text("bulb").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editDriverButton')));
    await tester.pumpAndSettle();
    expect(find.text("Confirm"), findsOneWidget);
    expect(find.text("Are you sure you want to save the changes?"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(
        find.text("A driver with the given name already exists."), findsOneWidget);
    verify(await mockApi.editDriver(1, 'newname', "bulb")).called(1);
  });

  /// tests if does not edit driver when empty name, english
  testWidgets('english,edits driver when empty name', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "clicker",
        ipAddress: "111.111.11.11",
        data: null);
    when(mockApi.editDriver(1, null, "clicker")).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditDriver page = EditDriver(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, '');
    expect(find.text("General"), findsOneWidget);
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("Category"), findsOneWidget);

    await tester.tap(find.byKey(Key('editDriverButton')));
    await tester.pumpAndSettle();
    expect(find.text("Required field"), findsOneWidget);
    verifyNever(await mockApi.editDriver(1, null, "clicker"));
  });
}
