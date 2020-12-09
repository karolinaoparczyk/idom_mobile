import 'dart:convert';

import 'package:idom/pages/actions/new_action.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';

class MockApi extends Mock implements Api {}

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  /// tests if adds action
  testWidgets('adds action', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addAction('name', null, null, null, "driver2",
            "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", "action", 2))
        .thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "201"}));

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
      }
    ];

    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

    List<Map<String, dynamic>> drivers = [
      {
        "id": 1,
        "name": "driver1",
        "category": "clicker",
        "ipAddress": "111.111.11.11",
        "data": true
      },
      {
        "id": 2,
        "name": "driver2",
        "category": "clicker",
        "ipAddress": "113.113.13.13",
        "data": true
      }
    ];

    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewAction page = NewAction(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');
    //
    // await tester.tap(find.byKey(Key('sensorsButton')));
    // await tester.pump();
    // await tester.pump(const Duration(seconds: 1));
    // await tester.tap(find.text("sensor1").last);
    // await tester.tap(find.byKey(Key('yesButton')));
    // await tester.pump();

    await tester.tap(find.byKey(Key('driversButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("driver2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("driver2"), findsNWidgets(2));
    await tester.tap(find.byKey(Key('saveActionButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.addAction('name', null, null, null, "driver2",
        "0, 1, 2, 3, 4, 5, 6", "13:40", "15:40", "action", 2)).called(1);
  });
}
