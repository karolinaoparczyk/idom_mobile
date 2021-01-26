import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/pages/actions/new_action.dart';
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

  /// tests if adds action without sensor with time range, turn on
  testWidgets('adds action without sensor with time range, turn on',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction('name', null, null, null, "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 2))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "201"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("Sterownik"), findsOneWidget);
    expect(find.text("Czujnik"), findsOneWidget);
    expect(find.text("Czas działania akcji"), findsOneWidget);
    expect(find.text("pn"), findsOneWidget);
    expect(find.text("wt"), findsOneWidget);
    expect(find.text("śr"), findsOneWidget);
    expect(find.text("czw"), findsOneWidget);
    expect(find.text("pt"), findsOneWidget);
    expect(find.text("sb"), findsOneWidget);
    expect(find.text("nd"), findsOneWidget);
    expect(find.text("Start"), findsOneWidget);
    expect(find.text("Koniec"), findsOneWidget);
    expect(find.text("Dodaj akcję"), findsOneWidget);
    expect(find.text("Wyzwalacz na czujniku"), findsNothing);
    expect(find.text("Operator"), findsNothing);
    expect(find.text("Wartość"), findsNothing);

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(Key("searchIcon")));
    await tester.pumpAndSettle();
    Finder searchField = find.byKey(Key('searchField'));
    await tester.enterText(searchField, '2');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 1);
    expect(find.text("driver1"), findsNothing);

    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Wciśnij przycisk").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.addAction('name', null, null, null, "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 2))
        .called(1);
  });

  /// tests if adds action without driver with start time
  testWidgets('adds action without driver with start time',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction('name', null, null, null, "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", null, {"status": "on"}, 1))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "201"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);

    await tester.tap(find.byKey(Key('removeEndTime')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Wciśnij przycisk").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.addAction('name', null, null, null, "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", null, {"status": "on"}, 1))
        .called(1);
  });

  /// tests if cancels drivers dialog
  testWidgets('cancels drivers dialog', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction('name', null, null, null, "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", null, {"status": "on"}, 1))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "201"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('Cancel')));
    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsNothing);
  });

  /// tests if adds action with sensor with time range, raise blinds
  testWidgets('adds action with sensor with time range, raise blinds',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "201"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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
        "category": "roller_blind",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(Key("searchIcon")));
    await tester.pumpAndSettle();
    Finder searchField = find.byKey(Key('searchField'));
    await tester.enterText(searchField, '1');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 1);

    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('triggerValueOperator')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Wybierz operator porównania"), findsOneWidget);
    expect(find.text("Anuluj"), findsOneWidget);
    expect(find.text("OK"), findsOneWidget);
    expect(find.text("< mniejsze niż"), findsOneWidget);
    expect(find.text("> większe niż"), findsOneWidget);
    expect(find.text("= równe"), findsOneWidget);
    await tester.tap(find.text("< mniejsze niż").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder sensorTrigger = find.byKey(Key('sensorTrigger'));
    await tester.enterText(sensorTrigger, '5');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Podnieś rolety").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("< mniejsze niż"), findsOneWidget);
    expect(find.text("5"), findsOneWidget);
    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 4))
        .called(1);
  });

  /// tests if cancels driver action dialog
  testWidgets('cancels driver action dialog',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "201"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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
        "category": "roller_blind",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(Key("searchIcon")));
    await tester.pumpAndSettle();
    Finder searchField = find.byKey(Key('searchField'));
    await tester.enterText(searchField, '1');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 1);

    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('triggerValueOperator')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Wybierz operator porównania"), findsOneWidget);
    expect(find.text("Anuluj"), findsOneWidget);
    expect(find.text("OK"), findsOneWidget);
    expect(find.text("< mniejsze niż"), findsOneWidget);
    expect(find.text("> większe niż"), findsOneWidget);
    expect(find.text("= równe"), findsOneWidget);
    await tester.tap(find.text("< mniejsze niż").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder sensorTrigger = find.byKey(Key('sensorTrigger'));
    await tester.enterText(sensorTrigger, '5');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Podnieś rolety").last);
    await tester.tap(find.byKey(Key('Cancel')));
    await tester.pumpAndSettle();

    expect(find.text("Podnieś rolety"), findsNothing);
  });

  /// tests if cancels sensor dialog
  testWidgets('cancels sensor dialog',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "201"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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
        "category": "roller_blind",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(Key("searchIcon")));
    await tester.pumpAndSettle();
    Finder searchField = find.byKey(Key('searchField'));
    await tester.enterText(searchField, '1');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 1);

    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('Cancel')));
    await tester.pumpAndSettle();

    expect(find.text("sensor1"), findsNothing);
  });

  /// tests if adds action with sensor with time range, lower blinds
  testWidgets('adds action with sensor with time range, lower blinds',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "off"}, 4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "201"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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
        "category": "roller_blind",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('triggerValueOperator')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Wybierz operator porównania"), findsOneWidget);
    expect(find.text("Anuluj"), findsOneWidget);
    expect(find.text("OK"), findsOneWidget);
    expect(find.text("< mniejsze niż"), findsOneWidget);
    expect(find.text("> większe niż"), findsOneWidget);
    expect(find.text("= równe"), findsOneWidget);
    await tester.tap(find.text("< mniejsze niż").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder sensorTrigger = find.byKey(Key('sensorTrigger'));
    await tester.enterText(sensorTrigger, '5');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Opuść rolety").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("< mniejsze niż"), findsOneWidget);
    expect(find.text("5"), findsOneWidget);
    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "off"}, 4))
        .called(1);
  });

  /// tests if logs out when no token
  testWidgets('logs out when no token',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "off"}, 4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "401"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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
        "category": "roller_blind",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('triggerValueOperator')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Wybierz operator porównania"), findsOneWidget);
    expect(find.text("Anuluj"), findsOneWidget);
    expect(find.text("OK"), findsOneWidget);
    expect(find.text("< mniejsze niż"), findsOneWidget);
    expect(find.text("> większe niż"), findsOneWidget);
    expect(find.text("= równe"), findsOneWidget);
    await tester.tap(find.text("< mniejsze niż").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder sensorTrigger = find.byKey(Key('sensorTrigger'));
    await tester.enterText(sensorTrigger, '5');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Opuść rolety").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("< mniejsze niż"), findsOneWidget);
    expect(find.text("5"), findsOneWidget);
    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "off"}, 4))
        .called(1);
  });

  /// tests if cancels trigger dialog
  testWidgets('cancels trigger dialog',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "off"}, 4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "201"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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
        "category": "roller_blind",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('triggerValueOperator')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Wybierz operator porównania"), findsOneWidget);
    expect(find.text("Anuluj"), findsOneWidget);
    expect(find.text("OK"), findsOneWidget);
    expect(find.text("< mniejsze niż"), findsOneWidget);
    expect(find.text("> większe niż"), findsOneWidget);
    expect(find.text("= równe"), findsOneWidget);
    await tester.tap(find.text("< mniejsze niż").last);
    await tester.tap(find.byKey(Key('Cancel')));
    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("< mniejsze niż"), findsNothing);
  });

  /// tests if adds action with sensor, turn on bulb
  testWidgets('adds action with sensor, turn on bulb',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction(
            'name',
            "sensor1",
            5.0,
            "<",
            "driver2",
            "0, 1, 2, 3, 4, 5, 6",
            "13:40",
            "15:40",
            {"type": "turn", "status": "on"},
            4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "201"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "bulb",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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
        "category": "bulb",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('triggerValueOperator')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("< mniejsze niż").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Włącz żarówkę").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    Finder sensorTrigger = find.byKey(Key('sensorTrigger'));
    await tester.enterText(sensorTrigger, '5');

    expect(find.text("Wyzwalacz na czujniku"), findsOneWidget);
    expect(find.text("Operator"), findsOneWidget);
    expect(find.text("Wartość"), findsOneWidget);

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("< mniejsze niż"), findsOneWidget);
    expect(find.text("5"), findsOneWidget);
    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.addAction(
            'name',
            "sensor1",
            5.0,
            "<",
            "driver2",
            "0, 1, 2, 3, 4, 5, 6",
            "13:40",
            "15:40",
            {"type": "turn", "status": "on"},
            4))
        .called(1);
  });

  /// tests if does not add if no name, no driver
  testWidgets('does not add if no name, no driver',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction(null, null, null, null, null, "0, 1, 2, 3, 4, 5, 6",
            "13:40", "15:40", {"status": "on"}, 2))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "400"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    expect(find.text("Pole wymagane"), findsNWidgets(3));

    verifyNever(await mockApi.addAction(
        null,
        null,
        null,
        null,
        null,
        "0, 1, 2, 3, 4, 5, 6",
        "13:40",
        "15:40",
        {"type": "turn", "status": "on"},
        2));
  });

  /// tests if does not add if no trigger, no operator if sensor chosen, turn off bulb
  testWidgets(
      'does not add if no trigger, no operator if sensor chosen, turn off bulb',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction(
            null,
            "sensor1",
            null,
            null,
            "driver2",
            "0, 1, 2, 3, 4, 5, 6",
            "13:40",
            "15:40",
            {"type": "turn", "status": "off"},
            4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "400"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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
        "category": "bulb",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Wyłącz żarówkę").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    expect(find.text("Pole wymagane"), findsNWidgets(2));

    verifyNever(await mockApi.addAction(
        null,
        "sensor1",
        null,
        null,
        "driver2",
        "0, 1, 2, 3, 4, 5, 6",
        "13:40",
        "15:40",
        {"type": "turn", "status": "off"},
        4));
  });

  /// tests if does not add if no trigger, no operator if sensor chosen, set bulb color
  testWidgets(
      'does not add if no trigger, no operator if sensor chosen, set bulb color',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction(
            null,
            "sensor1",
            null,
            null,
            "driver2",
            "0, 1, 2, 3, 4, 5, 6",
            "13:40",
            "15:40",
            {"red": 128, "blue": 128, "type": "colour", "green": 128},
            4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "400"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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
        "category": "bulb",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Ustaw kolor").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    expect(find.text("Pole wymagane"), findsNWidgets(2));

    verifyNever(await mockApi.addAction(
        null,
        "sensor1",
        null,
        null,
        "driver2",
        "0, 1, 2, 3, 4, 5, 6",
        "13:40",
        "15:40",
        {"red": 128, "blue": 128, "type": "colour", "green": 128},
        4));
  });

  /// tests if does not add if no trigger, no operator if sensor chosen, set bulb brightness
  testWidgets(
      'does not add if no trigger, no operator if sensor chosen, set bulb brightness',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction(
            null,
            "sensor1",
            null,
            null,
            "driver2",
            "0, 1, 2, 3, 4, 5, 6",
            "13:40",
            "15:40",
            {"type": "brightness", "brightness": 50},
            4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "400"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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
        "category": "bulb",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Ustaw jasność").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    expect(find.text("Pole wymagane"), findsNWidgets(2));

    verifyNever(await mockApi.addAction(
        null,
        "sensor1",
        null,
        null,
        "driver2",
        "0, 1, 2, 3, 4, 5, 6",
        "13:40",
        "15:40",
        {"type": "brightness", "brightness": 50},
        4));
  });

  /// tests if does not add when api error
  testWidgets('does not add when api error', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "404"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Wciśnij przycisk").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('triggerValueOperator')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("< mniejsze niż").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder sensorTrigger = find.byKey(Key('sensorTrigger'));
    await tester.enterText(sensorTrigger, '5');
    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("< mniejsze niż"), findsOneWidget);
    expect(find.text("5"), findsOneWidget);
    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    expect(find.text("Dodawanie akcji nie powiodło się. Spróbuj ponownie."),
        findsOneWidget);

    verify(await mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 4))
        .called(1);
  });

  /// tests if does not add when action exists
  testWidgets('does not add when action exists', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 4))
        .thenAnswer((_) async => Future.value({
              "body": "Action with provided name already exists",
              "statusCode": "404"
            }));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Wciśnij przycisk").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('triggerValueOperator')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("< mniejsze niż").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder sensorTrigger = find.byKey(Key('sensorTrigger'));
    await tester.enterText(sensorTrigger, '5');
    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("< mniejsze niż"), findsOneWidget);
    expect(find.text("5"), findsOneWidget);
    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    expect(find.text("Akcja o podanej nazwie już istnieje."), findsOneWidget);

    verify(await mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 4))
        .called(1);
  });

  /// tests if adds action without sensor with time range, english
  testWidgets('english adds action without sensor with time range',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction('name', null, null, null, "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 2))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "201"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("General"), findsOneWidget);
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("Driver"), findsOneWidget);
    expect(find.text("Sensor"), findsOneWidget);
    expect(find.text("Action time"), findsOneWidget);
    expect(find.text("Mon"), findsOneWidget);
    expect(find.text("Tue"), findsOneWidget);
    expect(find.text("Wed"), findsOneWidget);
    expect(find.text("Thur"), findsOneWidget);
    expect(find.text("Fri"), findsOneWidget);
    expect(find.text("Sat"), findsOneWidget);
    expect(find.text("Sun"), findsOneWidget);
    expect(find.text("Start"), findsOneWidget);
    expect(find.text("End"), findsOneWidget);
    expect(find.text("Create action"), findsOneWidget);
    expect(find.text("Trigger on the sensor"), findsNothing);
    expect(find.text("Operator"), findsNothing);
    expect(find.text("Value"), findsNothing);

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Press the button").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.addAction('name', null, null, null, "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 2))
        .called(1);
  });

  /// tests if adds action with sensor with time range, english
  testWidgets('english, adds action with sensor with time range',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "201"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('triggerValueOperator')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Choose a comparison operator"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);
    expect(find.text("OK"), findsOneWidget);
    expect(find.text("< smaller than"), findsOneWidget);
    expect(find.text("> larger than"), findsOneWidget);
    expect(find.text("= equal to"), findsOneWidget);
    await tester.tap(find.text("< smaller than").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder sensorTrigger = find.byKey(Key('sensorTrigger'));
    await tester.enterText(sensorTrigger, '5');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Press the button").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("< smaller than"), findsOneWidget);
    expect(find.text("5"), findsOneWidget);
    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 4))
        .called(1);
  });

  /// tests if does not add if no name, no driver, english
  testWidgets('english, does not add if no name, no driver',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction(null, null, null, null, null, "0, 1, 2, 3, 4, 5, 6",
            "13:40", "15:40", {"status": "on"}, 2))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "400"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    expect(find.text("Required field"), findsNWidgets(3));

    verifyNever(await mockApi.addAction(null, null, null, null, null,
        "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 2));
  });

  /// tests if does not add if no trigger, no operator if sensor chosen, english
  testWidgets(
      'english does not add if no trigger, no operator if sensor chosen',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction(null, "sensor1", null, null, "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "400"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Press the button").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    expect(find.text("Required field"), findsNWidgets(2));

    verifyNever(await mockApi.addAction(null, "sensor1", null, null, "driver2",
        "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 4));
  });

  /// tests if does not add when api error, english
  testWidgets('english does not add when api error',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "404"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('triggerValueOperator')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("< smaller than").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder sensorTrigger = find.byKey(Key('sensorTrigger'));
    await tester.enterText(sensorTrigger, '5');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Press the button").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("< smaller than"), findsOneWidget);
    expect(find.text("5"), findsOneWidget);
    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    expect(find.text("Creating action failed. Try again."), findsOneWidget);

    verify(await mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 4))
        .called(1);
  });

  /// tests if does not add when action exists, english
  testWidgets('english does not add when action exists',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 4))
        .thenAnswer((_) async => Future.value({
              "body": "Action with provided name already exists",
              "statusCode": "404"
            }));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Press the button").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('triggerValueOperator')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("< smaller than").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder sensorTrigger = find.byKey(Key('sensorTrigger'));
    await tester.enterText(sensorTrigger, '5');
    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("< smaller than"), findsOneWidget);
    expect(find.text("5"), findsOneWidget);
    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    expect(find.text("An action with the given name already exists."),
        findsOneWidget);

    verify(await mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 4))
        .called(1);
  });

  /// tests if adds action with sensor with time range, raise blinds, english
  testWidgets('english adds action with sensor with time range, raise blinds',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "201"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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
        "category": "roller_blind",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('triggerValueOperator')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Choose a comparison operator"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);
    expect(find.text("OK"), findsOneWidget);
    expect(find.text("< smaller than"), findsOneWidget);
    expect(find.text("> larger than"), findsOneWidget);
    expect(find.text("= equal to"), findsOneWidget);
    await tester.tap(find.text("< smaller than").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder sensorTrigger = find.byKey(Key('sensorTrigger'));
    await tester.enterText(sensorTrigger, '5');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Raise blinds").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("< smaller than"), findsOneWidget);
    expect(find.text("5"), findsOneWidget);
    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "on"}, 4))
        .called(1);
  });

  /// tests if adds action with sensor with time range, lower blinds, english
  testWidgets('english adds action with sensor with time range, lower blinds',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "off"}, 4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "201"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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
        "category": "roller_blind",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('triggerValueOperator')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("< smaller than").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder sensorTrigger = find.byKey(Key('sensorTrigger'));
    await tester.enterText(sensorTrigger, '5');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Lower blinds").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("< smaller than"), findsOneWidget);
    expect(find.text("5"), findsOneWidget);
    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.addAction('name', "sensor1", 5, "<", "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", {"status": "off"}, 4))
        .called(1);
  });

  /// tests if adds action with sensor, turn on bulb, english
  testWidgets('english adds action with sensor, turn on bulb',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction(
            'name',
            "sensor1",
            5.0,
            "<",
            "driver2",
            "0, 1, 2, 3, 4, 5, 6",
            "13:40",
            "15:40",
            {"type": "turn", "status": "on"},
            4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "201"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "bulb",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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
        "category": "bulb",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('triggerValueOperator')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("< smaller than").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Turn bulb on").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    Finder sensorTrigger = find.byKey(Key('sensorTrigger'));
    await tester.enterText(sensorTrigger, '5');

    expect(find.text("Trigger on the sensor"), findsOneWidget);
    expect(find.text("Operator"), findsOneWidget);
    expect(find.text("Value"), findsOneWidget);

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("< smaller than"), findsOneWidget);
    expect(find.text("5"), findsOneWidget);
    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.addAction(
            'name',
            "sensor1",
            5.0,
            "<",
            "driver2",
            "0, 1, 2, 3, 4, 5, 6",
            "13:40",
            "15:40",
            {"type": "turn", "status": "on"},
            4))
        .called(1);
  });

  /// tests if does not add if no trigger, no operator if sensor chosen, turn off bulb, english
  testWidgets(
      'english, does not add if no trigger, no operator if sensor chosen, turn off bulb',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction(
            null,
            "sensor1",
            null,
            null,
            "driver2",
            "0, 1, 2, 3, 4, 5, 6",
            "13:40",
            "15:40",
            {"type": "turn", "status": "off"},
            4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "400"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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
        "category": "bulb",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Turn bulb off").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    expect(find.text("Required field"), findsNWidgets(2));

    verifyNever(await mockApi.addAction(
        null,
        "sensor1",
        null,
        null,
        "driver2",
        "0, 1, 2, 3, 4, 5, 6",
        "13:40",
        "15:40",
        {"type": "turn", "status": "off"},
        4));
  });

  /// tests if does not add if no trigger, no operator if sensor chosen, set bulb color, ensligh
  testWidgets(
      'english does not add if no trigger, no operator if sensor chosen, set bulb color',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction(
            null,
            "sensor1",
            null,
            null,
            "driver2",
            "0, 1, 2, 3, 4, 5, 6",
            "13:40",
            "15:40",
            {"red": 128, "blue": 128, "type": "colour", "green": 128},
            4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "400"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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
        "category": "bulb",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Set color").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    expect(find.text("Required field"), findsNWidgets(2));

    verifyNever(await mockApi.addAction(
        null,
        "sensor1",
        null,
        null,
        "driver2",
        "0, 1, 2, 3, 4, 5, 6",
        "13:40",
        "15:40",
        {"red": 128, "blue": 128, "type": "colour", "green": 128},
        4));
  });

  /// tests if does not add if no trigger, no operator if sensor chosen, set bulb brightness, english
  testWidgets(
      'english does not add if no trigger, no operator if sensor chosen, set bulb brightness',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction(
            null,
            "sensor1",
            null,
            null,
            "driver2",
            "0, 1, 2, 3, 4, 5, 6",
            "13:40",
            "15:40",
            {"type": "brightness", "brightness": 50},
            4))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "400"}));

    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

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
        "category": "bulb",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);

    await tester.tap(find.byKey(Key('driverAction')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("Set brightness").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    expect(find.text("Required field"), findsNWidgets(2));

    verifyNever(await mockApi.addAction(
        null,
        "sensor1",
        null,
        null,
        "driver2",
        "0, 1, 2, 3, 4, 5, 6",
        "13:40",
        "15:40",
        {"type": "brightness", "brightness": 50},
        4));
  });
}
