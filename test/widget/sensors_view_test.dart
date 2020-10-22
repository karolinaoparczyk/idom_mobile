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
      'icons displayed correctly',
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
            "last_data": "27.0"},
          {
            "id": 2,
            "name": "sensor5",
            "category": "breathalyser",
            "frequency": 300,
            "last_data": "27.0"},
          {
            "id": 2,
            "name": "sensor5",
            "category": "water_temp",
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
        expect(find.byKey(Key("assets/icons/thermometer.svg")), findsOneWidget);
        expect(find.byKey(Key("assets/icons/rain.svg")), findsOneWidget);
        expect(find.byKey(Key("assets/icons/humidity.svg")), findsOneWidget);
        expect(find.byKey(Key("assets/icons/smoke.svg")), findsOneWidget);
        expect(find.byKey(Key("assets/icons/breathalyser.svg")), findsOneWidget);
        expect(find.byKey(Key("assets/icons/temperature.svg")), findsOneWidget);
      });
}
