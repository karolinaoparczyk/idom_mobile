import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/sensors/sensors.dart';

class MockApi extends Mock implements Api {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  /// tests if sensors on list
  testWidgets('sensors on list', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
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
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 2);
    expect(find.text("27.0 °C"), findsNWidgets(2));
  });

  /// tests if deletes sensor after confirmation
  testWidgets('sensors on list, confirms, deletes',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Sensor> sensors = List();
    sensors.add(Sensor(
        id: 1,
        name: "sensor1",
        category: "humidity",
        batteryLevel: null,
        notifications: true,
        lastData: "27.0"));
    sensors.add(Sensor(
        id: 2,
        name: "sensor2",
        category: "humidity",
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
        category: "humidity",
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
    when(mockApi.deactivateSensor(1, "token"))
        .thenAnswer((_) async => Future.value(404));
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
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 2);

    await tester.tap(find.byType(FlatButton).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('ok button')));

    verify(await mockApi.deactivateSensor(1, "token")).called(1);
  });
}
