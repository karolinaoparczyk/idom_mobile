import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/pages/drivers/driver_details.dart';
import 'package:idom/pages/drivers/drivers.dart';
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

  /// tests if drivers on list, send command to driver from context menu
  testWidgets('drivers on list, send command to driver from context menu',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> drivers = [
      {
        "id": 1,
        "name": "driver1",
        "category": "clicker",
        "ipAddress": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];
    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));
    when(mockApi.startDriver("driver1"))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getApiServerAddress())
        .thenAnswer((_) async => Future.value("apiAddress"));

    Drivers page = Drivers(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 2);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("driver2"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/tap.svg")), findsNWidgets(2));
    expect(find.byIcon(Icons.more_vert_outlined), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.more_vert_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text("Wciśnij przycisk"), findsOneWidget);
    expect(find.text("Usuń"), findsOneWidget);

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key("click")));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Wysłano komendę do sterownika driver1."), findsOneWidget);
    verify(await mockApi.startDriver("driver1")).called(1);

    await tester.tap(find.byKey(Key('searchButton')));
    await tester.pumpAndSettle();
    Finder searchField = find.byKey(Key('searchField'));
    await tester.enterText(searchField, 'driver');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 2);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("driver2"), findsOneWidget);

    await tester.enterText(searchField, '1');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 1);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("driver2"), findsNothing);
    await tester.tap(find.byKey(Key('arrowBack')));
    await tester.pumpAndSettle();
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("driver2"), findsOneWidget);

    await tester.tap(find.byKey(Key('searchButton')));
    await tester.pumpAndSettle();
    searchField = find.byKey(Key('searchField'));
    await tester.enterText(searchField, '2');
    await tester.pumpAndSettle();
    expect(find.text("driver1"), findsNothing);
    expect(find.text("driver2"), findsOneWidget);
    expect(find.byType(ListTile).evaluate().length, 1);
    await tester.tap(find.byKey(Key('clearSearchingBox')));
    await tester.pumpAndSettle();
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("driver2"), findsOneWidget);

    await tester.tap(find.text("driver1"));
    await tester.pumpAndSettle();
    expect(find.byType(DriverDetails), findsOneWidget);
  });

  /// tests if logs out when no token
  testWidgets('logs out when no token', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> drivers = [
      {
        "id": 1,
        "name": "driver1",
        "category": "clicker",
        "ipAddress": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];
    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "401"}));
    when(mockApi.startDriver("driver1"))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getApiServerAddress())
        .thenAnswer((_) async => Future.value("apiAddress"));

    Drivers page = Drivers(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
  });

  /// tests if drivers on list, delete driver from context menu
  testWidgets('delete driver from context menu', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> drivers = [
      {
        "id": 1,
        "name": "driver1",
        "category": "clicker",
        "ipAddress": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];
    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));
    when(mockApi.deleteDriver(1)).thenAnswer((_) async => Future.value(204));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Drivers page = Drivers(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert_outlined).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key("delete")));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key("yesButton")));
    await tester.pumpAndSettle();
    verify(await mockApi.deleteDriver(1)).called(1);
  });

  /// tests if turns on/off remote controller from context menu
  testWidgets('turn on/off remote controller from context menu',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> drivers = [
      {
        "id": 1,
        "name": "driver1",
        "category": "clicker",
        "ipAddress": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "remote_control",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];
    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getApiServerAddress())
        .thenAnswer((_) async => Future.value("apiAddress"));

    Drivers page = Drivers(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 2);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("driver2"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/tap.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/controller.svg")), findsOneWidget);
    expect(find.byIcon(Icons.more_vert_outlined), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.more_vert_outlined).last);
    await tester.pumpAndSettle();
    expect(find.text("Włącz/wyłącz pilot"), findsOneWidget);
    expect(find.text("Usuń"), findsOneWidget);
    await tester.tap(find.byKey(Key("click")));
    await tester.pumpAndSettle();

    await tester.drag(find.byKey(Key('DriversList')), const Offset(0.0, 300));
    await tester.pumpAndSettle();
    verify(await mockApi.getDrivers()).called(2);
  });

  /// tests if turns on/off bulb from context menu
  testWidgets('turn on/off bulb from context menu',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> drivers = [
      {
        "id": 1,
        "name": "driver1",
        "category": "bulb",
        "ipAddress": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "remote_control",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];
    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));
    when(mockApi.switchBulb(1, "off"))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getApiServerAddress())
        .thenAnswer((_) async => Future.value("apiAddress"));

    Drivers page = Drivers(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 2);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("driver2"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/light-bulb.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/controller.svg")), findsOneWidget);
    expect(find.byIcon(Icons.more_vert_outlined), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.more_vert_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text("Włącz/wyłącz żarówkę"), findsOneWidget);
    expect(find.text("Usuń"), findsOneWidget);
    await tester.tap(find.byKey(Key("click")));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Wysłano komendę wyłączenia żarówki driver1."),
        findsOneWidget);
    verify(await mockApi.switchBulb(1, "off")).called(1);
  });

  /// tests if raise/lower blinds from context menu
  testWidgets('raise/lower blinds from context menu',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> drivers = [
      {
        "id": 1,
        "name": "driver1",
        "category": "roller_blind",
        "ipAddress": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "remote_control",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];
    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));
    when(mockApi.switchBulb(1, "off"))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getApiServerAddress())
        .thenAnswer((_) async => Future.value("apiAddress"));

    Drivers page = Drivers(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 2);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("driver2"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/blinds.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/controller.svg")), findsOneWidget);
    expect(find.byIcon(Icons.more_vert_outlined), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.more_vert_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text("Podnieś/opuść rolety"), findsOneWidget);
    expect(find.text("Usuń"), findsOneWidget);
    await tester.tap(find.byKey(Key("click")));
    await tester.pumpAndSettle();
  });

  /// tests if drivers on list, send command to driver from context menu, english
  testWidgets(
      'english drivers on list, send command to driver from context menu',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> drivers = [
      {
        "id": 1,
        "name": "driver1",
        "category": "clicker",
        "ipAddress": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];
    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));
    when(mockApi.startDriver("driver1"))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getApiServerAddress())
        .thenAnswer((_) async => Future.value("apiAddress"));

    Drivers page = Drivers(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 2);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("driver2"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/tap.svg")), findsNWidgets(2));
    expect(find.byIcon(Icons.more_vert_outlined), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.more_vert_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text("Press the button"), findsOneWidget);
    expect(find.text("Remove"), findsOneWidget);

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key("click")));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("The command to driver driver1 has been sent."),
        findsOneWidget);
    verify(await mockApi.startDriver("driver1")).called(1);
  });

  /// tests if turns on/off remote controller from context menu, english
  testWidgets('english turn on/off remote controller from context menu',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> drivers = [
      {
        "id": 1,
        "name": "driver1",
        "category": "clicker",
        "ipAddress": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "remote_control",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];
    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getApiServerAddress())
        .thenAnswer((_) async => Future.value("apiAddress"));

    Drivers page = Drivers(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 2);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("driver2"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/tap.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/controller.svg")), findsOneWidget);
    expect(find.byIcon(Icons.more_vert_outlined), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.more_vert_outlined).last);
    await tester.pumpAndSettle();
    expect(find.text("Turn remote control on/off"), findsOneWidget);
    expect(find.text("Remove"), findsOneWidget);
    await tester.tap(find.byKey(Key("click")));
    await tester.pumpAndSettle();
  });

  /// tests if turns on/off bulb from context menu, english
  testWidgets('english turn on/off bulb from context menu',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> drivers = [
      {
        "id": 1,
        "name": "driver1",
        "category": "bulb",
        "ipAddress": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "remote_control",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];
    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));
    when(mockApi.switchBulb(1, "off"))
        .thenAnswer((_) async => Future.value(200));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getApiServerAddress())
        .thenAnswer((_) async => Future.value("apiAddress"));

    Drivers page = Drivers(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 2);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("driver2"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/light-bulb.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/controller.svg")), findsOneWidget);
    expect(find.byIcon(Icons.more_vert_outlined), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.more_vert_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text("Turn bulb on/off"), findsOneWidget);
    expect(find.text("Remove"), findsOneWidget);
    await tester.tap(find.byKey(Key("click")));
    await tester.pumpAndSettle();
    verify(await mockApi.switchBulb(1, "off")).called(1);
  });
}
