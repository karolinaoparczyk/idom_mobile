import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/cameras/edit_camera.dart';
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

  /// tests if edits camera name
  testWidgets('edits camera name', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Camera camera = Camera(id: 1, name: "camera1", ipAddress: "111.111.11.11");
    when(mockApi.editCamera(1, 'newname')).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    EditCamera page = EditCamera(
      storage: mockSecureStorage,
      camera: camera,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pump();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("Ogólne"), findsOneWidget);

    await tester.tap(find.byKey(Key('editCameraButton')));
    await tester.pumpAndSettle();
    expect(find.text("Potwierdź"), findsOneWidget);
    expect(find.text("Czy na pewno zapisać zmiany?"), findsOneWidget);
    expect(find.text("Tak"), findsOneWidget);
    expect(find.text("Nie"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verify(await mockApi.editCamera(1, 'newname')).called(1);
  });

  /// tests if camera name exists, does not save
  testWidgets('camera name exists, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Camera camera = Camera(id: 1, name: "camera1", ipAddress: "111.111.11.11");
    when(mockApi.editCamera(1, 'newname')).thenAnswer((_) async =>
        Future.value({
          "body": "Camera with provided name already exists",
          "statusCode": "400"
        }));

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    EditCamera page = EditCamera(
      storage: mockSecureStorage,
      camera: camera,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pump();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('editCameraButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Kamera o podanej nazwie już istnieje."), findsOneWidget);

    verify(await mockApi.editCamera(1, 'newname')).called(1);
  });

  /// tests if api error, does not save
  testWidgets('api error, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Camera camera = Camera(id: 1, name: "camera1", ipAddress: "111.111.11.11");
    when(mockApi.editCamera(1, 'newname')).thenAnswer((_) async =>
        Future.value({
          "body": "",
          "statusCode": "400"
        }));

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    EditCamera page = EditCamera(
      storage: mockSecureStorage,
      camera: camera,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pump();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('editCameraButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Edycja kamery nie powiodła się. Spróbuj ponownie."), findsOneWidget);

    verify(await mockApi.editCamera(1, 'newname')).called(1);
  });

  /// tests if edits camera name, english
  testWidgets('english edits camera name', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Camera camera = Camera(id: 1, name: "camera1", ipAddress: "111.111.11.11");
    when(mockApi.editCamera(1, 'newname')).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    EditCamera page = EditCamera(
      storage: mockSecureStorage,
      camera: camera,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pump();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("General"), findsOneWidget);

    await tester.tap(find.byKey(Key('editCameraButton')));
    await tester.pumpAndSettle();
    expect(find.text("Confirm"), findsOneWidget);
    expect(find.text("Are you sure you want to save the changes?"), findsOneWidget);
    expect(find.text("Yes"), findsOneWidget);
    expect(find.text("No"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verify(await mockApi.editCamera(1, 'newname')).called(1);
  });

  /// tests if camera name exists, does not save, english
  testWidgets('english camera name exists, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Camera camera = Camera(id: 1, name: "camera1", ipAddress: "111.111.11.11");
    when(mockApi.editCamera(1, 'newname')).thenAnswer((_) async =>
        Future.value({
          "body": "Camera with provided name already exists",
          "statusCode": "400"
        }));

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    EditCamera page = EditCamera(
      storage: mockSecureStorage,
      camera: camera,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pump();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('editCameraButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("A camera with the given name already exists."), findsOneWidget);

    verify(await mockApi.editCamera(1, 'newname')).called(1);
  });

  /// tests if api error, does not save, english
  testWidgets('english api error, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    Camera camera = Camera(id: 1, name: "camera1", ipAddress: "111.111.11.11");
    when(mockApi.editCamera(1, 'newname')).thenAnswer((_) async =>
        Future.value({
          "body": "",
          "statusCode": "400"
        }));

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    EditCamera page = EditCamera(
      storage: mockSecureStorage,
      camera: camera,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pump();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('editCameraButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Editing camera failed. Try again."), findsOneWidget);

    verify(await mockApi.editCamera(1, 'newname')).called(1);
  });
}
