import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/pages/actions/actions.dart';
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

  /// tests if actions on list
  testWidgets('actions on list', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> actions = [
      {
        "id": 1,
        "name": "action1",
        "sensor_id": 1,
        "driver_id": 1,
        "start_time": "17:30",
        "end_time": "19:30",
        "action": "action",
      },
      {
        "id": 1,
        "name": "action2",
        "sensor_id": 2,
        "driver_id": 2,
        "start_time": "13:20",
        "end_time": "16:40",
        "action": "action",
      }
    ];
    when(mockApi.getActions()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(actions), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    ActionsList page = ActionsList(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find
        .byType(ListTile)
        .evaluate()
        .length, 2);
    expect(find.text("action1"), findsOneWidget);
    expect(find.text("action2"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/hammer.svg")), findsNWidgets(2));
  });

  /// tests if actions not on list if api error
  testWidgets('actions not on list if api error', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getActions()).thenAnswer((_) async =>
        Future.value(null));

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    ActionsList page = ActionsList(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find
        .byType(ListTile)
        .evaluate()
        .length, 0);
    expect(find.text("Błąd połączenia z serwerem."), findsOneWidget);
    expect(find.byKey(Key("assets/icons/hammer.svg")), findsNothing);
  });


  /// tests if deletes action
  testWidgets('deletes action', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> actions = [
      {
        "id": 1,
        "name": "action1",
        "sensor_id": 1,
        "driver_id": 1,
        "start_time": "17:30",
        "end_time": "19:30",
        "action": "action",
      },
      {
        "id": 1,
        "name": "action2",
        "sensor_id": 2,
        "driver_id": 2,
        "start_time": "13:20",
        "end_time": "16:40",
        "action": "action",
      }
    ];
    when(mockApi.getActions()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(actions), "statusCode": "200"}));
    when(mockApi.deleteAction(1))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    ActionsList page = ActionsList(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find
        .byType(ListTile)
        .evaluate()
        .length, 2);

    when(mockApi.getActions()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode([actions[1]]), "statusCode": "200"}));

    await tester.tap(find.byKey(Key('deleteButton')).first);
    await tester.pump();
    expect(find.text("Potwierdź"), findsOneWidget);
    expect(find.text("Czy na pewno chcesz usunąć akcję action1?"), findsOneWidget);
    expect(find.text("Tak"), findsOneWidget);
    expect(find.text("Nie"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    verify(await mockApi.deleteAction(1)).called(1);
    expect(find
        .byType(ListTile)
        .evaluate()
        .length, 1);
    expect(find.text("action1"), findsNothing);
    expect(find.text("action2"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/hammer.svg")), findsOneWidget);
  });

  /// tests if actions not on list if api error, english
  testWidgets('english actions not on list if api error', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getActions()).thenAnswer((_) async =>
        Future.value(null));

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    ActionsList page = ActionsList(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find
        .byType(ListTile)
        .evaluate()
        .length, 0);
    expect(find.text("Server connection error."), findsOneWidget);
    expect(find.byKey(Key("assets/icons/hammer.svg")), findsNothing);
  });


  /// tests if deletes action
  testWidgets('deletes action', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> actions = [
      {
        "id": 1,
        "name": "action1",
        "sensor_id": 1,
        "driver_id": 1,
        "start_time": "17:30",
        "end_time": "19:30",
        "action": "action",
      },
      {
        "id": 1,
        "name": "action2",
        "sensor_id": 2,
        "driver_id": 2,
        "start_time": "13:20",
        "end_time": "16:40",
        "action": "action",
      }
    ];
    when(mockApi.getActions()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(actions), "statusCode": "200"}));
    when(mockApi.deleteAction(1))
        .thenAnswer((_) async => Future.value(200));

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    ActionsList page = ActionsList(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find
        .byType(ListTile)
        .evaluate()
        .length, 2);

    when(mockApi.getActions()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode([actions[1]]), "statusCode": "200"}));

    await tester.tap(find.byKey(Key('deleteButton')).first);
    await tester.pump();
    expect(find.text("Confirm"), findsOneWidget);
    expect(find.text("Are you sure you want to remove action action1?"), findsOneWidget);
    expect(find.text("Yes"), findsOneWidget);
    expect(find.text("No"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    verify(await mockApi.deleteAction(1)).called(1);
    expect(find
        .byType(ListTile)
        .evaluate()
        .length, 1);
    expect(find.text("action1"), findsNothing);
    expect(find.text("action2"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/hammer.svg")), findsOneWidget);
  });
}