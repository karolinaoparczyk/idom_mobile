import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
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

  /// tests if displays air temperature sensor
  testWidgets('displays air temperature sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, dynamic> sensorDataJson = {
      "id": 1,
      "sensor": "sensor1",
      "sensor_data": "27.0",
      "delivery_time": "12-04-2020T19:23:45"
    };
    when(mockApi.getSensorData(1)).thenAnswer(
        (_) async => Future.value({"body": jsonEncode(sensorDataJson), "statusCode": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0",
        batteryLevel: null);

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
    when(mockApi.getSensorDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(sensorJson), "statusCode": "200"}));

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("Kategoria"), findsOneWidget);
    expect(find.text("temperatura powietrza"), findsOneWidget);
    expect(find.text("Poziom baterii"), findsOneWidget);
    expect(find.text("- %"), findsOneWidget);
    expect(find.text("Dane z czujnika"), findsOneWidget);
    expect(find.text("Częstotliwość pobierania danych"), findsOneWidget);
    expect(find.text("5 minut"), findsOneWidget);
    expect(find.text("Aktualna temperatura"), findsOneWidget);
    expect(find.text("27.0 °C"), findsOneWidget);
    expect(find.text("Okres wyświetlanych danych"), findsOneWidget);
    expect(find.text("Dzisiaj"), findsOneWidget);
    expect(find.text("Ostatnie 2 tygodnie"), findsOneWidget);
    expect(find.text("Ostatnie 30 dni"), findsOneWidget);
  });

  /// tests if displays water temperature sensor
  testWidgets('displays water temperature sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData(1)).thenAnswer(
        (_) async => Future.value({"body": "[]", "statusCode": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "water_temp",
        frequency: 30,
        lastData: "27.0",
        batteryLevel: 50);

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

    when(mockApi.getSensorDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(sensorJson), "statusCode": "200"}));

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("temperatura wody"), findsOneWidget);
    expect(find.text("30 sekund"), findsOneWidget);
    expect(find.text("Aktualna temperatura"), findsOneWidget);
    expect(find.text("27.0 °C"), findsOneWidget);
  });

  /// tests if displays rain sensor
  testWidgets('displays rain sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData(1)).thenAnswer(
        (_) async => Future.value({"body": "[]", "statusCode": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "rain_sensor",
        frequency: 30,
        lastData: "27.0",
        batteryLevel: 50);

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

    when(mockApi.getSensorDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(sensorJson), "statusCode": "200"}));

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("opady atmosferyczne"), findsOneWidget);
    expect(find.text("30 sekund"), findsOneWidget);
    expect(find.text("Aktualna temperatura"), findsNothing);
    expect(find.text("27.0 °C"), findsNothing);
  });

  /// tests if displays pot humidity sensor
  testWidgets('displays pot humidity sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData(1)).thenAnswer(
        (_) async => Future.value({"body": "[]", "statusCode": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "humidity",
        frequency: 300,
        lastData: "27.0",
        batteryLevel: 50);

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

    when(mockApi.getSensorDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(sensorJson), "statusCode": "200"}));

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("wilgotność gleby"), findsOneWidget);
    expect(find.text("5 minut"), findsOneWidget);
    expect(find.text("Aktualna wilgotność"), findsOneWidget);
    expect(find.text("27.0 %"), findsOneWidget);
  });

  /// tests if displays air humidity sensor
  testWidgets('displays air humidity sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData(1)).thenAnswer(
        (_) async => Future.value({"body": "[]", "statusCode": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "air_humidity",
        frequency: 300,
        lastData: "27.0",
        batteryLevel: 50);

    SensorDetails page = SensorDetails(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    Map<String, dynamic> sensorJson = {
      "id": 1,
      "name": "sensor1",
      "category": "air_humidity",
      "frequency": 300,
      'last_data': "27.0"
    };

    when(mockApi.getSensorDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(sensorJson), "statusCode": "200"}));

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("wilgotność powietrza"), findsOneWidget);
    expect(find.text("5 minut"), findsOneWidget);
    expect(find.text("Aktualna wilgotność"), findsOneWidget);
    expect(find.text("27.0 %"), findsOneWidget);
  });

  /// tests if displays breathalyser sensor
  testWidgets('displays breathalyser sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData(1)).thenAnswer(
        (_) async => Future.value({"body": "[]", "statusCode": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "breathalyser",
        frequency: 30,
        lastData: "1.0",
        batteryLevel: 50);

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

    when(mockApi.getSensorDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(sensorJson), "statusCode": "200"}));

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("alkomat"), findsOneWidget);
    expect(find.text("30 sekund"), findsNothing);
    expect(find.text("Ostatni pomiar"), findsOneWidget);
    expect(find.text("1.0 ‰"), findsOneWidget);
  });

  /// tests if displays smoke correctly
  testWidgets('displays smoke correctly', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData(1)).thenAnswer((_) async =>
        Future.value({"bodySensorData": "[]", "statusSensorData": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockSecureStorage.resetUserData())
        .thenAnswer((_) async => Future.value());

    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "smoke",
        frequency: 30,
        lastData: "1.0",
        batteryLevel: 50);

    SensorDetails page = SensorDetails(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("dym"), findsOneWidget);
    expect(find.text("30 sekund"), findsOneWidget);
    expect(find.text("Ostatni pomiar"), findsNothing);
    expect(find.text("Aktualna wilgotność"), findsNothing);
    expect(find.text("Aktualna temperatura"), findsNothing);
    expect(find.text("Aktualne ciśnienie"), findsNothing);
  });

  /// tests if displays atmospheric pressure sensor correctly
  testWidgets('displays atmospheric pressure sensor correctly',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData(1)).thenAnswer((_) async =>
        Future.value({"bodySensorData": "[]", "statusSensorData": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockSecureStorage.resetUserData())
        .thenAnswer((_) async => Future.value());

    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "atmo_pressure",
        frequency: 300,
        lastData: "1.0",
        batteryLevel: 50);

    SensorDetails page = SensorDetails(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("ciśnienie atmosferyczne"), findsOneWidget);
    expect(find.text("5 minut"), findsOneWidget);
    expect(find.text("Aktualne ciśnienie"), findsOneWidget);
    expect(find.text("Aktualna wilgotność"), findsNothing);
    expect(find.text("Aktualna temperatura"), findsNothing);
    expect(find.text("Ostatni pomiar"), findsNothing);
  });

  /// tests if displays air temperature sensor, english
  testWidgets('english displays air temperature sensor',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData(1)).thenAnswer(
        (_) async => Future.value({"body": "[]", "statusCode": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0",
        batteryLevel: null);

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
    when(mockApi.getSensorDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(sensorJson), "statusCode": "200"}));

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.text("General"), findsOneWidget);
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("Category"), findsOneWidget);
    expect(find.text("air temperature"), findsOneWidget);
    expect(find.text("Battery level"), findsOneWidget);
    expect(find.text("- %"), findsOneWidget);
    expect(find.text("Sensor data"), findsOneWidget);
    expect(find.text("Data gathering frequency"), findsOneWidget);
    expect(find.text("5 minutes"), findsOneWidget);
    expect(find.text("Current temperature"), findsOneWidget);
    expect(find.text("27.0 °C"), findsOneWidget);
    expect(find.text("Period of displayed data"), findsOneWidget);
    expect(find.text("Today"), findsOneWidget);
    expect(find.text("Last 2 weeks"), findsOneWidget);
    expect(find.text("Last 30 days"), findsOneWidget);
  });

  /// tests if displays water temperature sensor, english
  testWidgets('english displays water temperature sensor',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData(1)).thenAnswer(
        (_) async => Future.value({"body": "[]", "statusCode": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "water_temp",
        frequency: 30,
        lastData: "27.0",
        batteryLevel: 50);

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

    when(mockApi.getSensorDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(sensorJson), "statusCode": "200"}));

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("water temperature"), findsOneWidget);
    expect(find.text("30 seconds"), findsOneWidget);
    expect(find.text("Current temperature"), findsOneWidget);
    expect(find.text("27.0 °C"), findsOneWidget);
  });

  /// tests if displays rain sensor, english
  testWidgets('english displays rain sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData(1)).thenAnswer(
        (_) async => Future.value({"body": "[]", "statusCode": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "rain_sensor",
        frequency: 30,
        lastData: "27.0",
        batteryLevel: 50);

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

    when(mockApi.getSensorDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(sensorJson), "statusCode": "200"}));

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("precipitation"), findsOneWidget);
    expect(find.text("30 seconds"), findsOneWidget);
    expect(find.text("Current temperature"), findsNothing);
    expect(find.text("27.0 °C"), findsNothing);
  });

  /// tests if displays pot humidity sensor, english
  testWidgets('english, displays pot humidity sensor',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData(1)).thenAnswer(
        (_) async => Future.value({"body": "[]", "statusCode": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "humidity",
        frequency: 300,
        lastData: "27.0",
        batteryLevel: 50);

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

    when(mockApi.getSensorDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(sensorJson), "statusCode": "200"}));

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("soil moisture"), findsOneWidget);
    expect(find.text("5 minutes"), findsOneWidget);
    expect(find.text("Current humidity"), findsOneWidget);
    expect(find.text("27.0 %"), findsOneWidget);
  });

  /// tests if displays air humidity sensor, english
  testWidgets('english, displays air humidity sensor',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData(1)).thenAnswer(
        (_) async => Future.value({"body": "[]", "statusCode": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "air_humidity",
        frequency: 300,
        lastData: "27.0",
        batteryLevel: 50);

    SensorDetails page = SensorDetails(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    Map<String, dynamic> sensorJson = {
      "id": 1,
      "name": "sensor1",
      "category": "air_humidity",
      "frequency": 300,
      'last_data': "27.0"
    };

    when(mockApi.getSensorDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(sensorJson), "statusCode": "200"}));

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("air humidity"), findsOneWidget);
    expect(find.text("5 minutes"), findsOneWidget);
    expect(find.text("Current humidity"), findsOneWidget);
    expect(find.text("27.0 %"), findsOneWidget);
  });

  /// tests if displays breathalyser sensor, english
  testWidgets('english displays breathalyser sensor',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData(1)).thenAnswer(
        (_) async => Future.value({"body": "[]", "statusCode": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "breathalyser",
        frequency: 30,
        lastData: "1.0",
        batteryLevel: 50);

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

    when(mockApi.getSensorDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(sensorJson), "statusCode": "200"}));

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("breathalyser"), findsOneWidget);
    expect(find.text("30 seconds"), findsNothing);
    expect(find.text("Last measurement"), findsOneWidget);
    expect(find.text("1.0 ‰"), findsOneWidget);
  });

  /// tests if displays smoke correctly, english
  testWidgets('english displays smoke correctly', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData(1)).thenAnswer((_) async =>
        Future.value({"bodySensorData": "[]", "statusSensorData": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockSecureStorage.resetUserData())
        .thenAnswer((_) async => Future.value());

    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "smoke",
        frequency: 30,
        lastData: "1.0",
        batteryLevel: 50);

    SensorDetails page = SensorDetails(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));

    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("smoke"), findsOneWidget);
    expect(find.text("30 seconds"), findsOneWidget);
    expect(find.text("Last measurement"), findsNothing);
    expect(find.text("Current temperature"), findsNothing);
    expect(find.text("Current humidity"), findsNothing);
    expect(find.text("Current pressure"), findsNothing);
  });

  /// tests if displays atmospheric pressure sensor correctly, english
  testWidgets('english displays atmospheric pressure sensor correctly',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getSensorData(1)).thenAnswer((_) async =>
        Future.value({"bodySensorData": "[]", "statusSensorData": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockSecureStorage.resetUserData())
        .thenAnswer((_) async => Future.value());

    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "atmo_pressure",
        frequency: 300,
        lastData: "1.0",
        batteryLevel: 50);

    SensorDetails page = SensorDetails(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    expect(find.text("sensor1"), findsNWidgets(2));
    expect(find.text("atmospheric pressure"), findsOneWidget);
    expect(find.text("5 minutes"), findsOneWidget);
    expect(find.text("Current pressure"), findsOneWidget);
    expect(find.text("Current humidity"), findsNothing);
    expect(find.text("Last measurement"), findsNothing);
    expect(find.text("Current temperature"), findsNothing);
  });
}
