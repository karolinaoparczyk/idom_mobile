import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/models.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/api.dart';

class MockApi extends Mock implements Api {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(home: child);
  }

  /// tests if does not save with empty body
  testWidgets('body is empty, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Account user = Account(
        id: 1,
        username: "user1",
        email: "user@email.com",
        telephone: "",
        smsNotifications: "true",
        appNotifications: "true",
        isStaff: false,
        isActive: false);
    AccountDetail page = AccountDetail(currentLoggedInToken: "token", account: user ,api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));
    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, '');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, '');

    Finder telephoneField = find.byKey(Key('username'));
    await tester.enterText(telephoneField, '');

    await tester.tap(find.byKey(Key('Zapisz zmiany')));

    verifyNever(await mockApi.editAccount('', '', '', ''));
  });

  /// tests if does not save with no change
  testWidgets('no change, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Account user = Account(
        id: 1,
        username: "user1",
        email: "user@email.com",
        telephone: "",
        smsNotifications: "true",
        appNotifications: "true",
        isStaff: false,
        isActive: false);
    AccountDetail page = AccountDetail(currentLoggedInToken: "token", account: user ,api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);

    verifyNever(await mockApi.editAccount(1, 'user1', 'user@email.com', ''));
  });

  /// tests if saves with data change
  testWidgets('changed data, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editAccount(1,'username', 'user@email.com', ''))
        .thenAnswer((_) async => Future.value(200));
    Account user = Account(
        id: 1,
        username: "user1",
        email: "user@email.com",
        telephone: "",
        smsNotifications: "true",
        appNotifications: "true",
        isStaff: false,
        isActive: false);
    AccountDetail page = AccountDetail(currentLoggedInToken: "token", account: user ,api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);

    verify(await mockApi.editAccount(1, 'username', 'user@email.com', '')).called(1);
  });

  /// tests if does not save with data change but no confirmation
  testWidgets('changed data, no confirmation, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editAccount(1,'username', 'user@email.com', ''))
        .thenAnswer((_) async => Future.value(200));
    Account user = Account(
        id: 1,
        username: "user1",
        email: "user@email.com",
        telephone: "",
        smsNotifications: "true",
        appNotifications: "true",
        isStaff: false,
        isActive: false);
    AccountDetail page = AccountDetail(currentLoggedInToken: "token", account: user ,api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('noButton')));

    verifyNever(await mockApi.editAccount(1, 'username', 'user@email.com', ''));
  });

  /// tests if does not save with error in data
  testWidgets('changed data, error in data, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Account user = Account(
        id: 1,
        username: "user1",
        email: "user@email.com",
        telephone: "",
        smsNotifications: "true",
        appNotifications: "true",
        isStaff: false,
        isActive: false);
    AccountDetail page = AccountDetail(currentLoggedInToken: "token", account: user ,api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('email'));
    await tester.enterText(usernameField, 'user@email');

    await tester.tap(find.byKey(Key('Zapisz zmiany')));

    verifyNever(await mockApi.editAccount(1, 'username', 'user@email', ''));
  });

  /// tests if does not save with error from API
  testWidgets('changed data, error in API, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editAccount(1,'user1', 'user@email.pl', ''))
        .thenAnswer((_) async => Future.value(400));
    Account user = Account(
        id: 1,
        username: "user1",
        email: "user@email.com",
        telephone: "",
        smsNotifications: "true",
        appNotifications: "true",
        isStaff: false,
        isActive: false);
    AccountDetail page = AccountDetail(currentLoggedInToken: "token", account: user ,api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('email'));
    await tester.enterText(usernameField, 'user@email.pl');

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);

    verify(await mockApi.editAccount(1, 'user1', 'user@email.pl', '')).called(1);
  });
}
