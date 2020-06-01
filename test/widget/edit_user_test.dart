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
    AccountDetail page = AccountDetail(
        currentLoggedInToken: "token", account: user, api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, '');

    await tester.tap(find.byKey(Key('Zapisz zmiany')));

    verifyNever(await mockApi.editAccount('', '', ''));
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
    AccountDetail page = AccountDetail(
        currentLoggedInToken: "token", account: user, api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);

    verifyNever(await mockApi.editAccount(1, 'user@email.com', ''));
  });

  /// tests if saves with data change
  testWidgets('changed data, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editAccount(1, 'user@email.pl', '')).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));
    Account user = Account(
        id: 1,
        username: "user1",
        email: "user@email.com",
        telephone: "",
        smsNotifications: "true",
        appNotifications: "true",
        isStaff: false,
        isActive: false);
    AccountDetail page = AccountDetail(
        currentLoggedInToken: "token", account: user, api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('email'));
    await tester.enterText(usernameField, 'user@email.pl');

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);

    verify(await mockApi.editAccount(1, 'user@email.pl', '')).called(1);
  });

  /// tests if does not save with data change but no confirmation
  testWidgets('changed data, no confirmation, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editAccount(1, 'user@email.pl', '')).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));
    Account user = Account(
        id: 1,
        username: "user1",
        email: "user@email.com",
        telephone: "",
        smsNotifications: "true",
        appNotifications: "true",
        isStaff: false,
        isActive: false);
    AccountDetail page = AccountDetail(
        currentLoggedInToken: "token", account: user, api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('email'));
    await tester.enterText(usernameField, 'user@email.pl');

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('noButton')));

    verifyNever(await mockApi.editAccount(1, 'user@email.pl', ''));
  });

  /// tests if does not save with error in data
  testWidgets('changed data, error in data, does not save',
      (WidgetTester tester) async {
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
    AccountDetail page = AccountDetail(
        currentLoggedInToken: "token", account: user, api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('email'));
    await tester.enterText(usernameField, 'user@email');

    await tester.tap(find.byKey(Key('Zapisz zmiany')));

    verifyNever(await mockApi.editAccount(1, 'user@email', ''));
  });

  /// tests if does not save when email exists
  testWidgets('changed data, email exists, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editAccount(1, 'user@email.pl', '')).thenAnswer((_) async =>
        Future.value({
          "body": "User with given email already exists",
          "statusCode": "400"
        }));
    Account user = Account(
        id: 1,
        username: "user1",
        email: "user@email.com",
        telephone: "",
        smsNotifications: "true",
        appNotifications: "true",
        isStaff: false,
        isActive: false);
    AccountDetail page = AccountDetail(
        currentLoggedInToken: "token", account: user, api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('email'));
    await tester.enterText(usernameField, 'user@email.pl');

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("ok button")), findsOneWidget);
    expect(find.text("Konto dla podanego adresu email już istnieje."),
        findsOneWidget);

    verify(await mockApi.editAccount(1, 'user@email.pl', '')).called(1);
  });

  /// tests if does not save when telephone exists
  testWidgets('changed data, telephone exists, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editAccount(1, 'user@email.com', '+48777666555')).thenAnswer(
        (_) async => Future.value({
              "body": "User with given telephone number already exists",
              "statusCode": "400"
            }));
    Account user = Account(
        id: 1,
        username: "user1",
        email: "user@email.com",
        telephone: "",
        smsNotifications: "true",
        appNotifications: "true",
        isStaff: false,
        isActive: false);
    AccountDetail page = AccountDetail(
        currentLoggedInToken: "token", account: user, api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('telephone'));
    await tester.enterText(usernameField, '+48777666555');

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("ok button")), findsOneWidget);
    expect(find.text("Konto dla podanego numeru telefonu już istnieje."),
        findsOneWidget);

    verify(await mockApi.editAccount(1, 'user@email.com', '+48777666555'))
        .called(1);
  });

  /// tests if does not save when telephone is invalid
  testWidgets('changed data, telephone invalid, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editAccount(1, 'user@email.com', '+48111111111')).thenAnswer(
        (_) async => Future.value(
            {"body": "Enter a valid phone number", "statusCode": "400"}));
    Account user = Account(
        id: 1,
        username: "user1",
        email: "user@email.com",
        telephone: "",
        smsNotifications: "true",
        appNotifications: "true",
        isStaff: false,
        isActive: false);
    AccountDetail page = AccountDetail(
        currentLoggedInToken: "token", account: user, api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('telephone'));
    await tester.enterText(usernameField, '+48111111111');

    await tester.tap(find.byKey(Key('Zapisz zmiany')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key("ok button")), findsOneWidget);
    expect(find.text("Numer telefonu jest niepoprawny."), findsOneWidget);

    verify(await mockApi.editAccount(1, 'user@email.com', '+48111111111'))
        .called(1);
  });
}
