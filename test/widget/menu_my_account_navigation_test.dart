import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/pages/sensors/new_sensor.dart';
import 'package:idom/pages/sensors/sensor_details.dart';
import 'package:idom/pages/sensors/sensors.dart';
import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/pages/account/accounts.dart';

class MockApi extends Mock implements Api {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  /// tests if navigates to my account from accounts page
  testWidgets('navigates to my account, page accounts',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Account account = Account(
        id: 1,
        username: "user1",
        email: "email@email.com",
        telephone: "",
        appNotifications: "true",
        smsNotifications: "true",
        isActive: true,
        isStaff: true);

    Accounts page = Accounts(
        currentLoggedInToken: "token", currentUser: account, api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.tap(find.byKey(Key('menuButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Moje konto'), findsOneWidget);
    await tester.tap(find.byKey(Key('Moje konto')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AccountDetail), findsOneWidget);
    expect(find.text('user1'), findsNWidgets(2));
    expect(find.text('email@email.com'), findsOneWidget);
  });

  /// tests if does not navigate to my account from accounts detail if user on my account page
  testWidgets(
      'does not navigate to my account from accounts detail if user on my account page',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();

    Account account = Account(
        id: 1,
        username: "username",
        email: "email@email.com",
        telephone: "",
        appNotifications: "true",
        smsNotifications: "true",
        isActive: true,
        isStaff: true);

    AccountDetail page = AccountDetail(
        currentLoggedInToken: "token",
        account: account,
        currentUser: account,
        api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('menuButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Moje konto'), findsOneWidget);
    await tester.tap(find.byKey(Key('Moje konto')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AccountDetail), findsOneWidget);
    expect(find.text('username'), findsNWidgets(2));
    expect(find.text('email@email.com'), findsOneWidget);
  });

  /// tests if navigates to my account from accounts detail if user not on my account page
  testWidgets(
      'navigates to my account from accounts detail if user not on my account page',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();

    Account account = Account(
        id: 1,
        username: "username",
        email: "email@email.com",
        telephone: "",
        appNotifications: "true",
        smsNotifications: "true",
        isActive: true,
        isStaff: true);

    Account currentUser = Account(
        id: 1,
        username: "user1",
        email: "email@f.com",
        telephone: "",
        appNotifications: "true",
        smsNotifications: "true",
        isActive: true,
        isStaff: true);

    AccountDetail page = AccountDetail(
        currentLoggedInToken: "token",
        account: account,
        currentUser: currentUser,
        api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('menuButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Moje konto'), findsOneWidget);
    await tester.tap(find.byKey(Key('Moje konto')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AccountDetail), findsOneWidget);
    expect(find.text('user1'), findsNWidgets(2));
    expect(find.text('email@f.com'), findsOneWidget);
  });

  /// tests if navigates to my account from sensors page
  testWidgets('navigates to my account, page sensors',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Sensor> sensors = List();
    sensors.add(Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0"));
    sensors.add(Sensor(
        id: 2,
        name: "sensor2",
        category: "temperature",
        frequency: 300,
        lastData: "27.0"));

    Account account = Account(
        id: 1,
        username: "username",
        email: "email@email.com",
        telephone: "",
        appNotifications: "true",
        smsNotifications: "true",
        isActive: true,
        isStaff: true);

    Sensors page = Sensors(
      currentLoggedInToken: "token",
      currentUser: account,
      api: mockApi,
      testSensors: sensors,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.tap(find.byKey(Key('menuButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Moje konto'), findsOneWidget);
    await tester.tap(find.byKey(Key('Moje konto')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AccountDetail), findsOneWidget);
    expect(find.text('username'), findsNWidgets(2));
    expect(find.text('email@email.com'), findsOneWidget);
  });

  /// tests if navigates to my account from sensors details page
  testWidgets('navigates to my account, page sensors details',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0");

    Account account = Account(
        id: 1,
        username: "username",
        email: "email@email.com",
        telephone: "",
        appNotifications: "true",
        smsNotifications: "true",
        isActive: true,
        isStaff: true);

    SensorDetails page = SensorDetails(
        currentLoggedInToken: "token",
        currentUser: account,
        sensor: sensor,
        api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('menuButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Moje konto'), findsOneWidget);
    await tester.tap(find.byKey(Key('Moje konto')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AccountDetail), findsOneWidget);
    expect(find.text('username'), findsNWidgets(2));
    expect(find.text('email@email.com'), findsOneWidget);
  });

  /// tests if navigates to my account from add sensor page
  testWidgets('navigates to my account, page add sensor',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Account account = Account(
        id: 1,
        username: "username",
        email: "email@email.com",
        telephone: "",
        appNotifications: "true",
        smsNotifications: "true",
        isActive: true,
        isStaff: true);

    NewSensor page = NewSensor(
        currentLoggedInToken: "token", currentUser: account, api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('menuButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Moje konto'), findsOneWidget);
    await tester.tap(find.byKey(Key('Moje konto')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AccountDetail), findsOneWidget);
    expect(find.text('username'), findsNWidgets(2));
    expect(find.text('email@email.com'), findsOneWidget);
  });
}
