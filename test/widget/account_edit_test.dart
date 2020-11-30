import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idom/pages/account/edit_account.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/models.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/api.dart';

class MockApi extends Mock implements Api {}

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(home: child);
  }

  /// tests if does not save with empty body
  testWidgets('body is empty, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Account user = Account(
        id: 1,
        username: "user1",
        email: "user@email.com",
        telephone: "",
        smsNotifications: true,
        appNotifications: true,
        isStaff: false,
        isActive: false);
    EditAccount page = EditAccount(
        storage: mockSecureStorage, account: user, testApi: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, '');

    await tester.tap(find.byKey(Key('saveAccountButton')));

    verifyNever(await mockApi.editAccount(1, '', ''));
  });

  /// tests if does not save with no change
  testWidgets('no change, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Account user = Account(
        id: 1,
        username: "user1",
        email: "user@email.com",
        telephone: "",
        smsNotifications: true,
        appNotifications: true,
        isStaff: false,
        isActive: false);
    EditAccount page = EditAccount(
        storage: mockSecureStorage, account: user, testApi: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    await tester.tap(find.byKey(Key('saveAccountButton')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);

    verifyNever(await mockApi.editAccount(1, 'user@email.com', ''));
  });

  /// tests if saves with email changed form superuser
  testWidgets('superuser, changed email, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editAccount(1, 'user@email.pl', null)).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));
    var userApi = {
      "id": 1,
      "username": "user1",
      "email": "user@email.pl",
      "telephone": "+48765677655",
      "sms_notifications": true,
      "app_notifications": true,
      "is_staff": false,
      "is_active": true,
    };
    when(mockApi.getUser('user1')).thenAnswer(
            (_) async => Future.value([jsonEncode(userApi), 200]));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.setEmail("user@email.pl")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.setTelephone("")).thenAnswer(
            (_) async => Future.value());

    var userStorage = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "telephone": "+48765677655",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userStorage));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);
    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("user@email.com"), findsOneWidget);

    await tester.tap(find.byKey(Key('editAccount')));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, 'user@email.pl');

    await tester.tap(find.byKey(Key('saveAccountButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.byType(AccountDetail), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Zapisano dane użytkownika."), findsOneWidget);

    expect(find.text("user@email.pl"), findsOneWidget);

    verify(await mockApi.editAccount(1, 'user@email.pl', null)).called(1);
  });

  /// tests if saves with telephone changed for superuser
  testWidgets('superuser, changed telephone, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editAccount(1, null, '+48999888777')).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));
    var userApi = {
      "id": 1,
      "username": "user1",
      "email": "user@email.pl",
      "telephone": "+48999888777",
      "sms_notifications": true,
      "app_notifications": true,
      "is_staff": false,
      "is_active": true,
    };
    when(mockApi.getUser('user1')).thenAnswer(
            (_) async => Future.value([jsonEncode(userApi), 200]));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.setEmail("user@email.pl")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.setTelephone("")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.getUsername()).thenAnswer(
            (_) async => Future.value("user1"));

    var userStorage = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "telephone": "",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userStorage));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);
    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("+48999888777"), findsNothing);

    await tester.tap(find.byKey(Key('editAccount')));
    await tester.pumpAndSettle();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, '+48999888777');

    await tester.tap(find.byKey(Key('saveAccountButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.byType(AccountDetail), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Zapisano dane użytkownika."), findsOneWidget);

    expect(find.text("+48999888777"), findsOneWidget);

    verify(await mockApi.editAccount(1, null, '+48999888777')).called(1);
  });

  /// tests if saves with email and telephone changed
  testWidgets('changed email and telephone, saves',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editAccount(1, 'user@email.pl', '+48999888777')).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));
    var userApi = {
      "id": 1,
      "username": "user1",
      "email": "user@email.pl",
      "telephone": "+48999888777",
      "sms_notifications": true,
      "app_notifications": true,
      "is_staff": false,
      "is_active": true,
    };
    when(mockApi.getUser('user1')).thenAnswer(
            (_) async => Future.value([jsonEncode(userApi), 200]));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.setEmail("user@email.pl")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.setTelephone("+48999888777")).thenAnswer(
            (_) async => Future.value());
    var userStorage = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "telephone": "+48666555444",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userStorage));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);
    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("user@email.com"), findsOneWidget);
    expect(find.text("+48666555444"), findsOneWidget);

    await tester.tap(find.byKey(Key('editAccount')));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, 'user@email.pl');

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, '+48999888777');

    await tester.tap(find.byKey(Key('saveAccountButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);

    expect(find.byType(AccountDetail), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Zapisano dane użytkownika."), findsOneWidget);
    expect(find.text("user@email.pl"), findsOneWidget);
    expect(find.text("+48999888777"), findsOneWidget);
    verify(await mockApi.editAccount(1, 'user@email.pl', '+48999888777'))
        .called(1);
  });

  /// tests if does not save with data change but no confirmation
  testWidgets('changed data, no confirmation, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editAccount(1, 'user@email.pl', null)).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));
    var userApi = {
      "id": 1,
      "username": "user1",
      "email": "user@email.pl",
      "telephone": "+48765677655",
      "sms_notifications": true,
      "app_notifications": true,
      "is_staff": false,
      "is_active": true,
    };
    when(mockApi.getUser('user1')).thenAnswer(
            (_) async => Future.value([jsonEncode(userApi), 200]));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.setEmail("user@email.pl")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.setTelephone("")).thenAnswer(
            (_) async => Future.value());

    var userStorage = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "telephone": "+48765677655",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userStorage));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);
    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('editAccount')));
    await tester.pumpAndSettle();

    Finder usernameField = find.byKey(Key('email'));
    await tester.enterText(usernameField, 'user@email.pl');

    await tester.tap(find.byKey(Key('saveAccountButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('noButton')));
    await tester.pumpAndSettle();
    expect(find.byType(EditAccount), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    verifyNever(await mockApi.editAccount(1, 'user@email.pl', null));
  });

  /// tests if does not save with error in data
  testWidgets('changed data, error in data, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editAccount(1, 'user@email.pl', null)).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));
    var userApi = {
      "id": 1,
      "username": "user1",
      "email": "user@email.pl",
      "telephone": "+48765677655",
      "sms_notifications": true,
      "app_notifications": true,
      "is_staff": false,
      "is_active": true,
    };
    when(mockApi.getUser('user1')).thenAnswer(
            (_) async => Future.value([jsonEncode(userApi), 200]));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.setEmail("user@email.pl")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.setTelephone("")).thenAnswer(
            (_) async => Future.value());

    var userStorage = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "telephone": "+48765677655",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userStorage));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);
    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('editAccount')));
    await tester.pumpAndSettle();

    Finder usernameField = find.byKey(Key('email'));
    await tester.enterText(usernameField, 'user@email.pl');

    await tester.tap(find.byKey(Key('saveAccountButton')));
    await tester.pumpAndSettle();

    verifyNever(await mockApi.editAccount(1, 'user@email', null));
  });

  /// tests if does not save when email exists
  testWidgets('changed data, email exists, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editAccount(1, 'user@email.pl', null)).thenAnswer((_) async =>
        Future.value({
          "body": "Email address already exists",
          "statusCode": "400"
        }));
    var userApi = {
      "id": 1,
      "username": "user1",
      "email": "user@email.pl",
      "telephone": "+48765677655",
      "sms_notifications": true,
      "app_notifications": true,
      "is_staff": false,
      "is_active": true,
    };
    when(mockApi.getUser('user1')).thenAnswer(
            (_) async => Future.value([jsonEncode(userApi), 200]));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.setEmail("user@email.pl")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.setTelephone("")).thenAnswer(
            (_) async => Future.value());

    var userStorage = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "telephone": "+48765677655",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userStorage));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);
    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('editAccount')));
    await tester.pumpAndSettle();

    Finder usernameField = find.byKey(Key('email'));
    await tester.enterText(usernameField, 'user@email.pl');

    await tester.tap(find.byKey(Key('saveAccountButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.byType(EditAccount), findsOneWidget);
    expect(find.text("Konto dla podanego adresu e-mail już istnieje."),
        findsOneWidget);

    verify(await mockApi.editAccount(1, 'user@email.pl', null)).called(1);
  });

  /// tests if does not save when telephone exists
  testWidgets('changed data, telephone exists, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editAccount(1, null, '+48999888777')).thenAnswer((_) async =>
        Future.value({
          "body": "Telephone number already exists",
          "statusCode": "400"
        }));
    var userApi = {
      "id": 1,
      "username": "user1",
      "email": "user@email.pl",
      "telephone": "+48999888777",
      "sms_notifications": true,
      "app_notifications": true,
      "is_staff": false,
      "is_active": true,
    };
    when(mockApi.getUser('user1')).thenAnswer(
            (_) async => Future.value([jsonEncode(userApi), 200]));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.setEmail("user@email.pl")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.setTelephone("")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.getUsername()).thenAnswer(
            (_) async => Future.value("user1"));

    var userStorage = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "telephone": "",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userStorage));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);
    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("+48999888777"), findsNothing);

    await tester.tap(find.byKey(Key('editAccount')));
    await tester.pumpAndSettle();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, '+48999888777');

    await tester.tap(find.byKey(Key('saveAccountButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.text("Konto dla podanego numeru telefonu już istnieje."),
        findsOneWidget);

    verify(await mockApi.editAccount(1, null, '+48999888777')).called(1);
  });

  /// tests if does not save when email and telephone exists
  testWidgets('changed data, email and telephone exists, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editAccount(1, "user@email.pl", '+48999888777')).thenAnswer((_) async =>
        Future.value({
          "body": "Email address already exists. Telephone number already exists",
          "statusCode": "400"
        }));
    var userApi = {
      "id": 1,
      "username": "user1",
      "email": "user@email.pl",
      "telephone": "+48999888777",
      "sms_notifications": true,
      "app_notifications": true,
      "is_staff": false,
      "is_active": true,
    };
    when(mockApi.getUser('user1')).thenAnswer(
            (_) async => Future.value([jsonEncode(userApi), 200]));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.setEmail("user@email.pl")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.setTelephone("")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.getUsername()).thenAnswer(
            (_) async => Future.value("user1"));

    var userStorage = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "telephone": "",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userStorage));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);
    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("+48999888777"), findsNothing);

    await tester.tap(find.byKey(Key('editAccount')));
    await tester.pumpAndSettle();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, '+48999888777');

    Finder usernameField = find.byKey(Key('email'));
    await tester.enterText(usernameField, 'user@email.pl');

    await tester.tap(find.byKey(Key('saveAccountButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.text("Konto dla podanego adresu e-mail i numeru telefonu już istnieje."),
        findsOneWidget);

    verify(await mockApi.editAccount(1, "user@email.pl", '+48999888777')).called(1);
  });

  /// tests if does not save when email invalid
  testWidgets('changed data, email invalid, does not save',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        when(mockApi.editAccount(1, 'user@email.pl', null)).thenAnswer((_) async =>
            Future.value({
              "body": "Enter a valid email address",
              "statusCode": "400"
            }));
        var userApi = {
          "id": 1,
          "username": "user1",
          "email": "user@email.pl",
          "telephone": "+48765677655",
          "sms_notifications": true,
          "app_notifications": true,
          "is_staff": false,
          "is_active": true,
        };
        when(mockApi.getUser('user1')).thenAnswer(
                (_) async => Future.value([jsonEncode(userApi), 200]));
        MockSecureStorage mockSecureStorage = MockSecureStorage();
        when(mockSecureStorage.setEmail("user@email.pl")).thenAnswer(
                (_) async => Future.value());
        when(mockSecureStorage.setTelephone("")).thenAnswer(
                (_) async => Future.value());

        var userStorage = {
          "id": "1",
          "username": "user1",
          "email": "user@email.com",
          "telephone": "+48765677655",
          "smsNotifications": "true",
          "appNotifications": "true",
          "isStaff": "false",
          "isActive": "true",
          "token": "token"
        };

        when(mockSecureStorage.getCurrentUserData())
            .thenAnswer((_) async => Future.value(userStorage));

        AccountDetail page = AccountDetail(
            storage: mockSecureStorage, username: "user1", testApi: mockApi);
        await tester.pumpWidget(makeTestableWidget(child: page));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key('editAccount')));
        await tester.pumpAndSettle();

        Finder usernameField = find.byKey(Key('email'));
        await tester.enterText(usernameField, 'user@email.pl');

        await tester.tap(find.byKey(Key('saveAccountButton')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pumpAndSettle();
        expect(find.byType(EditAccount), findsOneWidget);
        expect(find.text("Adres e-mail jest nieprawidłowy"),
            findsOneWidget);

        verify(await mockApi.editAccount(1, 'user@email.pl', null)).called(1);
      });

  /// tests if does not save when telephone is invalid
  testWidgets('changed data, telephone invalid, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editAccount(1, null, '+48111111111')).thenAnswer((_) async =>
        Future.value(
            {"body": "Enter a valid phone number", "statusCode": "400"}));
    var userApi = {
      "id": 1,
      "username": "user1",
      "email": "user@email.pl",
      "telephone": "+48999888777",
      "sms_notifications": true,
      "app_notifications": true,
      "is_staff": false,
      "is_active": true,
    };
    when(mockApi.getUser('user1')).thenAnswer(
            (_) async => Future.value([jsonEncode(userApi), 200]));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.setEmail("user@email.pl")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.setTelephone("")).thenAnswer(
            (_) async => Future.value());
    when(mockSecureStorage.getUsername()).thenAnswer(
            (_) async => Future.value("user1"));

    var userStorage = {
      "id": "1",
      "username": "user1",
      "email": "user@email.com",
      "telephone": "",
      "smsNotifications": "true",
      "appNotifications": "true",
      "isStaff": "false",
      "isActive": "true",
      "token": "token"
    };

    when(mockSecureStorage.getCurrentUserData())
        .thenAnswer((_) async => Future.value(userStorage));

    AccountDetail page = AccountDetail(
        storage: mockSecureStorage, username: "user1", testApi: mockApi);
    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("+48999888777"), findsNothing);

    await tester.tap(find.byKey(Key('editAccount')));
    await tester.pumpAndSettle();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, '+48111111111');

    await tester.tap(find.byKey(Key('saveAccountButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.text("Numer telefonu jest nieprawidłowy."),
        findsOneWidget);

    verify(await mockApi.editAccount(1, null, '+48111111111')).called(1);
  });

  /// tests if does not save when email and telephone invalid
  testWidgets('changed data, email and telephone invalid, does not save',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        when(mockApi.editAccount(1, "user@email.pl", '+48999888777')).thenAnswer((_) async =>
            Future.value({
              "body": "Enter a valid email address. Enter a valid phone number",
              "statusCode": "400"
            }));
        var userApi = {
          "id": 1,
          "username": "user1",
          "email": "user@email.pl",
          "telephone": "+48999888777",
          "sms_notifications": true,
          "app_notifications": true,
          "is_staff": false,
          "is_active": true,
        };
        when(mockApi.getUser('user1')).thenAnswer(
                (_) async => Future.value([jsonEncode(userApi), 200]));
        MockSecureStorage mockSecureStorage = MockSecureStorage();
        when(mockSecureStorage.setEmail("user@email.pl")).thenAnswer(
                (_) async => Future.value());
        when(mockSecureStorage.setTelephone("")).thenAnswer(
                (_) async => Future.value());
        when(mockSecureStorage.getUsername()).thenAnswer(
                (_) async => Future.value("user1"));

        var userStorage = {
          "id": "1",
          "username": "user1",
          "email": "user@email.com",
          "telephone": "",
          "smsNotifications": "true",
          "appNotifications": "true",
          "isStaff": "false",
          "isActive": "true",
          "token": "token"
        };

        when(mockSecureStorage.getCurrentUserData())
            .thenAnswer((_) async => Future.value(userStorage));

        AccountDetail page = AccountDetail(
            storage: mockSecureStorage, username: "user1", testApi: mockApi);
        await tester.pumpWidget(makeTestableWidget(child: page));
        await tester.pumpAndSettle();

        expect(find.text("+48999888777"), findsNothing);

        await tester.tap(find.byKey(Key('editAccount')));
        await tester.pumpAndSettle();

        Finder telephoneField = find.byKey(Key('telephone'));
        await tester.enterText(telephoneField, '+48999888777');

        Finder usernameField = find.byKey(Key('email'));
        await tester.enterText(usernameField, 'user@email.pl');

        await tester.tap(find.byKey(Key('saveAccountButton')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pumpAndSettle();
        expect(find.text("Adres e-mail oraz numer telefonu są nieprawidłowe."),
            findsOneWidget);

        verify(await mockApi.editAccount(1, "user@email.pl", '+48999888777')).called(1);
      });
}