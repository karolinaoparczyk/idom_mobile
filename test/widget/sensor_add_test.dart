import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/pages/sensors/new_sensor.dart';
import 'package:idom/pages/sensors/sensors.dart';
import 'package:idom/models.dart';
import 'package:idom/api.dart';

class MockApi extends Mock implements Api {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(home: child);
  }

  /// tests if does not save with empty name and category
  testWidgets(
      'name, category, frequency value and frequency units empty, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', null, "token")).thenAnswer(
        (_) async => Future.value({"bodySen": '"id": 3', "statusCodeSen": "201"}));
    when(mockApi.addFrequency(3, 7200, "token")).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "201"}));
    List<Sensor> sensors = List();
    sensors.add(Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        batteryLevel: null,
        notifications: true,
        lastData: "27.0"));
    sensors.add(Sensor(
        id: 2,
        name: "sensor2",
        category: "temperature",
        batteryLevel: null,
        notifications: true,
        lastData: "27.0"));

    Sensors page = Sensors(
      currentLoggedInToken: "token",
      currentLoggedInUsername: "username",
      api: mockApi,
      testSensors: sensors,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(Key('Dodaj czujnik')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(NewSensor), findsOneWidget);
    expect(find.text("Brak danych"), findsOneWidget);
    expect(
        find.text(
            "Wybierz kategorię czujnika. \nWybierz jednotski częstotliwości pobierania danych."),
        findsOneWidget);
    await tester.tap(find.byKey(Key('ok button')));
    await tester.pump();
    expect(find.text("Podaj nazwę"), findsOneWidget);
    expect(find.text("Podaj wartość"), findsOneWidget);

    verifyNever(await mockApi.addSensor("", null, "token"));
    verifyNever(await mockApi.addFrequency(3, null, "token"));
  });

  /// tests if does not save with only name
  testWidgets('only name, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', null, "token")).thenAnswer(
        (_) async => Future.value({"bodySen": '"id": 3', "statusCodeSen": "201"}));
    when(mockApi.addFrequency(3, 7200, "token")).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "201"}));
    List<Sensor> sensors = List();
    sensors.add(Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        batteryLevel: null,
        notifications: true,
        lastData: "27.0"));
    sensors.add(Sensor(
        id: 2,
        name: "sensor2",
        category: "temperature",
        batteryLevel: null,
        notifications: true,
        lastData: "27.0"));

    Sensors page = Sensors(
      currentLoggedInToken: "token",
      currentLoggedInUsername: "username",
      api: mockApi,
      testSensors: sensors,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'sensor');

    await tester.tap(find.byKey(Key('Dodaj czujnik')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(NewSensor), findsOneWidget);
    expect(find.text("Brak danych"), findsOneWidget);
    expect(
        find.text(
            "Wybierz kategorię czujnika. \nWybierz jednotski częstotliwości pobierania danych."),
        findsOneWidget);
    await tester.tap(find.byKey(Key('ok button')));
    await tester.pump();
    expect(find.text("Podaj wartość"), findsOneWidget);

    verifyNever(await mockApi.addSensor('sensor', null, "token"));
    verifyNever(await mockApi.addFrequency(3, null, "token"));
  });

  /// tests if does not save with only category
  testWidgets('only category, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', "humidity", "token")).thenAnswer(
        (_) async => Future.value({"bodySen": '"id": 3', "statusCodeSen": "201"}));
    when(mockApi.addFrequency(3, 7200, "token")).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "201"}));
    List<Sensor> sensors = List();
    sensors.add(Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        batteryLevel: null,
        notifications: true,
        lastData: "27.0"));
    sensors.add(Sensor(
        id: 2,
        name: "sensor2",
        category: "temperature",
        batteryLevel: null,
        notifications: true,
        lastData: "27.0"));

    Sensors page = Sensors(
      currentLoggedInToken: "token",
      currentLoggedInUsername: "username",
      api: mockApi,
      testSensors: sensors,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('categoriesButon')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("Wilgotność").last);
    await tester.pump();

    await tester.tap(find.byKey(Key('Dodaj czujnik')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(NewSensor), findsOneWidget);
    expect(find.text("Brak danych"), findsOneWidget);
    expect(find.text("Wybierz jednotski częstotliwości pobierania danych."),
        findsOneWidget);
    await tester.tap(find.byKey(Key('ok button')));
    await tester.pump();
    expect(find.text("Podaj nazwę"), findsOneWidget);
    verifyNever(await mockApi.addSensor(null, 'humidity', "token"));
    verifyNever(await mockApi.addFrequency(3, null, "token"));
  });

  /// tests if saves with name, category, frequency value and frequency units
  testWidgets(
      'non empty name, category, frequency value and frequency units, saves',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', 'humidity', "token")).thenAnswer(
        (_) async => Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
    when(mockApi.addFrequency(3, 7200, "token")).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "201"}));
    List<Sensor> sensors = List();
    sensors.add(Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        batteryLevel: null,
        notifications: true,
        lastData: "27.0"));
    sensors.add(Sensor(
        id: 2,
        name: "sensor2",
        category: "temperature",
        batteryLevel: null,
        notifications: true,
        lastData: "27.0"));

    Sensors page = Sensors(
      currentLoggedInToken: "token",
      currentLoggedInUsername: "username",
      api: mockApi,
      testSensors: sensors,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'sensor');

    await tester.tap(find.byKey(Key('categoriesButon')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("Wilgotność").last);
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '2');

    await tester.tap(find.byKey(Key('unitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("Godziny").last);
    await tester.pump();

    await tester.tap(find.byKey(Key('Dodaj czujnik')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(Sensors), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);

    verify(await mockApi.addSensor('sensor', 'humidity', "token")).called(1);
    verify(await mockApi.addFrequency(3, 7200, "token")).called(1);
  });

  /// tests if does not save when name exists
  testWidgets('valid data, name exists, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', "humidity", 'token')).thenAnswer(
        (_) async => Future.value({
              "bodySen": '{"name":["Sensor with provided name already exists"]}',
              "statusCodeSen": "400"
            }));
    when(mockApi.addFrequency(3, 7200, "token")).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "201"}));
    List<Sensor> sensors = List();
    sensors.add(Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        batteryLevel: null,
        notifications: true,
        lastData: "27.0"));
    sensors.add(Sensor(
        id: 2,
        name: "sensor2",
        category: "temperature",
        batteryLevel: null,
        notifications: true,
        lastData: "27.0"));

    Sensors page = Sensors(
      currentLoggedInToken: "token",
      currentLoggedInUsername: "username",
      api: mockApi,
      testSensors: sensors,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pumpAndSettle();

    Finder usernameField = find.byKey(Key('name'));
    await tester.enterText(usernameField, 'sensor');

    await tester.tap(find.byKey(Key('categoriesButon')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("Wilgotność").last);
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '2');

    await tester.tap(find.byKey(Key('unitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("Godziny").last);
    await tester.pump();

    await tester.tap(find.byKey(Key('Dodaj czujnik')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byKey(Key("ok button")), findsOneWidget);
    expect(find.text("Czujnik o podanej nazwie już istnieje."), findsOneWidget);
    expect(find.byType(NewSensor), findsOneWidget);

    verify(await mockApi.addSensor('sensor', "humidity", 'token')).called(1);
    verifyNever(await mockApi.addFrequency(3, 7200, "token"));
  });

  /// tests if does not save when frequency value not valid
  testWidgets('frequency value not valid, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', "humidity", 'token')).thenAnswer(
        (_) async => Future.value({"bodySen": '"id": 3', "statusCodeSen": "201"}));
    when(mockApi.addFrequency(3, 0, "token")).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "400"}));
    List<Sensor> sensors = List();
    sensors.add(Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        batteryLevel: null,
        notifications: true,
        lastData: "27.0"));
    sensors.add(Sensor(
        id: 2,
        name: "sensor2",
        category: "temperature",
        batteryLevel: null,
        notifications: true,
        lastData: "27.0"));

    Sensors page = Sensors(
      currentLoggedInToken: "token",
      currentLoggedInUsername: "username",
      api: mockApi,
      testSensors: sensors,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pumpAndSettle();

    Finder usernameField = find.byKey(Key('name'));
    await tester.enterText(usernameField, 'sensor');

    await tester.tap(find.byKey(Key('categoriesButon')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("Wilgotność").last);
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '0');

    await tester.tap(find.byKey(Key('unitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("Godziny").last);
    await tester.pump();

    await tester.tap(find.byKey(Key('Dodaj czujnik')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(NewSensor), findsOneWidget);
    expect(find.text("Błąd"), findsOneWidget);
    expect(find.text("Poprawne wartości dla jednostki: godziny to: 1 - 596523"),
        findsOneWidget);
    await tester.tap(find.byKey(Key('ok button')));
    await tester.pump();

    verifyNever(await mockApi.addSensor('sensor', "humidity", 'token'));
    verifyNever(await mockApi.addFrequency(3, 0, "token"));
  });
}
