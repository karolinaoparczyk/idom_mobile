import 'dart:convert';

import 'package:idom/models.dart';
import 'package:idom/pages/sensors/sensor_details.dart';
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

  /// tests if displays air temperature sensor
  testWidgets('displays air temperature sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData("token", 1)).thenAnswer(
            (_) async => Future.value({"body": "[]", "statusCode": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0");


    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    SensorDetails page = SensorDetails(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    Map<String, dynamic> sensorJson = {
      "id": 1,
      "name": "sensor1",
      "category": "temperature",
      "frequency": 300,
      'last_data': "27.0"
    };

    when(mockApi.getSensorDetails(1, "token")).thenAnswer(
            (_) async => Future.value({"body": jsonEncode(sensorJson), "statusCode": "200"}));

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("temperatura powietrza"), findsOneWidget);
    expect(find.text("300"), findsOneWidget);
    expect(find.text("sekund"), findsOneWidget);
    expect(find.text("Aktualna temperatura"), findsOneWidget);
    expect(find.text("27.0 °C"), findsOneWidget);
  });

  /// tests if displays water temperature sensor
  testWidgets('displays water temperature sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData("token", 1)).thenAnswer(
            (_) async => Future.value({"body": "[]", "statusCode": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "water_temp",
        frequency: 30,
        lastData: "27.0");


    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    SensorDetails page = SensorDetails(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    Map<String, dynamic> sensorJson = {
      "id": 1,
      "name": "sensor1",
      "category": "water_temp",
      "frequency": 30,
      'last_data': "27.0"
    };

    when(mockApi.getSensorDetails(1, "token")).thenAnswer(
            (_) async => Future.value({"body": jsonEncode(sensorJson), "statusCode": "200"}));

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("temperatura wody"), findsOneWidget);
    expect(find.text("30"), findsOneWidget);
    expect(find.text("sekund"), findsOneWidget);
    expect(find.text("Aktualna temperatura"), findsOneWidget);
    expect(find.text("27.0 °C"), findsOneWidget);
  });

  /// tests if displays rain sensor
  testWidgets('displays rain sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData("token", 1)).thenAnswer(
            (_) async => Future.value({"body": "[]", "statusCode": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "rain_sensor",
        frequency: 30,
        lastData: "27.0");


    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    SensorDetails page = SensorDetails(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    Map<String, dynamic> sensorJson = {
      "id": 1,
      "name": "sensor1",
      "category": "rain_sensor",
      "frequency": 30,
      'last_data': "27.0"
    };

    when(mockApi.getSensorDetails(1, "token")).thenAnswer(
            (_) async => Future.value({"body": jsonEncode(sensorJson), "statusCode": "200"}));

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("opady atmosferyczne"), findsOneWidget);
    expect(find.text("30"), findsOneWidget);
    expect(find.text("sekund"), findsOneWidget);
    expect(find.text("Aktualna temperatura"), findsNothing);
    expect(find.text("27.0 °C"), findsNothing);
  });

  /// tests if displays humidity sensor
  testWidgets('displays humidity sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData("token", 1)).thenAnswer(
            (_) async => Future.value({"body": "[]", "statusCode": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "humidity",
        frequency: 300,
        lastData: "27.0");


    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    SensorDetails page = SensorDetails(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    Map<String, dynamic> sensorJson = {
      "id": 1,
      "name": "sensor1",
      "category": "humidity",
      "frequency": 300,
      'last_data': "27.0"
    };

    when(mockApi.getSensorDetails(1, "token")).thenAnswer(
            (_) async => Future.value({"body": jsonEncode(sensorJson), "statusCode": "200"}));

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("wilgotność"), findsOneWidget);
    expect(find.text("300"), findsOneWidget);
    expect(find.text("sekund"), findsOneWidget);
    expect(find.text("Aktualna wilgotność"), findsOneWidget);
    expect(find.text("27.0 %"), findsOneWidget);
  });

  /// tests if displays breathalyser sensor
  testWidgets('displays breathalyser sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData("token", 1)).thenAnswer(
            (_) async => Future.value({"body": "[]", "statusCode": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "breathalyser",
        frequency: 30,
        lastData: "1.0");


    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    SensorDetails page = SensorDetails(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    Map<String, dynamic> sensorJson = {
      "id": 1,
      "name": "sensor1",
      "category": "breathalyser",
      "frequency": 30,
      'last_data': "1.0"
    };

    when(mockApi.getSensorDetails(1, "token")).thenAnswer(
            (_) async => Future.value({"body": jsonEncode(sensorJson), "statusCode": "200"}));

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("alkomat"), findsOneWidget);
    expect(find.text("30"), findsNothing);
    expect(find.text("sekund"), findsNothing);
    expect(find.text("Ostatni pomiar"), findsOneWidget);
    expect(find.text("1.0 ‰"), findsOneWidget);
  });
      /// tests if displays smoke correctly
      testWidgets('displays smoke correctly', (WidgetTester tester) async {
        MockApi mockApi = MockApi();

        MockSecureStorage mockSecureStorage = MockSecureStorage();
        when(mockSecureStorage.getToken()).thenAnswer(
                (_) async => Future.value("token"));
        when(mockSecureStorage.resetUserData()).thenAnswer(
                (_) async => Future.value());

        List<Sensor> sensors = List();
        sensors.add(Sensor(
            id: 1,
            name: "sensor1",
            category: "smoke",
            frequency: null,
            lastData: null));
        sensors.add(Sensor(
            id: 2,
            name: "sensor2",
            category: "temperature",
            frequency: 300,
            lastData: "27.0"));

        Sensors page = Sensors(
          storage: mockSecureStorage,
          testApi: mockApi,
          testSensors: sensors,
        );

        await tester.pumpWidget(makeTestableWidget(child: page));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key('sensor1')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(SensorDetails), findsOneWidget);
        expect(find.text("Dane z czujnika"), findsNothing);

        verifyNever(await mockApi.editSensor(1, '', null, null, "token"));
      });
}