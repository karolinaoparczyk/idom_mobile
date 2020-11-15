import 'package:idom/models.dart';
import 'package:idom/pages/drivers/edit_driver.dart';
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

  /// tests if edits driver name
  testWidgets('edits driver name', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Driver driver = Driver(
        id: 1,
        name: "driver1",
        category: "clicker",
        ipAddress: "111.111.11.11",
        data: null);
    when(mockApi.editDriver(1, 'newname', null, "token")).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    EditDriver page = EditDriver(
      storage: mockSecureStorage,
      driver: driver,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('editDriverButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editDriver(1, 'newname', null, "token"))
        .called(1);
  });
}
