import 'dart:convert';

import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';
import 'package:idom/pages/sensors/sensors.dart';

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
        "id": 3,
        "name": "sensor3",
        "category": "humidity",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 4,
        "name": "sensor4",
        "category": "smoke",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 5,
        "name": "sensor5",
        "category": "air_humidity",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 5);
    expect(find.text("ostatnia dana: 27.00 °C"), findsOneWidget);
    expect(find.text("ostatnia dana: 27.00 %"), findsNWidgets(2));
  });

  /// tests if deletes sensor after confirmation
  testWidgets('deletes sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
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
    when(mockApi.deactivateSensor(1))
        .thenAnswer((_) async => Future.value(200));

    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("deleteButton")).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.deactivateSensor(1)).called(1);
  });

  /// tests if does not delete sensor when no confirmation
  testWidgets('does not confirm, does not delete', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
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
    when(mockApi.deactivateSensor(1))
        .thenAnswer((_) async => Future.value(200));

    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("deleteButton")).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('noButton')));
    await tester.pumpAndSettle();

    verifyNever(await mockApi.deactivateSensor(1));
  });

  /// tests eror message when api error
  testWidgets('api error, message to user', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.deactivateSensor(1))
        .thenAnswer((_) async => Future.value(404));
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
    when(mockApi.deactivateSensor(1))
        .thenAnswer((_) async => Future.value(400));

    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("deleteButton")).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SnackBar));
    await tester.tap(
        find.text("Usunięcie czujnika nie powiodło się. Spróbuj ponownie."));

    verify(await mockApi.deactivateSensor(1)).called(1);
  });

  /// tests if icons displayed correctly
  testWidgets('icons displayed correctly', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
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
        "id": 3,
        "name": "sensor3",
        "category": "humidity",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 4,
        "name": "sensor4",
        "category": "smoke",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 5,
        "name": "sensor5",
        "category": "breathalyser",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 6,
        "name": "sensor6",
        "category": "water_temp",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 7,
        "name": "sensor7",
        "category": "air_humidity",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 8,
        "name": "sensor8",
        "category": "atmo_pressure",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("assets/icons/thermometer.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/rain.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/pot.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/smoke.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/breathalyser.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/temperature.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/humidity.svg")), findsOneWidget);
    /// scroll categories list
    await tester.drag(
        find.byKey(Key('SensorsList')), const Offset(0.0, -300));
    await tester.pump();
    expect(find.byKey(Key("assets/icons/barometer.svg")), findsOneWidget);
  });
}
