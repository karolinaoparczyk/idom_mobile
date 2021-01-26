import 'dart:async';
import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/pages/account/accounts.dart';
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

  /// tests if can delete if is staff, deletes after confirm
  testWidgets('accounts on list, user is staff, deletes after confirm',
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
    when(mockApi.getAccounts()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(accounts), "statusCode": "200"}));
    when(mockApi.deactivateAccount(1))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getIsUserStaff())
        .thenAnswer((_) async => Future.value("true"));

    Accounts page = Accounts(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("deleteButton")).evaluate().length, 2);
    expect(find.text("user1"), findsOneWidget);
    expect(find.text("user2"), findsOneWidget);
    await tester.tap(find.byKey(Key("deleteButton")).first);
    when(mockApi.getAccounts()).thenAnswer((_) async => Future.value({
          "body": jsonEncode([accounts[1]]),
          "statusCode": "200"
        }));
    await tester.pumpAndSettle();
    expect(find.text("Potwierdź"), findsOneWidget);
    expect(
        find.text("Czy na pewno chcesz usunąć konto user1?"), findsOneWidget);
    expect(find.text("Tak"), findsOneWidget);
    expect(find.text("Nie"), findsOneWidget);

    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("deleteButton")).evaluate().length, 1);
    expect(find.text("user1"), findsNothing);
    expect(find.text("user2"), findsOneWidget);
    verify(await mockApi.deactivateAccount(1)).called(1);
  });

  /// tests if logs out when no token
  testWidgets('logs out when no token', (WidgetTester tester) async {
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
    when(mockApi.getAccounts()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(accounts), "statusCode": "200"}));
    when(mockApi.deactivateAccount(1))
        .thenAnswer((_) async => Future.value(401));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getIsUserStaff())
        .thenAnswer((_) async => Future.value("true"));

    Accounts page = Accounts(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("deleteButton")).evaluate().length, 2);
    expect(find.text("user1"), findsOneWidget);
    expect(find.text("user2"), findsOneWidget);
    await tester.tap(find.byKey(Key("deleteButton")).first);
    when(mockApi.getAccounts()).thenAnswer((_) async => Future.value({
          "body": jsonEncode([accounts[1]]),
          "statusCode": "200"
        }));
    await tester.pumpAndSettle();
    expect(find.text("Potwierdź"), findsOneWidget);
    expect(
        find.text("Czy na pewno chcesz usunąć konto user1?"), findsOneWidget);
    expect(find.text("Tak"), findsOneWidget);
    expect(find.text("Nie"), findsOneWidget);

    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.deactivateAccount(1)).called(1);
  });

  /// tests if does not delete after no confirmation
  testWidgets('does not delete after no confirmation',
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
    when(mockApi.getAccounts()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(accounts), "statusCode": "200"}));
    when(mockApi.deactivateAccount(1))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getIsUserStaff())
        .thenAnswer((_) async => Future.value("true"));

    Accounts page = Accounts(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("deleteButton")).evaluate().length, 2);
    expect(find.text("user1"), findsOneWidget);
    expect(find.text("user2"), findsOneWidget);
    await tester.tap(find.byKey(Key("deleteButton")).first);
    when(mockApi.getAccounts()).thenAnswer((_) async => Future.value({
          "body": jsonEncode([accounts[1]]),
          "statusCode": "200"
        }));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('noButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("deleteButton")).evaluate().length, 2);
    expect(find.text("user1"), findsOneWidget);
    expect(find.text("user2"), findsOneWidget);
    verifyNever(await mockApi.deactivateAccount(1));
  });

  /// tests if does not delete after api error
  testWidgets('does not delete after api error', (WidgetTester tester) async {
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
    when(mockApi.getAccounts()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(accounts), "statusCode": "200"}));
    when(mockApi.deactivateAccount(1))
        .thenAnswer((_) async => Future.value(404));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getIsUserStaff())
        .thenAnswer((_) async => Future.value("true"));

    Accounts page = Accounts(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("deleteButton")).evaluate().length, 2);
    expect(find.text("user1"), findsOneWidget);
    expect(find.text("user2"), findsOneWidget);
    await tester.tap(find.byKey(Key("deleteButton")).first);
    when(mockApi.getAccounts()).thenAnswer((_) async => Future.value({
          "body": jsonEncode([accounts[1]]),
          "statusCode": "200"
        }));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("deleteButton")).evaluate().length, 2);
    expect(find.text("user1"), findsOneWidget);
    expect(find.text("user2"), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(
        find.text("Usunięcie użytkownika nie powiodło się. Spróbuj ponownie."),
        findsOneWidget);
    verify(await mockApi.deactivateAccount(1)).called(1);
  });

  /// tests if can delete if is staff, deletes after confirm, english
  testWidgets('english accounts on list, user is staff, deletes after confirm',
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
    when(mockApi.getAccounts()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(accounts), "statusCode": "200"}));
    when(mockApi.deactivateAccount(1))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getIsUserStaff())
        .thenAnswer((_) async => Future.value("true"));

    Accounts page = Accounts(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("deleteButton")).evaluate().length, 2);
    expect(find.text("user1"), findsOneWidget);
    expect(find.text("user2"), findsOneWidget);
    await tester.tap(find.byKey(Key("deleteButton")).first);
    when(mockApi.getAccounts()).thenAnswer((_) async => Future.value({
          "body": jsonEncode([accounts[1]]),
          "statusCode": "200"
        }));
    await tester.pumpAndSettle();
    expect(find.text("Confirm"), findsOneWidget);
    expect(find.text("Are you sure you want to remove user user1?"),
        findsOneWidget);
    expect(find.text("Yes"), findsOneWidget);
    expect(find.text("No"), findsOneWidget);

    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("deleteButton")).evaluate().length, 1);
    expect(find.text("user1"), findsNothing);
    expect(find.text("user2"), findsOneWidget);
    verify(await mockApi.deactivateAccount(1)).called(1);
  });

  /// tests if does not delete after api error, english
  testWidgets('english does not delete after api error',
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
    when(mockApi.getAccounts()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(accounts), "statusCode": "200"}));
    when(mockApi.deactivateAccount(1))
        .thenAnswer((_) async => Future.value(404));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getIsUserStaff())
        .thenAnswer((_) async => Future.value("true"));

    Accounts page = Accounts(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("deleteButton")).evaluate().length, 2);
    expect(find.text("user1"), findsOneWidget);
    expect(find.text("user2"), findsOneWidget);
    await tester.tap(find.byKey(Key("deleteButton")).first);
    when(mockApi.getAccounts()).thenAnswer((_) async => Future.value({
          "body": jsonEncode([accounts[1]]),
          "statusCode": "200"
        }));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("deleteButton")).evaluate().length, 2);
    expect(find.text("user1"), findsOneWidget);
    expect(find.text("user2"), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("User removal failed. Try again."), findsOneWidget);
    verify(await mockApi.deactivateAccount(1)).called(1);
  });
}
