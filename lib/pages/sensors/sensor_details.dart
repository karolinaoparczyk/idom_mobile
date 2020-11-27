import 'dart:convert';

import 'package:idom/enums/categories.dart';
import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/sensors/edit_sensor.dart';
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
    getSensorData().then((value) =>
        setState(() {
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
              text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...");
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
                "Błąd pobierania danych z czujnika. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych z czujnika. Adres serwera nieprawidłowy."));
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
      for (SensorData data in sensorData){
        var date = DateTime(data.deliveryTime.year, data.deliveryTime.month, data.deliveryTime.day);
        int diff = now.difference(date).inDays;
        if (diff < 14){
          _seriesData.add(data);
        }
      }

      /// last 30 days
    } else if (measurementTimeSelected[2] == true) {
      _seriesData = sensorData;
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
                                  Icon(Icons.info_outline_rounded, size: 17.5),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Text("Ogólne",
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(
                                            fontWeight: FontWeight.normal)),
                                  ),
                                ],
                              ))),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 52.5, top: 10.0, right: 30.0, bottom: 0.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Nazwa",
                                  style: TextStyle(
                                      color: IdomColors.additionalColor,
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.bold)))),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 52.5, top: 0, right: 30.0, bottom: 0.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(widget.sensor.name,
                                  style: TextStyle(fontSize: 21.0)))),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 52.5, top: 10.0, right: 30.0, bottom: 0.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Kategoria",
                                  style: TextStyle(
                                      color: IdomColors.additionalColor,
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.bold)))),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 52.5, top: 0, right: 30.0, bottom: 0.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  SensorCategories.values
                                      .where((element) =>
                                  element['value'] ==
                                      widget.sensor.category)
                                      .first['text'],
                                  style: TextStyle(fontSize: 21.0)))),
                      if (widget.sensor.category != "rain_sensor")
                        Padding(
                            padding: EdgeInsets.only(
                                left: 30.0,
                                top: 20.0,
                                right: 30.0,
                                bottom: 0.0),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time_outlined,
                                        size: 17.5),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Text("Dane z czujnika",
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(
                                              fontWeight:
                                              FontWeight.normal)),
                                    ),
                                  ],
                                ))),
                      if (widget.sensor.category != "breathalyser")
                        Padding(
                            padding: EdgeInsets.only(
                                top: 10, left: 52.5, right: 30.0, bottom: 0.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Częstotliwość pobierania danych",
                                  style: TextStyle(
                                      color: IdomColors.additionalColor,
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.bold)),
                            )),
                      if (widget.sensor.category != "breathalyser")
                        Padding(
                            padding: EdgeInsets.only(
                                left: 52.5, top: 0.0, right: 30.0, bottom: 0.0),
                            child: SizedBox(
                                child: Row(children: <Widget>[
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: <Widget>[
                                        Text(widget.sensor.frequency.toString(),
                                            style: TextStyle(fontSize: 21.0)),
                                      ]),
                                  SizedBox(width: 5.0),
                                  Column(children: <Widget>[
                                    Text(getProperUnitsName(),
                                        style: TextStyle(fontSize: 21.0)),
                                  ])
                                ]))),
                      if (widget.sensor.category != "rain_sensor" &&
                          widget.sensor.category != "smoke")
                        Padding(
                            padding: EdgeInsets.only(
                                top: 10, left: 52.5, right: 30.0, bottom: 0.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(getSensorLastDataLabel(),
                                  style: TextStyle(
                                      color: IdomColors.additionalColor,
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.bold)),
                            )),
                      if (widget.sensor.category != "rain_sensor" &&
                          widget.sensor.category != "smoke")
                        Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 52.5),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(getSensorLastData(),
                                    style: TextStyle(fontSize: 21.0)))),
                      if (widget.sensor.category != "rain_sensor" &&
                          widget.sensor.category != "smoke")
                        Padding(
                            padding: EdgeInsets.only(
                                left: 30.0,
                                top: 20.0,
                                right: 30.0,
                                bottom: 0.0),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today_outlined,
                                        size: 17.5),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Text("Okres wyświetlanych danych",
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(
                                              fontWeight:
                                              FontWeight.normal)),
                                    ),
                                  ],
                                ))),
                      if (widget.sensor.category != "rain_sensor" &&
                          widget.sensor.category != "smoke")
                        Padding(
                          padding: EdgeInsets.only(
                              left: 52.5, top: 13.5, right: 30.0, bottom: 0),
                          child: ToggleButtons(
                              borderRadius: BorderRadius.circular(30),
                              borderColor: IdomColors.additionalColor,
                              splashColor: Colors.transparent,
                              fillColor: IdomColors.lighten(
                                  IdomColors.additionalColor, 0.2),
                              selectedColor: IdomColors.textDark,
                              children: [
                                Container(
                                    child: Center(
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text("Dzisiaj")))),
                                Container(
                                    child: Center(
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child:
                                                Text("Ostatnie 2 tygodnie")))),
                                Container(
                                    child: Center(
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text("Ostatnie 30 dni")))),
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
                          widget.sensor.category != "smoke")
                        Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width - 40,
                            padding: EdgeInsets.only(
                                left: 10.0,
                                top: 20.0,
                                right: 20.0,
                                bottom: 0.0),
                            child: Center(child: chartWid)),
                      SizedBox(height: 30)
                    ]),
                  ))),
        ));
  }

  String getProperUnitsName() {
    var lastDigitFrequencyValue = widget.sensor.frequency
        .toString()
        .substring(widget.sensor.frequency
        .toString()
        .length - 1);
    var firstVersion = "sekundy";
    var secondVersion = "sekund";
    if (RegExp(r"^[0-1|5-9]").hasMatch(lastDigitFrequencyValue))
      return secondVersion;
    else if (RegExp(r"^[2-4]").hasMatch(lastDigitFrequencyValue))
      return firstVersion;
    return "";
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
        label = "Aktualna temperatura";
        break;
      case "air_humidity":
      case "humidity":
        label = "Aktualna wilgotność";
        break;
      case "atmo_pressure":
        label = "Aktualne ciśnienie";
        break;
      case "breathalyser":
        label = "Ostatni pomiar";
        break;
    }
    return label;
  }

  _navigateToEditSensor() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditSensor(
                    storage: widget.storage,
                    sensor: widget.sensor,
                    testApi: widget.testApi),
            fullscreenDialog: true));
    if (result == true) {
      final snackBar =
      new SnackBar(content: new Text("Zapisano dane czujnika."));
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
        getSensorData().then((value) =>
            setState(() {
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
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...");
        await new Future.delayed(const Duration(seconds: 3));
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        await widget.storage.resetUserData();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        final snackBar = new SnackBar(
            content: new Text("Odświeżenie danych czujnika nie powiodło się."));
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
                "Błąd pobierania danych czujnika. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych czujnika. Adres serwera nieprawidłowy."));
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
            child: Text("Brak danych z wybranego okresu.",
                style: TextStyle(fontSize: 16.5)),
          ));
    } else if (dataLoaded) {
      return SfCartesianChart(
          enableAxisAnimation: true,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(
              labelFormat: "{value} ${getFormattedSensorDataUnitsForChart()}"),
          tooltipBehavior: TooltipBehavior(
              enable: true,
              builder: (dynamic data, dynamic point, dynamic series,
                  int pointIndex, int seriesIndex) {
                return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(),
                        color: IdomColors.lighten(
                            IdomColors.additionalColor, 0.2)),
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${point.x}',
                          style: TextStyle(fontSize: 16.5),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${data
                              .data} ${getFormattedSensorDataUnitsForChart()}',
                          style: TextStyle(fontSize: 16.5),
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
                markerSettings: MarkerSettings(isVisible: true),
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
                markerSettings: MarkerSettings(isVisible: true),
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
