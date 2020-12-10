import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/pages/cameras/new_camera.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/api.dart';

class MockApi extends Mock implements Api {}

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  Widget makePolishTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
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

  /// tests if adds camera
  testWidgets('adds camera', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addCamera('name')).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "201"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewCamera page = NewCamera(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');
    expect(find.text("Nazwa"), findsOneWidget);

    await tester.tap(find.byKey(Key('saveCameraButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.addCamera('name')).called(1);
  });

  /// tests if does not add camera if name exists
  testWidgets('does not add camera if name exists',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addCamera('name')).thenAnswer((_) async => Future.value({
          "body": "Camera with provided name already exists",
          "statusCode": "400"
        }));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewCamera page = NewCamera(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('saveCameraButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Kamera o podanej nazwie już istnieje."), findsOneWidget);
    verify(await mockApi.addCamera('name')).called(1);
  });

  /// tests if does not save if api error
  testWidgets('does not save if api error',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addCamera('name')).thenAnswer((_) async => Future.value({
          "body": "",
          "statusCode": "400"
        }));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewCamera page = NewCamera(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('saveCameraButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Dodawanie kamery nie powiodło się. Spróbuj ponownie."), findsOneWidget);
    verify(await mockApi.addCamera('name')).called(1);
  });

  /// tests if does not add camera if name exists, english
  testWidgets('english does not add camera if name exists',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addCamera('name')).thenAnswer((_) async => Future.value({
          "body": "Camera with provided name already exists",
          "statusCode": "400"
        }));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewCamera page = NewCamera(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');
    expect(find.text("Name"), findsOneWidget);

    await tester.tap(find.byKey(Key('saveCameraButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("A camera with the given name already exists."), findsOneWidget);
    verify(await mockApi.addCamera('name')).called(1);
  });

  /// tests if does not save if api error, english
  testWidgets('english does not save if api error',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addCamera('name')).thenAnswer((_) async => Future.value({
          "body": "",
          "statusCode": "400"
        }));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    NewCamera page = NewCamera(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'name');

    await tester.tap(find.byKey(Key('saveCameraButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Creating camera failed. Try again."), findsOneWidget);
    verify(await mockApi.addCamera('name')).called(1);
  });
}
