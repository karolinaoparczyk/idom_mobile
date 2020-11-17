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

  /// tests if drivers on list, send command to driver from context menu
  testWidgets('drivers on list, send command to driver from context menu',
      (WidgetTester tester) async {
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

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    Drivers page = Drivers(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 2);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("driver2"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/tap.svg")), findsNWidgets(2));
    expect(find.byIcon(Icons.more_vert_outlined), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.more_vert_outlined).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key("click")));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Wysłano komendę do sterownika driver1."), findsOneWidget);
  });

  /// tests if drivers on list, delete driver from context menu
  testWidgets('delete driver from context menu',
      (WidgetTester tester) async {
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
when(mockApi.deleteDriver(1, "token")).thenAnswer((_) async =>
        Future.value(204));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    Drivers page = Drivers(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert_outlined).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key("delete")));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key("yesButton")));
    await tester.pumpAndSettle();
    verify(mockApi.deleteDriver(1, "token")).called(1);
  });
}
