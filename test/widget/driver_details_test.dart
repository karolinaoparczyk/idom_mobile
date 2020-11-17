import 'dart:convert';

import 'package:idom/models.dart';
import 'package:idom/pages/drivers/driver_details.dart';
import 'package:idom/pages/drivers/drivers.dart';
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
    expect(find.text("naduszacz"), findsOneWidget);
    expect(find.text("Wciśnij przycisk"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/play.svg")), findsOneWidget);
    await tester.tap(find.byKey(Key("click")));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Wysłano komendę do sterownika driver1."), findsOneWidget);
  });
}
