import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:idom/pages/sensors/new_sensor.dart';
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

  /// tests if does not save with empty name and category
  testWidgets(
      'name, category, frequency value and frequency units empty, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.addSensor(null, null, null)).thenAnswer((_) async =>
        Future.value({"bodySen": '"id": 3', "statusCodeSen": "201"}));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text("Pole wymagane"), findsNWidgets(4));
    verifyNever(await mockApi.addSensor(null, null, null));
  });

  /// tests if does not save with only name
  testWidgets('only name, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.addSensor('sensor', null, null)).thenAnswer((_) async =>
        Future.value({"bodySen": '"id": 3', "statusCodeSen": "201"}));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'sensor');

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Pole wymagane"), findsNWidgets(3));

    verifyNever(await mockApi.addSensor('sensor', null, null));
  });

  /// tests if does not save with only category
  testWidgets('only category, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.addSensor('', "humidity", null)).thenAnswer((_) async =>
        Future.value({"bodySen": '"id": 3', "statusCodeSen": "201"}));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
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

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Pole wymagane"), findsNWidgets(3));
    verifyNever(await mockApi.addSensor('', 'humidity', null));
  });

  /// tests if does not save with only category smoke
  testWidgets('only category smoke, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('', "smoke", null)).thenAnswer((_) async =>
        Future.value({"bodySen": '"id": 3', "statusCodeSen": "201"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.resetUserData())
        .thenAnswer((_) async => Future.value());

    NewSensor page = NewSensor(
      storage: mockSecureStorage,
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
    await tester.tap(find.text("dym").last);

    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(NewSensor), findsOneWidget);
    expect(find.text("Pole wymagane"), findsOneWidget);

    verifyNever(await mockApi.addSensor('', 'smoke', null));
  });

  /// tests if cancels category dialog
  testWidgets('cancels category dialog', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('', "smoke", null)).thenAnswer((_) async =>
        Future.value({"bodySen": '"id": 3', "statusCodeSen": "201"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.resetUserData())
        .thenAnswer((_) async => Future.value());

    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(Key('Cancel')));
    await tester.pump();
    verifyNever(await mockApi.addSensor('', 'smoke', null));
  });

  /// tests if saves with name, category, frequency value and frequency units
  testWidgets(
      'non empty name, category, frequency value and frequency units, saves',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.addSensor('sensor', 'humidity', 7200)).thenAnswer((_) async =>
        Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'sensor');

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

    verify(await mockApi.addSensor('sensor', 'humidity', 7200)).called(1);
  });

  /// tests if cancels frequency dialog
  testWidgets('cancels frequency dialog', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.addSensor('sensor', 'humidity', 7200)).thenAnswer((_) async =>
        Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'sensor');

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
    await tester.enterText(frequencyValueField, '2');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("godziny").last);
    await tester.tap(find.byKey(Key('Cancel')));
    await tester.pumpAndSettle();

    expect(find.text("godziny"), findsNothing);
  });

  /// tests if can choose rain_sensor sensor, frequency read only
  testWidgets('can add rain_sensor sensor, frequency read only',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', 'rain_sensor', 30)).thenAnswer((_) async =>
        Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
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

    verify(await mockApi.addSensor('sensor', 'rain_sensor', 30)).called(1);
  });

  /// tests if logs out when no token
  testWidgets('logs out when no token',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', 'rain_sensor', 30)).thenAnswer((_) async =>
        Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "401"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.resetUserData()).thenAnswer((_) async =>
        Future.value(null));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
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

    verify(await mockApi.addSensor('sensor', 'rain_sensor', 30)).called(1);
  });

  /// tests if can choose rain_sensor sensor, choose another category - frequency not read only
  testWidgets(
      'can add rain_sensor sensor, choose another category - frequency not read only',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', 'humidity', 7200)).thenAnswer((_) async =>
        Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
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

    /// scroll categories list
    await tester.drag(
        find.byKey(Key('categories_list')), const Offset(0.0, -300));
    await tester.pump();
    await tester.tap(find.text("wilgotność gleby").last);
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

    verify(await mockApi.addSensor('sensor', 'humidity', 7200)).called(1);
  });

  /// tests if can choose breathalyser sensor, frequency invisible
  testWidgets('can add breathalyser sensor, frequency invisible',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', 'breathalyser', 30)).thenAnswer(
        (_) async =>
            Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
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

    await tester.tap(find.text("alkomat").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("sekundy"), findsNothing);
    expect(find.text("30"), findsNothing);
    expect(find.text("sensor"), findsOneWidget);

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verify(await mockApi.addSensor('sensor', 'breathalyser', 30)).called(1);
  });

  /// tests if can choose breathalyser sensor, choose another category - frequency visible
  testWidgets(
      'can add breathalyser sensor, choose another category - frequency visible',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', 'humidity', 7200)).thenAnswer((_) async =>
        Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'sensor');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("alkomat").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("sekundy"), findsNothing);
    expect(find.text("30"), findsNothing);
    expect(find.text("sensor"), findsOneWidget);

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

    verify(await mockApi.addSensor('sensor', 'humidity', 7200)).called(1);
  });

  /// tests if can add air humidity sensor
  testWidgets('can add air humidity sensor', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', 'air_humidity', 7200)).thenAnswer(
        (_) async =>
            Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'sensor');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    /// scroll categories list
    await tester.drag(
        find.byKey(Key('categories_list')), const Offset(0.0, -300));
    await tester.pump();
    await tester.tap(find.text("wilgotność powietrza").last);
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

    verify(await mockApi.addSensor('sensor', 'air_humidity', 7200)).called(1);
  });

  /// tests if can add atmospheric pressure sensor
  testWidgets('can add atmospheric pressure sensor',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', 'atmo_pressure', 7200)).thenAnswer(
        (_) async =>
            Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'sensor');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("ciśnienie atmosferyczne").last);
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

    verify(await mockApi.addSensor('sensor', 'atmo_pressure', 7200)).called(1);
  });

  /// tests if does not save when name exists
  testWidgets('valid data, name exists, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.addSensor('sensor', "humidity", 7200))
        .thenAnswer((_) async => Future.value({
              "bodySen":
                  '{"name":["Sensor with provided name already exists"]}',
              "statusCodeSen": "400"
            }));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder usernameField = find.byKey(Key('name'));
    await tester.enterText(usernameField, 'sensor');

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
    expect(find.text("Czujnik o podanej nazwie już istnieje."), findsOneWidget);
    expect(find.byType(NewSensor), findsOneWidget);

    verify(await mockApi.addSensor('sensor', "humidity", 7200)).called(1);
  });

  /// tests if does not save when frequency value not valid
  testWidgets('frequency value not valid, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.addSensor('sensor', "humidity", 0)).thenAnswer((_) async =>
        Future.value({"bodySen": '"id": 3', "statusCodeSen": "400"}));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'sensor');

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
    expect(
        find.text(
            "Wartość częstotliwości pobierania danych musi być nieujemną liczbą całkowitą."),
        findsOneWidget);

    verifyNever(await mockApi.addSensor('sensor', "humidity", 0));
  });

  /// tests if saves with name, category smoke
  testWidgets('non empty name, category smoke, saves',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', 'smoke', 30)).thenAnswer((_) async =>
        Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.resetUserData())
        .thenAnswer((_) async => Future.value());

    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'sensor');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    /// scroll categories list
    await tester.drag(
        find.byKey(Key('categories_list')), const Offset(0.0, -300));
    await tester.pump();
    await tester.tap(find.text("dym").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("sekundy"), findsOneWidget);
    expect(find.text("30"), findsOneWidget);
    expect(find.text("sensor"), findsOneWidget);

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verify(await mockApi.addSensor('sensor', 'smoke', 30)).called(1);
  });

  /// tests if does not save with empty name and category, english
  testWidgets(
      'english name, category, frequency value and frequency units empty, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.addSensor(null, null, null)).thenAnswer((_) async =>
        Future.value({"bodySen": '"id": 3', "statusCodeSen": "201"}));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text("Required field"), findsNWidgets(4));
    verifyNever(await mockApi.addSensor(null, null, null));
  });

  /// tests if does not save with only name, english
  testWidgets('english only name, does not save', (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.addSensor('sensor', null, null)).thenAnswer((_) async =>
        Future.value({"bodySen": '"id": 3', "statusCodeSen": "201"}));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'sensor');

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Required field"), findsNWidgets(3));

    verifyNever(await mockApi.addSensor('sensor', null, null));
  });

  /// tests if does not save with only category, english
  testWidgets('english only category, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.addSensor('', "humidity", null)).thenAnswer((_) async =>
        Future.value({"bodySen": '"id": 3', "statusCodeSen": "201"}));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("breathalyser"), findsOneWidget);
    expect(find.text("atmospheric pressure"), findsOneWidget);
    expect(find.text("precipitation"), findsOneWidget);
    expect(find.text("air temperature"), findsOneWidget);
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

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Required field"), findsNWidgets(3));
    verifyNever(await mockApi.addSensor('', 'humidity', null));
  });

  /// tests if does not save with only category smoke, english
  testWidgets('english only category smoke, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('', "smoke", null)).thenAnswer((_) async =>
        Future.value({"bodySen": '"id": 3', "statusCodeSen": "201"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.resetUserData())
        .thenAnswer((_) async => Future.value());

    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    /// scroll categories list
    await tester.drag(
        find.byKey(Key('categories_list')), const Offset(0.0, -300));
    await tester.pump();
    await tester.tap(find.text("smoke").last);

    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(NewSensor), findsOneWidget);
    expect(find.text("Required field"), findsOneWidget);

    verifyNever(await mockApi.addSensor('', 'smoke', null));
  });

  /// tests if saves with name, category, frequency value and frequency units, english
  testWidgets(
      'english non empty name, category, frequency value and frequency units, saves',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.addSensor('sensor', 'humidity', 7200)).thenAnswer((_) async =>
        Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'sensor');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    /// scroll categories list
    await tester.drag(
        find.byKey(Key('categories_list')), const Offset(0.0, -300));
    await tester.pump();
    await tester.tap(find.text("soil moisture").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '2');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("hours").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verify(await mockApi.addSensor('sensor', 'humidity', 7200)).called(1);
  });

  /// tests if can choose rain_sensor sensor, frequency read only, english
  testWidgets('english can add rain_sensor sensor, frequency read only',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', 'rain_sensor', 30)).thenAnswer((_) async =>
        Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'sensor');

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '2');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("hours").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("hours"), findsNWidgets(2));
    expect(find.text("2"), findsOneWidget);
    expect(find.text("sensor"), findsOneWidget);

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("precipitation").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("seconds"), findsOneWidget);
    expect(find.text("30"), findsOneWidget);
    expect(find.text("sensor"), findsOneWidget);

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verify(await mockApi.addSensor('sensor', 'rain_sensor', 30)).called(1);
  });

  /// tests if can choose rain_sensor sensor, choose another category - frequency not read only, english
  testWidgets(
      'english can add rain_sensor sensor, choose another category - frequency not read only',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', 'humidity', 7200)).thenAnswer((_) async =>
        Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'sensor');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("precipitation").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("seconds"), findsOneWidget);
    expect(find.text("30"), findsOneWidget);
    expect(find.text("sensor"), findsOneWidget);

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    /// scroll categories list
    await tester.drag(
        find.byKey(Key('categories_list')), const Offset(0.0, -300));
    await tester.pump();
    await tester.tap(find.text("soil moisture").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '2');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("hours").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("hours"), findsNWidgets(2));
    expect(find.text("2"), findsOneWidget);
    expect(find.text("sensor"), findsOneWidget);

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verify(await mockApi.addSensor('sensor', 'humidity', 7200)).called(1);
  });

  /// tests if can choose breathalyser sensor, frequency invisible, english
  testWidgets('english can add breathalyser sensor, frequency invisible',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', 'breathalyser', 30)).thenAnswer(
        (_) async =>
            Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder emailField = find.byKey(Key('name'));
    await tester.enterText(emailField, 'sensor');

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '2');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("hours").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("hours"), findsNWidgets(2));
    expect(find.text("2"), findsOneWidget);
    expect(find.text("sensor"), findsOneWidget);

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("breathalyser").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("seconds"), findsNothing);
    expect(find.text("30"), findsNothing);
    expect(find.text("sensor"), findsOneWidget);

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verify(await mockApi.addSensor('sensor', 'breathalyser', 30)).called(1);
  });

  /// tests if can choose breathalyser sensor, choose another category - frequency visible, english
  testWidgets(
      'english can add breathalyser sensor, choose another category - frequency visible',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', 'humidity', 7200)).thenAnswer((_) async =>
        Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'sensor');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("breathalyser").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("seconds"), findsNothing);
    expect(find.text("30"), findsNothing);
    expect(find.text("sensor"), findsOneWidget);

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    /// scroll categories list
    await tester.drag(
        find.byKey(Key('categories_list')), const Offset(0.0, -300));
    await tester.pump();
    await tester.tap(find.text("soil moisture").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '2');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("hours").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("hours"), findsNWidgets(2));
    expect(find.text("2"), findsOneWidget);
    expect(find.text("sensor"), findsOneWidget);

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verify(await mockApi.addSensor('sensor', 'humidity', 7200)).called(1);
  });

  /// tests if can add air humidity sensor, english
  testWidgets('english can add air humidity sensor',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', 'air_humidity', 7200)).thenAnswer(
        (_) async =>
            Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'sensor');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    /// scroll categories list
    await tester.drag(
        find.byKey(Key('categories_list')), const Offset(0.0, -300));
    await tester.pump();
    await tester.tap(find.text("air humidity").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '2');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("hours").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("hours"), findsNWidgets(2));
    expect(find.text("2"), findsOneWidget);
    expect(find.text("sensor"), findsOneWidget);

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verify(await mockApi.addSensor('sensor', 'air_humidity', 7200)).called(1);
  });

  /// tests if can add atmospheric pressure sensor, english
  testWidgets('english can add atmospheric pressure sensor',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', 'atmo_pressure', 7200)).thenAnswer(
        (_) async =>
            Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'sensor');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("atmospheric pressure").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '2');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("hours").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    expect(find.text("hours"), findsNWidgets(2));
    expect(find.text("2"), findsOneWidget);
    expect(find.text("sensor"), findsOneWidget);

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verify(await mockApi.addSensor('sensor', 'atmo_pressure', 7200)).called(1);
  });

  /// tests if does not save when name exists, english
  testWidgets('english valid data, name exists, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.addSensor('sensor', "humidity", 7200))
        .thenAnswer((_) async => Future.value({
              "bodySen":
                  '{"name":["Sensor with provided name already exists"]}',
              "statusCodeSen": "400"
            }));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder usernameField = find.byKey(Key('name'));
    await tester.enterText(usernameField, 'sensor');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    /// scroll categories list
    await tester.drag(
        find.byKey(Key('categories_list')), const Offset(0.0, -300));
    await tester.pump();
    await tester.tap(find.text("soil moisture").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '2');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("hours").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("A sensor with the given name already exists."),
        findsOneWidget);
    expect(find.byType(NewSensor), findsOneWidget);

    verify(await mockApi.addSensor('sensor', "humidity", 7200)).called(1);
  });

  /// tests if does not save when frequency value not valid, english
  testWidgets('english frequency value not valid, does not save',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockApi.addSensor('sensor', "humidity", 0)).thenAnswer((_) async =>
        Future.value({"bodySen": '"id": 3', "statusCodeSen": "400"}));
    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'sensor');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    /// scroll categories list
    await tester.drag(
        find.byKey(Key('categories_list')), const Offset(0.0, -300));
    await tester.pump();
    await tester.tap(find.text("soil moisture").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    Finder frequencyValueField = find.byKey(Key('frequencyValue'));
    await tester.enterText(frequencyValueField, '0');

    await tester.tap(find.byKey(Key('frequencyUnitsButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("hours").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(NewSensor), findsOneWidget);
    expect(
        find.text(
            "The data gathering frequency value must be a non-negative integer."),
        findsOneWidget);

    verifyNever(await mockApi.addSensor('sensor', "humidity", 0));
  });

  /// tests if saves with name, category smoke, english
  testWidgets('english non empty name, category smoke, saves',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    when(mockApi.addSensor('sensor', 'smoke', 30)).thenAnswer((_) async =>
        Future.value({"bodySen": '{"id": 3}', "statusCodeSen": "201"}));

    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.resetUserData())
        .thenAnswer((_) async => Future.value());

    NewSensor page = NewSensor(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makeEnglishTestableWidget(child: page));

    Finder nameField = find.byKey(Key('name'));
    await tester.enterText(nameField, 'sensor');

    await tester.tap(find.byKey(Key('categoriesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    /// scroll categories list
    await tester.drag(
        find.byKey(Key('categories_list')), const Offset(0.0, -300));
    await tester.pump();
    await tester.tap(find.text("smoke").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pumpAndSettle();

    expect(find.text("seconds"), findsOneWidget);
    expect(find.text("30"), findsOneWidget);
    expect(find.text("sensor"), findsOneWidget);

    await tester.tap(find.byKey(Key('addSensorButton')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verify(await mockApi.addSensor('sensor', 'smoke', 30)).called(1);
  });
}
