import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/drivers/driver_details.dart';
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
    expect(find.text("przycisk"), findsNWidgets(2));
    expect(find.text("pilot"), findsOneWidget);
    expect(find.text("rolety"), findsOneWidget);
    await tester.tap(find
        .text("żarówka")
        .last);
    await tester.tap(find
        .text("żarówka")
        .last);
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

  /// tests if navigates back to details
  testWidgets('navigates back to details', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "clicker",
        ipAddress: "111.111.11.11",
        data: null);
    when(mockApi.editDriver(1, 'newname', "bulb")).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));
    Map<String, dynamic> driverJson = {
      "id": 1,
      "name": "driver1",
      "category": "clicker",
      "ipAddress": "111.111.11.11",
      "data": true
    };
    when(mockApi.getDriverDetails(1)).thenAnswer(
            (_) async =>
            Future.value({"body": jsonEncode(driverJson), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );
    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('editDriver')));
    await tester.pumpAndSettle();
    expect(find.byType(EditDriver), findsOneWidget);

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
    expect(find.text("przycisk"), findsNWidgets(2));
    expect(find.text("pilot"), findsOneWidget);
    expect(find.text("rolety"), findsOneWidget);
    await tester.tap(find
        .text("żarówka")
        .last);
    await tester.tap(find
        .text("żarówka")
        .last);
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
    expect(find.byType(DriverDetails), findsOneWidget);

    verify(await mockApi.editDriver(1, 'newname', "bulb")).called(1);
  });

  /// tests if logs out when no token while refreshing data
  testWidgets('logs out when no token while refreshing data', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "clicker",
        ipAddress: "111.111.11.11",
        data: null);
    when(mockApi.editDriver(1, 'newname', "bulb")).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));
    Map<String, dynamic> driverJson = {
      "id": 1,
      "name": "driver1",
      "category": "clicker",
      "ipAddress": "111.111.11.11",
      "data": true
    };
    when(mockApi.getDriverDetails(1)).thenAnswer(
            (_) async =>
            Future.value({"body": jsonEncode(driverJson), "statusCode": "401"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );
    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('editDriver')));
    await tester.pumpAndSettle();
    expect(find.byType(EditDriver), findsOneWidget);

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
    expect(find.text("przycisk"), findsNWidgets(2));
    expect(find.text("pilot"), findsOneWidget);
    expect(find.text("rolety"), findsOneWidget);
    await tester.tap(find
        .text("żarówka")
        .last);
    await tester.tap(find
        .text("żarówka")
        .last);
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
    expect(find.byType(DriverDetails), findsOneWidget);

    verify(await mockApi.editDriver(1, 'newname', "bulb")).called(1);
  });

  /// tests if logs out when no token
  testWidgets('logs out when no token', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "clicker",
        ipAddress: "111.111.11.11",
        data: null);
    when(mockApi.editDriver(1, 'newname', "bulb")).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "401"}));

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
    expect(find.text("przycisk"), findsNWidgets(2));
    expect(find.text("pilot"), findsOneWidget);
    expect(find.text("rolety"), findsOneWidget);
    await tester.tap(find
        .text("żarówka")
        .last);
    await tester.tap(find
        .text("żarówka")
        .last);
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

  /// tests if edits bulb, ip address invalid
  testWidgets('edits bulb, ip address invalid', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "bulb",
        ipAddress: "111.111.11.11",
        data: null);
    when(mockApi.editDriver(1, 'newname', null)).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));
    when(mockApi.addIpAddress(1, '111.222.33.44'))
        .thenAnswer((_) async => Future.value(400));

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

    Finder ipField = find.byKey(Key('ipAddress'));
    await tester.enterText(ipField, '111.222.33.44');

    await tester.tap(find.byKey(Key('editDriverButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editDriver(1, 'newname', null)).called(1);
    verify(await mockApi.addIpAddress(1, '111.222.33.44')).called(1);
    expect(find.byType(EditDriver), findsOneWidget);
    expect(find.text("Adres IP jest niepoprawny."), findsOneWidget);
  });

  /// tests if edits bulb, name exists
  testWidgets('edits bulb, name exists', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "bulb",
        ipAddress: "111.111.11.11",
        data: null);
    when(mockApi.editDriver(1, 'newname', null)).thenAnswer((_) async =>
        Future.value({
          "body": "Driver with provided name already exists",
          "statusCode": "400"
        }));
    when(mockApi.addIpAddress(1, '111.222.33.44'))
        .thenAnswer((_) async => Future.value(200));

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

    Finder ipField = find.byKey(Key('ipAddress'));
    await tester.enterText(ipField, '111.222.33.44');

    await tester.tap(find.byKey(Key('editDriverButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editDriver(1, 'newname', null)).called(1);
    verify(await mockApi.addIpAddress(1, '111.222.33.44')).called(1);
    expect(find.byType(EditDriver), findsOneWidget);
    expect(
        find.text("Sterownik o podanej nazwie już istnieje."), findsOneWidget);
  });

  /// tests if edits bulb, name exists and ip address invalid
  testWidgets('edits bulb, name exists and ip address invalid',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        Driver driver = Driver(
            id: 1,
            name: "driver1",
            category: "bulb",
            ipAddress: "111.111.11.11",
            data: null);
        when(mockApi.editDriver(1, 'newname', null)).thenAnswer((_) async =>
            Future.value({
              "body": "Driver with provided name already exists",
              "statusCode": "400"
            }));
        when(mockApi.addIpAddress(1, '111.222.33.44'))
            .thenAnswer((_) async => Future.value(400));

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

        Finder ipField = find.byKey(Key('ipAddress'));
        await tester.enterText(ipField, '111.222.33.44');

        await tester.tap(find.byKey(Key('editDriverButton')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));
        verify(await mockApi.editDriver(1, 'newname', null)).called(1);
        verify(await mockApi.addIpAddress(1, '111.222.33.44')).called(1);
        expect(find.byType(EditDriver), findsOneWidget);
        expect(
            find.text(
                "Sterownik o podanej nazwie już istnieje. Adres IP jest niepoprawny."),
            findsOneWidget);
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
        expect(find.text("przycisk"), findsNWidgets(2));
        expect(find.text("pilot"), findsOneWidget);
        expect(find.text("żarówka"), findsOneWidget);
        await tester.tap(find
            .text("żarówka")
            .last);
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
            find.text("Edycja sterownika nie powiodła się. Spróbuj ponownie."),
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
        expect(find.text("przycisk"), findsNWidgets(2));
        expect(find.text("pilot"), findsOneWidget);
        expect(find.text("żarówka"), findsOneWidget);
        await tester.tap(find
            .text("żarówka")
            .last);
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
            find.text("Sterownik o podanej nazwie już istnieje."),
            findsOneWidget);
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
    await tester.tap(find
        .text("bulb")
        .last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editDriverButton')));
    await tester.pumpAndSettle();
    expect(find.text("Confirm"), findsOneWidget);
    expect(find.text("Are you sure you want to save the changes?"),
        findsOneWidget);
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
        await tester.tap(find
            .text("bulb")
            .last);
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();

        await tester.tap(find.byKey(Key('editDriverButton')));
        await tester.pumpAndSettle();
        expect(find.text("Confirm"), findsOneWidget);
        expect(find.text("Are you sure you want to save the changes?"),
            findsOneWidget);
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));
        expect(find.text("Editing driver failed. Try again."), findsOneWidget);
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
        await tester.tap(find
            .text("bulb")
            .last);
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();

        await tester.tap(find.byKey(Key('editDriverButton')));
        await tester.pumpAndSettle();
        expect(find.text("Confirm"), findsOneWidget);
        expect(find.text("Are you sure you want to save the changes?"),
            findsOneWidget);
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));
        expect(find.text("A driver with the given name already exists."),
            findsOneWidget);
        verify(await mockApi.editDriver(1, 'newname', "bulb")).called(1);
      });

  /// tests if does not edit driver when empty name, english
  testWidgets('english,edits driver when empty name',
          (WidgetTester tester) async {
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

  /// tests if edits bulb, ip address invalid, english
  testWidgets('english edits bulb, ip address invalid',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        Driver driver = Driver(
            id: 1,
            name: "driver1",
            category: "bulb",
            ipAddress: "111.111.11.11",
            data: null);
        when(mockApi.editDriver(1, 'newname', null)).thenAnswer(
                (_) async => Future.value({"body": "", "statusCode": "200"}));
        when(mockApi.addIpAddress(1, '111.222.33.44'))
            .thenAnswer((_) async => Future.value(400));

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

        Finder ipField = find.byKey(Key('ipAddress'));
        await tester.enterText(ipField, '111.222.33.44');

        await tester.tap(find.byKey(Key('editDriverButton')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));
        verify(await mockApi.editDriver(1, 'newname', null)).called(1);
        verify(await mockApi.addIpAddress(1, '111.222.33.44')).called(1);
        expect(find.byType(EditDriver), findsOneWidget);
        expect(find.text("The IP address is incorrect."), findsOneWidget);
      });

  /// tests if edits bulb, name exists, english
  testWidgets('english edits bulb, name exists', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "bulb",
        ipAddress: "111.111.11.11",
        data: null);
    when(mockApi.editDriver(1, 'newname', null)).thenAnswer((_) async =>
        Future.value({
          "body": "Driver with provided name already exists",
          "statusCode": "400"
        }));
    when(mockApi.addIpAddress(1, '111.222.33.44'))
        .thenAnswer((_) async => Future.value(200));

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

    Finder ipField = find.byKey(Key('ipAddress'));
    await tester.enterText(ipField, '111.222.33.44');

    await tester.tap(find.byKey(Key('editDriverButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editDriver(1, 'newname', null)).called(1);
    verify(await mockApi.addIpAddress(1, '111.222.33.44')).called(1);
    expect(find.byType(EditDriver), findsOneWidget);
    expect(find.text("A driver with the given name already exists."),
        findsOneWidget);
  });

  /// tests if edits bulb, name exists and ip address invalid, english
  testWidgets('english edits bulb, name exists and ip address invalid',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        Driver driver = Driver(
            id: 1,
            name: "driver1",
            category: "bulb",
            ipAddress: "111.111.11.11",
            data: null);
        when(mockApi.editDriver(1, 'newname', null)).thenAnswer((_) async =>
            Future.value({
              "body": "Driver with provided name already exists",
              "statusCode": "400"
            }));
        when(mockApi.addIpAddress(1, '111.222.33.44'))
            .thenAnswer((_) async => Future.value(400));

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

        Finder ipField = find.byKey(Key('ipAddress'));
        await tester.enterText(ipField, '111.222.33.44');

        await tester.tap(find.byKey(Key('editDriverButton')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));
        verify(await mockApi.editDriver(1, 'newname', null)).called(1);
        verify(await mockApi.addIpAddress(1, '111.222.33.44')).called(1);
        expect(find.byType(EditDriver), findsOneWidget);
        expect(
            find.text(
                "A driver with the given name already exists. The IP address is incorrect."),
            findsOneWidget);
      });
}
