import 'package:idom/pages/sensors/edit_sensor.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idom/pages/sensors/sensors.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/models.dart';
import 'package:idom/api.dart';
import 'package:idom/pages/sensors/sensor_details.dart';

class MockApi extends Mock implements Api {}

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(home: child);
  }

  /// tests if does not save with empty name
  testWidgets('name is empty, does not save', (WidgetTester tester) async {
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
    await tester.tap(find.byKey(Key('sensor1')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SensorDetails), findsOneWidget);
    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, '');

    expect(find.text("Dane z czujnika"), findsOneWidget);
    expect(find.text("27.0 °C"), findsOneWidget);

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();

    expect(find.text("Podaj nazwę"), findsOneWidget);
    expect(find.byType(SensorDetails), findsOneWidget);
    verifyNever(await mockApi.editSensor(1, '', null, null, "token"));
  });

  /// tests if displays humidity correctly
  testWidgets('displays humidity correctly', (WidgetTester tester) async {
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
        category: "temperature",
        frequency: 300,
        lastData: "27.0"));

    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );
    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('sensor1')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SensorDetails), findsOneWidget);
    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, '');

    expect(find.text("Dane z czujnika"), findsOneWidget);
    expect(find.text("27.0 %"), findsOneWidget);

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pump();
    expect(find.text("Podaj nazwę"), findsOneWidget);
    expect(find.byType(SensorDetails), findsOneWidget);
    verifyNever(await mockApi.editSensor(1, '', null, null, "token"));
  });

  /// tests if does not save with no change
  testWidgets('no change, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    List<Sensor> sensors = List();
    sensors.add(Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
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
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('sensor1')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SensorDetails), findsOneWidget);

    expect(find.text("Dane z czujnika"), findsOneWidget);
    expect(find.text("Brak danych"), findsOneWidget);

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byType(SensorDetails), findsOneWidget);

    verifyNever(await mockApi.editSensor(1, null, null, null, "token"));
  });

  /// tests if saves with name changed
  testWidgets('changed name, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, 'newname', null, null, "token")).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));
    List<Sensor> sensors = List();
    sensors.add(Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
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
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('sensor1')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SensorDetails), findsOneWidget);

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(Sensors), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);

    verify(await mockApi.editSensor(1, 'newname', null, null, "token")).called(1);
  });

  /// tests if saves with category changed
  testWidgets('changed category, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, null, "humidity", null, "token")).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));
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
    await tester.tap(find.byKey(Key('sensor1')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SensorDetails), findsOneWidget);

    await tester.tap(find.byKey(Key('dropdownbutton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("Wilgotność").last);
    await tester.pump();

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(Sensors), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    verify(await mockApi.editSensor(1, null, 'humidity', null, "token")).called(1);
  });

  /// tests if saves with frequency value changed
  testWidgets('changed frequency value, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, null, null, 3000, "token")).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));
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
    await tester.tap(find.byKey(Key('sensor1')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SensorDetails), findsOneWidget);

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '3000');

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(Sensors), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    verify(await mockApi.editSensor(1, null, null, 3000, "token")).called(1);
  });

  /// tests if saves with frequency units changed
  testWidgets('changed frequency units, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, null, null, 18000, "token")).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));
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
    await tester.tap(find.byKey(Key('sensor1')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SensorDetails), findsOneWidget);

    await tester.tap(find.byKey(Key('unitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("Minuty").last);
    await tester.pump();

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(Sensors), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    verify(await mockApi.editSensor(1, null, null, 18000, "token")).called(1);
  });


  /// tests if saves with name, category, frequency value and frequency units changed
  testWidgets('changed name, category frequency value, frequency units, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, 'newname', 'humidity', 86400, "token")).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));
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
    await tester.tap(find.byKey(Key('sensor1')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SensorDetails), findsOneWidget);

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('dropdownbutton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("Wilgotność").last);
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '1');

    await tester.tap(find.byKey(Key('unitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("Dni").last);
    await tester.pump();

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(Sensors), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    verify(await mockApi.editSensor(1, 'newname', 'humidity', 86400, "token"))
        .called(1);
  });

  /// tests if does not save with data change but no confirmation
  testWidgets('changed data, no confirmation, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, 'newname', 'humidity', 86400, 'token')).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));
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
    await tester.tap(find.byKey(Key('sensor1')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SensorDetails), findsOneWidget);

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('dropdownbutton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("Wilgotność").last);
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '1');

    await tester.tap(find.byKey(Key('unitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("Dni").last);
    await tester.pump();

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('noButton')));
    await tester.pump();
    expect(find.byType(SensorDetails), findsOneWidget);
    verifyNever(await mockApi.editSensor(1, 'newname', 'humidity', 86400, 'token'));
  });

  /// tests if does not save when name exists
  testWidgets('changed data, name exists, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, 'sensor2', null, null, 'token')).thenAnswer(
        (_) async => Future.value({
              "body": "Sensor with provided name already exists",
              "statusCode": "400"
            }));
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
    await tester.tap(find.byKey(Key('sensor1')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SensorDetails), findsOneWidget);

    Finder usernameField = find.byKey(Key('name'));
    await tester.enterText(usernameField, 'sensor2');

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("ok button")), findsOneWidget);
    expect(find.text("Czujnik o podanej nazwie już istnieje."), findsOneWidget);
    await tester.tap(find.byKey(Key('ok button')));
    await tester.pump();
    expect(find.byType(SensorDetails), findsOneWidget);
    verify(await mockApi.editSensor(1, 'sensor2', null, null, 'token')).called(1);
  });

  /// tests if when category rain, cannot change frequency
  testWidgets('when category rain, cannot change frequency', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockApi.editSensor(1, 'newname', 'rain', 30, "token")).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));

    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("opady atmosferyczne").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("sekundy"), findsOneWidget);
    expect(find.text("30"), findsOneWidget);
    expect(find.text("newname"), findsOneWidget);

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, 'newname', 'rain', 30, "token"))
        .called(1);
  });
}
