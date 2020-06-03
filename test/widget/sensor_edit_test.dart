import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idom/pages/sensors/sensor_details.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/models.dart';
import 'package:idom/api.dart';

class MockApi extends Mock implements Api {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(home: child);
  }

  /// tests if does not save with empty name
  testWidgets('name is empty, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        batteryLevel: null,
        notifications: true,
        isActive: false);
    SensorDetails page = SensorDetails(
        currentLoggedInToken: "token",
        currentLoggedInUsername: "user",
        sensor: sensor,
        api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, '');

    await tester.tap(find.byKey(Key('Zapisz zmiany')));

    verifyNever(await mockApi.editSensor(1, '', null, "token"));
  });

  /// tests if does not save with no change
  testWidgets('no change, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        batteryLevel: null,
        notifications: true,
        isActive: false);
    SensorDetails page = SensorDetails(
        currentLoggedInToken: "token",
        currentLoggedInUsername: "user",
        sensor: sensor,
        api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);

    verifyNever(await mockApi.editSensor(1, null, null, "token"));
  });

  /// tests if saves with name changed
  testWidgets('changed name, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editSensor(1, 'newname', null, "token")).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        batteryLevel: null,
        notifications: true,
        isActive: false);
    SensorDetails page = SensorDetails(
        currentLoggedInToken: "token",
        currentLoggedInUsername: "user",
        sensor: sensor,
        api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);

    verify(await mockApi.editSensor(1, 'newname', null, "token")).called(1);
  });

  /// tests if saves with category changed
  testWidgets('changed category, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editSensor(1, null, "humidity", "token")).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        batteryLevel: null,
        notifications: true,
        isActive: false);
    SensorDetails page = SensorDetails(
        currentLoggedInToken: "token",
        currentLoggedInUsername: "user",
        sensor: sensor,
        api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    await tester.tap(find.byKey(Key('dropdownbutton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("Wilgotność").last);
    await tester.pump();

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);

    verify(await mockApi.editSensor(1, null, 'humidity', "token")).called(1);
  });

  /// tests if saves with name and category changed
  testWidgets('changed name and category, saves',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        when(mockApi.editSensor(1, 'newname', 'humidity', "token")).thenAnswer(
                (_) async => Future.value({"body": "", "statusCode": "200"}));
        Sensor sensor = Sensor(
            id: 1,
            name: "sensor1",
            category: "temperature",
            batteryLevel: null,
            notifications: true,
            isActive: false);
        SensorDetails page = SensorDetails(
            currentLoggedInToken: "token",
            currentLoggedInUsername: "user",
            sensor: sensor,
            api: mockApi);

        await tester.pumpWidget(makeTestableWidget(child: page));

        Finder emailField = find.byKey(Key('name'));
        await tester.enterText(emailField, 'newname');

        await tester.tap(find.byKey(Key('dropdownbutton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text("Wilgotność").last);
        await tester.pump();

        await tester.tap(find.byKey(Key('Zapisz zmiany')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pumpAndSettle();
        expect(find.byType(SnackBar), findsOneWidget);

        verify(await mockApi.editSensor(1, 'newname', 'humidity', "token"))
            .called(1);
      });

  /// tests if does not save with data change but no confirmation
  testWidgets('changed data, no confirmation, does not save',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        when(mockApi.editSensor(1, 'newname', 'humidity', 'token')).thenAnswer(
                (_) async => Future.value({"body": "", "statusCode": "200"}));
        Sensor sensor = Sensor(
            id: 1,
            name: "sensor1",
            category: "temperature",
            batteryLevel: null,
            notifications: true,
            isActive: false);
        SensorDetails page = SensorDetails(
            currentLoggedInToken: "token",
            currentLoggedInUsername: "user",
            sensor: sensor,
            api: mockApi);

        await tester.pumpWidget(makeTestableWidget(child: page));

        Finder emailField = find.byKey(Key('name'));
        await tester.enterText(emailField, 'newname');

        await tester.tap(find.byKey(Key('dropdownbutton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text("Wilgotność").last);
        await tester.pump();

        await tester.tap(find.byKey(Key('Zapisz zmiany')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key('noButton')));

        verifyNever(await mockApi.editSensor(1, 'newname', 'humidity', 'token'));
      });

  /// tests if does not save with error in data
  testWidgets('changed data, error in data, does not save',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        Sensor sensor = Sensor(
            id: 1,
            name: "sensor1",
            category: "temperature",
            batteryLevel: null,
            notifications: true,
            isActive: false);
        SensorDetails page = SensorDetails(
            currentLoggedInToken: "token",
            currentLoggedInUsername: "user",
            sensor: sensor,
            api: mockApi);

        await tester.pumpWidget(makeTestableWidget(child: page));

        Finder nameField = find.byKey(Key('name'));
        await tester.enterText(nameField, 'new name');

        await tester.tap(find.byKey(Key('Zapisz zmiany')));

        verifyNever(await mockApi.editSensor(1, 'new name', null, "token"));
      });

  /// tests if does not save when name exists
  testWidgets('changed data, name exists, does not save',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        when(mockApi.editSensor(1, 'sensor2', null, 'token')).thenAnswer((_) async =>
            Future.value({
              "body": "Sensor with provided name already exists",
              "statusCode": "400"
            }));
        Sensor sensor = Sensor(
            id: 1,
            name: "sensor1",
            category: "temperature",
            batteryLevel: null,
            notifications: true,
            isActive: false);
        SensorDetails page = SensorDetails(
            currentLoggedInToken: "token",
            currentLoggedInUsername: "user",
            sensor: sensor,
            api: mockApi);

        await tester.pumpWidget(makeTestableWidget(child: page));

        Finder usernameField = find.byKey(Key('name'));
        await tester.enterText(usernameField, 'sensor2');

        await tester.tap(find.byKey(Key('Zapisz zmiany')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pumpAndSettle();
        expect(find.byKey(Key("ok button")), findsOneWidget);
        expect(find.text("Czujnik o podanej nazwie już istnieje."),
            findsOneWidget);

        verify(await mockApi.editSensor(1, 'sensor2', null, 'token')).called(1);
      });
}
