import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/pages/sensors/edit_sensor.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:idom/models.dart';
import 'package:idom/api.dart';

class MockApi extends Mock implements Api {}

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  Widget makePolishTestableWidget({Widget child}) {
    return MaterialApp(home: child);
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

  /// tests if does not save with empty name
  testWidgets('name is empty, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "humidity",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, '');

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();

    expect(find.text("Pole wymagane"), findsOneWidget);
    expect(find.text("Nazwa"), findsOneWidget);
    expect(find.text("Kategoria"), findsOneWidget);
    expect(find.text("Wartość"), findsOneWidget);
    expect(find.text("Jednostki"), findsOneWidget);
    expect(find.text("Ogólne"), findsOneWidget);
    expect(find.text("Częstotliwość pobierania danych"), findsOneWidget);
    expect(find.byType(EditSensor), findsOneWidget);
    verifyNever(await mockApi.editSensor(1, '', null, null));
  });

  /// tests if does not save with no change
  testWidgets('no change, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "humidity",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Nie wprowadzono żadnych zmian."), findsOneWidget);
    expect(find.byType(EditSensor), findsOneWidget);

    verifyNever(await mockApi.editSensor(1, null, null, null));
  });

  /// tests if saves with name changed
  testWidgets('changed name, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, 'newname', null, null)).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "humidity",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    expect(find.text("Potwierdź"), findsOneWidget);
    expect(find.text("Czy na pewno zapisać zmiany?"), findsOneWidget);
    expect(find.text("Tak"), findsOneWidget);
    expect(find.text("Nie"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verify(await mockApi.editSensor(1, 'newname', null, null)).called(1);
  });

  /// tests if saves with category changed
  testWidgets('changed category, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, null, "humidity", null)).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    /// scroll categories list
    await tester.drag(
        find.byKey(Key('categories_list')), const Offset(0.0, -300));
    await tester.pump();
    await tester.tap(find.text("wilgotność gleby").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, null, 'humidity', null)).called(1);
  });

  /// tests if saves with frequency value changed
  testWidgets('changed frequency value, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, null, null, 3000)).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '3000');

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, null, null, 3000)).called(1);
  });

  /// tests if saves with frequency units changed
  testWidgets('changed frequency units, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, null, null, 18000)).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));

    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("sekundy"), findsNWidgets(2));
    expect(find.text("minuty"), findsOneWidget);
    expect(find.text("godziny"), findsOneWidget);
    expect(find.text("dni"), findsOneWidget);
    expect(find.text("Wybierz jednostki"), findsOneWidget);
    expect(find.text("Anuluj"), findsOneWidget);
    await tester.tap(find.text("minuty").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, null, null, 18000,)).called(1);
  });


  /// tests if saves with name, category, frequency value and frequency units changed
  testWidgets('changed name, category frequency value, frequency units, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, 'newname', 'humidity', 86400)).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    /// scroll categories list
    await tester.drag(
        find.byKey(Key('categories_list')), const Offset(0.0, -300));
    await tester.pump();
    await tester.tap(find.text("wilgotność gleby").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '1');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("dni").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, 'newname', 'humidity', 86400))
        .called(1);
  });

  /// tests if does not save with data change but no confirmation
  testWidgets('changed data, no confirmation, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, 'newname', 'humidity', 86400)).thenAnswer(
        (_) async => Future.value({"body": "", "statusCode": "200"}));
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    /// scroll categories list
    await tester.drag(
        find.byKey(Key('categories_list')), const Offset(0.0, -300));
    await tester.pump();
    await tester.tap(find.text("wilgotność gleby").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '1');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("dni").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('noButton')));
    await tester.pump();
    expect(find.byType(EditSensor), findsOneWidget);
    verifyNever(await mockApi.editSensor(1, 'newname', 'humidity', 86400));
  });

  /// tests if does not save when name exists
  testWidgets('changed data, name exists, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, 'sensor2', null, null)).thenAnswer(
        (_) async => Future.value({
              "body": "Sensor with provided name already exists",
              "statusCode": "400"
            }));
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder usernameField = find.byKey(Key('name'));
    await tester.enterText(usernameField, 'sensor2');

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();
    expect(find.text("Czujnik o podanej nazwie już istnieje."), findsOneWidget);
    await tester.pump();
    expect(find.byType(EditSensor), findsOneWidget);
    verify(await mockApi.editSensor(1, 'sensor2', null, null)).called(1);
  });

  /// tests if when category rain_sensor, cannot change frequency
  testWidgets('when category rain_sensor, cannot change frequency', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, 'newname', 'rain_sensor', 30)).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));

    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("opady atmosferyczne").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("sekundy"), findsOneWidget);
    expect(find.text("30"), findsOneWidget);
    expect(find.text("newname"), findsOneWidget);

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, 'newname', 'rain_sensor', 30))
        .called(1);
  });

  /// tests if when category breathalyser, cannot change frequency
  testWidgets('when category breathalyser, cannot change frequency', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, 'newname', 'breathalyser', 30)).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));

    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("alkomat").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("sekundy"), findsNothing);
    expect(find.text("30"), findsNothing);
    expect(find.text("newname"), findsOneWidget);
    expect(find.text("alkomat"), findsNWidgets(2));

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, 'newname', 'breathalyser', 30))
        .called(1);
  });

  /// tests can change category to air_humidity
  testWidgets('change category to air_humidity', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, 'newname', 'air_humidity', null)).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));

    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("alkomat"), findsOneWidget);
    expect(find.text("ciśnienie atmosferyczne"), findsOneWidget);
    expect(find.text("opady atmosferyczne"), findsOneWidget);
    expect(find.text("temperatura powietrza"), findsNWidgets(2));
    expect(find.text("temperatura wody"), findsOneWidget);
    expect(find.text("dym"), findsOneWidget);
    /// scroll categories list
    await tester.drag(
        find.byKey(Key('categories_list')), const Offset(0.0, -300));
    await tester.pump();
    expect(find.text("gaz"), findsOneWidget);
    expect(find.text("wilgotność gleby"), findsOneWidget);
    expect(find.text("wilgotność powietrza"), findsOneWidget);
    expect(find.text("Wybierz kategorię"), findsOneWidget);
    expect(find.text("Anuluj"), findsOneWidget);
    await tester.tap(find.text("wilgotność powietrza").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("sekundy"), findsOneWidget);
    expect(find.text("300"), findsOneWidget);
    expect(find.text("newname"), findsOneWidget);
    expect(find.text("wilgotność powietrza"), findsNWidgets(2));

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, 'newname', 'air_humidity', null))
        .called(1);
  });

  /// tests if when  edits category breathalyser, can change frequency
  testWidgets('when  edits category breathalyser, can change frequency', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, 'newname', 'temperature', 180)).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));

    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "breathalyser",
        frequency: 30,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'newname');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("temperatura powietrza").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("sekundy"), findsOneWidget);
    expect(find.text("30"), findsOneWidget);
    expect(find.text("newname"), findsOneWidget);
    expect(find.text("temperatura powietrza"), findsNWidgets(2));

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '3');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("minuty").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, 'newname', 'temperature', 180))
        .called(1);
  });

  /// tests if changes smoke sensor details correctly
  testWidgets('changes smoke sensor details correctly', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editSensor(1, 'newname', null, null)).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken()).thenAnswer(
            (_) async => Future.value("token"));
    when(mockSecureStorage.resetUserData()).thenAnswer(
            (_) async => Future.value());

    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "smoke",
        frequency: 30,
        lastData: null);

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder usernameField = find.byKey(Key('name'));
    await tester.enterText(usernameField, 'newname');

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, 'newname', null, null))
        .called(1);
  });

  /// tests if changes atmospheric pressure sensor details correctly
  testWidgets('changes atmospheric pressure sensor details correctly', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.editSensor(1, 'newname', null, 180)).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken()).thenAnswer(
            (_) async => Future.value("token"));
    when(mockSecureStorage.resetUserData()).thenAnswer(
            (_) async => Future.value());

    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "atmo_pressure",
        frequency: 30,
        lastData: null);

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder usernameField = find.byKey(Key('name'));
    await tester.enterText(usernameField, 'newname');

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '3');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("minuty").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();


    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, 'newname', null, 180))
        .called(1);
  });

  /// tests if does not save with empty name, english
  testWidgets('name is empty, does not save, english', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "humidity",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, '');

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();

    expect(find.text("Required field"), findsOneWidget);
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("Category"), findsOneWidget);
    expect(find.text("Value"), findsOneWidget);
    expect(find.text("Units"), findsOneWidget);
    expect(find.text("General"), findsOneWidget);
    expect(find.text("Data gathering frequency"), findsOneWidget);
    expect(find.byType(EditSensor), findsOneWidget);
    verifyNever(await mockApi.editSensor(1, '', null, null));
  });

  /// tests if does not save with no change, english
  testWidgets('no change, does not save, english', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "humidity",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("No changes have been made."), findsOneWidget);
    expect(find.byType(EditSensor), findsOneWidget);

    verifyNever(await mockApi.editSensor(1, null, null, null));
  });

  /// tests if saves with name changed, english
  testWidgets('changed name, saves, english', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, 'newname', null, null)).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "humidity",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'newname');

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    expect(find.text("Confirm"), findsOneWidget);
    expect(find.text("Are you sure you want to save the changes?"), findsOneWidget);
    expect(find.text("Yes"), findsOneWidget);
    expect(find.text("No"), findsOneWidget);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verify(await mockApi.editSensor(1, 'newname', null, null)).called(1);
  });

  /// tests if saves with frequency units changed, english
  testWidgets('english changed frequency units, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, null, null, 18000)).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));

    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pumpAndSettle();
    expect(find.text("Select units"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);
    expect(find.text("seconds"), findsOneWidget);
    expect(find.text("minutes"), findsOneWidget);
    expect(find.text("hours"), findsOneWidget);
    expect(find.text("days"), findsOneWidget);

    await tester.tap(find.text("minutes").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, null, null, 18000,)).called(1);
  });

  /// tests if saves with category changed, english
  testWidgets('english, changed category, saves', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.editSensor(1, null, "humidity", null)).thenAnswer(
            (_) async => Future.value({"body": "", "statusCode": "200"}));
    Sensor sensor = Sensor(
        id: 1,
        name: "sensor1",
        category: "temperature",
        frequency: 300,
        lastData: "27.0");

    EditSensor page = EditSensor(
      storage: mockSecureStorage,
      sensor: sensor,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    expect(find.text("breathalyser"), findsOneWidget);
    expect(find.text("atmospheric pressure"), findsOneWidget);
    expect(find.text("precipitation"), findsOneWidget);
    expect(find.text("air temperature"), findsNWidgets(2));
    expect(find.text("water temperature"), findsOneWidget);
    expect(find.text("smoke"), findsOneWidget);
    /// scroll categories list
    await tester.drag(
        find.byKey(Key('categories_list')), const Offset(0.0, -300));
    await tester.pump();
    expect(find.text("gas"), findsOneWidget);
    expect(find.text("soil moisture"), findsOneWidget);
    expect(find.text("air humidity"), findsOneWidget);
    expect(find.text("Select a category"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);
    await tester.tap(find.text("soil moisture").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('editSensorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.editSensor(1, null, 'humidity', null)).called(1);
  });

}
