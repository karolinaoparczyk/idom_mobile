import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idom/api.dart';
import 'package:idom/pages/setup/sign_in.dart';
import 'package:mockito/mockito.dart';

class MockApi extends Mock implements Api {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  /// tests if signs in with empty email or password
  testWidgets('email or password is empty, does not sign in',
      (WidgetTester tester) async {
        MockApi mockApi = MockApi();
    bool isSignedIn = false;
    SignIn page = SignIn(api: mockApi, onSignedIn: () => isSignedIn = true);

    await tester.pumpWidget(makeTestableWidget(child: page));

    await tester.tap(find.byKey(Key('Zaloguj się')));

    verifyNever(mockApi.signIn('', ''));
    expect(isSignedIn, false);
  });

  /// tests if signed in with valid email and password
  testWidgets('email and password non-empty, success sign in',
      (WidgetTester tester) async {
        MockApi mockApi = MockApi();
    bool isSignedIn = false;
    List<dynamic> res = ['"token": "wertyuiopasdfghjklzxcvbnmwertyuiopasdf"', 200];
    when(mockApi
        .signIn('email@mail.com', 'password'))
        .thenAnswer((_)async => Future.value(res));
    SignIn page = SignIn(api: mockApi, onSignedIn: () => isSignedIn = true);

    await tester.pumpWidget(makeTestableWidget(child: page));

    Finder emailField = find.byKey(Key('email'));
    await tester.enterText(emailField, 'email@mail.com');

    Finder passwordField = find.byKey(Key('password'));
    await tester.enterText(passwordField, 'password');

    await tester.tap(find.byKey(Key('Zaloguj się')));

    verify(await mockApi.signIn('email@mail.com', 'password'))
        .called(1);
    expect(isSignedIn, true);
  });

  /// tests if does not sign in with invalid email or password
  testWidgets('email and password non-empty, error sign in',
          (WidgetTester tester) async {
            MockApi mockApi = MockApi();
        bool isSignedIn = false;
        List<dynamic> res = ['Wrong credentials', 400];
        when(mockApi
            .signIn('email@mail.com', 'password'))
            .thenAnswer((_) => Future.value(res));
        SignIn page = SignIn(api: mockApi, onSignedIn: () => isSignedIn = true);

        await tester.pumpWidget(makeTestableWidget(child: page));

        Finder emailField = find.byKey(Key('email'));
        await tester.enterText(emailField, 'email@mail.com');

        Finder passwordField = find.byKey(Key('password'));
        await tester.enterText(passwordField, 'password');

        await tester.tap(find.byKey(Key('Zaloguj się')));

        verify(mockApi.signIn('email@mail.com', 'password'))
            .called(1);
        expect(isSignedIn, false);
      });
}
