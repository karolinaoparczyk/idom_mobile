import 'dart:convert';

import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/sensors/sensors.dart';
import 'package:weather_icons/weather_icons.dart';

class MockApi extends Mock implements Api {}

class MockSecureStorage extends Mock implements SecureStorage {}


void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  /// tests if sensors on list
  testWidgets('sensors on list', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    List<Sensor> sensors = List();
    sensors.add(Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0"));
    sensors.add(Sensor(
        id: 2,
        name: "sensor2",
        category: "temperature",
        frequency: 300,
        lastData: "27.0"));

    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 2);
    expect(find.text("27.0 °C"), findsNWidgets(2));
  });

  /// tests if deletes sensor after confirmation
  testWidgets('sensors on list, confirms, deletes',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    List<Sensor> sensors = List();
    sensors.add(Sensor(
        id: 1,
        name: "sensor1",
        category: "humidity",
        frequency: 300,
        lastData: "27.0"));
    sensors.add(Sensor(
        id: 2,
        name: "sensor2",
        category: "humidity",
        frequency: 300,
        lastData: "27.0"));

    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 2);
    expect(find.text("27.0 %"), findsNWidgets(2));

    await tester.tap(find.byType(FlatButton).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.deactivateSensor(1, "token")).called(1);
  });

  /// tests if does not delete sensor when no confirmation
  testWidgets('sensors on list, does not confirm, does not delete',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    List<Sensor> sensors = List();
    sensors.add(Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0"));
    sensors.add(Sensor(
        id: 2,
        name: "sensor2",
        category: "humidity",
        frequency: 300,
        lastData: "27.0"));

    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 2);
    expect(find.text("27.0 °C"), findsOneWidget);
    expect(find.text("27.0 %"), findsOneWidget);

    await tester.tap(find.byType(FlatButton).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('noButton')));
    await tester.pumpAndSettle();

    verifyNever(await mockApi.deactivateSensor(1, "token"));
  });

  /// tests eror message when api error
  testWidgets('sensors on list, api error, message to user',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.deactivateSensor(1, "token"))
        .thenAnswer((_) async => Future.value(404));
    List<Sensor> sensors = List();
    sensors.add(Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0"));
    sensors.add(Sensor(
        id: 2,
        name: "sensor2",
        category: "temperature",
        frequency: 300,
        lastData: "27.0"));

    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 2);

    await tester.tap(find.byType(FlatButton).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('ok button')));

    verify(await mockApi.deactivateSensor(1, "token")).called(1);
  });

  /// tests if icons displayed correctly
  testWidgets(
      'rain_sensor and air temperature icons displayed correctly',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        MockSecureStorage mockSecureStorage = MockSecureStorage();
        when(mockApi.addSensor('sensor', 'rain_sensor', 7200, "token")).thenAnswer(
                (_) async => Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
        List<Map<String, dynamic>> sensors = [{
          "id": 1,
          "name": "sensor1",
          "category": "temperature",
          "frequency": 300,
          "lastData": "27.0"},
          {
            "id": 2,
            "name": "sensor2",
            "category": "rain_sensor",
            "frequency": 300,
            "lastData": "27.0"},
          {
            "id": 2,
            "name": "sensor3",
            "category": "humidity",
            "frequency": 300,
            "lastData": "27.0"},
          {
            "id": 2,
            "name": "sensor4",
            "category": "smoke",
            "frequency": 300,
            "lastData": "27.0"}];
        when(mockApi.getSensors("token")).thenAnswer(
                (_) async => Future.value({"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

        when(mockSecureStorage.getToken())
            .thenAnswer((_) async => Future.value("token"));
        Sensors page = Sensors(
          storage: mockSecureStorage,
          testApi: mockApi,
        );

        await tester.pumpWidget(makeTestableWidget(child: page));
        await tester.pumpAndSettle();
        expect(find.byIcon(WeatherIcons.showers), findsOneWidget);
        expect(find.byIcon(WeatherIcons.thermometer), findsOneWidget);
        expect(find.byIcon(WeatherIcons.humidity), findsOneWidget);
        expect(find.byIcon(WeatherIcons.smog), findsOneWidget);
      });
}
