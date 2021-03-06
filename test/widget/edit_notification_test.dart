import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/api.dart';

class MockApi extends Mock implements Api {}

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  Widget makePolishTestableWidget({Widget child}) {
    return MaterialApp(home: child);
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

  /// tests if changes sms notifications with logged in user
  testWidgets('changes sms notifications with logged in user', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editNotifications(1, "true", "false")).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.setAppNotifications("true")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.setSmsNotifications("false")).thenAnswer(
            (_) async => Future.value());

    var userJson = {"id": "1",
      "username": "user1",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData()).thenAnswer(
            (_) async => Future.value(userJson));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("smsNotifications")));
    await tester.pump();
    expect(find.byType(SnackBar), findsNothing);

    verify(await mockApi.editNotifications(1, "true", "false"));
  });

 /// tests if logs out when no token
  testWidgets('logs out when no token', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editNotifications(1, "true", "false")).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "401"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.setAppNotifications("true")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.setSmsNotifications("false")).thenAnswer(
            (_) async => Future.value());

    var userJson = {"id": "1",
      "username": "user1",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData()).thenAnswer(
            (_) async => Future.value(userJson));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("smsNotifications")));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verify(await mockApi.editNotifications(1, "true", "false"));
  });

  /// tests if changes app notifications with logged in user
  testWidgets('changes app notifications with logged in user', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editNotifications(1, "false", "true")).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.setAppNotifications("true")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.setSmsNotifications("false")).thenAnswer(
            (_) async => Future.value());

    var userJson = {"id": "1",
      "username": "user1",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"};

    when(mockSecureStorage.getCurrentUserData()).thenAnswer(
            (_) async => Future.value(userJson));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("appNotifications")));
    await tester.pump();
    expect(find.byType(SnackBar), findsNothing);

    verify(await mockApi.editNotifications(1, "false", "true"));
  });

  /// tests if does not change sms notifications if api error
  testWidgets('does not change sms notifications if api error', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editNotifications(1, "true", "false")).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "400"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.setAppNotifications("true")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.setSmsNotifications("false")).thenAnswer(
            (_) async => Future.value());

    var userJson = {"id": "1",
      "username": "user1",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"};

    when(mockSecureStorage.getCurrentUserData()).thenAnswer(
            (_) async => Future.value(userJson));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("smsNotifications")));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Błąd edycji powiadomień. Spróbuj ponownie."), findsOneWidget);

    verify(await mockApi.editNotifications(1, "true", "false"));
  });

  /// tests if does not change app notifications if api error
  testWidgets('does not change app notifications if api error', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editNotifications(1, "false", "true")).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "400"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.setAppNotifications("true")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.setSmsNotifications("false")).thenAnswer(
            (_) async => Future.value());

    var userJson = {"id": "1",
      "username": "user1",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"};

    when(mockSecureStorage.getCurrentUserData()).thenAnswer(
            (_) async => Future.value(userJson));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("appNotifications")));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Błąd edycji powiadomień. Spróbuj ponownie."), findsOneWidget);

    verify(await mockApi.editNotifications(1, "false", "true"));
  });

  /// tests if changes sms notifications with other account
  testWidgets('changes sms notifications with other account', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editNotifications(1, "true", "false")).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "400"}));

    var user1Json = {"id": 1,
      "username": "user1",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "",
      "sms_notifications": true,
      "app_notifications": true,
      "is_staff": false,
      "is_active": true};
    when(mockApi.getUser("user1")).thenAnswer(
            (_) async => Future.value([jsonEncode(user1Json), 200]));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.setAppNotifications("true")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.setSmsNotifications("false")).thenAnswer(
            (_) async => Future.value());

    var user2Json = {"id": "2",
      "username": "user2",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"};
    when(mockSecureStorage.getCurrentUserData()).thenAnswer(
            (_) async => Future.value(user2Json));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("smsNotifications")));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Błąd edycji powiadomień. Spróbuj ponownie."), findsOneWidget);

    verify(await mockApi.editNotifications(1, "true", "false"));
  });

  /// tests if changes app notifications with other account
  testWidgets('changes app notifications with other account', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editNotifications(1, "false", "true")).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "400"}));

    var user1Json = {"id": 1,
      "username": "user1",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "",
      "sms_notifications": true,
      "app_notifications": true,
      "is_staff": false,
      "is_active": true};
    when(mockApi.getUser("user1")).thenAnswer(
            (_) async => Future.value([jsonEncode(user1Json), 200]));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.setAppNotifications("true")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.setSmsNotifications("false")).thenAnswer(
            (_) async => Future.value());

    var user2Json = {"id": "2",
      "username": "user2",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"
    };
    when(mockSecureStorage.getCurrentUserData()).thenAnswer(
            (_) async => Future.value(user2Json));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("appNotifications")));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Błąd edycji powiadomień. Spróbuj ponownie."), findsOneWidget);

    verify(await mockApi.editNotifications(1, "false", "true"));
  });

  /// tests if does not change sms notifications if api error, english
  testWidgets('english does not change sms notifications if api error', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editNotifications(1, "true", "false")).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "400"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.setAppNotifications("true")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.setSmsNotifications("false")).thenAnswer(
            (_) async => Future.value());

    var userJson = {"id": "1",
      "username": "user1",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"};

    when(mockSecureStorage.getCurrentUserData()).thenAnswer(
            (_) async => Future.value(userJson));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("smsNotifications")));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Editing notifications error. Try again."), findsOneWidget);

    verify(await mockApi.editNotifications(1, "true", "false"));
  });
}