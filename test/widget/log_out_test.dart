import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    when(mockApi.logOut('token')).thenAnswer((_) async => Future.value(200));
    Accounts page = Accounts(
        currentLoggedInToken: "token",
        currentLoggedInUsername: "username",
        api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    await tester.tap(find.byKey(Key('logOut')));

    await tester.runAsync(() async {
      verify(await mockApi.logOut('token'));
    });
    await tester.pumpAndSettle();
    expect(find.byType(Front), findsOneWidget);
  });

  /// tests if logged out from account details page when valid token
  testWidgets('invalid token, logged out, page account details',
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
    when(mockApi.logOut('token')).thenAnswer((_) async => Future.value(200));
    AccountDetail page = AccountDetail(
        currentLoggedInToken: "token", account: account, api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    await tester.tap(find.byKey(Key('logOut')));

    await tester.runAsync(() async {
      verify(await mockApi.logOut('token'));
    });
    await tester.pumpAndSettle();

    expect(find.byType(Front), findsOneWidget);
  });
}
