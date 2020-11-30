import 'dart:convert';

import 'package:idom/pages/cameras/cameras.dart';
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

  /// tests if cameras on list
  testWidgets('cameras on list', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> cameras = [
      {
        "id": 1,
        "name": "camera1",
        "ipAddress": "111.111.11.11"
      },
      {
        "id": 2,
        "name": "camera2",
        "ipAddress": "113.113.13.13"
      }
    ];
    when(mockApi.getCameras()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(cameras), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    Cameras page = Cameras(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find
        .byType(ListTile)
        .evaluate()
        .length, 2);
    expect(find.text("camera1"), findsOneWidget);
    expect(find.text("camera2"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/video-camera.svg")), findsNWidgets(2));
  });

  /// tests if deletes camera
  testWidgets('deletes camera', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> cameras = [
      {
        "id": 1,
        "name": "camera1",
        "ipAddress": "111.111.11.11"
      },
      {
        "id": 2,
        "name": "camera2",
        "ipAddress": "113.113.13.13"
      }
    ];
    when(mockApi.getCameras()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(cameras), "statusCode": "200"}));
    when(mockApi.deleteCamera(1))
        .thenAnswer((_) async => Future.value(200));
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    Cameras page = Cameras(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find
        .byType(ListTile)
        .evaluate()
        .length, 2);
    expect(find.text("camera1"), findsOneWidget);
    expect(find.text("camera2"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/video-camera.svg")), findsNWidgets(2));
    await tester.tap(find.byKey(Key("deleteButton")).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.deleteCamera(1)).called(1);
  });

  /// tests if does not delete if api error
  testWidgets('does not delete if api error', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> cameras = [
      {
        "id": 1,
        "name": "camera1",
        "ipAddress": "111.111.11.11"
      },
      {
        "id": 2,
        "name": "camera2",
        "ipAddress": "113.113.13.13"
      }
    ];
    when(mockApi.getCameras()).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(cameras), "statusCode": "200"}));
    when(mockApi.deleteCamera(1))
        .thenAnswer((_) async => Future.value(404));
    MockSecureStorage mockSecureStorage = MockSecureStorage();

    Cameras page = Cameras(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find
        .byType(ListTile)
        .evaluate()
        .length, 2);
    expect(find.text("camera1"), findsOneWidget);
    expect(find.text("camera2"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/video-camera.svg")), findsNWidgets(2));
    await tester.tap(find.byKey(Key("deleteButton")).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
   expect(find.byType(SnackBar), findsOneWidget);
   expect(find.text("Usunięcie kamery nie powiodło się. Spróbuj ponownie."), findsOneWidget);
   
    verify(await mockApi.deleteCamera(1)).called(1);
  });
}