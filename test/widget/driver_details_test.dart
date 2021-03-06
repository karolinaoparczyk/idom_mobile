import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/drivers/driver_details.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';

class MockApi extends Mock implements Api {}

class RemoteControl extends Mock implements Api {}

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

  /// tests if displays driver's details, sends command to driver
  testWidgets('displays driver details, sends command to driver',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(id: 1, name: "driver1", category: "clicker");

    when(mockApi.startDriver("driver1"))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("driver1"), findsNWidgets(2));
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Obsługa sterownika"), findsOneWidget);
    expect(find.text("Wciśnij przycisk"), findsOneWidget);
    expect(find.text("Aktualny stan"), findsNothing);
    expect(find.text("włączona"), findsNothing);
    expect(find.text("wyłączona"), findsNothing);
    expect(find.text("Wciśnij przycisk"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/play.svg")), findsOneWidget);
    await tester.tap(find.byKey(Key("click")));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Wysłano komendę do sterownika driver1."), findsOneWidget);
  });

  /// tests if displays blinds's details, sends command to blinds
  testWidgets('displays blinds details, sends command to blinds',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver =
        Driver(id: 1, name: "driver1", category: "roller_blind", data: true);

    when(mockApi.startDriver("driver1"))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("driver1"), findsNWidgets(2));
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Obsługa sterownika"), findsOneWidget);
    expect(find.text("Aktualny stan"), findsOneWidget);
    expect(find.text("podniesione"), findsOneWidget);
    expect(find.text("opuszczone"), findsNothing);
    expect(find.text("Podnieś/opuść rolety"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/up-arrow.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/down-arrow.svg")), findsOneWidget);
  });

  /// tests if displays remote controller driver's details
  testWidgets('displays remote controller driver details',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "remote_control",
        ipAddress: "127.0.0.1");

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
      remoteStatusCode: 200,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("driver1"), findsNWidgets(2));
    expect(find.byKey(Key("assets/icons/menu.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/turn-off.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/up-arrow.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/left-arrow.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/right-arrow.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/down-arrow.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/no-sound.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/return.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/volume-up.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/cubes.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/next_channel.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/volume-down.svg")), findsOneWidget);
    expect(
        find.byKey(Key("assets/icons/previous_channel.svg")), findsOneWidget);
    expect(find.text("VOL"), findsOneWidget);
    expect(find.text("CH"), findsOneWidget);
    expect(find.text("OK"), findsOneWidget);

    await tester.tap(find.byKey(Key("assets/icons/cubes.svg")));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("1")), findsOneWidget);
    expect(find.byKey(Key("2")), findsOneWidget);
    expect(find.byKey(Key("3")), findsOneWidget);
    expect(find.byKey(Key("4")), findsOneWidget);
    expect(find.byKey(Key("5")), findsOneWidget);
    expect(find.byKey(Key("6")), findsOneWidget);
    expect(find.byKey(Key("7")), findsOneWidget);
    expect(find.byKey(Key("8")), findsOneWidget);
    expect(find.byKey(Key("9")), findsOneWidget);
    expect(find.byKey(Key("0")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/left-arrow-long.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/enter.svg")), findsOneWidget);
    expect(find.text("WRÓĆ"), findsOneWidget);

    await tester.tap(find.byKey(Key("1")));
    await tester.tap(find.byKey(Key("2")));
    await tester.tap(find.byKey(Key("3")));
    await tester.tap(find.byKey(Key("4")));

    await tester.pumpAndSettle();
    expect(find.text("123"), findsOneWidget);
    await tester.tap(find.byKey(Key("assets/icons/left-arrow-long.svg")));
    expect(find.text("12"), findsOneWidget);
  });

  /// tests if displays remote controller driver's details, sends command
  testWidgets('displays remote controller driver details, sends command',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "remote_control",
        ipAddress: "127.0.0.1");

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
      remoteStatusCode: 200,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("driver1"), findsNWidgets(2));
    expect(find.byKey(Key("assets/icons/menu.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/turn-off.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/up-arrow.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/left-arrow.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/right-arrow.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/down-arrow.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/no-sound.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/return.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/volume-up.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/cubes.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/next_channel.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/volume-down.svg")), findsOneWidget);
    expect(
        find.byKey(Key("assets/icons/previous_channel.svg")), findsOneWidget);
    expect(find.text("VOL"), findsOneWidget);
    expect(find.text("CH"), findsOneWidget);
    expect(find.text("OK"), findsOneWidget);

    await tester.tap(find.byKey(Key("Mute")));
    await tester.pumpAndSettle();
    expect(find.text("Komenda wysłana do pilota."), findsOneWidget);
    await tester.pump(Duration(seconds: 5));

    await tester.tap(find.byKey(Key("assets/icons/cubes.svg")));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("1")), findsOneWidget);
    expect(find.byKey(Key("2")), findsOneWidget);
    expect(find.byKey(Key("3")), findsOneWidget);
    expect(find.byKey(Key("4")), findsOneWidget);
    expect(find.byKey(Key("5")), findsOneWidget);
    expect(find.byKey(Key("6")), findsOneWidget);
    expect(find.byKey(Key("7")), findsOneWidget);
    expect(find.byKey(Key("8")), findsOneWidget);
    expect(find.byKey(Key("9")), findsOneWidget);
    expect(find.byKey(Key("0")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/left-arrow-long.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/enter.svg")), findsOneWidget);
    expect(find.text("WRÓĆ"), findsOneWidget);

    await tester.tap(find.byKey(Key("1")));
    await tester.tap(find.byKey(Key("2")));
    await tester.tap(find.byKey(Key("3")));
    await tester.tap(find.byKey(Key("4")));
  });

  /// tests if displays bulb's details, change color
  testWidgets('displays bulbs details, change color',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "bulb",
        ipAddress: "111.222.33.44",
        data: true);

    when(mockApi.changeBulbColor(1, 128, 128, 128))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("driver1"), findsNWidgets(2));
    expect(find.text("Aktualny stan"), findsOneWidget);
    expect(find.text("włączona"), findsOneWidget);
    expect(find.text("Obsługa sterownika"), findsOneWidget);
    expect(find.text("Wciśnij przycisk"), findsNothing);
    expect(find.text("Ustaw kolor"), findsOneWidget);
    expect(find.text("Ustaw jasność"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/turn-off.svg")), findsOneWidget);
    await tester.tap(find.byKey(Key("assets/icons/enter.svg")).first);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Wysłano komendę zmiany koloru żarówki driver1."),
        findsOneWidget);
    verify(await mockApi.changeBulbColor(1, 128, 128, 128)).called(1);
  });

  /// tests if changes bulb's brightness
  testWidgets('change bulb brightness', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "bulb",
        ipAddress: "111.222.33.44",
        data: false);

    when(mockApi.changeBulbBrightness(1, 50))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("driver1"), findsNWidgets(2));
    expect(find.text("Aktualny stan"), findsOneWidget);
    expect(find.text("wyłączona"), findsOneWidget);
    await tester.tap(find.byKey(Key("assets/icons/enter.svg")).last);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Wysłano komendę zmiany jasności żarówki driver1."),
        findsOneWidget);
    verify(await mockApi.changeBulbBrightness(1, 50)).called(1);
  });

  /// tests if displays bulb's details, change color, no ip
  testWidgets('displays bulbs details, change color, no ip',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1, name: "driver1", category: "bulb", ipAddress: null, data: true);

    when(mockApi.changeBulbColor(1, 128, 128, 128))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key("assets/icons/enter.svg")).first);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Żarówka nie posiada adresu IP."), findsOneWidget);
    verifyNever(await mockApi.changeBulbColor(1, 128, 128, 128));
  });

  /// tests if changes bulb's brightness, no ip
  testWidgets('change bulb brightness, no ip', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1, name: "driver1", category: "bulb", ipAddress: null, data: false);

    when(mockApi.changeBulbBrightness(1, 50))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("assets/icons/enter.svg")).last);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Żarówka nie posiada adresu IP."), findsOneWidget);
    verifyNever(await mockApi.changeBulbBrightness(1, 50));
  });

  /// tests if turns bulb on, data null
  testWidgets('turn bulb on, data null', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "bulb",
        ipAddress: "111.222.33.44",
        data: null);

    Map<String, dynamic> bulb = {
      "id": 1,
      "name": "driver1",
      "category": "bulb",
      "data": true,
      "ipAddress": "111.222.33.44"
    };
    when(mockApi.switchBulb(1, "on"))
        .thenAnswer((_) async => Future.value(200));
    when(mockApi.getDriverDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(bulb), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("driver1"), findsNWidgets(2));
    expect(find.text("Aktualny stan"), findsNothing);
    await tester.tap(find.byKey(Key("assets/icons/turn-off.svg")));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Wysłano komendę włączenia żarówki driver1."),
        findsOneWidget);
    verify(await mockApi.switchBulb(1, "on")).called(1);
  });

  /// tests if turns bulb on, data false
  testWidgets('turn bulb on, data false', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "bulb",
        ipAddress: "111.222.33.44",
        data: false);

    Map<String, dynamic> bulb = {
      "id": 1,
      "name": "driver1",
      "category": "bulb",
      "data": true
    };
    when(mockApi.switchBulb(1, "on"))
        .thenAnswer((_) async => Future.value(200));
    when(mockApi.getDriverDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(bulb), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("driver1"), findsNWidgets(2));
    expect(find.text("Aktualny stan"), findsOneWidget);
    expect(find.text("wyłączona"), findsOneWidget);
    await tester.tap(find.byKey(Key("assets/icons/turn-off.svg")));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Wysłano komendę włączenia żarówki driver1."),
        findsOneWidget);
    expect(find.text("włączona"), findsOneWidget);
    verify(await mockApi.switchBulb(1, "on")).called(1);
  });

  /// tests if turns bulb on, data false, no ip
  testWidgets('turn bulb on, data false, no ip', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1, name: "driver1", category: "bulb", ipAddress: null, data: false);

    Map<String, dynamic> bulb = {
      "id": 1,
      "name": "driver1",
      "category": "bulb",
      "data": true
    };
    when(mockApi.switchBulb(1, "on"))
        .thenAnswer((_) async => Future.value(200));
    when(mockApi.getDriverDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(bulb), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("assets/icons/turn-off.svg")));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Żarówka nie posiada adresu IP."), findsOneWidget);
    expect(find.text("wyłączona"), findsOneWidget);
    verifyNever(await mockApi.switchBulb(1, "on"));
  });

  /// tests if turns bulb off, data true
  testWidgets('turn bulb off, data true', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "bulb",
        ipAddress: "111.222.33.44",
        data: true);

    Map<String, dynamic> bulb = {
      "id": 1,
      "name": "driver1",
      "category": "bulb",
      "data": false
    };
    when(mockApi.switchBulb(1, "off"))
        .thenAnswer((_) async => Future.value(200));
    when(mockApi.getDriverDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(bulb), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("driver1"), findsNWidgets(2));
    expect(find.text("Aktualny stan"), findsOneWidget);
    expect(find.text("włączona"), findsOneWidget);
    await tester.tap(find.byKey(Key("assets/icons/turn-off.svg")));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Wysłano komendę wyłączenia żarówki driver1."),
        findsOneWidget);
    expect(find.text("wyłączona"), findsOneWidget);
    verify(await mockApi.switchBulb(1, "off")).called(1);
  });

  /// tests if displays driver's details, sends command to driver, english
  testWidgets('english displays driver details, sends command to driver',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(id: 1, name: "driver1", category: "clicker");

    when(mockApi.startDriver("driver1"))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("driver1"), findsNWidgets(2));
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("General"), findsOneWidget);
    expect(find.text("Driver handler"), findsOneWidget);
    expect(find.text("Press the button"), findsOneWidget);
    expect(find.text("Current state"), findsNothing);
    expect(find.text("on"), findsNothing);
    expect(find.text("off"), findsNothing);
    expect(find.byKey(Key("assets/icons/play.svg")), findsOneWidget);
    await tester.tap(find.byKey(Key("click")));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("The command to driver driver1 has been sent."),
        findsOneWidget);
  });

  /// tests if displays remote controller driver's details, english
  testWidgets('english displays remote controller driver details',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(id: 1, name: "driver1", category: "remote_control");

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("driver1"), findsNWidgets(2));
    expect(find.byKey(Key("assets/icons/menu.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/turn-off.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/up-arrow.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/left-arrow.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/right-arrow.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/down-arrow.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/no-sound.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/return.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/volume-up.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/cubes.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/next_channel.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/volume-down.svg")), findsOneWidget);
    expect(
        find.byKey(Key("assets/icons/previous_channel.svg")), findsOneWidget);
    expect(find.text("VOL"), findsOneWidget);
    expect(find.text("CH"), findsOneWidget);
    expect(find.text("OK"), findsOneWidget);

    await tester.tap(find.byKey(Key("assets/icons/cubes.svg")));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("1")), findsOneWidget);
    expect(find.byKey(Key("2")), findsOneWidget);
    expect(find.byKey(Key("3")), findsOneWidget);
    expect(find.byKey(Key("4")), findsOneWidget);
    expect(find.byKey(Key("5")), findsOneWidget);
    expect(find.byKey(Key("6")), findsOneWidget);
    expect(find.byKey(Key("7")), findsOneWidget);
    expect(find.byKey(Key("8")), findsOneWidget);
    expect(find.byKey(Key("9")), findsOneWidget);
    expect(find.byKey(Key("0")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/left-arrow-long.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/enter.svg")), findsOneWidget);
    expect(find.text("GO BACK"), findsOneWidget);

    await tester.tap(find.byKey(Key("1")));
    await tester.tap(find.byKey(Key("2")));
    await tester.tap(find.byKey(Key("3")));
    await tester.tap(find.byKey(Key("4")));

    expect(find.text("123"), findsOneWidget);
    await tester.tap(find.byKey(Key("assets/icons/left-arrow-long.svg")));
    expect(find.text("12"), findsOneWidget);
  });

  /// tests if displays bulb's details, change color, english
  testWidgets('english displays bulbs details, change color',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "bulb",
        ipAddress: "111.222.33.44",
        data: true);

    when(mockApi.changeBulbColor(1, 128, 128, 128))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("driver1"), findsNWidgets(2));
    expect(find.text("Current state"), findsOneWidget);
    expect(find.text("on"), findsOneWidget);
    expect(find.text("Driver handler"), findsOneWidget);
    expect(find.text("Press the button"), findsNothing);
    expect(find.text("Set color"), findsOneWidget);
    expect(find.text("Set brightness"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/turn-off.svg")), findsOneWidget);
    await tester.tap(find.byKey(Key("assets/icons/enter.svg")).first);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(
        find.text(
            "The command to change the color of bulb driver1 has been sent."),
        findsOneWidget);
    verify(await mockApi.changeBulbColor(1, 128, 128, 128)).called(1);
  });

  /// tests if changes bulb's brightness, english
  testWidgets('english change bulb brightness', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "bulb",
        ipAddress: "111.222.33.44",
        data: false);

    when(mockApi.changeBulbBrightness(1, 50))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("driver1"), findsNWidgets(2));
    expect(find.text("Current state"), findsOneWidget);
    expect(find.text("off"), findsOneWidget);
    expect(find.text("Driver handler"), findsOneWidget);
    expect(find.text("Press the button"), findsNothing);
    expect(find.text("Set color"), findsOneWidget);
    expect(find.text("Set brightness"), findsOneWidget);
    await tester.tap(find.byKey(Key("assets/icons/enter.svg")).last);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(
        find.text(
            "The command to change the brightness of bulb driver1 has been sent."),
        findsOneWidget);
    verify(await mockApi.changeBulbBrightness(1, 50)).called(1);
  });

  /// tests if turns bulb on, data null, english
  testWidgets('english turn bulb on, data null', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "bulb",
        ipAddress: "111.222.33.44",
        data: null);

    Map<String, dynamic> bulb = {
      "id": 1,
      "name": "driver1",
      "category": "bulb",
      "data": true
    };
    when(mockApi.switchBulb(1, "on"))
        .thenAnswer((_) async => Future.value(200));
    when(mockApi.getDriverDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(bulb), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("driver1"), findsNWidgets(2));
    expect(find.text("Current state"), findsNothing);
    await tester.tap(find.byKey(Key("assets/icons/turn-off.svg")));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("The command to turn on bulb driver1 has been sent."),
        findsOneWidget);
    verify(await mockApi.switchBulb(1, "on")).called(1);
  });

  /// tests if turns bulb on, data false, english
  testWidgets('english turn bulb on, data false', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "bulb",
        ipAddress: "111.222.33.44",
        data: false);

    Map<String, dynamic> bulb = {
      "id": 1,
      "name": "driver1",
      "category": "bulb",
      "data": true
    };
    when(mockApi.switchBulb(1, "on"))
        .thenAnswer((_) async => Future.value(200));
    when(mockApi.getDriverDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(bulb), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("driver1"), findsNWidgets(2));
    expect(find.text("Current state"), findsOneWidget);
    expect(find.text("off"), findsOneWidget);
    await tester.tap(find.byKey(Key("assets/icons/turn-off.svg")));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("The command to turn on bulb driver1 has been sent."),
        findsOneWidget);
    expect(find.text("on"), findsOneWidget);
    verify(await mockApi.switchBulb(1, "on")).called(1);
  });

  /// tests if turns bulb off, data true, english
  testWidgets('english turn bulb off, data true', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "bulb",
        ipAddress: "111.222.33.44",
        data: true);

    Map<String, dynamic> bulb = {
      "id": 1,
      "name": "driver1",
      "category": "bulb",
      "data": false
    };
    when(mockApi.switchBulb(1, "off"))
        .thenAnswer((_) async => Future.value(200));
    when(mockApi.getDriverDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(bulb), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("driver1"), findsNWidgets(2));
    expect(find.text("Current state"), findsOneWidget);
    expect(find.text("on"), findsOneWidget);
    await tester.tap(find.byKey(Key("assets/icons/turn-off.svg")));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("The command to turn off bulb driver1 has been sent."),
        findsOneWidget);
    expect(find.text("off"), findsOneWidget);
    verify(await mockApi.switchBulb(1, "off")).called(1);
  });

  /// tests if displays blinds's details, sends command to blinds, english
  testWidgets('english displays blinds details, sends command to blinds',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver =
        Driver(id: 1, name: "driver1", category: "roller_blind", data: true);

    when(mockApi.startDriver("driver1"))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("driver1"), findsNWidgets(2));
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("General"), findsOneWidget);
    expect(find.text("Driver handler"), findsOneWidget);
    expect(find.text("Current state"), findsOneWidget);
    expect(find.text("raised"), findsOneWidget);
    expect(find.text("lowered"), findsNothing);
    expect(find.text("Raise/lower blinds"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/up-arrow.svg")), findsOneWidget);
    expect(find.byKey(Key("assets/icons/down-arrow.svg")), findsOneWidget);
  });

  /// tests if displays bulb's details, change color, no ip, english
  testWidgets('english displays bulbs details, change color, no ip',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1, name: "driver1", category: "bulb", ipAddress: null, data: true);

    when(mockApi.changeBulbColor(1, 128, 128, 128))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key("assets/icons/enter.svg")).first);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("The bulb does not have an IP address."), findsOneWidget);
    verifyNever(await mockApi.changeBulbColor(1, 128, 128, 128));
  });

  /// tests if changes bulb's brightness, no ip, english
  testWidgets('english change bulb brightness, no ip',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1, name: "driver1", category: "bulb", ipAddress: null, data: false);

    when(mockApi.changeBulbBrightness(1, 50))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("assets/icons/enter.svg")).last);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("The bulb does not have an IP address."), findsOneWidget);
    verifyNever(await mockApi.changeBulbBrightness(1, 50));
  });

  /// tests if turns bulb on, data false, no ip, english
  testWidgets('english urn bulb on, data false, no ip',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1, name: "driver1", category: "bulb", ipAddress: null, data: false);

    Map<String, dynamic> bulb = {
      "id": 1,
      "name": "driver1",
      "category": "bulb",
      "data": true
    };
    when(mockApi.switchBulb(1, "on"))
        .thenAnswer((_) async => Future.value(200));
    when(mockApi.getDriverDetails(1)).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(bulb), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("assets/icons/turn-off.svg")));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("The bulb does not have an IP address."), findsOneWidget);
    expect(find.text("off"), findsOneWidget);
    verifyNever(await mockApi.switchBulb(1, "on"));
  });
}
