import 'package:idom/pages/sensors/edit_sensor.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/models.dart';
import 'package:idom/api.dart';

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
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "humidity",
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
    await tester.enterText(emailField, '');

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();

    expect(find.text("Pole wymagane"), findsOneWidget);
    expect(find.byType(EditSensor), findsOneWidget);
    verifyNever(await mockApi.editSensor(1, '', null, null, "token"));
  });

  /// tests if does not save with no change
  testWidgets('no change, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "humidity",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Nie wprowadzono żadnych zmian."), findsOneWidget);
    expect(find.byType(EditSensor), findsOneWidget);

    verifyNever(await mockApi.editSensor(1, null, null, null, "token"));
  });

  /// tests if saves with name changed
  testWidgets('changed name, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockApi.editSensor(1, 'newname', null, null, "token")).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "humidity",
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

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verify(await mockApi.editSensor(1, 'newname', null, null, "token")).called(1);
  });

  /// tests if saves with category changed
  testWidgets('changed category, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockApi.editSensor(1, null, "humidity", null, "token")).thenAnswer(
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

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("wilgotność").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, null, 'humidity', null, "token")).called(1);
  });

  /// tests if saves with frequency value changed
  testWidgets('changed frequency value, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockApi.editSensor(1, null, null, 3000, "token")).thenAnswer(
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

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '3000');

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, null, null, 3000, "token")).called(1);
  });

  /// tests if saves with frequency units changed
  testWidgets('changed frequency units, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockApi.editSensor(1, null, null, 18000, "token")).thenAnswer(
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

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("minuty").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, null, null, 18000, "token")).called(1);
  });


  /// tests if saves with name, category, frequency value and frequency units changed
  testWidgets('changed name, category frequency value, frequency units, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockApi.editSensor(1, 'newname', 'humidity', 86400, "token")).thenAnswer(
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
    await tester.tap(find.text("wilgotność").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '1');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("dni").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, 'newname', 'humidity', 86400, "token"))
        .called(1);
  });

  /// tests if does not save with data change but no confirmation
  testWidgets('changed data, no confirmation, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockApi.editSensor(1, 'newname', 'humidity', 86400, 'token')).thenAnswer(
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
    await tester.tap(find.text("wilgotność").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '1');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("dni").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('noButton')));
    await tester.pump();
    expect(find.byType(EditSensor), findsOneWidget);
    verifyNever(await mockApi.editSensor(1, 'newname', 'humidity', 86400, 'token'));
  });

  /// tests if does not save when name exists
  testWidgets('changed data, name exists, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockApi.editSensor(1, 'sensor2', null, null, 'token')).thenAnswer(
        (_) async => Future.value({
              "body": "Sensor with provided name already exists",
              "statusCode": "400"
            }));
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

    Finder usernameField = find.byKey(Key('name'));
    await tester.enterText(usernameField, 'sensor2');

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Czujnik o podanej nazwie już istnieje."), findsOneWidget);
    await tester.pump();
    expect(find.byType(EditSensor), findsOneWidget);
    verify(await mockApi.editSensor(1, 'sensor2', null, null, 'token')).called(1);
  });

  /// tests if when category rain_sensor, cannot change frequency
  testWidgets('when category rain_sensor, cannot change frequency', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockApi.editSensor(1, 'newname', 'rain_sensor', 30, "token")).thenAnswer(
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
    verify(await mockApi.editSensor(1, 'newname', 'rain_sensor', 30, "token"))
        .called(1);
  });

  /// tests if when category breathalyser, cannot change frequency
  testWidgets('when category breathalyser, cannot change frequency', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockApi.editSensor(1, 'newname', 'breathalyser', 30, "token")).thenAnswer(
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
    await tester.tap(find.text("alkomat").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("sekundy"), findsNothing);
    expect(find.text("30"), findsNothing);
    expect(find.text("newname"), findsOneWidget);
    expect(find.text("alkomat"), findsNWidgets(2));

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, 'newname', 'breathalyser', 30, "token"))
        .called(1);
  });

  /// tests if when  edits category breathalyser, can change frequency
  testWidgets('when  edits category breathalyser, can change frequency', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockApi.editSensor(1, 'newname', 'temperature', 180, "token")).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));

    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "breathalyser",
        frequency: 30,
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
    await tester.tap(find.text("temperatura powietrza").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("sekundy"), findsOneWidget);
    expect(find.text("30"), findsOneWidget);
    expect(find.text("newname"), findsOneWidget);
    expect(find.text("temperatura powietrza"), findsNWidgets(2));

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '3');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("minuty").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, 'newname', 'temperature', 180, "token"))
        .called(1);
  });
}
