import 'dart:convert';

import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';
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
    List<Map<String, dynamic>> sensors = [{
      "id": 1,
      "name": "sensor1",
      "category": "temperature",
      "frequency": 300,
      "last_data": "27.0"},
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"},
      {
        "id": 2,
        "name": "sensor3",
        "category": "humidity",
        "frequency": 300,
        "last_data": "27.0"},
      {
        "id": 2,
        "name": "sensor4",
        "category": "smoke",
        "frequency": 300,
        "last_data": "27.0"}];
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
    expect(find.byType(ListTile).evaluate().length, 4);
    expect(find.text("ostatnia dana: 27.0 °C"), findsOneWidget);
    expect(find.text("ostatnia dana: 27.0 %"), findsOneWidget);
  });

  /// tests if deletes sensor after confirmation
  testWidgets('deletes sensor',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    List<Map<String, dynamic>> sensors = [{
      "id": 1,
      "name": "sensor1",
      "category": "temperature",
      "frequency": 300,
      "last_data": "27.0"},
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"},
      {
        "id": 2,
        "name": "sensor3",
        "category": "humidity",
        "frequency": 300,
        "last_data": "27.0"},
      {
        "id": 2,
        "name": "sensor4",
        "category": "smoke",
        "frequency": 300,
        "last_data": "27.0"}];
    when(mockApi.getSensors("token")).thenAnswer(
            (_) async => Future.value({"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
    when(mockApi.deactivateSensor(1, "token")).thenAnswer(
            (_) async => Future.value(200));

    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

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

    verify(await mockApi.deactivateSensor(1, "token")).called(1);
  });

  /// tests if does not delete sensor when no confirmation
  testWidgets('does not confirm, does not delete',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    List<Map<String, dynamic>> sensors = [{
      "id": 1,
      "name": "sensor1",
      "category": "temperature",
      "frequency": 300,
      "last_data": "27.0"},
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"},
      {
        "id": 2,
        "name": "sensor3",
        "category": "humidity",
        "frequency": 300,
        "last_data": "27.0"},
      {
        "id": 2,
        "name": "sensor4",
        "category": "smoke",
        "frequency": 300,
        "last_data": "27.0"}];
    when(mockApi.getSensors("token")).thenAnswer(
            (_) async => Future.value({"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
    when(mockApi.deactivateSensor(1, "token")).thenAnswer(
            (_) async => Future.value(200));

    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

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

    verifyNever(await mockApi.deactivateSensor(1, "token"));
  });

  /// tests eror message when api error
  testWidgets('api error, message to user',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.deactivateSensor(1, "token"))
        .thenAnswer((_) async => Future.value(404));
    List<Map<String, dynamic>> sensors = [{
      "id": 1,
      "name": "sensor1",
      "category": "temperature",
      "frequency": 300,
      "last_data": "27.0"},
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"},
      {
        "id": 2,
        "name": "sensor3",
        "category": "humidity",
        "frequency": 300,
        "last_data": "27.0"},
      {
        "id": 2,
        "name": "sensor4",
        "category": "smoke",
        "frequency": 300,
        "last_data": "27.0"}];
    when(mockApi.getSensors("token")).thenAnswer(
            (_) async => Future.value({"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
    when(mockApi.deactivateSensor(1, "token")).thenAnswer(
            (_) async => Future.value(400));

    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

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
    await tester.tap(find.text("Usunięcie czujnika nie powiodło się. Spróbuj ponownie."));

    verify(await mockApi.deactivateSensor(1, "token")).called(1);
  });

  /// tests if icons displayed correctly
  testWidgets(
      'rain_sensor and air temperature icons displayed correctly',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        MockSecureStorage mockSecureStorage = MockSecureStorage();
        List<Map<String, dynamic>> sensors = [{
          "id": 1,
          "name": "sensor1",
          "category": "temperature",
          "frequency": 300,
          "last_data": "27.0"},
          {
            "id": 2,
            "name": "sensor2",
            "category": "rain_sensor",
            "frequency": 300,
            "last_data": "27.0"},
          {
            "id": 2,
            "name": "sensor3",
            "category": "humidity",
            "frequency": 300,
            "last_data": "27.0"},
          {
            "id": 2,
            "name": "sensor4",
            "category": "smoke",
            "frequency": 300,
            "last_data": "27.0"}];
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
