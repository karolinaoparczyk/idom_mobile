import 'dart:convert';

import 'package:idom/pages/drivers/drivers.dart';
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

  /// tests if edits driver name
  testWidgets('edits driver name', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
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
    when(mockApi.getDrivers("token")).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));
    // when(mockApi.newDriver('name', 'clicker', "token")).thenAnswer((_) async =>
    //     Future.value({"body": "", "statusCode": "201"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    Drivers page = Drivers(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key("addDriverButton")));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("naduszacz").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('saveDriverButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    // verify(await mockApi.newDriver('name', 'clicker', "token"))
    //     .called(1);
  });
}
