import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idom/pages/sensors/new_sensor.dart';
import 'package:idom/pages/sensors/sensor_details.dart';
import 'package:idom/pages/sensors/sensors.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/pages/setup/front.dart';

class MockApi extends Mock implements Api {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  /// tests if logged out from accounts page when valid token
  testWidgets('valid token, logged out, page accounts',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        when(mockApi.logOut('token')).thenAnswer((_) async =>
            Future.value(200));
        Accounts page = Accounts(
            currentLoggedInToken: "token",
            currentLoggedInUsername: "username",
            api: mockApi);

        await tester.pumpWidget(makeTestableWidget(child: page));
        await tester.tap(find.byKey(Key('menuButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Wyloguj'), findsOneWidget);
        await tester.tap(find.byKey(Key('Wyloguj')));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(Front), findsOneWidget);
        verify(await mockApi.logOut('token')).called(1);
      });

  /// tests if still logged in when invalid token, accounts page
  testWidgets('invalid token, still logged in, page accounts',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        when(mockApi.logOut('token')).thenAnswer((_) async =>
            Future.value(404));
        Accounts page = Accounts(
            currentLoggedInToken: "token",
            currentLoggedInUsername: "username",
            api: mockApi);

        await tester.pumpWidget(makeTestableWidget(child: page));
        await tester.tap(find.byKey(Key('menuButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Wyloguj'), findsOneWidget);
        await tester.tap(find.byKey(Key('Wyloguj')));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.byKey(Key("ok button")), findsOneWidget);
        expect(find.byType(Accounts), findsOneWidget);
        verify(await mockApi.logOut('token')).called(1);
      });

  /// tests if logged out from account details page when valid token
  testWidgets('valid token, logged out, page account details',
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
        when(mockApi.logOut('token')).thenAnswer((_) async =>
            Future.value(200));
        AccountDetail page = AccountDetail(
            currentLoggedInToken: "token", account: account, api: mockApi);

        await tester.pumpWidget(makeTestableWidget(child: page));

        await tester.tap(find.byKey(Key('menuButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Wyloguj'), findsOneWidget);
        await tester.tap(find.byKey(Key('Wyloguj')));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(Front), findsOneWidget);
        verify(await mockApi.logOut('token')).called(1);
      });

  /// tests if still logged in, when invalid token, account details page
  testWidgets('invalid token, still logged in, page account details',
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
        when(mockApi.logOut('token')).thenAnswer((_) async =>
            Future.value(404));
        AccountDetail page = AccountDetail(
            currentLoggedInToken: "token", account: account, api: mockApi);

        await tester.pumpWidget(makeTestableWidget(child: page));

        await tester.tap(find.byKey(Key('menuButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Wyloguj'), findsOneWidget);
        await tester.tap(find.byKey(Key('Wyloguj')));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.byKey(Key("ok button")), findsOneWidget);
        expect(find.byType(AccountDetail), findsOneWidget);
        verify(await mockApi.logOut('token')).called(1);
      });

  /// tests if logged out from sensors list page when valid token
  testWidgets('valid token, logged out, page sensors list',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        List<Sensor> sensors = List();
        sensors.add(Sensor(
            id: 1,
            name: "sensor1",
            category: "temperature",
            batteryLevel: null,
            notifications: true,
            isActive: false));
        sensors.add(Sensor(
            id: 2,
            name: "sensor2",
            category: "temperature",
            batteryLevel: null,
            notifications: true,
            isActive: false));

        Sensors page = Sensors(
          currentLoggedInToken: "token",
          currentLoggedInUsername: "username",
          api: mockApi,
          testSensors: sensors,
        );
        when(mockApi.logOut('token')).thenAnswer((_) async =>
            Future.value(200));

        await tester.pumpWidget(makeTestableWidget(child: page));

        await tester.tap(find.byKey(Key('menuButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Wyloguj'), findsOneWidget);
        await tester.tap(find.byKey(Key('Wyloguj')));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(Front), findsOneWidget);
        verify(await mockApi.logOut('token')).called(1);
      });

  /// tests if still logged in, when invalid token, sensors list page
  testWidgets('invalid token, still logged in, page sensors list',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        List<Sensor> sensors = List();
        sensors.add(Sensor(
            id: 1,
            name: "sensor1",
            category: "temperature",
            batteryLevel: null,
            notifications: true,
            isActive: false));
        sensors.add(Sensor(
            id: 2,
            name: "sensor2",
            category: "temperature",
            batteryLevel: null,
            notifications: true,
            isActive: false));

        Sensors page = Sensors(
          currentLoggedInToken: "token",
          currentLoggedInUsername: "username",
          api: mockApi,
          testSensors: sensors,
        );
        when(mockApi.logOut('token')).thenAnswer((_) async =>
            Future.value(404));

        await tester.pumpWidget(makeTestableWidget(child: page));

        await tester.tap(find.byKey(Key('menuButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Wyloguj'), findsOneWidget);
        await tester.tap(find.byKey(Key('Wyloguj')));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.byKey(Key("ok button")), findsOneWidget);
        expect(find.byType(Sensors), findsOneWidget);
        verify(await mockApi.logOut('token')).called(1);
      });

  /// tests if logged out from sensor details page when valid token
  testWidgets('valid token, logged out, page sensor details',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        Sensor sensor = Sensor(
            id: 1,
            name: "sensor1",
            category: "temperature",
            batteryLevel: null,
            notifications: true,
            isActive: false);

        SensorDetails page = SensorDetails(
            currentLoggedInToken: "token", currentLoggedInUsername: "username",
            sensor: sensor, api: mockApi);
        when(mockApi.logOut('token')).thenAnswer((_) async =>
            Future.value(200));

        await tester.pumpWidget(makeTestableWidget(child: page));

        await tester.tap(find.byKey(Key('menuButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Wyloguj'), findsOneWidget);
        await tester.tap(find.byKey(Key('Wyloguj')));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(Front), findsOneWidget);
        verify(await mockApi.logOut('token')).called(1);
      });

  /// tests if still logged in, when invalid token, sensor details page
  testWidgets('invalid token, still logged in, page sensor details',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        Sensor sensor = Sensor(
            id: 1,
            name: "sensor1",
            category: "temperature",
            batteryLevel: null,
            notifications: true,
            isActive: false);

        SensorDetails page = SensorDetails(
            currentLoggedInToken: "token", currentLoggedInUsername: "username",
            sensor: sensor, api: mockApi);
        when(mockApi.logOut('token')).thenAnswer((_) async =>
            Future.value(404));

        await tester.pumpWidget(makeTestableWidget(child: page));

        await tester.tap(find.byKey(Key('menuButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Wyloguj'), findsOneWidget);
        await tester.tap(find.byKey(Key('Wyloguj')));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.byKey(Key("ok button")), findsOneWidget);
        expect(find.byType(SensorDetails), findsOneWidget);
        verify(await mockApi.logOut('token')).called(1);
      });

  /// tests if logged out from add sensor page when valid token
  testWidgets('valid token, logged out, page add sensor',
          (WidgetTester tester) async {
            MockApi mockApi = MockApi();
            when(mockApi.logOut('token')).thenAnswer((_) async =>
                Future.value(200));
            NewSensor page = NewSensor(
                currentLoggedInToken: "token",
                currentLoggedInUsername: "username",
                api: mockApi);

            await tester.pumpWidget(makeTestableWidget(child: page));
            await tester.tap(find.byKey(Key('menuButton')));
            await tester.pump();
            await tester.pump(const Duration(seconds: 1));

            expect(find.text('Wyloguj'), findsOneWidget);
            await tester.tap(find.byKey(Key('Wyloguj')));
            await tester.pump();
            await tester.pump();
            await tester.pump(const Duration(seconds: 1));
            expect(find.byType(Front), findsOneWidget);
            verify(await mockApi.logOut('token')).called(1);
      });

  /// tests if still logged in when invalid token, add sensor page
  testWidgets('invalid token, still logged in, page add sensor',
          (WidgetTester tester) async {
            MockApi mockApi = MockApi();
            when(mockApi.logOut('token')).thenAnswer((_) async =>
                Future.value(404));
            NewSensor page = NewSensor(
                currentLoggedInToken: "token",
                currentLoggedInUsername: "username",
                api: mockApi);

            await tester.pumpWidget(makeTestableWidget(child: page));
            await tester.tap(find.byKey(Key('menuButton')));
            await tester.pump();
            await tester.pump(const Duration(seconds: 1));

            expect(find.text('Wyloguj'), findsOneWidget);
            await tester.tap(find.byKey(Key('Wyloguj')));
            await tester.pump();
            await tester.pump();
            await tester.pump(const Duration(seconds: 1));
            expect(find.byKey(Key("ok button")), findsOneWidget);
            expect(find.byType(NewSensor), findsOneWidget);
            verify(await mockApi.logOut('token')).called(1);
      });
}
