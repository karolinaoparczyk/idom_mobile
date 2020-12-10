import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';
import 'package:idom/pages/setup/enter_email.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/pages/setup/sign_in.dart';

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

  /// tests if request is sent when entered email from sign in page
  testWidgets('enter email, request sent, sign in page',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.resetPassword("email@email.com"))
        .thenAnswer((_) async => Future.value(200));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignIn page = SignIn(storage: mockSecureStorage, isFromSignUp: false, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('passwordReset')));
    await tester.pumpAndSettle();

    expect(find.text("Adres e-mail"), findsOneWidget);
    expect(find.text("Reset hasła"), findsOneWidget);
    expect(find.text("Podaj adres e-mail połączony z Twoim kontem"), findsOneWidget);
    expect(find.text("Resetuj hasło"), findsOneWidget);

    Finder emailField = find.byKey(Key("email"));
    await tester.enterText(emailField, "email@email.com");
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('Resetuj hasło')));
    await tester.pumpAndSettle();

    verify(await mockApi.resetPassword("email@email.com")).called(1);
    await tester.pumpAndSettle();

    expect(find.text("Link do resetu hasła został wysłany na podany adres e-mail."), findsOneWidget);
    expect(find.byType(EnterEmail), findsOneWidget);
  });

  /// tests if entered email does not exist
  testWidgets('enter email, does not exist',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.resetPassword("email@email.com"))
        .thenAnswer((_) async => Future.value(400));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignIn page = SignIn(storage: mockSecureStorage, isFromSignUp: false, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('passwordReset')));
    await tester.pumpAndSettle();

    expect(find.text("Adres e-mail"), findsOneWidget);
    expect(find.text("Reset hasła"), findsOneWidget);
    expect(find.text("Podaj adres e-mail połączony z Twoim kontem"), findsOneWidget);
    expect(find.text("Resetuj hasło"), findsOneWidget);

    Finder emailField = find.byKey(Key("email"));
    await tester.enterText(emailField, "email@email.com");
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('Resetuj hasło')));
    await tester.pumpAndSettle();

    verify(await mockApi.resetPassword("email@email.com")).called(1);
    await tester.pumpAndSettle();

    expect(find.text("Konto dla podanego adresu e-mail nie istnieje."), findsOneWidget);
    expect(find.byType(EnterEmail), findsOneWidget);
  });

  /// tests if request is not sent when empty email from sign in page
  testWidgets('empty email, request not sent, sign in page',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.resetPassword("")).thenAnswer((_) async => Future.value(200));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignIn page = SignIn(storage: mockSecureStorage, isFromSignUp: false, testApi: mockApi);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('passwordReset')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('Resetuj hasło')));
    await tester.pumpAndSettle();

    verifyNever(await mockApi.resetPassword(""));
    await tester.pumpAndSettle();

    expect(find.text("Pole wymagane"), findsOneWidget);
    expect(find.byType(EnterEmail), findsOneWidget);
  });

  /// tests if request is sent when entered email from front page
  testWidgets('enter email, request sent, front page',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.resetPassword("email@email.com"))
        .thenAnswer((_) async => Future.value(200));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getApiServerAddress()).thenAnswer((_) async =>
        Future.value("apiAddress"));
    Front page = Front(storage: mockSecureStorage, testApi: mockApi);
    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('passwordReset')));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key("email"));
    await tester.enterText(emailField, "email@email.com");
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('Resetuj hasło')));
    await tester.pumpAndSettle();

    verify(await mockApi.resetPassword("email@email.com")).called(1);
    await tester.pumpAndSettle();

    expect(find.text("Link do resetu hasła został wysłany na podany adres e-mail."), findsOneWidget);
    expect(find.byType(EnterEmail), findsOneWidget);
  });

  /// tests if request is sent when entered email from sign in page, english
  testWidgets('english enter email, request sent, sign in page',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.resetPassword("email@email.com"))
        .thenAnswer((_) async => Future.value(200));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignIn page = SignIn(storage: mockSecureStorage, isFromSignUp: false, testApi: mockApi);

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('passwordReset')));
    await tester.pumpAndSettle();

    expect(find.text("E-mail address"), findsOneWidget);
    expect(find.text("Reset password"), findsNWidgets(2));
    expect(find.text("Enter the e-mail address associated with your account"), findsOneWidget);

    Finder emailField = find.byKey(Key("email"));
    await tester.enterText(emailField, "email@email.com");
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('Reset password')));
    await tester.pumpAndSettle();

    verify(await mockApi.resetPassword("email@email.com")).called(1);
    await tester.pumpAndSettle();

    expect(find.text("A link to reset a password has been sent to the provided e-mail address."), findsOneWidget);
    expect(find.byType(EnterEmail), findsOneWidget);
  });

  /// tests if entered email does not exist, english
  testWidgets('english enter email, does not exist',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.resetPassword("email@email.com"))
        .thenAnswer((_) async => Future.value(400));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignIn page = SignIn(storage: mockSecureStorage, isFromSignUp: false, testApi: mockApi);

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('passwordReset')));
    await tester.pumpAndSettle();

    expect(find.text("E-mail address"), findsOneWidget);
    expect(find.text("Reset password"), findsNWidgets(2));
    expect(find.text("Enter the e-mail address associated with your account"), findsOneWidget);

    Finder emailField = find.byKey(Key("email"));
    await tester.enterText(emailField, "email@email.com");
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('Reset password')));
    await tester.pumpAndSettle();

    verify(await mockApi.resetPassword("email@email.com")).called(1);
    await tester.pumpAndSettle();

    expect(find.text("The account for the given e-mail address does not exist."), findsOneWidget);
    expect(find.byType(EnterEmail), findsOneWidget);
  });

  /// tests if request is not sent when empty email from sign in page, english
  testWidgets('english empty email, request not sent, sign in page',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.resetPassword("")).thenAnswer((_) async => Future.value(200));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    SignIn page = SignIn(storage: mockSecureStorage, isFromSignUp: false, testApi: mockApi);

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('passwordReset')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('Reset password')));
    await tester.pumpAndSettle();

    verifyNever(await mockApi.resetPassword(""));
    await tester.pumpAndSettle();

    expect(find.text("Required field"), findsOneWidget);
    expect(find.byType(EnterEmail), findsOneWidget);
  });

  /// tests if request is sent when entered email from front page, english
  testWidgets('english enter email, request sent, front page',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.resetPassword("email@email.com"))
        .thenAnswer((_) async => Future.value(200));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getApiServerAddress()).thenAnswer((_) async =>
        Future.value("apiAddress"));
    Front page = Front(storage: mockSecureStorage, testApi: mockApi);
    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('passwordReset')));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key("email"));
    await tester.enterText(emailField, "email@email.com");
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('Reset password')));
    await tester.pumpAndSettle();

    verify(await mockApi.resetPassword("email@email.com")).called(1);
    await tester.pumpAndSettle();

    expect(find.text("A link to reset a password has been sent to the provided e-mail address."), findsOneWidget);
    expect(find.byType(EnterEmail), findsOneWidget);
  });
}
