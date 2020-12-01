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
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
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

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pump();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('editCameraButton')));
    await tester.pumpAndSettle();
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

    await tester.pumpWidget(makeTestableWidget(child: page));
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

    await tester.pumpWidget(makeTestableWidget(child: page));
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
}
