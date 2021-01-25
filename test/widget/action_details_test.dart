import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/actions/action_details.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';

class MockApi extends Mock implements Api {}

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  Widget makePolishTestableWidget({Widget child}) {
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
        return Locale('pl', "PL");
      },
      home:  I18n(child: child),
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

  /// tests if displays action's details, with sensor and time range
  testWidgets('displays action details, with sensor and time range',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    ActionAction actionAction = ActionAction(status: "on");
    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: "sensor2",
      trigger: "30",
      operator: "=",
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 4,
      driver: "driver1",
      startTime: "13:20",
      endTime: "16:40",
      action: actionAction,
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    ActionDetails page = ActionDetails(
      storage: mockSecureStorage,
      action: action,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("action2"), findsNWidgets(2));
    expect(find.text("Sterownik"), findsOneWidget);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("Czujnik"), findsOneWidget);
    expect(find.text("sensor2"), findsOneWidget);
    expect(find.text("Wyzwalacz"), findsOneWidget);
    expect(find.text("Wartość z czujnika"), findsOneWidget);
    expect(find.text("= 30.00"), findsOneWidget);
    expect(find.text("Akcja"), findsOneWidget);
    expect(find.text("Włącz"), findsOneWidget);
    expect(find.text("Dni tygodnia"), findsOneWidget);
    expect(find.text("pn, wt, śr, czw, pt, sb, nd"), findsOneWidget);
    expect(find.text("Godziny"), findsOneWidget);
    expect(find.text("13:20 - 16:40"), findsOneWidget);
  });

  /// tests if displays action's details, without sensor, with time range
  testWidgets('displays action details, without sensor, with time range',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    ActionAction actionAction = ActionAction(status: "off");
    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: null,
      trigger: null,
      operator: null,
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 4,
      driver: "driver1",
      startTime: "13:20",
      endTime: "16:40",
      action: actionAction,
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    ActionDetails page = ActionDetails(
      storage: mockSecureStorage,
      action: action,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("action2"), findsNWidgets(2));
    expect(find.text("Sterownik"), findsOneWidget);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("Czujnik"), findsNothing);
    expect(find.text("sensor2"), findsNothing);
    expect(find.text("Wyzwalacz"), findsNothing);
    expect(find.text("Wartość z czujnika"), findsNothing);
    expect(find.text("= 30.00"), findsNothing);
    expect(find.text("Akcja"), findsOneWidget);
    expect(find.text("Wyłącz"), findsOneWidget);
    expect(find.text("Czas działania akcji"), findsOneWidget);
    expect(find.text("Dni tygodnia"), findsOneWidget);
    expect(find.text("pn, wt, śr, czw, pt, sb, nd"), findsOneWidget);
    expect(find.text("Godziny"), findsOneWidget);
    expect(find.text("13:20 - 16:40"), findsOneWidget);
  });

  /// tests if displays action's details, with sensor and only start time
  testWidgets('displays action details, with sensor and only start time',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    ActionAction actionAction = ActionAction(red: 0, blue: 255, type: "colour", green: 141);
    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: "sensor2",
      trigger: "30",
      operator: "=",
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 4,
      driver: "driver1",
      startTime: "13:20",
      endTime: null,
      action: actionAction,
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    ActionDetails page = ActionDetails(
      storage: mockSecureStorage,
      action: action,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("action2"), findsNWidgets(2));
    expect(find.text("Sterownik"), findsOneWidget);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("Czujnik"), findsOneWidget);
    expect(find.text("sensor2"), findsOneWidget);
    expect(find.text("Wyzwalacz"), findsOneWidget);
    expect(find.text("Wartość z czujnika"), findsOneWidget);
    expect(find.text("= 30.00"), findsOneWidget);
    expect(find.text("Akcja"), findsOneWidget);
    expect(find.text("Ustaw kolor"), findsOneWidget);
    expect(find.text("Czas działania akcji"), findsOneWidget);
    expect(find.text("Dni tygodnia"), findsOneWidget);
    expect(find.text("pn, wt, śr, czw, pt, sb, nd"), findsOneWidget);
    expect(find.text("Godzina"), findsOneWidget);
    expect(find.text("13:20"), findsOneWidget);
  });

  /// tests if displays action's details, without sensor and only start time
  testWidgets('displays action details, without sensor and only start time',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    ActionAction actionAction = ActionAction(brightness: 84, type: "brightness");
    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: null,
      trigger: null,
      operator: null,
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 4,
      driver: "driver1",
      startTime: "13:20",
      endTime: null,
      action: actionAction,
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    ActionDetails page = ActionDetails(
      storage: mockSecureStorage,
      action: action,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("action2"), findsNWidgets(2));
    expect(find.text("Sterownik"), findsOneWidget);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("Czujnik"), findsNothing);
    expect(find.text("sensor2"), findsNothing);
    expect(find.text("Wyzwalacz"), findsNothing);
    expect(find.text("Wartość z czujnika"), findsNothing);
    expect(find.text("= 30.00"), findsNothing);
    expect(find.text("Akcja"), findsOneWidget);
    expect(find.text("Ustaw jasność: 84"), findsOneWidget);
    expect(find.text("Czas działania akcji"), findsOneWidget);
    expect(find.text("Dni tygodnia"), findsOneWidget);
    expect(find.text("pn, wt, śr, czw, pt, sb, nd"), findsOneWidget);
    expect(find.text("Godzina"), findsOneWidget);
    expect(find.text("13:20"), findsOneWidget);
  });

  /// tests if displays action's details, with sensor and time range, english
  testWidgets('english displays action details, with sensor and time range',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    ActionAction actionAction = ActionAction(status: "on");
    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: "sensor2",
      trigger: "30",
      operator: "=",
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 4,
      driver: "driver1",
      startTime: "13:20",
      endTime: "16:40",
      action: actionAction,
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    ActionDetails page = ActionDetails(
      storage: mockSecureStorage,
      action: action,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("General"), findsOneWidget);
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("action2"), findsNWidgets(2));
    expect(find.text("Driver"), findsOneWidget);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("Sensor"), findsOneWidget);
    expect(find.text("sensor2"), findsOneWidget);
    expect(find.text("Trigger"), findsOneWidget);
    expect(find.text("Sensor value"), findsOneWidget);
    expect(find.text("= 30.00"), findsOneWidget);
    expect(find.text("Action"), findsOneWidget);
    expect(find.text("Turn on"), findsOneWidget);
    expect(find.text("Action time"), findsOneWidget);
    expect(find.text("Days of the week"), findsOneWidget);
    expect(find.text("Mon, Tue, Wed, Thur, Fri, Sat, Sun"), findsOneWidget);
    expect(find.text("Time"), findsOneWidget);
    expect(find.text("1:20 PM - 4:40 PM"), findsOneWidget);
  });

  /// tests if displays action's details, without sensor, with time range, english
  testWidgets(
      'english displays action details, without sensor, with time range',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    ActionAction actionAction = ActionAction(status: "off");
    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: null,
      trigger: null,
      operator: null,
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 4,
      driver: "driver1",
      startTime: "13:20",
      endTime: "16:40",
      action: actionAction,
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    ActionDetails page = ActionDetails(
      storage: mockSecureStorage,
      action: action,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("General"), findsOneWidget);
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("action2"), findsNWidgets(2));
    expect(find.text("Driver"), findsOneWidget);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("Sensor"), findsNothing);
    expect(find.text("sensor2"), findsNothing);
    expect(find.text("Trigger"), findsNothing);
    expect(find.text("Sensor value"), findsNothing);
    expect(find.text("= 30.00"), findsNothing);
    expect(find.text("Action"), findsOneWidget);
    expect(find.text("Turn off"), findsOneWidget);
    expect(find.text("Action time"), findsOneWidget);
    expect(find.text("Days of the week"), findsOneWidget);
    expect(find.text("Mon, Tue, Wed, Thur, Fri, Sat, Sun"), findsOneWidget);
    expect(find.text("Time"), findsOneWidget);
    expect(find.text("1:20 PM - 4:40 PM"), findsOneWidget);
  });

  /// tests if displays action's details, with sensor and only start time, english
  testWidgets(
      'english displays action details, with sensor and only start time',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    ActionAction actionAction = ActionAction(red: 0, blue: 255, type: "colour", green: 141);
    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: "sensor2",
      trigger: "30",
      operator: "=",
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 4,
      driver: "driver1",
      startTime: "13:20",
      endTime: null,
      action: actionAction,
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    ActionDetails page = ActionDetails(
      storage: mockSecureStorage,
      action: action,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("General"), findsOneWidget);
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("action2"), findsNWidgets(2));
    expect(find.text("Driver"), findsOneWidget);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("Sensor"), findsOneWidget);
    expect(find.text("sensor2"), findsOneWidget);
    expect(find.text("Trigger"), findsOneWidget);
    expect(find.text("Sensor value"), findsOneWidget);
    expect(find.text("= 30.00"), findsOneWidget);
    expect(find.text("Action"), findsOneWidget);
    expect(find.text("Set color"), findsOneWidget);
    expect(find.text("Action time"), findsOneWidget);
    expect(find.text("Days of the week"), findsOneWidget);
    expect(find.text("Mon, Tue, Wed, Thur, Fri, Sat, Sun"), findsOneWidget);
    expect(find.text("Time"), findsOneWidget);
    expect(find.text("1:20 PM"), findsOneWidget);
  });

  /// tests if displays action's details, without sensor and only start time, english
  testWidgets(
      'english displays action details, without sensor and only start time',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    ActionAction actionAction = ActionAction(brightness: 84, type: "brightness");
    SensorDriverAction action = SensorDriverAction(
      id: 1,
      name: "action2",
      sensor: null,
      trigger: null,
      operator: null,
      days: "0, 1, 2, 3, 4, 5, 6",
      flag: 4,
      driver: "driver1",
      startTime: "13:20",
      endTime: null,
      action: actionAction,
    );

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    ActionDetails page = ActionDetails(
      storage: mockSecureStorage,
      action: action,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("General"), findsOneWidget);
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("action2"), findsNWidgets(2));
    expect(find.text("Driver"), findsOneWidget);
    expect(find.text("driver1"), findsOneWidget);
    expect(find.text("Sensor"), findsNothing);
    expect(find.text("sensor2"), findsNothing);
    expect(find.text("Trigger"), findsNothing);
    expect(find.text("Sensor value"), findsNothing);
    expect(find.text("= 30.00"), findsNothing);
    expect(find.text("Action"), findsOneWidget);
    expect(find.text("Set brightness: 84"), findsOneWidget);
    expect(find.text("Action time"), findsOneWidget);
    expect(find.text("Days of the week"), findsOneWidget);
    expect(find.text("Mon, Tue, Wed, Thur, Fri, Sat, Sun"), findsOneWidget);
    expect(find.text("Time"), findsOneWidget);
    expect(find.text("1:20 PM"), findsOneWidget);
  });
}
