import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/pages/sensors/sensor_details.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';
import 'package:idom/pages/sensors/sensors.dart';

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

  /// tests if sensors on list
  testWidgets('sensors on list, search results', (WidgetTester tester) async {
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
        "name": "SENSOR2",
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

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 5);
    expect(find.text("ostatnia dana: 27.00 °C"), findsOneWidget);
    expect(find.text("ostatnia dana: 27.00 %"), findsNWidgets(2));

    await tester.tap(find.byKey(Key('searchButton')));
    await tester.pumpAndSettle();
    Finder searchField = find.byKey(Key('searchField'));
    await tester.enterText(searchField, 'sensor');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 5);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("SENSOR2"), findsOneWidget);

    await tester.enterText(searchField, '1');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 1);
    expect(find.text("sensor1"), findsOneWidget);

    await tester.tap(find.text("sensor1"));
    await tester.pumpAndSettle();
    expect(find.byType(SensorDetails), findsOneWidget);
  });

  /// tests if logs out when no token
  testWidgets('logs out when no token', (WidgetTester tester) async {
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
        "name": "SENSOR2",
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
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "401"}));

    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
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

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("deleteButton")).first);
    await tester.pumpAndSettle();

    expect(find.text("Potwierdź"), findsOneWidget);
    expect(find.text("Czy na pewno chcesz usunąć czujnik sensor1?"),
        findsOneWidget);
    expect(find.text("Tak"), findsOneWidget);
    expect(find.text("Nie"), findsOneWidget);
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

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("deleteButton")).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('noButton')));
    await tester.pumpAndSettle();

    verifyNever(await mockApi.deactivateSensor(1));

    await tester.drag(find.byKey(Key('SensorsList')), const Offset(0.0, 300));
    await tester.pumpAndSettle();
    verify(await mockApi.getSensors()).called(2);
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

    await tester.pumpWidget(makePolishTestableWidget(child: page));
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

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("assets/icons/thermometer.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/rain.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/pot.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/smoke.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/breathalyser.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/temperature.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/humidity.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/battery.svg")), findsNWidgets(4));

    /// scroll categories list
    await tester.drag(find.byKey(Key('SensorsList')), const Offset(0.0, -300));
    await tester.pump();
    expect(find.byKey(Key("assets/icons/barometer.svg")), findsOneWidget);
  });

  /// tests if sensors on list english
  testWidgets('english sensors on list, search results',
      (WidgetTester tester) async {
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
        "name": "SENSOR2",
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

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 5);
    expect(find.text("last data: 27.00 °C"), findsOneWidget);
    expect(find.text("last data: 27.00 %"), findsNWidgets(2));

    await tester.tap(find.byKey(Key('searchButton')));
    await tester.pumpAndSettle();
    Finder searchField = find.byKey(Key('searchField'));
    await tester.enterText(searchField, 'sensor');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 5);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("SENSOR2"), findsOneWidget);

    await tester.enterText(searchField, '1');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 1);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("SENSOR2"), findsNothing);
    await tester.tap(find.byKey(Key('arrowBack')));
    await tester.pumpAndSettle();
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("SENSOR2"), findsOneWidget);

    await tester.tap(find.byKey(Key('searchButton')));
    await tester.pumpAndSettle();
    searchField = find.byKey(Key('searchField'));
    await tester.enterText(searchField, '2');
    await tester.pumpAndSettle();
    expect(find.text("sensor1"), findsNothing);
    expect(find.text("SENSOR2"), findsOneWidget);
    expect(find.byType(ListTile).evaluate().length, 1);
    await tester.tap(find.byKey(Key('clearSearchingBox')));
    await tester.pumpAndSettle();
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("SENSOR2"), findsOneWidget);
  });

  /// tests if deletes sensor after confirmation, english
  testWidgets('english deletes sensor', (WidgetTester tester) async {
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

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("deleteButton")).first);
    await tester.pumpAndSettle();

    expect(find.text("Confirm"), findsOneWidget);
    expect(find.text("Are you sure you want to remove sensor sensor1?"),
        findsOneWidget);
    expect(find.text("Yes"), findsOneWidget);
    expect(find.text("No"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.deactivateSensor(1)).called(1);
  });

  /// tests eror message when api error, english
  testWidgets('english api error, message to user',
      (WidgetTester tester) async {
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

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("deleteButton")).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SnackBar));
    await tester.tap(find.text("Sensor removal failed. Try again."));

    verify(await mockApi.deactivateSensor(1)).called(1);
  });
}
