import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idom/api/api_login.dart';
import 'package:idom/pages/setup/sign_in.dart';
import 'package:mockito/mockito.dart';

class MockApiLogIn extends Mock implements ApiLogIn {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('email or password is empty, does not sign in',
      (WidgetTester tester) async {
    MockApiLogIn mockApiLogIn = MockApiLogIn();
    bool isSignedIn = false;
    SignIn page = SignIn(apiLogIn: mockApiLogIn, onSignedIn: () => isSignedIn = true);

    await tester.pumpWidget(makeTestableWidget(child: page));

    await tester.tap(find.byKey(Key('signIn')));

    verifyNever(mockApiLogIn.attemptToSignIn('', ''));
    expect(isSignedIn, false);
  });

  testWidgets('email and password non-empty, success sign in',
      (WidgetTester tester) async {
    MockApiLogIn mockApiLogIn = MockApiLogIn();
    bool isSignedIn = false;
    when(mockApiLogIn
        .attemptToSignIn('email@mail.com', 'password'))
        .thenAnswer((_) => Future.value('ok'));
    SignIn page = SignIn(apiLogIn: mockApiLogIn, onSignedIn: () => isSignedIn = true);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, 'email@mail.com');

    Finder passwordField = find.byKey(Key('password'));
    await tester.enterText(passwordField, 'password');

    await tester.tap(find.byKey(Key('signIn')));

    verify(mockApiLogIn.attemptToSignIn('email@mail.com', 'password'))
        .called(1);
    expect(isSignedIn, true);
  });

  testWidgets('email and password non-empty, success sign in',
          (WidgetTester tester) async {
        MockApiLogIn mockApiLogIn = MockApiLogIn();
        bool isSignedIn = false;
        when(mockApiLogIn
            .attemptToSignIn('email@mail.com', 'password'))
            .thenAnswer((_) => Future.value('wrong credentials'));
        SignIn page = SignIn(apiLogIn: mockApiLogIn, onSignedIn: () => isSignedIn = true);

        await tester.pumpWidget(makeTestableWidget(child: page));

        Finder emailField = find.byKey(Key('email'));
        await tester.enterText(emailField, 'email@mail.com');

        Finder passwordField = find.byKey(Key('password'));
        await tester.enterText(passwordField, 'password');

        await tester.tap(find.byKey(Key('signIn')));

        verify(mockApiLogIn.attemptToSignIn('email@mail.com', 'password'))
            .called(1);
        expect(isSignedIn, false);
      });
}
