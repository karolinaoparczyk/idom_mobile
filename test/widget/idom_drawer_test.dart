import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/pages/actions/actions.dart';
import 'package:idom/pages/cameras/cameras.dart';
import 'package:idom/pages/data_download/data_download.dart';
import 'package:idom/pages/drivers/drivers.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/pages/setup/settings.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';
import 'package:idom/pages/sensors/sensors.dart';

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

  /// tests if goes to my account
  testWidgets('goes to my account', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    when(mockSecureStorage.getIsUserStaff())
        .thenAnswer((_) async => Future.value("true"));
    when(mockSecureStorage.getUserId())
        .thenAnswer((_) async => Future.value("1"));
    when(mockSecureStorage.getUsername())
        .thenAnswer((_) async => Future.value("user1"));
    var userJson = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "+48765677655",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "true",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userJson));

    List<Map<String, dynamic>> sensors = [];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('drawer')));
    await tester.pumpAndSettle();

    expect(find.text("IDOM"), findsOneWidget);
    expect(find.text("TWÓJ INTELIGENTNY DOM W JEDNYM MIEJSCU"), findsOneWidget);
    expect(find.text("user1"), findsOneWidget);
    expect(find.text("Moje konto"), findsOneWidget);
    expect(find.text("Wszystkie konta"), findsOneWidget);
    expect(find.text("Czujniki"), findsNWidgets(2));
    expect(find.text("Kamery"), findsOneWidget);
    expect(find.text("Sterowniki"), findsOneWidget);
    expect(find.text("Akcje"), findsOneWidget);
    expect(find.text("Ustawienia"), findsOneWidget);
    await tester.drag(find.byKey(Key('drawerList')), const Offset(0.0, -300));
    expect(find.text("Pobierz dane"), findsOneWidget);
    expect(find.text("Wyloguj"), findsOneWidget);
    expect(find.text("O projekcie"), findsOneWidget);

    await tester.pumpAndSettle();
    await tester.tap(find.text('Moje konto'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountDetail), findsOneWidget);
  });

  /// tests if goes to all accounts
  testWidgets('goes to all accounts', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    when(mockSecureStorage.getIsUserStaff())
        .thenAnswer((_) async => Future.value("true"));
    when(mockSecureStorage.getUserId())
        .thenAnswer((_) async => Future.value("1"));
    when(mockSecureStorage.getUsername())
        .thenAnswer((_) async => Future.value("user1"));
    var userJson = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "+48765677655",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "true",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userJson));

    List<Map<String, dynamic>> sensors = [];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
    List<Map<String, dynamic>> accounts = [];
    when(mockApi.getAccounts()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(accounts), "statusCode": "200"}));

    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('drawer')));

    await tester.pumpAndSettle();
    await tester.tap(find.text('Wszystkie konta'));
    await tester.pumpAndSettle();
    expect(find.byType(Accounts), findsOneWidget);
  });

  /// tests if goes to sensors
  testWidgets('goes to sensors', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    when(mockSecureStorage.getIsUserStaff())
        .thenAnswer((_) async => Future.value("true"));
    when(mockSecureStorage.getUserId())
        .thenAnswer((_) async => Future.value("1"));
    when(mockSecureStorage.getUsername())
        .thenAnswer((_) async => Future.value("user1"));
    var userJson = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "+48765677655",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "true",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userJson));

    List<Map<String, dynamic>> sensors = [];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
    List<Map<String, dynamic>> accounts = [];
    when(mockApi.getAccounts()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(accounts), "statusCode": "200"}));

    Accounts page = Accounts(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('drawer')));

    await tester.pumpAndSettle();
    await tester.tap(find.text('Czujniki'));
  });

  /// tests if goes to cameras
  testWidgets('goes to cameras', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    when(mockSecureStorage.getIsUserStaff())
        .thenAnswer((_) async => Future.value("true"));
    when(mockSecureStorage.getUserId())
        .thenAnswer((_) async => Future.value("1"));
    when(mockSecureStorage.getUsername())
        .thenAnswer((_) async => Future.value("user1"));
    var userJson = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "+48765677655",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "true",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userJson));

    List<Map<String, dynamic>> sensors = [];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
    List<Map<String, dynamic>> cameras = [];
    when(mockApi.getCameras()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(cameras), "statusCode": "200"}));

    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('drawer')));

    await tester.pumpAndSettle();
    await tester.tap(find.text('Kamery'));
    await tester.pumpAndSettle();
    expect(find.byType(Cameras), findsOneWidget);
  });

  /// tests if goes to drivers
  testWidgets('goes to drivers', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    when(mockSecureStorage.getIsUserStaff())
        .thenAnswer((_) async => Future.value("true"));
    when(mockSecureStorage.getUserId())
        .thenAnswer((_) async => Future.value("1"));
    when(mockSecureStorage.getUsername())
        .thenAnswer((_) async => Future.value("user1"));
    var userJson = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "+48765677655",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "true",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userJson));

    List<Map<String, dynamic>> sensors = [];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
    List<Map<String, dynamic>> drivers = [];
    when(mockApi.getDrivers()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(drivers), "statusCode": "200"}));

    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('drawer')));

    await tester.pumpAndSettle();
    await tester.tap(find.text('Sterowniki'));
    await tester.pumpAndSettle();
    expect(find.byType(Drivers), findsOneWidget);
  });

  /// tests if goes to actions
  testWidgets('goes to actions', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    when(mockSecureStorage.getIsUserStaff())
        .thenAnswer((_) async => Future.value("true"));
    when(mockSecureStorage.getUserId())
        .thenAnswer((_) async => Future.value("1"));
    when(mockSecureStorage.getUsername())
        .thenAnswer((_) async => Future.value("user1"));
    var userJson = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "+48765677655",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "true",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userJson));

    List<Map<String, dynamic>> sensors = [];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
    List<Map<String, dynamic>> actions = [];
    when(mockApi.getActions()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(actions), "statusCode": "200"}));

    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('drawer')));

    await tester.pumpAndSettle();
    await tester.tap(find.text('Akcje'));
    await tester.pumpAndSettle();
    expect(find.byType(ActionsList), findsOneWidget);
  });

  /// tests if goes to settings
  testWidgets('goes to settings', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    when(mockSecureStorage.getIsUserStaff())
        .thenAnswer((_) async => Future.value("true"));
    when(mockSecureStorage.getUserId())
        .thenAnswer((_) async => Future.value("1"));
    when(mockSecureStorage.getUsername())
        .thenAnswer((_) async => Future.value("user1"));
    var userJson = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "+48765677655",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "true",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userJson));

    List<Map<String, dynamic>> sensors = [];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('drawer')));

    await tester.pumpAndSettle();
    await tester.tap(find.text('Ustawienia'));
    await tester.pumpAndSettle();
    expect(find.byType(Settings), findsOneWidget);
  });

  /// tests if goes to download data
  testWidgets('goes to download data', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    when(mockSecureStorage.getIsUserStaff())
        .thenAnswer((_) async => Future.value("true"));
    when(mockSecureStorage.getUserId())
        .thenAnswer((_) async => Future.value("1"));
    when(mockSecureStorage.getUsername())
        .thenAnswer((_) async => Future.value("user1"));
    var userJson = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "+48765677655",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "true",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userJson));

    List<Map<String, dynamic>> sensors = [];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));

    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('drawer')));

    await tester.pumpAndSettle();
    await tester.drag(find.byKey(Key('drawerList')), const Offset(0.0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pobierz dane'));
    await tester.pumpAndSettle();
    expect(find.byType(DataDownload), findsOneWidget);
  });

  /// tests if goes to log out
  testWidgets('goes to log out', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    when(mockSecureStorage.getIsUserStaff())
        .thenAnswer((_) async => Future.value("true"));
    when(mockSecureStorage.getUserId())
        .thenAnswer((_) async => Future.value("1"));
    when(mockSecureStorage.getUsername())
        .thenAnswer((_) async => Future.value("user1"));
    var userJson = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "language": "pl",
      "telephone": "+48765677655",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "true",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userJson));

    List<Map<String, dynamic>> sensors = [];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
    when(mockApi.logOut()).thenAnswer((_) async => Future.value(null));
    Sensors page = Sensors(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('drawer')));

    await tester.pumpAndSettle();
    await tester.drag(find.byKey(Key('drawerList')), const Offset(0.0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wyloguj'));
    await tester.pumpAndSettle();
    verify(await mockApi.logOut()).called(1);
  });
}
