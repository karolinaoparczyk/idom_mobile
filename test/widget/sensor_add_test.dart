import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/pages/sensors/new_sensor.dart';
import 'package:idom/api.dart';

class MockApi extends Mock implements Api {}

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(home: child);
  }

  /// tests if does not save with empty name and category
  testWidgets(
      'name, category, frequency value and frequency units empty, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockApi.addSensor(null, null, null, "token")).thenAnswer(
        (_) async => Future.value({"bodySen": '"id": 3', "statusCodeSen": "201"}));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text("Pole wymagane"), findsNWidgets(4));
    verifyNever(await mockApi.addSensor(null, null, null, "token"));
  });

  /// tests if does not save with only name
  testWidgets('only name, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockApi.addSensor('sensor', null, null, "token")).thenAnswer(
        (_) async => Future.value({"bodySen": '"id": 3', "statusCodeSen": "201"}));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'sensor');

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Pole wymagane"), findsNWidgets(3));

    verifyNever(await mockApi.addSensor('sensor', null, null, "token"));
  });

  /// tests if does not save with only category
  testWidgets('only category, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockApi.addSensor('', "humidity", null, "token")).thenAnswer(
        (_) async => Future.value({"bodySen": '"id": 3', "statusCodeSen": "201"}));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("wilgotność").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Pole wymagane"), findsNWidgets(3));
    verifyNever(await mockApi.addSensor('', 'humidity', null, "token"));
  });

  /// tests if saves with name, category, frequency value and frequency units
  testWidgets(
      'non empty name, category, frequency value and frequency units, saves',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockApi.addSensor('sensor', 'humidity', 7200, "token")).thenAnswer(
        (_) async => Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'sensor');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("wilgotność").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '2');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("godziny").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verify(await mockApi.addSensor('sensor', 'humidity', 7200, "token")).called(1);
  });

  /// tests if can choose rain_sensor sensor, frequency read only
  testWidgets(
      'can add rain_sensor sensor, frequency read only',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        when(mockApi.addSensor('sensor', 'rain_sensor', 30, "token")).thenAnswer(
                (_) async => Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
        MockSecureStorage mockSecureStorage = MockSecureStorage();
        when(mockSecureStorage.getToken())
            .thenAnswer((_) async => Future.value("token"));
        NewSensor page = NewSensor(
          storage: mockSecureStorage,
          testApi: mockApi,
        );

        await tester.pumpWidget(makeTestableWidget(child: page));
        await tester.pumpAndSettle();

        Finder emailField = find.byKey(Key('name'));
        await tester.enterText(emailField, 'sensor');

        Finder frequencyValueField = find.byKey(Key('frequencyValue'));
        await tester.enterText(frequencyValueField, '2');

        await tester.tap(find.byKey(Key('frequencyUnitsButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text("godziny").last);
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();

        expect(find.text("godziny"), findsNWidgets(2));
        expect(find.text("2"), findsOneWidget);
        expect(find.text("sensor"), findsOneWidget);

        await tester.tap(find.byKey(Key('categoriesButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text("opady atmosferyczne").last);
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();

        expect(find.text("sekundy"), findsOneWidget);
        expect(find.text("30"), findsOneWidget);
        expect(find.text("sensor"), findsOneWidget);

        await tester.tap(find.byKey(Key('addSensorButton')));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));

        verify(await mockApi.addSensor('sensor', 'rain_sensor', 30, "token"))
            .called(1);
      });

  /// tests if can choose rain_sensor sensor, choose another category - frequency not read only
  testWidgets(
      'can add rain_sensor sensor, choose another category - frequency not read only',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        when(mockApi.addSensor('sensor', 'humidity', 7200, "token")).thenAnswer(
                (_) async => Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
        MockSecureStorage mockSecureStorage = MockSecureStorage();
        when(mockSecureStorage.getToken())
            .thenAnswer((_) async => Future.value("token"));
        NewSensor page = NewSensor(
          storage: mockSecureStorage,
          testApi: mockApi,
        );

        await tester.pumpWidget(makeTestableWidget(child: page));
        await tester.pumpAndSettle();

        Finder emailField = find.byKey(Key('name'));
        await tester.enterText(emailField, 'sensor');

        await tester.tap(find.byKey(Key('categoriesButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text("opady atmosferyczne").last);
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();

        expect(find.text("sekundy"), findsOneWidget);
        expect(find.text("30"), findsOneWidget);
        expect(find.text("sensor"), findsOneWidget);

        await tester.tap(find.byKey(Key('categoriesButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text("wilgotność").last);
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();

        Finder frequencyValueField = find.byKey(Key('frequencyValue'));
        await tester.enterText(frequencyValueField, '2');

        await tester.tap(find.byKey(Key('frequencyUnitsButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text("godziny").last);
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();

        expect(find.text("godziny"), findsNWidgets(2));
        expect(find.text("2"), findsOneWidget);
        expect(find.text("sensor"), findsOneWidget);

        await tester.tap(find.byKey(Key('addSensorButton')));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));

        verify(await mockApi.addSensor('sensor', 'humidity', 7200, "token"))
            .called(1);
      });

  /// tests if does not save when name exists
  testWidgets('valid data, name exists, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockApi.addSensor('sensor', "humidity", 7200, 'token')).thenAnswer(
        (_) async => Future.value({
              "bodySen": '{"name":["Sensor with provided name already exists"]}',
              "statusCodeSen": "400"
            }));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder usernameField = find.byKey(Key('name'));
    await tester.enterText(usernameField, 'sensor');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("wilgotność").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '2');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("godziny").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Czujnik o podanej nazwie już istnieje."), findsOneWidget);
    expect(find.byType(NewSensor), findsOneWidget);

    verify(await mockApi.addSensor('sensor', "humidity", 7200, 'token')).called(1);
  });

  /// tests if does not save when frequency value not valid
  testWidgets('frequency value not valid, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));
    when(mockApi.addSensor('sensor', "humidity", 0, 'token')).thenAnswer(
        (_) async => Future.value({"bodySen": '"id": 3', "statusCodeSen": "400"}));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder usernameField = find.byKey(Key('name'));
    await tester.enterText(usernameField, 'sensor');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("wilgotność").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '0');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("godziny").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(NewSensor), findsOneWidget);
    expect(find.text("Wartość częstotliwości pobierania danych musi być nieujemną liczbą całkowitą."), findsOneWidget);

    verifyNever(await mockApi.addSensor('sensor', "humidity", 0, 'token'));
  });
}
