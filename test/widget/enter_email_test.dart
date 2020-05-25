import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idom/api.dart';
import 'package:idom/pages/setup/enter_email.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/pages/setup/sign_in.dart';
import 'package:mockito/mockito.dart';

class MockApi extends Mock implements Api {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(home: child);
  }

  /// tests if request is sent when entered email from sign in page
  testWidgets('enter email, request sent, sign in page', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.resetPassword("email@email.com"))
        .thenAnswer((_) async => Future.value(200));
    SignIn page = SignIn(api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));
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

    expect(find.byType(SignIn), findsOneWidget);
  });

  /// tests if request is not sent when empty email from sign in page
  testWidgets('empty email, request not sent, sign in page', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.resetPassword(""))
        .thenAnswer((_) async => Future.value(400));
    SignIn page = SignIn(api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('passwordReset')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('Resetuj hasło')));
    await tester.pumpAndSettle();

    verifyNever(await mockApi.resetPassword(""));
    await tester.pumpAndSettle();

    expect(find.byType(EnterEmail), findsOneWidget);
  });

  /// tests if request is sent when entered email from front page
  testWidgets('enter email, request sent, front page', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.resetPassword("email@email.com"))
        .thenAnswer((_) async => Future.value(200));
    Front page = Front(api: mockApi);

    await tester.pumpWidget(makeTestableWidget(child: page));
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

    expect(find.byType(Front), findsOneWidget);
  });

}
