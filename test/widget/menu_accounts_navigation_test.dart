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

  /// tests if does not navigate to accounts from accounts page
  testWidgets('does not navigate, page accounts', (WidgetTester tester) async {
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

    Accounts page = Accounts(
        currentLoggedInToken: "token", currentUser: account, api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.tap(find.byKey(Key('menuButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Konta'), findsOneWidget);
    await tester.tap(find.byKey(Key('Konta')));
    expect(find.byType(Accounts), findsOneWidget);
  });

  /// tests if navigates back to accounts from account details page
  testWidgets('navigates back, page account details',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Account> accounts = List();
    accounts.add(Account(
        id: 1,
        username: "user1",
        email: "user@email.com",
        telephone: "",
        smsNotifications: "true",
        appNotifications: "true",
        isStaff: true,
        isActive: false));
    accounts.add(Account(
        id: 2,
        username: "user2",
        email: "user2@email.com",
        telephone: "",
        smsNotifications: "true",
        appNotifications: "true",
        isStaff: false,
        isActive: false));

    Account account = Account(
        id: 1,
        username: "username",
        email: "email@email.com",
        telephone: "",
        appNotifications: "true",
        smsNotifications: "true",
        isActive: true,
        isStaff: true);

    Accounts page = Accounts(
        currentLoggedInToken: "token",
        currentUser: account,
        api: mockApi,
        testAccounts: accounts);

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('user1')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AccountDetail), findsOneWidget);

    await tester.tap(find.byKey(Key('menuButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Konta'), findsOneWidget);
    await tester.tap(find.byKey(Key('Konta')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(Accounts), findsOneWidget);
  });

  /// tests if navigates to accounts from sensors page
  testWidgets('navigates, page sensors', (WidgetTester tester) async {
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

    expect(find.text('Konta'), findsOneWidget);
    await tester.tap(find.byKey(Key('Konta')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(Accounts), findsOneWidget);
  });

  /// tests if navigates accounts from sensor details page
  testWidgets('navigates, page sensor details', (WidgetTester tester) async {
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

    expect(find.text('Konta'), findsOneWidget);
    await tester.tap(find.byKey(Key('Konta')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(Accounts), findsOneWidget);
  });

  /// tests if navigates accounts from add sensor page
  testWidgets('navigates, page add sensor', (WidgetTester tester) async {
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

    expect(find.text('Konta'), findsOneWidget);
    await tester.tap(find.byKey(Key('Konta')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(Accounts), findsOneWidget);
  });

  /// tests if no go to accounts choice available when not superuser, page accounts
  testWidgets('no go to accounts choice available when not superuser, page accounts', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Account account = Account(
        id: 1,
        username: "username",
        email: "email@email.com",
        telephone: "",
        appNotifications: "true",
        smsNotifications: "true",
        isActive: true,
        isStaff: false);

    Accounts page = Accounts(
        currentLoggedInToken: "token", currentUser: account, api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.tap(find.byKey(Key('menuButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Konta'), findsNothing);
  });

  /// tests if no go to accounts choice available when not superuser, page accounts details
  testWidgets('no go to accounts choice available when not superuser, page accounts details', (WidgetTester tester) async {
        MockApi mockApi = MockApi();

        Account account = Account(
            id: 1,
            username: "username",
            email: "email@email.com",
            telephone: "",
            appNotifications: "true",
            smsNotifications: "true",
            isActive: true,
            isStaff: false);

        AccountDetail page = AccountDetail(
            currentLoggedInToken: "token",
            account: account,
            currentUser: account,
            api: mockApi,);

        await tester.pumpWidget(makeTestableWidget(child: page));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key('menuButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Konta'), findsNothing);
  });

  /// tests if no go to accounts choice available when not superuser, page sensors
  testWidgets('no go to accounts choice available when not superuser, page sensors', (WidgetTester tester) async {
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
        isStaff: false);

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

    expect(find.text('Konta'), findsNothing);
  });

  /// tests if no go to accounts choice available when not superuser, page sensors details
  testWidgets('no go to accounts choice available when not superuser, page sensors details', (WidgetTester tester) async {
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
        isStaff: false);

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

    expect(find.text('Konta'), findsNothing);
  });

  /// tests if no go to accounts choice available when not superuser, page add sensor
  testWidgets('no go to accounts choice available when not superuser, page add sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();

    Account account = Account(
        id: 1,
        username: "username",
        email: "email@email.com",
        telephone: "",
        appNotifications: "true",
        smsNotifications: "true",
        isActive: true,
        isStaff: false);

    NewSensor page = NewSensor(
        currentLoggedInToken: "token", currentUser: account, api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('menuButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Konta'), findsNothing);
  });
}
