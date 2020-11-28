import 'dart:convert';

import 'package:idom/pages/actions/actions.dart';
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

  /// tests if actions on list
  testWidgets('actions on list', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> actions = [
      {
        "id": 1,
        "name": "action1",
        "sensor_id": 1,
        "driver_id": 1,
        "startTime": "17:30",
        "endTime": "19:30",
        "action": "action",
      },
      {
        "id": 1,
        "name": "action2",
        "sensor_id": 2,
        "driver_id": 2,
        "startTime": "13:20",
        "endTime": "16:40",
        "action": "action",
      }
    ];
    when(mockApi.getActions()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(actions), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    ActionsList page = ActionsList(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find
        .byType(ListTile)
        .evaluate()
        .length, 2);
    expect(find.text("action1"), findsOneWidget);
    expect(find.text("action2"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/hammer.svg")), findsNWidgets(2));
  });

  /// tests if actions not on list if api error
  testWidgets('actions not on list if api error', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getActions()).thenAnswer((_) async =>
        Future.value(null));

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    ActionsList page = ActionsList(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find
        .byType(ListTile)
        .evaluate()
        .length, 0);
    expect(find.text("Błąd połączenia z serwerem."), findsOneWidget);
    expect(find.byKey(Key("assets/icons/hammer.svg")), findsNothing);
  });
}