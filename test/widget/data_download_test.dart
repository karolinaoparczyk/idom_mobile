import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/pages/data_download/data_download.dart';
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

  /// tests if chooses data filter with sensors, without days and filling in days
  testWidgets(
      'choose data filter with sensors, without days and filling in days',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor3",
        "category": "humidity",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor4",
        "category": "smoke",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
    when(mockApi.generateFile(["1", "2"], null, 20))
        .thenAnswer((_) async => Future.value({"body": "", "statusCode": 200}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DataDownload page = DataDownload(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Uzupełnij filtry, aby wygenerować plik .csv z danymi"),
        findsOneWidget);
    expect(find.text("Czujniki"), findsOneWidget);
    expect(find.text("Kategorie"), findsOneWidget);
    expect(find.text("Liczba ostatnich dni"), findsOneWidget);
    expect(find.text("Pobierz dane"), findsOneWidget);
    expect(find.text("Generuj plik"), findsOneWidget);
    expect(find.text("Dodaj"), findsNWidgets(2));

    await tester.tap(find.byKey(Key("addSensors")));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.text("sensor2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("sensor2"), findsOneWidget);
    expect(find.text("sensor3"), findsNothing);
    expect(find.text("sensor4"), findsNothing);

    await tester.tap(find.byKey(Key("Generuj plik")));
    await tester.pump();
    expect(find.text("Pole wymagane"), findsOneWidget);
    verifyNever(await mockApi.generateFile(["1", "2"], null, null));

    Finder emailField = find.byKey(Key('lastDaysAmountButton'));
    await tester.enterText(emailField, '20');
    await tester.tap(find.byKey(Key("Generuj plik")));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(await mockApi.generateFile(["1", "2"], null, 20)).called(1);
  });

  /// tests if chooses data filter with categories
  testWidgets('choose data filter with categories',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor3",
        "category": "humidity",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor4",
        "category": "smoke",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DataDownload page = DataDownload(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Uzupełnij filtry, aby wygenerować plik .csv z danymi"),
        findsOneWidget);

    await tester.tap(find.byKey(Key("addCategories")));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("temperatura powietrza").last);
    await tester.tap(find.text("temperatura wody").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text("temperatura powietrza"), findsOneWidget);
    expect(find.text("temperatura wody"), findsOneWidget);
    expect(find.text("opady atmosferyczne"), findsNothing);
    expect(find.text("wilgotność gleby"), findsNothing);
  });

  /// tests if cannot choose categories if sensors are chosen
  testWidgets('cannot choose categories if sensors are chosen',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor3",
        "category": "humidity",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor4",
        "category": "smoke",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DataDownload page = DataDownload(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Uzupełnij filtry, aby wygenerować plik .csv z danymi"),
        findsOneWidget);

    await tester.tap(find.byKey(Key("addSensors")));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.text("sensor2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("sensor2"), findsOneWidget);
    expect(find.text("sensor3"), findsNothing);
    expect(find.text("sensor4"), findsNothing);

    await tester.tap(find.byKey(Key("addCategories")));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("temperatura powietrza"), findsNothing);
    expect(find.text("temperatura wody"), findsNothing);
    expect(find.text("opady atmosferyczne"), findsNothing);
    expect(find.text("wilgotność gleby"), findsNothing);
    expect(find.text("Usuń wybrane czujniki, aby wybrać kategorie."),
        findsOneWidget);

    await tester.tap(find.byKey(Key("deleteSensors")));
    await tester.tap(find.byKey(Key("addCategories")));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("temperatura powietrza").last);
    await tester.tap(find.text("temperatura wody").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text("Usuń wybrane czujniki, aby wybrać kategorie."),
        findsNothing);
    expect(find.text("temperatura powietrza"), findsOneWidget);
    expect(find.text("temperatura wody"), findsOneWidget);
    expect(find.text("opady atmosferyczne"), findsNothing);
    expect(find.text("wilgotność gleby"), findsNothing);
  });

  /// tests if cannot choose sensors if categories are chosen
  testWidgets('cannot choose sensors if categories are chosen',
      (WidgetTester tester) async {
    MockApi mockApi = MockApi();
    List<Map<String, dynamic>> sensors = [
      {
        "id": 1,
        "name": "sensor1",
        "category": "temperature",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor2",
        "category": "rain_sensor",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor3",
        "category": "humidity",
        "frequency": 300,
        "last_data": "27.0"
      },
      {
        "id": 2,
        "name": "sensor4",
        "category": "smoke",
        "frequency": 300,
        "last_data": "27.0"
      }
    ];
    when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
        {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
    MockSecureStorage mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.getToken())
        .thenAnswer((_) async => Future.value("token"));

    DataDownload page = DataDownload(
      storage: mockSecureStorage,
      testApi: mockApi,
    );

    await tester.pumpWidget(makePolishTestableWidget(child: page));
    await tester.pumpAndSettle();

    expect(find.text("Uzupełnij filtry, aby wygenerować plik .csv z danymi"),
        findsOneWidget);

    await tester.tap(find.byKey(Key("addCategories")));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Wybierz kategorie"), findsOneWidget);
    expect(find.text("Anuluj"), findsOneWidget);
    await tester.tap(find.text("temperatura powietrza").last);
    await tester.tap(find.text("temperatura wody").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text("temperatura powietrza"), findsOneWidget);
    expect(find.text("temperatura wody"), findsOneWidget);
    expect(find.text("opady atmosferyczne"), findsNothing);
    expect(find.text("wilgotność gleby"), findsNothing);

    await tester.tap(find.byKey(Key("addSensors")));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("sensor1"), findsNothing);
    expect(find.text("sensor2"), findsNothing);
    expect(find.text("sensor3"), findsNothing);
    expect(find.text("sensor4"), findsNothing);
    expect(find.text("Usuń wybrane kategorie, aby wybrać czujniki."),
        findsOneWidget);

    await tester.tap(find.byKey(Key("deleteCategories")));
    await tester.tap(find.byKey(Key("addSensors")));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text("sensor1").last);
    await tester.tap(find.text("sensor2").last);
    await tester.tap(find.byKey(Key('yesButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text("Usuń wybrane kategorie, aby wybrać czujniki."),
        findsNothing);
    expect(find.text("sensor1"), findsOneWidget);
    expect(find.text("sensor2"), findsOneWidget);
    expect(find.text("sensor3"), findsNothing);
    expect(find.text("sensor4"), findsNothing);
  });

  /// tests if chooses data filter with categories, english
  testWidgets('english choose data filter with categories',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        List<Map<String, dynamic>> sensors = [
          {
            "id": 1,
            "name": "sensor1",
            "category": "temperature",
            "frequency": 300,
            "last_data": "27.0"
          },
          {
            "id": 2,
            "name": "sensor2",
            "category": "rain_sensor",
            "frequency": 300,
            "last_data": "27.0"
          },
          {
            "id": 2,
            "name": "sensor3",
            "category": "humidity",
            "frequency": 300,
            "last_data": "27.0"
          },
          {
            "id": 2,
            "name": "sensor4",
            "category": "smoke",
            "frequency": 300,
            "last_data": "27.0"
          }
        ];
        when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
            {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
        MockSecureStorage mockSecureStorage = MockSecureStorage();
        when(mockSecureStorage.getToken())
            .thenAnswer((_) async => Future.value("token"));

        DataDownload page = DataDownload(
          storage: mockSecureStorage,
          testApi: mockApi,
        );

        await tester.pumpWidget(makeEnglishTestableWidget(child: page));
        await tester.pumpAndSettle();

        expect(find.text("Fill in filters to generate a .csv file with data"),
            findsOneWidget);

        await tester.tap(find.byKey(Key("addCategories")));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text("air temperature").last);
        await tester.tap(find.text("water temperature").last);
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text("air temperature"), findsOneWidget);
        expect(find.text("water temperature"), findsOneWidget);
        expect(find.text("precipitation"), findsNothing);
        expect(find.text("soil moisture"), findsNothing);
      });

  /// tests if cannot choose categories if sensors are chosen, english
  testWidgets('english cannot choose categories if sensors are chosen',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        List<Map<String, dynamic>> sensors = [
          {
            "id": 1,
            "name": "sensor1",
            "category": "temperature",
            "frequency": 300,
            "last_data": "27.0"
          },
          {
            "id": 2,
            "name": "sensor2",
            "category": "rain_sensor",
            "frequency": 300,
            "last_data": "27.0"
          },
          {
            "id": 2,
            "name": "sensor3",
            "category": "humidity",
            "frequency": 300,
            "last_data": "27.0"
          },
          {
            "id": 2,
            "name": "sensor4",
            "category": "smoke",
            "frequency": 300,
            "last_data": "27.0"
          }
        ];
        when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
            {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
        MockSecureStorage mockSecureStorage = MockSecureStorage();
        when(mockSecureStorage.getToken())
            .thenAnswer((_) async => Future.value("token"));

        DataDownload page = DataDownload(
          storage: mockSecureStorage,
          testApi: mockApi,
        );

        await tester.pumpWidget(makeEnglishTestableWidget(child: page));
        await tester.pumpAndSettle();

        expect(find.text("Fill in filters to generate a .csv file with data"),
            findsOneWidget);

        await tester.tap(find.byKey(Key("addSensors")));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text("sensor1").last);
        await tester.tap(find.text("sensor2").last);
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text("sensor1"), findsOneWidget);
        expect(find.text("sensor2"), findsOneWidget);
        expect(find.text("sensor3"), findsNothing);
        expect(find.text("sensor4"), findsNothing);

        await tester.tap(find.byKey(Key("addCategories")));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.text("air temperature"), findsNothing);
        expect(find.text("water temperature"), findsNothing);
        expect(find.text("precipitation"), findsNothing);
        expect(find.text("soil moisture"), findsNothing);
        expect(find.text("Delete selected sensors to select categories."),
            findsOneWidget);

        await tester.tap(find.byKey(Key("deleteSensors")));
        await tester.tap(find.byKey(Key("addCategories")));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.text("Choose categories"), findsOneWidget);
        expect(find.text("Cancel"), findsOneWidget);
        await tester.tap(find.text("air temperature").last);
        await tester.tap(find.text("water temperature").last);
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text("Delete selected sensors to select categories."),
            findsNothing);
        expect(find.text("air temperature"), findsOneWidget);
        expect(find.text("water temperature"), findsOneWidget);
        expect(find.text("precipitation"), findsNothing);
        expect(find.text("soil moisture"), findsNothing);
      });

  /// tests if cannot choose sensors if categories are chosen, english
  testWidgets('english cannot choose sensors if categories are chosen',
          (WidgetTester tester) async {
        MockApi mockApi = MockApi();
        List<Map<String, dynamic>> sensors = [
          {
            "id": 1,
            "name": "sensor1",
            "category": "temperature",
            "frequency": 300,
            "last_data": "27.0"
          },
          {
            "id": 2,
            "name": "sensor2",
            "category": "rain_sensor",
            "frequency": 300,
            "last_data": "27.0"
          },
          {
            "id": 2,
            "name": "sensor3",
            "category": "humidity",
            "frequency": 300,
            "last_data": "27.0"
          },
          {
            "id": 2,
            "name": "sensor4",
            "category": "smoke",
            "frequency": 300,
            "last_data": "27.0"
          }
        ];
        when(mockApi.getSensors()).thenAnswer((_) async => Future.value(
            {"bodySensors": jsonEncode(sensors), "statusCodeSensors": "200"}));
        MockSecureStorage mockSecureStorage = MockSecureStorage();
        when(mockSecureStorage.getToken())
            .thenAnswer((_) async => Future.value("token"));

        DataDownload page = DataDownload(
          storage: mockSecureStorage,
          testApi: mockApi,
        );

        await tester.pumpWidget(makeEnglishTestableWidget(child: page));
        await tester.pumpAndSettle();

        expect(find.text("Fill in filters to generate a .csv file with data"),
            findsOneWidget);

        await tester.tap(find.byKey(Key("addCategories")));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text("air temperature").last);
        await tester.tap(find.text("water temperature").last);
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text("air temperature"), findsOneWidget);
        expect(find.text("water temperature"), findsOneWidget);
        expect(find.text("precipitation"), findsNothing);
        expect(find.text("soil moisture"), findsNothing);

        await tester.tap(find.byKey(Key("addSensors")));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.text("sensor1"), findsNothing);
        expect(find.text("sensor2"), findsNothing);
        expect(find.text("sensor3"), findsNothing);
        expect(find.text("sensor4"), findsNothing);
        expect(find.text("Delete selected categories to select sensors."),
            findsOneWidget);

        await tester.tap(find.byKey(Key("deleteCategories")));
        await tester.tap(find.byKey(Key("addSensors")));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text("sensor1").last);
        await tester.tap(find.text("sensor2").last);
        await tester.tap(find.byKey(Key('yesButton')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text("Delete selected categories to select sensors."),
            findsNothing);
        expect(find.text("sensor1"), findsOneWidget);
        expect(find.text("sensor2"), findsOneWidget);
        expect(find.text("sensor3"), findsNothing);
        expect(find.text("sensor4"), findsNothing);
      });
}
