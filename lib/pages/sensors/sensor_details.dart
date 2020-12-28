import 'dart:convert';

import 'package:idom/enums/categories.dart';
import 'package:flutter/material.dart';

import 'package:idom/localization/sensors/sensor_details.i18n.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/sensors/edit_sensor.dart';
import 'package:idom/utils/frequency_calculations.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

/// displays sensor details and allows editing them
class SensorDetails extends StatefulWidget {
  SensorDetails({@required this.storage, @required this.sensor, this.testApi});

  final SecureStorage storage;
  Sensor sensor;
  final Api testApi;

  @override
  _SensorDetailsState createState() => new _SensorDetailsState();
}

class _SensorDetailsState extends State<SensorDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  Api api = Api();
  bool _load;
  List<SensorData> sensorData;
  List<SensorData> _seriesData;
  List<bool> measurementTimeSelected;
  bool noDataForChart;
  bool dataLoaded;
  Widget chartWid = Text("");

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }

    _load = true;
    noDataForChart = false;
    dataLoaded = false;
    _seriesData = List<SensorData>();
    measurementTimeSelected = [true, false, false];
    getSensorData().then((value) => setState(() {
          if (sensorData != null && sensorData.length > 0) {
            getDataForChart();
          }
          chartWid = buildChartWidget();
          _load = false;
        }));
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  getSensorData() async {
    if (widget.sensor.category == "smoke" ||
        widget.sensor.category == "rain_sensor") {
      return;
    }
    try {
      if (widget.sensor != null) {
        var res = await api.getSensorData(widget.sensor.id);
        if (res == null) {
          noDataForChart = true;
          dataLoaded = false;
        }
        if (res['statusSensorData'] == "200") {
          if (res['bodySensorData'] != "[]") {
            List<dynamic> bodySensorData = jsonDecode(res['bodySensorData']);
            sensorData = List<SensorData>();
            for (var i = 0; i < bodySensorData.length; i++) {
              sensorData.add(SensorData.fromJson(bodySensorData[i], i + 1));
            }
            noDataForChart = false;
            dataLoaded = true;
            return sensorData;
          } else {
            noDataForChart = true;
            dataLoaded = false;
          }
        } else if (res != null && res['statusSensorData'] == "401") {
          displayProgressDialog(
              context: _scaffoldKey.currentContext,
              key: _keyLoader,
              text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
          await new Future.delayed(const Duration(seconds: 3));
          Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
          await widget.storage.resetUserData();
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      print(e.toString());
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych z czujnika. Sprawdź połączenie z serwerem i spróbuj ponownie."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych z czujnika. Adres serwera nieprawidłowy."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }

  getDataForChart() {
    var now = DateTime.now();

    /// today
    if (measurementTimeSelected[0] == true) {
      _seriesData = sensorData
          .where((data) =>
              data.deliveryTime.year == now.year &&
              data.deliveryTime.month == now.month &&
              data.deliveryTime.day == now.day)
          .toList();

      /// last 2 weeks
    } else if (measurementTimeSelected[1] == true) {
      _seriesData.clear();
      for (SensorData data in sensorData) {
        var date = DateTime(data.deliveryTime.year, data.deliveryTime.month,
            data.deliveryTime.day);
        int diff = now.difference(date).inDays;
        if (diff < 14) {
          _seriesData.add(data);
        }
      }

      /// last 30 days
    } else if (measurementTimeSelected[2] == true) {
      _seriesData.clear();
      for (SensorData data in sensorData) {
        var date = DateTime(data.deliveryTime.year, data.deliveryTime.month,
            data.deliveryTime.day);
        int diff = now.difference(date).inDays;
        if (diff < 30) {
          _seriesData.add(data);
        }
      }
    }

    if (_seriesData.length > 0) {
      noDataForChart = false;
      setState(() {
        dataLoaded = true;
      });
    } else {
      noDataForChart = true;
    }
    setState(() {
      _load = false;
    });
  }

  @override
  void dispose() {
    chartWid = null;
    super.dispose();
  }

  onLogOutFailure(String text) {
    final snackBar = new SnackBar(content: new Text(text));
    _scaffoldKey.currentState.showSnackBar((snackBar));
  }

  Future<bool> _onBackButton() async {
    Navigator.pop(context);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackButton,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: Text(widget.sensor.name), actions: [
            IconButton(
                key: Key("editSensor"),
                icon: Icon(Icons.edit),
                onPressed: _navigateToEditSensor)
          ]),
          drawer: IdomDrawer(
              storage: widget.storage,
              parentWidgetType: "SensorDetails",
              onLogOutFailure: onLogOutFailure),

          /// builds form with editable and non-editable sensor properties
          body: SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: AnimatedContainer(
                    curve: Curves.easeInToLinear,
                    duration: Duration(
                      milliseconds: 10,
                    ),
                    alignment: Alignment.topCenter,
                    child: Column(children: [
                      Align(
                        child: loadingIndicator(_load),
                        alignment: FractionalOffset.center,
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 30.0, top: 20.0, right: 30.0, bottom: 0.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 21),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Text("Ogólne".i18n,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1),
                                  ),
                                ],
                              ))),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 62, top: 10.0, right: 30.0, bottom: 0.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Nazwa".i18n,
                                  style:
                                      Theme.of(context).textTheme.headline5))),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 62, top: 0, right: 30.0, bottom: 0.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.sensor.name,
                                style: Theme.of(context).textTheme.bodyText2,
                              ))),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 62, top: 10.0, right: 30.0, bottom: 0.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Kategoria".i18n,
                                  style:
                                      Theme.of(context).textTheme.headline5))),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 62, top: 0, right: 30.0, bottom: 0.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  SensorCategories.values
                                      .where((element) =>
                                          element['value'] ==
                                          widget.sensor.category)
                                      .first['text']
                                      .i18n,
                                  style:
                                      Theme.of(context).textTheme.bodyText2))),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 62, top: 10.0, right: 30.0, bottom: 0.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Poziom baterii".i18n,
                                  style:
                                      Theme.of(context).textTheme.headline5))),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 62, top: 0, right: 30.0, bottom: 10.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  "${widget.sensor.batteryLevel != null ? widget.sensor.batteryLevel : "-"} %",
                                  style:
                                      Theme.of(context).textTheme.bodyText2))),
                      Divider(),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 30.0, top: 10.0, right: 30.0, bottom: 10.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_outlined, size: 21),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Text("Dane z czujnika".i18n,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1),
                                  ),
                                ],
                              ))),
                      if (widget.sensor.category != "breathalyser")
                        Padding(
                            padding: EdgeInsets.only(
                                top: 0, left: 62, right: 30.0, bottom: 0.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  "Częstotliwość pobierania danych".i18n,
                                  style: Theme.of(context).textTheme.headline5),
                            )),
                      if (widget.sensor.category != "breathalyser")
                        Padding(
                            padding: EdgeInsets.only(
                                left: 62, top: 0.0, right: 30.0, bottom: 10.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                FrequencyCalculation.calculateFrequencyValue(
                                    widget.sensor.frequency),
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                            )),
                      if (widget.sensor.category != "rain_sensor" &&
                          widget.sensor.category != "smoke" &&
                          widget.sensor.category != "gas")
                        Padding(
                            padding: EdgeInsets.only(
                                top: 0, left: 62, right: 30.0, bottom: 0.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(getSensorLastDataLabel(),
                                  style: Theme.of(context).textTheme.headline5),
                            )),
                      if (widget.sensor.category != "rain_sensor" &&
                          widget.sensor.category != "smoke" &&
                          widget.sensor.category != "gas")
                        Padding(
                            padding: EdgeInsets.only(
                                left: 62, top: 0.0, right: 30, bottom: 10.0),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  getSensorLastData(),
                                  style: Theme.of(context).textTheme.bodyText2,
                                ))),
                      Divider(),
                      if (widget.sensor.category != "rain_sensor" &&
                          widget.sensor.category != "smoke" &&
                          widget.sensor.category != "gas")
                        Padding(
                            padding: EdgeInsets.only(
                                left: 30.0,
                                top: 10.0,
                                right: 30.0,
                                bottom: 0.0),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today_outlined,
                                        size: 21),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Text(
                                          "Okres wyświetlanych danych".i18n,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1),
                                    ),
                                  ],
                                ))),
                      if (widget.sensor.category != "rain_sensor" &&
                          widget.sensor.category != "smoke" &&
                          widget.sensor.category != "gas")
                        Padding(
                          padding: EdgeInsets.only(
                              left: 30, top: 13.5, right: 30.0, bottom: 0),
                          child: ToggleButtons(
                              borderRadius: BorderRadius.circular(30),
                              borderColor: IdomColors.additionalColor,
                              splashColor: Colors.transparent,
                              fillColor: IdomColors.lighten(
                                  IdomColors.additionalColor, 0.2),
                              selectedColor: IdomColors.blackTextLight,
                              children: [
                                Container(
                                    child: Center(
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              "Dzisiaj".i18n,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(
                                                      color:
                                                          measurementTimeSelected[
                                                                  0]
                                                              ? IdomColors
                                                                  .whiteTextDark
                                                              : Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyText1
                                                                  .color),
                                            )))),
                                Container(
                                    child: Center(
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              "Ostatnie 2 tygodnie".i18n,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(
                                                      color:
                                                          measurementTimeSelected[
                                                                  1]
                                                              ? IdomColors
                                                                  .whiteTextDark
                                                              : Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyText1
                                                                  .color),
                                            )))),
                                Container(
                                    child: Center(
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              "Ostatnie 30 dni".i18n,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(
                                                      color:
                                                          measurementTimeSelected[
                                                                  2]
                                                              ? IdomColors
                                                                  .whiteTextDark
                                                              : Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyText1
                                                                  .color),
                                            )))),
                              ],
                              isSelected: measurementTimeSelected,
                              onPressed: (int index) {
                                setState(() {
                                  if (measurementTimeSelected[index] == false) {
                                    for (int i = 0;
                                        i < measurementTimeSelected.length;
                                        i++) {
                                      if (i == index) {
                                        measurementTimeSelected[i] = true;
                                      } else {
                                        measurementTimeSelected[i] = false;
                                      }
                                    }
                                    if (sensorData != null &&
                                        sensorData.length > 0) {
                                      getDataForChart();
                                    }
                                    chartWid = buildChartWidget();
                                  }
                                });
                              }),
                        ),
                      if (widget.sensor.category != "rain_sensor" &&
                          widget.sensor.category != "smoke" &&
                          widget.sensor.category != "gas")
                        Container(
                            width: MediaQuery.of(context).size.width - 40,
                            padding: EdgeInsets.only(
                                left: 0.0, top: 13.5, right: 5.0, bottom: 0.0),
                            child: Center(child: chartWid)),
                      SizedBox(height: 30)
                    ]),
                  ))),
        ));
  }

  String getSensorLastData() {
    if (widget.sensor.lastData == null) return "-";
    var data;
    switch (widget.sensor.category) {
      case "temperature":
      case "water_temp":
        data = "${widget.sensor.lastData} °C";
        break;
      case "air_humidity":
      case "humidity":
        data = "${widget.sensor.lastData} %";
        break;
      case "breathalyser":
        data = "${widget.sensor.lastData} ‰";
        break;
      case "atmo_pressure":
        data = "${widget.sensor.lastData} hPa";
        break;
    }
    return data;
  }

  String getSensorLastDataLabel() {
    var label;
    switch (widget.sensor.category) {
      case "temperature":
      case "water_temp":
        label = "Aktualna temperatura".i18n;
        break;
      case "air_humidity":
      case "humidity":
        label = "Aktualna wilgotność".i18n;
        break;
      case "atmo_pressure":
        label = "Aktualne ciśnienie".i18n;
        break;
      case "breathalyser":
        label = "Ostatni pomiar".i18n;
        break;
    }
    return label;
  }

  _navigateToEditSensor() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditSensor(
                storage: widget.storage,
                sensor: widget.sensor,
                testApi: widget.testApi),
            fullscreenDialog: true));
    if (result == true) {
      final snackBar =
          new SnackBar(content: new Text("Zapisano czujnik.".i18n));
      _scaffoldKey.currentState.showSnackBar((snackBar));
      await _refreshSensorDetails();
    }
  }

  _refreshSensorDetails() async {
    try {
      setState(() {
        _load = true;
      });
      var res = await api.getSensorDetails(widget.sensor.id);
      if (res['statusCode'] == "200") {
        dynamic body = jsonDecode(res['body']);
        Sensor refreshedSensor = Sensor.fromJson(body);
        getSensorData().then((value) => setState(() {
              widget.sensor = refreshedSensor;
              if (sensorData != null && sensorData.length > 0) {
                getDataForChart();
              }
              chartWid = buildChartWidget();
            }));
      } else if (res['statusCode'] == "401") {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoader,
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
        await new Future.delayed(const Duration(seconds: 3));
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        await widget.storage.resetUserData();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        final snackBar = new SnackBar(
            content:
                new Text("Odświeżenie danych czujnika nie powiodło się.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _load = false;
      });
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych czujnika. Sprawdź połączenie z serwerem i spróbuj ponownie."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych czujnika. Adres serwera nieprawidłowy."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
    setState(() {
      _load = false;
    });
  }

  Widget buildChartWidget() {
    if (noDataForChart) {
      return Container(
          child: Padding(
        padding: const EdgeInsets.only(left: 22.5),
        child: Text(
          "Brak danych z wybranego okresu.".i18n,
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ));
    } else if (dataLoaded) {
      return SfCartesianChart(
          zoomPanBehavior: ZoomPanBehavior(enablePinching: true),
          enableAxisAnimation: true,
          primaryXAxis: CategoryAxis(
              plotOffset: 32,
              labelStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyText2.color)),
          primaryYAxis: NumericAxis(
              labelFormat: "{value} ${getFormattedSensorDataUnitsForChart()}",
              labelStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyText2.color)),
          tooltipBehavior: TooltipBehavior(
              enable: true,
              canShowMarker: false,
              builder: (dynamic data, dynamic point, dynamic series,
                  int pointIndex, int seriesIndex) {
                return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(color: IdomColors.additionalColor),
                        color: IdomColors.lighten(
                            IdomColors.additionalColor, 0.2)),
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${point.x}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .copyWith(color: IdomColors.whiteTextDark),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${data.data} ${getFormattedSensorDataUnitsForChart()}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .copyWith(color: IdomColors.whiteTextDark),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ));
              }),
          series: widget.sensor.category == "breathalyser"
              ? [
                  ScatterSeries<SensorData, String>(
                      sortingOrder: SortingOrder.ascending,
                      sortFieldValueMapper: (SensorData sensorData, _) =>
                          sensorData.deliveryTime,
                      color: IdomColors.additionalColor,
                      dataSource: _seriesData,
                      xValueMapper: (SensorData sensorData, _) {
                        return DateFormat("yyy-MM-dd\nhh:mm:ss")
                            .format(sensorData.deliveryTime);
                      },
                      yValueMapper: (SensorData sensorData, _) =>
                          double.parse(sensorData.data),
                      markerSettings: MarkerSettings(
                          isVisible: true,
                          color: Theme.of(context).backgroundColor),
                      dataLabelSettings: DataLabelSettings(isVisible: false))
                ]
              : [
                  SplineSeries<SensorData, String>(
                      sortingOrder: SortingOrder.ascending,
                      sortFieldValueMapper: (SensorData sensorData, _) =>
                          sensorData.deliveryTime,
                      color: IdomColors.additionalColor,
                      dataSource: _seriesData,
                      xValueMapper: (SensorData sensorData, _) {
                        return DateFormat("yyy-MM-dd\nhh:mm:ss")
                            .format(sensorData.deliveryTime);
                      },
                      yValueMapper: (SensorData sensorData, _) =>
                          double.parse(sensorData.data),
                      markerSettings: MarkerSettings(
                          isVisible: true,
                          color: Theme.of(context).backgroundColor),
                      dataLabelSettings: DataLabelSettings(isVisible: false))
                ]);
    }
    return null;
  }

  String getFormattedSensorDataUnitsForChart() {
    var data;
    switch (widget.sensor.category) {
      case "temperature":
      case "water_temp":
        data = "°C";
        break;
      case "air_humidity":
      case "humidity":
        data = "%";
        break;
      case "breathalyser":
        data = "‰";
        break;
      case "atmo_pressure":
        data = "hPa";
        break;
    }
    return data;
  }
}
