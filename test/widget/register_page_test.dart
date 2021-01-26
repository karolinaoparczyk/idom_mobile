import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';
import 'package:idom/pages/setup/sign_in.dart';
import 'package:idom/pages/setup/sign_up.dart';

class MockApi extends Mock implements Api {}

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  Widget makePolishTestableWidget({Widget child}) {
    return MaterialApp(home: child);
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

  /// tests if signs up with empty body
  testWidgets('body is empty, does not sign up', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    await tester.tap(find.byKey(Key('registerButton')));

    verifyNever(await mockApi.signUp('', '', '', '', null, ''));
    await tester.pump();
    expect(find.byType(SignUp), findsOneWidget);
    expect(find.text("Pole wymagane"), findsNWidgets(4));
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
            "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polski").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
        .called(1);
    expect(find.text("Konto zostało utworzone. Możesz się zalogować."),
        findsOneWidget);
    expect(find.byType(SignIn), findsOneWidget);
  });

  /// tets if cancels language dialog
  testWidgets('cancels language dialog', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "ok",
      "statusCode": "201",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polski").last);
    await tester.tap(find.byKey(Key('Cancel')));
    await tester.pumpAndSettle();

    expect(find.text("polski"), findsNothing);
  });

  /// tests if not signed up with api error
  testWidgets('not signed up with api error', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polski").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
        .called(1);
    expect(find.text("Rejestracja nie powiodła się. Spróbuj ponownie."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed up when username already in database
  /// user gets error message and stays at sign up page
  testWidgets('username already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "username This field must be unique",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polski").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
        .called(1);
    expect(find.text("Konto dla podanej nazwy użytkownika już istnieje."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed up when email already in database
  /// user gets error message and stays at sign up page
  testWidgets('email already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "email This field must be unique",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "eng", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("angielski").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));

    await tester.pumpAndSettle();
    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "eng", "+48765678789"))
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
      "body": "telephone This field must be unique",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polski").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));

    await tester.pumpAndSettle();
    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
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
      "body": "telephone email This field must be unique",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polski").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));

    await tester.pumpAndSettle();
    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
        .called(1);
    expect(
        find.text(
            "Konto dla podanego adresu e-mail i numeru telefonu już istnieje."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed up when telephone and username already in database
  /// user gets error message and stays at sign up page
  testWidgets('telephone and username already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "telephone username This field must be unique",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polski").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));

    await tester.pumpAndSettle();
    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
        .called(1);
    expect(
        find.text(
            "Konto dla podanej nazwy użytkownika i numeru telefonu już istnieje."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed up when email and username already in database
  /// user gets error message and stays at sign up page
  testWidgets('username and email already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "email username This field must be unique",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "eng", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("angielski").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));

    await tester.pumpAndSettle();
    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "eng", "+48765678789"))
        .called(1);
    expect(
        find.text(
            "Konto dla podanej nazwy użytkownika i adresu e-mail już istnieje."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed up when telephone, username and email already in database
  /// user gets error message and stays at sign up page
  testWidgets(
      'telephone, username and email already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body":
          "email username telephone This field must be unique",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polski").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));

    await tester.pumpAndSettle();
    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
        .called(1);
    expect(
        find.text(
            "Konto dla podanej nazwy użytkownika, adresu e-mail i numeru telefonu już istnieje."),
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
            "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polski").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
        .called(1);
    expect(find.text(" Numer telefonu jest nieprawidłowy."), findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed email address invalid
  /// user gets error message and stays at sign up page
  testWidgets('email address invalid, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "Enter a valid email address",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polski").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
        .called(1);
    expect(find.text(" Adres e-mail jest nieprawidłowy"), findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed email address and phone number invalid
  /// user gets error message and stays at sign up page
  testWidgets('email address invalid, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "Enter a valid email address. Enter a valid phone number",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polski").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
        .called(1);
    expect(find.text(" Adres e-mail oraz numer telefonu są nieprawidłowe."), findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if signs up with empty body, english
  testWidgets('english body is empty, does not sign up', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));

    await tester.tap(find.byKey(Key('registerButton')));

    verifyNever(await mockApi.signUp('', '', '', '', null, ''));
    await tester.pump();
    expect(find.byType(SignUp), findsOneWidget);
    expect(find.text("Required field"), findsNWidgets(4));
  });

  /// tests if signed up with valid body, english
  /// gets success message and goes to sign in page
  testWidgets('english body non-empty, success sign up', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "ok",
      "statusCode": "201",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polish").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
        .called(1);
    expect(find.text("The account has been created. You can log in."),
        findsOneWidget);
    expect(find.byType(SignIn), findsOneWidget);
  });

  /// tests if not signed up when username already in database, english
  /// user gets error message and stays at sign up page
  testWidgets('english username already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "username This field must be unique",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polish").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
        .called(1);
    expect(find.text("An account for the given username already exists."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed up when email already in database, english
  /// user gets error message and stays at sign up page
  testWidgets('english email already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "email This field must be unique",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "eng", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("english").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));

    await tester.pumpAndSettle();
    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "eng", "+48765678789"))
        .called(1);
    expect(find.text("An account for the given e-mail address already exists."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed up when telephone already in database, english
  /// user gets error message and stays at sign up page
  testWidgets('english telephone already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "telephone This field must be unique",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polish").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));

    await tester.pumpAndSettle();
    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
        .called(1);
    expect(find.text("An account for the given cell phone number already exists."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed up when telephone and email already in database, english
  /// user gets error message and stays at sign up page
  testWidgets('english telephone and email already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "email telephone This field must be unique",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polish").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));

    await tester.pumpAndSettle();
    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
        .called(1);
    expect(
        find.text(
            "An account for the given e-mail address and cell phone number already exists."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed up when telephone and username already in database, english
  /// user gets error message and stays at sign up page
  testWidgets('english telephone and username already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "username telephone This field must be unique",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polish").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));

    await tester.pumpAndSettle();
    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
        .called(1);
    expect(
        find.text(
            "An account for the given username and cell phone number already exists."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed up when email and username already in database, english
  /// user gets error message and stays at sign up page
  testWidgets('english username and email already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "email username This field must be unique",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "eng", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("english").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));

    await tester.pumpAndSettle();
    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "eng", "+48765678789"))
        .called(1);
    expect(
        find.text(
            "An account for the given username and e-mail address already exists."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed up when telephone, username and email already in database, english
  /// user gets error message and stays at sign up page
  testWidgets(
      'english telephone, username and email already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body":
          "email username telephone This field must be unique",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polish").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));

    await tester.pumpAndSettle();
    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
        .called(1);
    expect(
        find.text(
            "An account for the given username, e-mail address and cell phone number already exists."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed up when telephone invalid, english
  /// user gets error message and stays at sign up page
  testWidgets('english telephone invalid, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "Enter a valid phone number",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polish").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
        .called(1);
    expect(find.text(" The cell phone number is invalid."), findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if not signed email address invalid, english
  /// user gets error message and stays at sign up page
  testWidgets('english email address invalid, does not sign up',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        Map<String, String> res = {
          "body": "Enter a valid email address",
          "statusCode": "400",
        };
        when(mockApi.signUp("username", "password", "password", "email@email.com",
            "pl", "+48765678789"))
            .thenAnswer((_) async => Future.value(res));
        MockSecureStorage mockSecureStorage = MockSecureStorage();
        SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

        await tester.pumpWidget(makeEnglishTestableWidget(child: page));

        Finder usernameField = find.byKey(Key('username'));
        await tester.enterText(usernameField, 'username');

        Finder password1Field = find.byKey(Key('password1'));
        await tester.enterText(password1Field, 'password');

        Finder password2Field = find.byKey(Key('password2'));
        await tester.enterText(password2Field, 'password');

        Finder emailField = find.byKey(Key('email'));
        await tester.enterText(emailField, "email@email.com");

        await tester.tap(find.byKey(Key('language')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text("polish").last);
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();

        Finder telephoneField = find.byKey(Key('telephone'));
        await tester.enterText(telephoneField, "+48765678789");

        await tester.tap(find.byKey(Key('registerButton')));
        await tester.pumpAndSettle();

        verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
            .called(1);
        expect(find.text(" The e-mail address is invalid."), findsOneWidget);
        expect(find.byType(SignUp), findsOneWidget);
      });

  /// tests if not signed email address and phone number invalid, english
  /// user gets error message and stays at sign up page
  testWidgets('english email address invalid, does not sign up',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        Map<String, String> res = {
          "body": "Enter a valid email address. Enter a valid phone number",
          "statusCode": "400",
        };
        when(mockApi.signUp("username", "password", "password", "email@email.com",
            "pl", "+48765678789"))
            .thenAnswer((_) async => Future.value(res));
        MockSecureStorage mockSecureStorage = MockSecureStorage();
        SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

        await tester.pumpWidget(makeEnglishTestableWidget(child: page));

        Finder usernameField = find.byKey(Key('username'));
        await tester.enterText(usernameField, 'username');

        Finder password1Field = find.byKey(Key('password1'));
        await tester.enterText(password1Field, 'password');

        Finder password2Field = find.byKey(Key('password2'));
        await tester.enterText(password2Field, 'password');

        Finder emailField = find.byKey(Key('email'));
        await tester.enterText(emailField, "email@email.com");

        await tester.tap(find.byKey(Key('language')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text("polish").last);
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();

        Finder telephoneField = find.byKey(Key('telephone'));
        await tester.enterText(telephoneField, "+48765678789");

        await tester.tap(find.byKey(Key('registerButton')));
        await tester.pumpAndSettle();

        verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "pl", "+48765678789"))
            .called(1);
        expect(find.text(" The e-mail address and cell phone number are invalid."), findsOneWidget);
        expect(find.byType(SignUp), findsOneWidget);
      });

  /// tests if not signed up with api error, english
  testWidgets('english not signed up with api error', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
        "pl", "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignUp page = SignUp(storage: mockSecureStorage, testApi: mockApi);

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));

    Finder usernameField = find.byKey(Key('username'));
    await tester.enterText(usernameField, 'username');

    Finder password1Field = find.byKey(Key('password1'));
    await tester.enterText(password1Field, 'password');

    Finder password2Field = find.byKey(Key('password2'));
    await tester.enterText(password2Field, 'password');

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, "email@email.com");

    await tester.tap(find.byKey(Key('language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("polish").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder telephoneField = find.byKey(Key('telephone'));
    await tester.enterText(telephoneField, "+48765678789");

    await tester.tap(find.byKey(Key('registerButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.signUp("username", "password", "password",
        "email@email.com", "pl", "+48765678789"))
        .called(1);
    expect(find.text("Registration failed. Try again."),
        findsOneWidget);
    expect(find.byType(SignUp), findsOneWidget);
  });
}
