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

  /// tests if user details displayed correctly for current user, all data, notifications on
  testWidgets('user details displayed correctly, all data, notifications on',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    var userJson = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "telephone": "+48765677655",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userJson));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa użytkownika"), findsOneWidget);
    expect(find.text("user1"), findsNWidgets(2));
    expect(find.text("Adres e-mail"), findsOneWidget);
    expect(find.text("user@email.com"), findsOneWidget);
    expect(find.text("Nr telefonu komórkowego"), findsOneWidget);
    expect(find.text("+48765677655"), findsOneWidget);
    expect(find.text("Powiadomienia"), findsOneWidget);
    expect(find.text("Aplikacja"), findsOneWidget);
    expect(find.text("Sms"), findsOneWidget);
    final finderApp = find.byWidgetPredicate(
        (widget) =>
            widget is Switch &&
            widget.key == Key("appNotifications") &&
            widget.value == true);
    expect(finderApp, findsOneWidget);
    final finderSms = find.byWidgetPredicate(
        (widget) =>
            widget is Switch &&
            widget.key == Key("smsNotifications") &&
            widget.value == true);
    expect(finderSms, findsOneWidget);
  });

  /// tests if user details displayed correctly for current user, no telephone, notifications off
  testWidgets('user details displayed correctly, no telephone, notifications off',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    var userJson = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "telephone": "",
      "smsNotifications": "false",
      "appNotifications": "false",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userJson));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("user1"), findsNWidgets(2));
    expect(find.text("user@email.com"), findsOneWidget);
    expect(find.text("+48765677655"), findsNothing);
    final finderApp = find.byWidgetPredicate(
        (widget) =>
            widget is Switch &&
            widget.key == Key("appNotifications") &&
            widget.value == false);
    expect(finderApp, findsOneWidget);
    final finderSms = find.byWidgetPredicate(
        (widget) =>
            widget is Switch &&
            widget.key == Key("smsNotifications") &&
            widget.value == false);
    expect(finderSms, findsOneWidget);
  });

  /// tests if user details displayed correctly for other user, all data, notifications on
  testWidgets('user details displayed correctly for other user, all data, notifications on',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();

    var user1Json = {"id": 1,
      "username": "user1",
      "email": "user@email.com",
      "telephone": "+48765677655",
      "sms_notifications": true,
      "app_notifications": true,
      "is_staff": false,
      "is_active": true};
    when(mockApi.getUser("user1")).thenAnswer(
            (_) async => Future.value([jsonEncode(user1Json), 200]));

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    var user2Json = {"id": "2",
      "username": "user2",
      "email": "user@other.com",
      "telephone": "",
      "smsNotifications": "false",
      "appNotifications": "false",
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

    expect(find.text("user1"), findsNWidgets(2));
    expect(find.text("user@email.com"), findsOneWidget);
    expect(find.text("+48765677655"), findsOneWidget);
    final finderApp = find.byWidgetPredicate(
        (widget) =>
            widget is Switch &&
            widget.key == Key("appNotifications") &&
            widget.value == true);
    expect(finderApp, findsOneWidget);
    final finderSms = find.byWidgetPredicate(
        (widget) =>
            widget is Switch &&
            widget.key == Key("smsNotifications") &&
            widget.value == true);
    expect(finderSms, findsOneWidget);
  });

  /// tests if user details displayed correctly for other user, no telephone, notifications off
  testWidgets('user details displayed correctly for other user, no telephone, notifications off',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();

    var user1Json = {"id": 1,
      "username": "user1",
      "email": "user@email.com",
      "telephone": "",
      "sms_notifications": false,
      "app_notifications": false,
      "is_staff": false,
      "is_active": true};
    when(mockApi.getUser("user1")).thenAnswer(
            (_) async => Future.value([jsonEncode(user1Json), 200]));

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    var user2Json = {"id": "2",
      "username": "user2",
      "email": "user@other.com",
      "telephone": "+48765677655",
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

    expect(find.text("user1"), findsNWidgets(2));
    expect(find.text("user@email.com"), findsOneWidget);
    expect(find.text("+48765677655"), findsNothing);
    final finderApp = find.byWidgetPredicate(
        (widget) =>
            widget is Switch &&
            widget.key == Key("appNotifications") &&
            widget.value == false);
    expect(finderApp, findsOneWidget);
    final finderSms = find.byWidgetPredicate(
        (widget) =>
            widget is Switch &&
            widget.key == Key("smsNotifications") &&
            widget.value == false);
    expect(finderSms, findsOneWidget);
  });

  /// tests if user details displayed correctly for current user, all data, notifications on, english
  testWidgets('english user details displayed correctly, all data, notifications on',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();

        MockSecureStorage mockSecureStorage = MockSecureStorage();

        var userJson = {
          "id": "1",
          "username": "user1",
          "email": "user@email.com",
          "telephone": "+48765677655",
          "smsNotifications": "true",
          "appNotifications": "true",
          "isStaff": "false",
          "isActive": "true",
          "token": "token"
        };

        when(mockSecureStorage.getCurrentUserData())
            .thenAnswer((_) async => Future.value(userJson));

        AccountDetail page = AccountDetail(
            storage: mockSecureStorage, username: "user1", testApi: mockApi);

        await tester.pumpWidget(makeEnglishTestableWidget(child: page));
        await tester.pumpAndSettle();

        expect(find.text("General"), findsOneWidget);
        expect(find.text("Username"), findsOneWidget);
        expect(find.text("user1"), findsNWidgets(2));
        expect(find.text("E-mail address"), findsOneWidget);
        expect(find.text("user@email.com"), findsOneWidget);
        expect(find.text("Cell phone number"), findsOneWidget);
        expect(find.text("+48765677655"), findsOneWidget);
        expect(find.text("Notifications"), findsOneWidget);
        expect(find.text("Application"), findsOneWidget);
        expect(find.text("Sms"), findsOneWidget);
        final finderApp = find.byWidgetPredicate(
                (widget) =>
            widget is Switch &&
                widget.key == Key("appNotifications") &&
                widget.value == true);
        expect(finderApp, findsOneWidget);
        final finderSms = find.byWidgetPredicate(
                (widget) =>
            widget is Switch &&
                widget.key == Key("smsNotifications") &&
                widget.value == true);
        expect(finderSms, findsOneWidget);
      });
}
