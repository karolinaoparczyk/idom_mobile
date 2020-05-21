import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idom/api.dart';
import 'package:idom/pages/setup/sign_in.dart';
import 'package:idom/pages/setup/sign_up.dart';
import 'package:mockito/mockito.dart';

class MockApi extends Mock implements Api {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(home: child);
  }

  /// tests if signs up with empty body
  testWidgets('body is empty, does not sign up', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    SignUp page = SignUp(api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));

    await tester.tap(find.byKey(Key('signUp')));

    verifyNever(await mockApi.signUp('', '', '', '', ''));
    expect(find.byType(SignUp), findsOneWidget);
  });

  /// tests if signed up with valid body
  /// use gets success message and goes to sign in page
  testWidgets('body non-empty, success sign up', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "ok",
      "statusCode": "201",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    SignUp page = SignUp(api: mockApi);

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

    await tester.tap(find.byKey(Key('signUp')));
    await tester.pumpAndSettle();

    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "+48765678789"))
        .called(1);
    expect(find.text("Sukces"), findsOneWidget);
    await tester.tap(find.byKey(Key('ok button')));
    await tester.pumpAndSettle();
    expect(find.byType(SignIn), findsOneWidget);
  });

  /// tests if not signed up when username or email already in database
  /// user gets error message and stays at sign up page
  testWidgets('username or email already in database, does not sign up',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Map<String, String> res = {
      "body": "for key 'register_customuser.username'",
      "statusCode": "400",
    };
    when(mockApi.signUp("username", "password", "password", "email@email.com",
            "+48765678789"))
        .thenAnswer((_) async => Future.value(res));
    SignUp page = SignUp(api: mockApi);

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

    await tester.tap(find.byKey(Key('signUp')));

    verify(await mockApi.signUp("username", "password", "password",
            "email@email.com", "+48765678789"))
        .called(1);
    await tester.pumpAndSettle();
    expect(find.text("Błąd"), findsOneWidget);
    await tester.tap(find.byKey(Key('ok button')));
    await tester.pumpAndSettle();
    expect(find.byType(SignUp), findsOneWidget);
  });
}
