import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:mockito/mockito.dart';

class MockApi extends Mock implements Api {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(home: child);
  }

  /// tests if request to delete account is sent when pressed button after confirmation
  testWidgets('delete user, confirm', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.deactivateAccount(1))
        .thenAnswer((_) async => Future.value(204));
    List<Account> accounts = List();
    accounts.add(Account(
        id: 1,
        username: "user1",
        email: "user@email.com",
        telephone: "",
        smsNotifications: "true",
        appNotifications: "true",
        isStaff: false,
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

    Accounts page = Accounts(
      currentLoggedInToken: "token",
      currentLoggedInUsername: "username",
      api: mockApi,
      testAccounts: accounts,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.byType(FlatButton).evaluate().length, 2);
    await tester.tap(find.byType(FlatButton).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.deactivateAccount(1)).called(1);
  });

  /// tests if request to delete account is not sent when pressed button without confirmation
  testWidgets('delete user, does not confirm', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.deactivateAccount(1))
        .thenAnswer((_) async => Future.value(204));
    List<Account> accounts = List();
    accounts.add(Account(
        id: 1,
        username: "user1",
        email: "user@email.com",
        telephone: "",
        smsNotifications: "true",
        appNotifications: "true",
        isStaff: false,
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

    Accounts page = Accounts(
      currentLoggedInToken: "token",
      currentLoggedInUsername: "username",
      api: mockApi,
      testAccounts: accounts,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.byType(FlatButton).evaluate().length, 2);
    await tester.tap(find.byType(FlatButton).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('noButton')));
    await tester.pumpAndSettle();

    verifyNever(await mockApi.deactivateAccount(1));
  });
}