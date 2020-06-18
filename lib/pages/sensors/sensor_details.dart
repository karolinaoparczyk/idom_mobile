import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/utils/menu_items.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/dialog.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/widgets/text_color.dart';

import 'edit_sensor.dart';

/// displays sensor details and allows editing them
class SensorDetails extends StatefulWidget {
  SensorDetails(
      {Key key,
        @required this.currentLoggedInToken,
        @required this.currentUser,
        @required this.sensor,
        @required this.api})
      : super(key: key);
  final String currentLoggedInToken;
  final Account currentUser;
  final Api api;
  Sensor sensor;

  @override
  _SensorDetailsState createState() => new _SensorDetailsState();
}

class _SensorDetailsState extends State<SensorDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _nameController;
  TextEditingController _frequencyValueController;
  TextEditingController _categoryController;
  TextEditingController _frequencyUnitsController;
  TextEditingController _currentSensorDataController;
  bool _load;
  List<SensorData> sensorData;
  List<charts.Series<SensorData, DateTime>> _seriesData;
  DateTime _time;
  String _measure;
  String dataMeasuresTime;
  bool todayChart = true;
  bool thisMonthChart = false;
  bool allTimeChart = false;
  bool noDataForChart = false;
  bool dataLoaded = false;
  Widget chartWid = Text("");
  DateTime firstDeliveryTime;

  List<DropdownMenuItem<String>> categories;
  List<DropdownMenuItem<String>> units;
  Map<String, String> englishToPolishUnits = {
    "seconds": "sekund",
    "minutes": "minut",
    "hours": "godzin",
    "days": "dni"
  };

  Map<String, String> englishToPolishCategories = {
    "temperature": "temperatura",
    "humidity": "wilgotność",
  };

  @override
  void initState() {
    super.initState();
    _load = true;

    /// seting current sensor name
    _nameController = TextEditingController(text: widget.sensor.name);

    /// setting current sensor category
    _categoryController = TextEditingController(text: widget.sensor.category);

    /// setting current sensor units
    _frequencyUnitsController = TextEditingController(text: "seconds");

    /// setting current sensor frequency
    _frequencyValueController =
        TextEditingController(text: widget.sensor.frequency.toString());

    _currentSensorDataController =
        TextEditingController(text: widget.sensor.lastData.toString());

    _seriesData = List<charts.Series<SensorData, DateTime>>();
    dataMeasuresTime = "today";
    getSensorData().then((value) => setState(() {
      if (sensorData != null && sensorData.length > 0) {
        drawPlot();
      }
      chartWid = chartWidget();
      setState(() {
        _load = false;
      });
    }));
  }

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;

    DateTime time;
    String measure;

    if (selectedDatum.isNotEmpty) {
      time = selectedDatum.first.datum.deliveryTime;
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        measure = datumPair.datum.data;
      });
    }

    setState(() {
      _time = time;
      _measure = measure;
    });
  }

  getSensorData() async {
      var res = await widget.api
          .getSensorData(widget.currentLoggedInToken, widget.sensor.id);
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
      }
  }

  drawPlot() {
    if (_seriesData.length != 0) _seriesData.removeLast();
    var now = DateTime.now();
    var data;

    if (dataMeasuresTime == "today") {
      data = sensorData
          .where((data) =>
      data.deliveryTime.year == now.year &&
          data.deliveryTime.month == now.month &&
          data.deliveryTime.day == now.day)
          .toList();
    } else if (dataMeasuresTime == "thisMonth") {
      data = sensorData
          .where((data) =>
      data.deliveryTime.year == now.year &&
          data.deliveryTime.month == now.month)
          .toList();
    } else if (dataMeasuresTime == "allTime") {
      data = sensorData;
    }

    if (data.length > 0) {
      firstDeliveryTime = data[0].deliveryTime;
      setState(() {
        _time = data[0].deliveryTime;
        _measure = data[0].data;
      });

      noDataForChart = false;
      _seriesData.add(charts.Series(
          colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xffdaa520)),
          id: "timeChart",
          data: data,
          domainFn: (SensorData sensorData, _) => sensorData.deliveryTime,
          measureFn: (SensorData sensorData, _) =>
              double.parse(sensorData.data)));
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

  todayPlot() {
    setState(() {
      dataMeasuresTime = "today";
      todayChart = true;
      thisMonthChart = false;
      allTimeChart = false;
      _time = null;
      _measure = null;
      if (sensorData != null && sensorData.length > 0) {
        drawPlot();}
        chartWid = chartWidget();

    });
  }

  thisMonthPlot() {
    setState(() {
      dataMeasuresTime = "thisMonth";
      todayChart = false;
      thisMonthChart = true;
      allTimeChart = false;
      _time = null;
      _measure = null;
      if (sensorData != null && sensorData.length > 0) {
        drawPlot();}
        chartWid = chartWidget();

    });
  }

  allTimePlot() {
    setState(() {
      dataMeasuresTime = "allTime";
      todayChart = false;
      thisMonthChart = false;
      allTimeChart = true;
      _time = null;
      _measure = null;
      if (sensorData != null && sensorData.length > 0) {
        drawPlot();}
        chartWid = chartWidget();

    });
  }

  /// logs the user out of the app
  _logOut() async {
    try {
      var statusCode;
      if (widget.api != null)
        statusCode = await widget.api.logOut(widget.currentLoggedInToken);
      else {
        Api api = Api();
        statusCode = await api.logOut(widget.currentLoggedInToken);
      }
      if (statusCode == 200) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Front(), fullscreenDialog: true));
      } else {
        displayDialog(
            context, "Błąd", "Wylogowanie nie powiodło się. Spróbuj ponownie.");
      }
    } catch (e) {
      print(e);
    }
  }

  /// navigates according to menu choice
  void _choiceAction(String choice) {
    if (choice == "Moje konto") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AccountDetail(
                  currentLoggedInToken: widget.currentLoggedInToken,
                  account: widget.currentUser,
                  currentUser: widget.currentUser,
                  api: widget.api),
              fullscreenDialog: true));
    } else if (choice == "Konta") {
      Api api = Api();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Accounts(
                  currentLoggedInToken: widget.currentLoggedInToken,
                  currentUser: widget.currentUser,
                  api: api),
              fullscreenDialog: true));
    } else if (choice == "Wyloguj") {
      _logOut();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.sensor.name),
          actions: <Widget>[
            /// menu dropdown button
            PopupMenuButton(
                key: Key("menuButton"),
                offset: Offset(0, 100),
                onSelected: _choiceAction,
                itemBuilder: (BuildContext context) {
                  /// menu choices from utils/menu_items.dart
                  return widget.currentUser.isStaff
                      ? menuChoicesSuperUser.map((String choice) {
                    return PopupMenuItem(
                        key: Key(choice),
                        value: choice,
                        child: Text(choice));
                  }).toList()
                      : menuChoicesNormalUser.map((String choice) {
                    return PopupMenuItem(
                        key: Key(choice),
                        value: choice,
                        child: Text(choice));
                  }).toList();
                })
          ],
        ),

        /// builds form with editable and non-editable sensor properties
        body: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  Align(
                    child: loadingIndicator(_load),
                    alignment: FractionalOffset.center,
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 13.5, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Nazwa",
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 13.5, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_nameController.text,
                              style: TextStyle(fontSize: 17.0)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 14, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Kategoria",
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 14, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              englishToPolishCategories[
                              _categoryController.text],
                              style: TextStyle(fontSize: 17.0)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 13.5, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Częstotliwość pobierania danych",
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 13.5, right: 30.0, bottom: 0.0),
                      child: SizedBox(
                          child: Row(children: <Widget>[
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(_frequencyValueController.text,
                                      style: TextStyle(fontSize: 17.0)),
                                ]),
                            SizedBox(width: 5.0),
                            Column(children: <Widget>[
                              Text(
                                  englishToPolishUnits[
                                  _frequencyUnitsController.text],
                                  style: TextStyle(fontSize: 17.0)),
                            ])
                          ]))),
                  Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 13.5, horizontal: 30.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(getSensorLastDataLabel(),
                            style: TextStyle(
                                color: textColor,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold)),
                      )),
                  Padding(
                      padding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(getSensorLastData(), style: TextStyle(fontSize: 17.0)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 13.5, right: 30.0, bottom: 0.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Okres wyświetlanych danych:",
                            style: TextStyle(
                                color: textColor,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold)),
                      )),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 5.0, right: 30.0, bottom: 0.0),
                      child: SizedBox(
                          child: Row(children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: Container(
                                    margin: EdgeInsets.only(
                                        left: 10.0, top: 5.0, right: 10.0, bottom: 0.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: !todayChart
                                                ? textColor
                                                : Colors.black),
                                        borderRadius: BorderRadius.circular(30.0)),
                                    child: FlatButton(
                                      key: Key("today"),
                                      child: Text('Dzisiaj',
                                          textAlign: TextAlign.center),
                                      onPressed: !todayChart ? todayPlot : null,
                                    ))),
                            Expanded(
                                flex: 1,
                                child: Container(
                                    margin: EdgeInsets.only(
                                        left: 10.0, top: 5.0, right: 10.0, bottom: 0.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: !thisMonthChart
                                                ? textColor
                                                : Colors.black),
                                        borderRadius: BorderRadius.circular(30.0)),
                                    child: FlatButton(
                                      key: Key("thisMonth"),
                                      child: Text('Ten miesiąc',
                                          textAlign: TextAlign.center),
                                      onPressed:
                                      !thisMonthChart ? thisMonthPlot : null,
                                    ))),
                            Expanded(
                                flex: 1,
                                child: Container(
                                    margin: EdgeInsets.only(
                                        left: 10.0, top: 5.0, right: 10.0, bottom: 0.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: !allTimeChart
                                                ? textColor
                                                : Colors.black),
                                        borderRadius: BorderRadius.circular(30.0)),
                                    child: FlatButton(
                                      key: Key("allTime"),
                                      child: Text('Ostatnie \n30 dni',
                                          textAlign: TextAlign.center),
                                      onPressed: !allTimeChart ? allTimePlot : null,
                                    ))),
                          ]))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 5.0, right: 17.0, bottom: 0.0),
                      child: Container(
                          child: Center(
                              child: Column(children: <Widget>[
                                SizedBox(width: 355, height: 200, child: chartWid)
                              ])))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 5.0, right: 30.0, bottom: 10.0),
                      child: _time != null
                          ? Align(
                        alignment: Alignment.center,
                        child: Text(
                            "${_time.toString().substring(0, 19)}    ${_measure.toString()} °C",
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold)),
                      )
                          : SizedBox()),
                  buttonWidget(
                      context, "Edytuj czujnik", _navigateToEditSensor),
                  SizedBox(height: 50)
                ]))));
  }

  String getSensorLastData() {
    if (_currentSensorDataController.text == "null")
      return "Brak danych";
    return widget.sensor.category == "temperature"
        ? "${_currentSensorDataController.text} °C"
        : "${_currentSensorDataController.text} %";
  }

  String getSensorLastDataLabel() {
    return widget.sensor.category == "temperature"
        ? "Aktualna temperatura"
        : "Aktualna wilgotność";
  }

  _navigateToEditSensor() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditSensor(
                currentLoggedInToken: widget.currentLoggedInToken,
                currentUser: widget.currentUser,
                sensor: widget.sensor,
                api: widget.api),
            fullscreenDialog: true));

    if (result != null && result == true) {
      var snackBar = SnackBar(content: Text("Zapisano dane czujnika."));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
      setState(() {
        _load = true;
      });

      await _refreshSensorDetails();
  }

  _refreshSensorDetails() async {
    var res = await widget.api
        .getSensorDetails(widget.sensor.id, widget.currentLoggedInToken);
    if (res['statusCode'] == "200") {
      dynamic body = jsonDecode(res['body']);
      Sensor refreshedSensor = Sensor.fromJson(body);
      getSensorData().then((value) => setState(() {
        _nameController = TextEditingController(text: refreshedSensor.name);
        _categoryController =
            TextEditingController(text: refreshedSensor.category);
        _frequencyValueController = TextEditingController(
            text: refreshedSensor.frequency.toString());
        _currentSensorDataController = TextEditingController(
            text: refreshedSensor.lastData.toString());
        widget.sensor = refreshedSensor;
        if (sensorData.length > 0) {
          drawPlot();
        }
        chartWid = chartWidget();
      }));
    } else {
      displayDialog(
          context, "Błąd", "Odświeżenie danych czujnika nie powiodło się.");
    }
  }

  Widget chartWidget() {
    if (noDataForChart) {
      return Container(
          child: Text("Brak danych z wybranego okresu.",
              style: TextStyle(fontSize: 17.0)));
    } else if (dataLoaded) {
      return charts.TimeSeriesChart(
        _seriesData,
        defaultRenderer:
        charts.LineRendererConfig(includeArea: true, stacked: true),
        animate: true,
        behaviors: [
          charts.InitialSelection(selectedDataConfig: [
            new charts.SeriesDatumConfig<DateTime>('timeChart', firstDeliveryTime)
          ])
        ],
        primaryMeasureAxis: new charts.NumericAxisSpec(
            tickProviderSpec:
            new charts.BasicNumericTickProviderSpec(zeroBound: false),
        tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
                (num value) => getFormattedSensorDataForChart(value))),
        selectionModels: [
          new charts.SelectionModelConfig(
            type: charts.SelectionModelType.info,
            changedListener: _onSelectionChanged,
          )
        ],
          domainAxis: new charts.DateTimeAxisSpec(
              tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
                  day: new charts.TimeFormatterSpec(
                      format: 'dd.MM', transitionFormat: 'dd.MM'),
                  minute: new charts.TimeFormatterSpec(
                      format: 'HH:mm', transitionFormat: 'HH:mm'),
                  hour: new charts.TimeFormatterSpec(
                      format: 'HH:mm', transitionFormat: 'HH:mm'))),
      );
    }
    return null;
  }

  String getFormattedSensorDataForChart(num value) {
    return widget.sensor.category == "temperature"
        ? "$value °C"
        : "$value %";
  }
}
