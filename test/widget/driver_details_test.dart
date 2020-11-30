import 'package:idom/models.dart';
import 'package:idom/pages/drivers/driver_details.dart';
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

  /// tests if displays driver's details, sends command to driver
  testWidgets('displays driver details, sends command to driver', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
   Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "clicker");

    when(mockApi.startDriver("driver1")).thenAnswer((_) async =>
        Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("driver1"), findsNWidgets(2));
    expect(find.text("Wciśnij przycisk"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/play.svg")), findsOneWidget);
    await tester.tap(find.byKey(Key("click")));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Wysłano komendę do sterownika driver1."), findsOneWidget);
  });

  /// tests if displays remote controller driver's details
  testWidgets('displays remote controller driver details', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
   Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "remote_control");

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DriverDetails page = DriverDetails(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
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
    expect(find.byKey(Key("assets/icons/previous_channel.svg")), findsOneWidget);
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

    expect(find.text("123"), findsOneWidget);
    await tester.tap(find.byKey(Key("assets/icons/left-arrow-long.svg")));
    expect(find.text("12"), findsOneWidget);
  });
}
