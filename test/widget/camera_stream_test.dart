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

  /// tests if opens up camera stream on click
  testWidgets('opens up camera stream on click', (WidgetTester tester) async {
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
    when(mockApi.getCameras("token")).thenAnswer((_) async =>
        Future.value({"body": jsonEncode(cameras), "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    Cameras page = Cameras(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();


    await tester.tap(find.byKey(Key("camera1")));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("camera1"), findsOneWidget);
    expect(find.byKey(Key("goToBrowser")), findsOneWidget);
  });
}