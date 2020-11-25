import 'dart:convert';

import 'package:idom/pages/data_download/data_download.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';

class MockApi extends Mock implements Api {}

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  /// tests if chooses data filter with sensors, without days and filling in days
  testWidgets(
      'choose data filter with sensors, without days and filling in days',
      (WidgetTester tester) async {
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
      },
      {
        "id": 2,
        "name": "sensor3",
        "category": "humidity",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor4",
        "category": "smoke",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
    when(mockApi.generateFile(["1", "2"], null, 20))
        .thenAnswer((_) async => Future.value({"body": "", "statusCode": 200}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DataDownload page = DataDownload(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Uzupełnij filtry, aby wygenerować plik .csv z danymi"),
        findsOneWidget);

    await tester.tap(find.byKey(Key("addSensors")));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.text("sensor2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("sensor2"), findsOneWidget);
    expect(find.text("sensor3"), findsNothing);
    expect(find.text("sensor4"), findsNothing);

    await tester.tap(find.byKey(Key("Generuj plik")));
    await tester.pump();
    expect(find.text("Pole wymagane"), findsOneWidget);
    verifyNever(await mockApi.generateFile(["1", "2"], null, null));

    Finder emailField = find.byKey(Key('lastDaysAmountButton'));
    await tester.enterText(emailField, '20');
    await tester.tap(find.byKey(Key("Generuj plik")));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.generateFile(["1", "2"], null, 20)).called(1);
  });

  /// tests if chooses data filter with categories
  testWidgets('choose data filter with categories',
      (WidgetTester tester) async {
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
      },
      {
        "id": 2,
        "name": "sensor3",
        "category": "humidity",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor4",
        "category": "smoke",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DataDownload page = DataDownload(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Uzupełnij filtry, aby wygenerować plik .csv z danymi"),
        findsOneWidget);

    await tester.tap(find.byKey(Key("addCategories")));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("temperatura powietrza").last);
    await tester.tap(find.text("temperatura wody").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text("temperatura powietrza"), findsOneWidget);
    expect(find.text("temperatura wody"), findsOneWidget);
    expect(find.text("opady atmosferyczne"), findsNothing);
    expect(find.text("wilgotność gleby"), findsNothing);
  });

  /// tests if cannot choose categories if sensors are chosen
  testWidgets('cannot choose categories if sensors are chosen',
      (WidgetTester tester) async {
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
      },
      {
        "id": 2,
        "name": "sensor3",
        "category": "humidity",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor4",
        "category": "smoke",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DataDownload page = DataDownload(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Uzupełnij filtry, aby wygenerować plik .csv z danymi"),
        findsOneWidget);

    await tester.tap(find.byKey(Key("addSensors")));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.text("sensor2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("sensor2"), findsOneWidget);
    expect(find.text("sensor3"), findsNothing);
    expect(find.text("sensor4"), findsNothing);

    await tester.tap(find.byKey(Key("addCategories")));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("temperatura powietrza"), findsNothing);
    expect(find.text("temperatura wody"), findsNothing);
    expect(find.text("opady atmosferyczne"), findsNothing);
    expect(find.text("wilgotność gleby"), findsNothing);
    expect(find.text("Usuń wybrane czujniki, aby wybrać kategorie."),
        findsOneWidget);

    await tester.tap(find.byKey(Key("deleteSensors")));
    await tester.tap(find.byKey(Key("addCategories")));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("temperatura powietrza").last);
    await tester.tap(find.text("temperatura wody").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text("Usuń wybrane czujniki, aby wybrać kategorie."),
        findsNothing);
    expect(find.text("temperatura powietrza"), findsOneWidget);
    expect(find.text("temperatura wody"), findsOneWidget);
    expect(find.text("opady atmosferyczne"), findsNothing);
    expect(find.text("wilgotność gleby"), findsNothing);
  });

  /// tests if cannot choose sensors if categories are chosen
  testWidgets('cannot choose sensors if categories are chosen',
      (WidgetTester tester) async {
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
      },
      {
        "id": 2,
        "name": "sensor3",
        "category": "humidity",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor4",
        "category": "smoke",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DataDownload page = DataDownload(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Uzupełnij filtry, aby wygenerować plik .csv z danymi"),
        findsOneWidget);

    await tester.tap(find.byKey(Key("addCategories")));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("temperatura powietrza").last);
    await tester.tap(find.text("temperatura wody").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text("temperatura powietrza"), findsOneWidget);
    expect(find.text("temperatura wody"), findsOneWidget);
    expect(find.text("opady atmosferyczne"), findsNothing);
    expect(find.text("wilgotność gleby"), findsNothing);

    await tester.tap(find.byKey(Key("addSensors")));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("sensor1"), findsNothing);
    expect(find.text("sensor2"), findsNothing);
    expect(find.text("sensor3"), findsNothing);
    expect(find.text("sensor4"), findsNothing);
    expect(find.text("Usuń wybrane kategorie, aby wybrać czujniki."),
        findsOneWidget);

    await tester.tap(find.byKey(Key("deleteCategories")));
    await tester.tap(find.byKey(Key("addSensors")));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.text("sensor2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text("Usuń wybrane kategorie, aby wybrać czujniki."),
        findsNothing);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("sensor2"), findsOneWidget);
    expect(find.text("sensor3"), findsNothing);
    expect(find.text("sensor4"), findsNothing);
  });
}
