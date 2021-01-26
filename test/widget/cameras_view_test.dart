import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/pages/cameras/camera_stream.dart';
import 'package:idom/pages/cameras/cameras.dart';
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
    when(mockSecureStorage.getApiServerAddress()).thenAnswer((_) async =>
        Future.value("apiAddress"));
    Cameras page = Cameras(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find
        .byType(ListTile)
        .evaluate()
        .length, 2);
    expect(find.text("camera1"), findsOneWidget);
    expect(find.text("camera2"), findsOneWidget);
    expect(find.byKey(Key("assets/icons/video-camera.svg")), findsNWidgets(2));

    await tester.tap(find.byKey(Key('searchButton')));
    await tester.pumpAndSettle();
    Finder searchField = find.byKey(Key('searchField'));
    await tester.enterText(searchField, 'camera');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 2);
    expect(find.text("camera1"), findsOneWidget);
    expect(find.text("camera2"), findsOneWidget);

    await tester.enterText(searchField, '1');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, 1);
    expect(find.text("camera1"), findsOneWidget);
    expect(find.text("camera2"), findsNothing);
    await tester.tap(find.byKey(Key('arrowBack')));
    await tester.pumpAndSettle();
    expect(find.text("camera1"), findsOneWidget);
    expect(find.text("camera2"), findsOneWidget);

    await tester.tap(find.byKey(Key('searchButton')));
    await tester.pumpAndSettle();
    searchField = find.byKey(Key('searchField'));
    await tester.enterText(searchField, '2');
    await tester.pumpAndSettle();
    expect(find.text("camera1"), findsNothing);
    expect(find.text("camera2"), findsOneWidget);
    expect(find.byType(ListTile).evaluate().length, 1);
    await tester.tap(find.byKey(Key('clearSearchingBox')));
    await tester.pumpAndSettle();
    expect(find.text("camera1"), findsOneWidget);
    expect(find.text("camera2"), findsOneWidget);

    await tester.tap(find.text("camera1"));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(CameraStream), findsOneWidget);
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

    await tester.pumpWidget(makePolishTestableWidget(child: page));
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
    expect(find.text("Potwierdź"), findsOneWidget);
    expect(find.text("Czy na pewno chcesz usunąć kamerę camera1?"), findsOneWidget);
    expect(find.text("Tak"), findsOneWidget);
    expect(find.text("Nie"), findsOneWidget);

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

    await tester.pumpWidget(makePolishTestableWidget(child: page));
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

    await tester.drag(find.byKey(Key('CamerasList')), const Offset(0.0, 300));
    await tester.pumpAndSettle();
    verify(await mockApi.getCameras()).called(2);
  });

  /// tests if deletes camera, english
  testWidgets('english deletes camera', (WidgetTester tester) async {
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

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
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
    expect(find.text("Confirm"), findsOneWidget);
    expect(find.text("Are you sure you want to remove camera camera1?"), findsOneWidget);
    expect(find.text("Yes"), findsOneWidget);
    expect(find.text("No"), findsOneWidget);

    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    verify(await mockApi.deleteCamera(1)).called(1);
  });

  /// tests if does not delete if api error, english
  testWidgets('english does not delete if api error', (WidgetTester tester) async {
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

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
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
   expect(find.text("Camera removal failed. Try again."), findsOneWidget);

    verify(await mockApi.deleteCamera(1)).called(1);
  });



  /// tests if cameras not on list if api error, english
  testWidgets('english cameras not on list if api error', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.getCameras()).thenAnswer((_) async =>
        Future.value(null));

    MockSecureStorage mockSecureStorage = MockSecureStorage();

    Cameras page = Cameras(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    expect(find
        .byType(ListTile)
        .evaluate()
        .length, 0);
    expect(find.text("Server connection error."), findsOneWidget);
    expect(find.byKey(Key("assets/icons/video-camera.svg")), findsNothing);
  });
}