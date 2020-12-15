import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/actions/edit_action.dart';
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

  /// tests if does not edit when no change
  testWidgets('does not edit when no change', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    var body = {
      "name": null,
      "sensor": null,
      "trigger": null,
      "operator": null,
      "driver": null,
      "days": null,
      "action": null,
      "flag": null,
      "start_event": null,
      "end_event": null,
    };
    when(mockApi.editAction(1, body)).thenAnswer(
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
        "ip_address": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ip_address": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: "sensor2",
      trigger: "30",
      operator: "=",
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 4,
      driver: "driver1",
      startTime: "13:20",
      endTime: "16:40",
      action: "action",
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditAction page = EditAction(
      storage: mockSecureStorage,
      action: action,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("Sterownik"), findsOneWidget);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("Czujnik"), findsOneWidget);
    expect(find.text("sensor2"), findsOneWidget);
    expect(find.text("Czas działania akcji"), findsOneWidget);
    expect(find.text("pn"), findsOneWidget);
    expect(find.text("wt"), findsOneWidget);
    expect(find.text("śr"), findsOneWidget);
    expect(find.text("czw"), findsOneWidget);
    expect(find.text("pt"), findsOneWidget);
    expect(find.text("sb"), findsOneWidget);
    expect(find.text("nd"), findsOneWidget);
    expect(find.text("Start"), findsOneWidget);
    expect(find.text("13:20"), findsOneWidget);
    expect(find.text("16:40"), findsOneWidget);
    expect(find.text("Koniec"), findsOneWidget);
    expect(find.text("Edytuj akcję"), findsOneWidget);
    expect(find.text("Wyzwalacz na czujniku"), findsOneWidget);
    expect(find.text("= równe"), findsOneWidget);
    expect(find.text("Operator"), findsOneWidget);
    expect(find.text("30"), findsOneWidget);
    expect(find.text("Wartość"), findsOneWidget);

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pump();
    expect(find.text("Nie wprowadzono żadnych zmian."), findsOneWidget);
    verifyNever(await mockApi.editAction(1, body));
  });

  /// tests if edits name, no sensor
  testWidgets('edits name, no sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    var body = {
      "name": "newname",
    };
    when(mockApi.editAction(1, body)).thenAnswer(
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
        "ip_address": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ip_address": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: null,
      trigger: null,
      operator: null,
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 2,
      driver: "driver1",
      startTime: "13:20",
      endTime: "16:40",
      action: "action",
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditAction page = EditAction(
      storage: mockSecureStorage,
      action: action,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("Sterownik"), findsOneWidget);
    expect(find.text("driver1"), findsOneWidget);
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
    expect(find.text("13:20"), findsOneWidget);
    expect(find.text("16:40"), findsOneWidget);
    expect(find.text("Koniec"), findsOneWidget);
    expect(find.text("Edytuj akcję"), findsOneWidget);
    expect(find.text("Wyzwalacz na czujniku"), findsNothing);
    expect(find.text("Operator"), findsNothing);
    expect(find.text("Wartość"), findsNothing);

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'newname');
    await tester.pump();

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();
    expect(find.text("Potwierdź"), findsOneWidget);
    expect(find.text("Czy na pewno zapisać zmiany?"), findsOneWidget);
    expect(find.text("Tak"), findsOneWidget);
    expect(find.text("Nie"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    verify(await mockApi.editAction(1, body)).called(1);
  });

  /// tests if does not edit name when action exists
  testWidgets('does not edit name when action exists', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    var body = {
      "name": "newname",
    };
    when(mockApi.editAction(1, body)).thenAnswer(
        (_) async => Future.value({"body": "Action with provided name already exists", "statusCode": "400"}));

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
        "ip_address": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ip_address": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: null,
      trigger: null,
      operator: null,
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 2,
      driver: "driver1",
      startTime: "13:20",
      endTime: "16:40",
      action: "action",
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditAction page = EditAction(
      storage: mockSecureStorage,
      action: action,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'newname');
    await tester.pump();

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.text("Akcja o podanej nazwie już istnieje."), findsOneWidget);
    verify(await mockApi.editAction(1, body)).called(1);
  });

  /// tests if edits driver, with sensor
  testWidgets('edits driver, with sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    var body = {
      "driver": "driver2",
    };
    when(mockApi.editAction(1, body)).thenAnswer(
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
        "ip_address": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ip_address": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: "sensor1",
      trigger: "30",
      operator: "=",
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 4,
      driver: "driver1",
      startTime: "13:20",
      endTime: "16:40",
      action: "action",
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditAction page = EditAction(
      storage: mockSecureStorage,
      action: action,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("Sterownik"), findsOneWidget);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("Czujnik"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("Czas działania akcji"), findsOneWidget);
    expect(find.text("pn"), findsOneWidget);
    expect(find.text("wt"), findsOneWidget);
    expect(find.text("śr"), findsOneWidget);
    expect(find.text("czw"), findsOneWidget);
    expect(find.text("pt"), findsOneWidget);
    expect(find.text("sb"), findsOneWidget);
    expect(find.text("nd"), findsOneWidget);
    expect(find.text("Start"), findsOneWidget);
    expect(find.text("13:20"), findsOneWidget);
    expect(find.text("16:40"), findsOneWidget);
    expect(find.text("Koniec"), findsOneWidget);
    expect(find.text("Edytuj akcję"), findsOneWidget);
    expect(find.text("Wyzwalacz na czujniku"), findsOneWidget);
    expect(find.text("= równe"), findsOneWidget);
    expect(find.text("Operator"), findsOneWidget);
    expect(find.text("30"), findsOneWidget);
    expect(find.text("Wartość"), findsOneWidget);

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();
    expect(find.text("Potwierdź"), findsOneWidget);
    expect(find.text("Czy na pewno zapisać zmiany?"), findsOneWidget);
    expect(find.text("Tak"), findsOneWidget);
    expect(find.text("Nie"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    verify(await mockApi.editAction(1, body)).called(1);
  });

  /// tests if edits sensor, trigger and operator
  testWidgets('edits sensor, trigger and operator', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    var body = {
      "sensor": "sensor2",
      "trigger": 5,
      "operator": "<",
    };
    when(mockApi.editAction(1, body)).thenAnswer(
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
        "ip_address": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ip_address": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: "sensor1",
      trigger: "30",
      operator: "=",
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 4,
      driver: "driver1",
      startTime: "13:20",
      endTime: "16:40",
      action: "action",
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditAction page = EditAction(
      storage: mockSecureStorage,
      action: action,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("Sterownik"), findsOneWidget);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("Czujnik"), findsOneWidget);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("Czas działania akcji"), findsOneWidget);
    expect(find.text("pn"), findsOneWidget);
    expect(find.text("wt"), findsOneWidget);
    expect(find.text("śr"), findsOneWidget);
    expect(find.text("czw"), findsOneWidget);
    expect(find.text("pt"), findsOneWidget);
    expect(find.text("sb"), findsOneWidget);
    expect(find.text("nd"), findsOneWidget);
    expect(find.text("Start"), findsOneWidget);
    expect(find.text("13:20"), findsOneWidget);
    expect(find.text("16:40"), findsOneWidget);
    expect(find.text("Koniec"), findsOneWidget);
    expect(find.text("Edytuj akcję"), findsOneWidget);
    expect(find.text("Wyzwalacz na czujniku"), findsOneWidget);
    expect(find.text("= równe"), findsOneWidget);
    expect(find.text("Operator"), findsOneWidget);
    expect(find.text("30"), findsOneWidget);
    expect(find.text("Wartość"), findsOneWidget);

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("sensor2"), findsOneWidget);

    await tester.tap(find.byKey(Key('triggerValueOperator')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Wybierz operator porównania"), findsOneWidget);
    expect(find.text("Anuluj"), findsOneWidget);
    expect(find.text("OK"), findsOneWidget);
    expect(find.text("< mniejsze niż"), findsOneWidget);
    expect(find.text("> większe niż"), findsOneWidget);
    expect(find.text("= równe"), findsNWidgets(2));
    await tester.tap(find.text("< mniejsze niż").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("< mniejsze niż"), findsOneWidget);

    Finder sensorTrigger = find.byKey(Key('sensorTrigger'));
    await tester.enterText(sensorTrigger, '5');
    await tester.pumpAndSettle();

    expect(find.text("5"), findsOneWidget);

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();
    expect(find.text("Potwierdź"), findsOneWidget);
    expect(find.text("Czy na pewno zapisać zmiany?"), findsOneWidget);
    expect(find.text("Tak"), findsOneWidget);
    expect(find.text("Nie"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    verify(await mockApi.editAction(1, body)).called(1);
  });

  /// tests if no sensor, trigger operator, but visible when adds sensor
  testWidgets('no sensor, trigger operator, but visible when adds sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
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
        "ip_address": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ip_address": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: null,
      trigger: null,
      operator: null,
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 2,
      driver: "driver1",
      startTime: "13:20",
      endTime: "16:40",
      action: "action",
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditAction page = EditAction(
      storage: mockSecureStorage,
      action: action,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("Sterownik"), findsOneWidget);
    expect(find.text("driver1"), findsOneWidget);
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
    expect(find.text("13:20"), findsOneWidget);
    expect(find.text("16:40"), findsOneWidget);
    expect(find.text("Koniec"), findsOneWidget);
    expect(find.text("Edytuj akcję"), findsOneWidget);
    expect(find.text("Wyzwalacz na czujniku"), findsNothing);
    expect(find.text("Operator"), findsNothing);
    expect(find.text("Wartość"), findsNothing);

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("Wyzwalacz na czujniku"), findsOneWidget);
    expect(find.text("Operator"), findsOneWidget);
    expect(find.text("Wartość"), findsOneWidget);
  });


  /// tests if edits when removing end time, without sensor
  testWidgets('edits when removing end time, without sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    var body = {
      "flag": 1,
      "end_event": null,
    };
    when(mockApi.editAction(1, body)).thenAnswer(
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
        "ip_address": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ip_address": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: null,
      trigger: null,
      operator: null,
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 2,
      driver: "driver1",
      startTime: "13:20",
      endTime: "16:40",
      action: "action",
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    var testStartTime = "13:20";
    var testEndTime;

    EditAction page = EditAction(
        storage: mockSecureStorage,
        action: action,
        testApi: mockApi,
        testStartTime: testStartTime,
        testEndTime: testEndTime
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("16:40"), findsNothing);

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();
    expect(find.text("Potwierdź"), findsOneWidget);
    expect(find.text("Czy na pewno zapisać zmiany?"), findsOneWidget);
    expect(find.text("Tak"), findsOneWidget);
    expect(find.text("Nie"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    verify(await mockApi.editAction(1, body)).called(1);
  });

  /// tests if edits when removing end time, with sensor
  testWidgets('edits when removing end time, with sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    var body = {
      "flag": 3,
      "end_event": null,
    };
    when(mockApi.editAction(1, body)).thenAnswer(
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
        "ip_address": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ip_address": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: "sensor1",
      trigger: "30",
      operator: "=",
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 4,
      driver: "driver1",
      startTime: "13:20",
      endTime: "16:40",
      action: "action",
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    var testStartTime = "13:20";
    var testEndTime;

    EditAction page = EditAction(
        storage: mockSecureStorage,
        action: action,
        testApi: mockApi,
        testStartTime: testStartTime,
        testEndTime: testEndTime
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("16:40"), findsNothing);

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();
    expect(find.text("Potwierdź"), findsOneWidget);
    expect(find.text("Czy na pewno zapisać zmiany?"), findsOneWidget);
    expect(find.text("Tak"), findsOneWidget);
    expect(find.text("Nie"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    verify(await mockApi.editAction(1, body)).called(1);
  });

  /// tests if edits when adding end time, without sensor
  testWidgets('edits when adding end time, without sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    var body = {
      "flag": 2,
      "end_event": "16:40",
    };
    when(mockApi.editAction(1, body)).thenAnswer(
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
        "ip_address": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ip_address": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: null,
      trigger: null,
      operator: null,
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 1,
      driver: "driver1",
      startTime: "13:20",
      endTime: null,
      action: "action",
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    var testStartTime = "13:20";
    var testEndTime = "16:40";

    EditAction page = EditAction(
        storage: mockSecureStorage,
        action: action,
        testApi: mockApi,
        testStartTime: testStartTime,
        testEndTime: testEndTime
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("16:40"), findsOneWidget);

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();
    expect(find.text("Potwierdź"), findsOneWidget);
    expect(find.text("Czy na pewno zapisać zmiany?"), findsOneWidget);
    expect(find.text("Tak"), findsOneWidget);
    expect(find.text("Nie"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    verify(await mockApi.editAction(1, body)).called(1);
  });

  /// tests if edits when adding end time, with sensor
  testWidgets('edits when adding end time, with sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    var body = {
      "flag": 4,
      "end_event": "16:40",
    };
    when(mockApi.editAction(1, body)).thenAnswer(
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
        "ip_address": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ip_address": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: "sensor1",
      trigger: "30",
      operator: "=",
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 3,
      driver: "driver1",
      startTime: "13:20",
      endTime: null,
      action: "action",
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    var testStartTime = "13:20";
    var testEndTime = "16:40";

    EditAction page = EditAction(
        storage: mockSecureStorage,
        action: action,
        testApi: mockApi,
        testStartTime: testStartTime,
        testEndTime: testEndTime
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("16:40"), findsOneWidget);

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();
    expect(find.text("Potwierdź"), findsOneWidget);
    expect(find.text("Czy na pewno zapisać zmiany?"), findsOneWidget);
    expect(find.text("Tak"), findsOneWidget);
    expect(find.text("Nie"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    verify(await mockApi.editAction(1, body)).called(1);
  });

  /// tests if does not edit when no change, english
  testWidgets('english does not edit when no change', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    var body = {
      "name": null,
      "sensor": null,
      "trigger": null,
      "operator": null,
      "driver": null,
      "days": null,
      "action": null,
      "flag": null,
      "start_event": null,
      "end_event": null,
    };
    when(mockApi.editAction(1, body)).thenAnswer(
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
        "ip_address": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ip_address": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: "sensor2",
      trigger: "30",
      operator: "=",
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 4,
      driver: "driver1",
      startTime: "13:20",
      endTime: "16:40",
      action: "action",
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditAction page = EditAction(
      storage: mockSecureStorage,
      action: action,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("General"), findsOneWidget);
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("Driver"), findsOneWidget);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("Sensor"), findsOneWidget);
    expect(find.text("sensor2"), findsOneWidget);
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
    expect(find.text("Edit action"), findsOneWidget);
    expect(find.text("Trigger on the sensor"), findsOneWidget);
    expect(find.text("= equal to"), findsOneWidget);
    expect(find.text("Operator"), findsOneWidget);
    expect(find.text("30"), findsOneWidget);
    expect(find.text("Value"), findsOneWidget);

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pump();
    expect(find.text("No changes have been made."), findsOneWidget);
    verifyNever(await mockApi.editAction(1, body));
  });

  /// tests if does not edit name when action exists, english
  testWidgets('english does not edit name when action exists', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    var body = {
      "name": "newname",
    };
    when(mockApi.editAction(1, body)).thenAnswer(
            (_) async => Future.value({"body": "Action with provided name already exists", "statusCode": "400"}));

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
        "ip_address": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ip_address": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: null,
      trigger: null,
      operator: null,
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 2,
      driver: "driver1",
      startTime: "13:20",
      endTime: "16:40",
      action: "action",
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditAction page = EditAction(
      storage: mockSecureStorage,
      action: action,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'newname');
    await tester.pump();

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.text("An action with the given name already exists."), findsOneWidget);
    verify(await mockApi.editAction(1, body)).called(1);
  });

  /// tests if edits driver, with sensor, english
  testWidgets('english edits driver, with sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    var body = {
      "driver": "driver2",
    };
    when(mockApi.editAction(1, body)).thenAnswer(
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
        "ip_address": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ip_address": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: "sensor1",
      trigger: "30",
      operator: "=",
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 4,
      driver: "driver1",
      startTime: "13:20",
      endTime: "16:40",
      action: "action",
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditAction page = EditAction(
      storage: mockSecureStorage,
      action: action,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("driver2"), findsOneWidget);

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();
    expect(find.text("Confirm"), findsOneWidget);
    expect(find.text("Are you sure you want to save the changes?"), findsOneWidget);
    expect(find.text("Yes"), findsOneWidget);
    expect(find.text("No"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    verify(await mockApi.editAction(1, body)).called(1);
  });

  /// tests if edits sensor, trigger and operator, english
  testWidgets('english edits sensor, trigger and operator', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    var body = {
      "sensor": "sensor2",
      "trigger": 5,
      "operator": "<",
    };
    when(mockApi.editAction(1, body)).thenAnswer(
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
        "ip_address": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ip_address": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: "sensor1",
      trigger: "30",
      operator: "=",
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 4,
      driver: "driver1",
      startTime: "13:20",
      endTime: "16:40",
      action: "action",
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditAction page = EditAction(
      storage: mockSecureStorage,
      action: action,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('sensorsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("sensor2"), findsOneWidget);

    await tester.tap(find.byKey(Key('triggerValueOperator')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Choose a comparison operator"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);
    expect(find.text("OK"), findsOneWidget);
    expect(find.text("< smaller than"), findsOneWidget);
    expect(find.text("> larger than"), findsOneWidget);
    expect(find.text("= equal to"), findsNWidgets(2));
    await tester.tap(find.text("< smaller than").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("< smaller than"), findsOneWidget);

    Finder sensorTrigger = find.byKey(Key('sensorTrigger'));
    await tester.enterText(sensorTrigger, '5');
    await tester.pumpAndSettle();

    expect(find.text("5"), findsOneWidget);

    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    verify(await mockApi.editAction(1, body)).called(1);
  });
}
