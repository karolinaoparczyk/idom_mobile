import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/pages/home.dart';
import 'package:idom/pages/logotype_widget.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/pages/setup/settings.dart';
import 'package:idom/utils/app_state_notifier.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';
import 'package:provider/provider.dart';

class MockApi extends Mock implements Api {}

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  Widget makePolishTestableWidget({Widget child}) {
    return ChangeNotifierProvider<AppStateNotifier>(
        create: (context) => AppStateNotifier(),
        child: MaterialApp(
          home: child,
        ));
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

  /// tests if sets dark mode
  testWidgets('sets dark mode', (WidgetTester tester) async {
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    when(mockSecureStorage.getIsLoggedIn())
        .thenAnswer((_) async => Future.value("true"));
    when(mockSecureStorage.getThemeMode())
        .thenAnswer((_) async => Future.value("light"));

    Map<String, dynamic> googleServicesJson = {
      'project_info': {
        'firebase_url': 'firebase_url',
        'storage_bucket': 'storage_bucket'
      },
      "client": [
        {
          'client_info': {'mobilesdk_app_id': 'mobilesdk_app_id'},
          "api_key": [
            {"current_key": "current_key"}
          ]
        }
      ]
    };
    Settings page = Settings(
        storage: mockSecureStorage,
        inTestMode: true,
        googleServicesJson: googleServicesJson);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('darkMode')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('deleteData')));
  });

  /// tests if sets light mode
  testWidgets('sets light mode', (WidgetTester tester) async {
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    when(mockSecureStorage.getIsLoggedIn())
        .thenAnswer((_) async => Future.value("true"));
    when(mockSecureStorage.getThemeMode())
        .thenAnswer((_) async => Future.value("dark"));

    Map<String, dynamic> googleServicesJson = {
      'project_info': {
        'firebase_url': 'firebase_url',
        'storage_bucket': 'storage_bucket'
      },
      "client": [
        {
          'client_info': {'mobilesdk_app_id': 'mobilesdk_app_id'},
          "api_key": [
            {"current_key": "current_key"}
          ]
        }
      ]
    };
    Settings page = Settings(
        storage: mockSecureStorage,
        inTestMode: true,
        googleServicesJson: googleServicesJson);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('lightMode')));

    await tester.tap(find.byKey(Key('pickFile')));
    await tester.pumpAndSettle();
    expect(
        find.text(
            "Plik jest niepoprawny. Pobierz go z serwisu Firebase i spróbuj ponownie."),
        findsNothing);

    Finder nameField = find.byKey(Key('apiAddress'));
    await tester.enterText(nameField, 'address');

    await tester.tap(find.byKey(Key('save')));
    await tester.pumpAndSettle();
    expect(find.text("Potwierdź"), findsOneWidget);
    expect(find.text("Czy na pewno zapisać zmiany?"), findsOneWidget);
    expect(find.text("Tak"), findsOneWidget);
    expect(find.text("Nie"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
  });

  /// tests if invalid file
  testWidgets('invalid file', (WidgetTester tester) async {
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    when(mockSecureStorage.getIsLoggedIn())
        .thenAnswer((_) async => Future.value("true"));
    when(mockSecureStorage.getThemeMode())
        .thenAnswer((_) async => Future.value("dark"));

    Map<String, dynamic> googleServicesJson = {'project_info': "invalid file"};
    Settings page = Settings(
        storage: mockSecureStorage,
        inTestMode: true,
        googleServicesJson: googleServicesJson);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('pickFile')));
    await tester.pumpAndSettle();
    expect(
        find.text(
            "Plik jest niepoprawny. Pobierz go z serwisu Firebase i spróbuj ponownie."),
        findsOneWidget);
  });

  /// tests if changes address
  testWidgets('changes address', (WidgetTester tester) async {
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    when(mockSecureStorage.getIsLoggedIn())
        .thenAnswer((_) async => Future.value("true"));
    when(mockSecureStorage.getThemeMode())
        .thenAnswer((_) async => Future.value("dark"));

    Settings page = Settings(
        storage: mockSecureStorage,
        inTestMode: true);

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('apiAddress'));
    await tester.enterText(nameField, 'address');

    await tester.tap(find.byKey(Key('save')));
    await tester.pumpAndSettle();
    expect(find.text("Potwierdź"), findsOneWidget);
    expect(find.text("Czy na pewno zapisać zmiany?"), findsOneWidget);
    expect(find.text("Tak"), findsOneWidget);
    expect(find.text("Nie"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

  });
}
