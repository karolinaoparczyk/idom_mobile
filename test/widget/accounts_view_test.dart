import 'dart:async';
import 'dart:convert';

import 'package:idom/utils/secure_storage.dart';
import 'package:idom/pages/account/accounts.dart';
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

  /// tests if accounts on list, user not staff
  testWidgets('accounts on list, user is not staff',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> accounts = [
      {
        "id": 1,
        "username": "user1",
        "email": "user@email.com",
        "telephone": "",
        "sms_notifications": true,
        "app_notifications": true,
        "is_staff": false,
        "is_active": true
      },
      {
        "id": 2,
        "username": "user2",
        "email": "user@2email.com",
        "telephone": "",
        "sms_notifications": true,
        "app_notifications": true,
        "is_staff": false,
        "is_active": true
      }
    ];
    when(mockApi.getAccounts("token")).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(accounts), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockSecureStorage.getIsUserStaff())
        .thenAnswer((_) async => Future.value("false"));

    Accounts page = Accounts(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 2);
    expect(find.byKey(Key("deleteButton")).evaluate().length, 0);
    expect(find.text("user1"), findsOneWidget);
    expect(find.text("user2"), findsOneWidget);
  });

  /// tests if can delete if is staff
  testWidgets('accounts on list, user is staff', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> accounts = [
      {
        "id": 1,
        "username": "user1",
        "email": "user@email.com",
        "telephone": "",
        "sms_notifications": true,
        "app_notifications": true,
        "is_staff": false,
        "is_active": true
      },
      {
        "id": 2,
        "username": "user2",
        "email": "user@2email.com",
        "telephone": "",
        "sms_notifications": true,
        "app_notifications": true,
        "is_staff": false,
        "is_active": true
      }
    ];
    when(mockApi.getAccounts("token")).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(accounts), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockSecureStorage.getIsUserStaff())
        .thenAnswer((_) async => Future.value("true"));

    Accounts page = Accounts(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("deleteButton")).evaluate().length, 2);
    expect(find.text("user1"), findsOneWidget);
    expect(find.text("user2"), findsOneWidget);
  });
}
