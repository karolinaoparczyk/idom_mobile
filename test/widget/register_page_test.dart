import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';
import 'package:idom/pages/setup/sign_in.dart';
import 'package:idom/pages/setup/sign_up.dart';

class MockApi extends Mock implements Api {}

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(home: child);
  }

  /// tests if signs up with empty body
  testWidgets('body is empty, does not sign up', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    await tester.tap(find.byKey(Key('registerButton')));

    verifyNever(await mockApi.signUp('', '', '', '', ''));
    await tester.pump();
    expect(find.byType(SignUp), findsOneWidget);
    expect(find.text("Pole wymagane"), findsNWidgets(3));
  });

  /// tests if signed up with valid body
  /// gets success message and goes to sign in page
  testWidgets('body non-empty, success sign up', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "ok",
      "statusCode": "201",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "+48765678789"))
        .called(1);
    expect(find.text("Konto zostało utworzone. Możesz się zalogować."), findsOneWidget);
    expect(find.byType(SignIn), findsOneWidget);
  });

  /// tests if not signed up when username already in database
  /// user gets error message and stays at sign up page
  testWidgets('username already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "Username already exists",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "+48765678789"))
        .called(1);
    expect(
        find.text("Konto dla podanej nazwy użytkownika już istnieje."), findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed up when email already in database
  /// user gets error message and stays at sign up page
  testWidgets('email already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "Email address already exists",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));

    await tester.pumpAndSettle();
    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "+48765678789"))
        .called(1);
    expect(find.text("Konto dla podanego adresu e-mail już istnieje."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed up when telephone already in database
  /// user gets error message and stays at sign up page
  testWidgets('telephone already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "Telephone number already exists",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));

    await tester.pumpAndSettle();
    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "+48765678789"))
        .called(1);
    expect(find.text("Konto dla podanego numeru telefonu już istnieje."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

 /// tests if not signed up when telephone and email already in database
  /// user gets error message and stays at sign up page
  testWidgets('telephone and email already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "Telephone number already exists. Email address already exists",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));

    await tester.pumpAndSettle();
    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "+48765678789"))
        .called(1);
    expect(find.text("Konto dla podanego adresu e-mail i numeru telefonu już istnieje."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed up when telephone and username already in database
  /// user gets error message and stays at sign up page
  testWidgets('telephone and username already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "Telephone number already exists. Username already exists",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));

    await tester.pumpAndSettle();
    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "+48765678789"))
        .called(1);
    expect(find.text("Konto dla podanej nazwy użytkownika i numeru telefonu już istnieje."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

 /// tests if not signed up when email and username already in database
  /// user gets error message and stays at sign up page
  testWidgets('username and email already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "Email address already exists. Username already exists",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));

    await tester.pumpAndSettle();
    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "+48765678789"))
        .called(1);
    expect(find.text("Konto dla podanej nazwy użytkownika i adresu e-mail już istnieje."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

/// tests if not signed up when telephone, username and email already in database
  /// user gets error message and stays at sign up page
  testWidgets('telephone, username and email already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "Email address already exists. Username already exists. Telephone number already exists",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));

    await tester.pumpAndSettle();
    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "+48765678789"))
        .called(1);
    expect(find.text("Konto dla podanej nazwy użytkownika, adresu e-mail i numeru telefonu już istnieje."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed up when telephone invalid
  /// user gets error message and stays at sign up page
  testWidgets('telephone invalid, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "Enter a valid phone number",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "+48765678789"))
        .called(1);
    expect(find.text(" Podaj poprawny numeru telefonu."), findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });
}
