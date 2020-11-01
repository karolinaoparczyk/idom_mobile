import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';

import 'edit_sensor.dart';

/// displays sensor details and allows editing them
class SensorDetails extends StatefulWidget {
  SensorDetails({@required this.storage, @required this.sensor});

  final SecureStorage storage;
  Sensor sensor;

  @override
  _SensorDetailsState createState() => new _SensorDetailsState();
}

class _SensorDetailsState extends State<SensorDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final Api api = Api();
  TextEditingController _nameController;
  TextEditingController _frequencyValueController;
  TextEditingController _categoryController;
  TextEditingController _currentSensorDataController;
  bool _load;
  List<SensorData> sensorData;
  List<charts.Series<SensorData, DateTime>> _seriesData;
  DateTime _time;
  String _measure;
  List<bool> measurementTimeSelected;
  bool noDataForChart;
  bool dataLoaded;
  Widget chartWid = Text("");
  DateTime firstDeliveryTime;
  String _token;

  List<DropdownMenuItem<String>> categories;
  List<DropdownMenuItem<String>> units;
  Map<String, String> englishToPolishCategories = {
    "temperature": "temperatura",
    "humidity": "wilgotność",
  };

  @override
  void initState() {
    super.initState();
    _load = true;
    noDataForChart = false;
    dataLoaded = false;
    /// seting current sensor name
    _nameController = TextEditingController(text: widget.sensor.name);

    /// setting current sensor category
    _categoryController = TextEditingController(text: widget.sensor.category);

    /// setting current sensor frequency
    _frequencyValueController =
        TextEditingController(text: widget.sensor.frequency.toString());

    _currentSensorDataController =
        TextEditingController(text: widget.sensor.lastData.toString());

    _seriesData = List<charts.Series<SensorData, DateTime>>();
    measurementTimeSelected = [true, false, false];
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

  Future<void> getToken() async {
    _token = await widget.storage.getToken();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
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
    await getToken();
    try {
      if (widget.sensor != null) {
        var res = await api.getSensorData(_token, widget.sensor.id);
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
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych z czujnika. Adres serwera nieprawidłowy."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    }
  }

  drawPlot() {
    if (_seriesData.length != 0) _seriesData.removeLast();
    var now = DateTime.now();
    var data;

    /// today
    if (measurementTimeSelected[0] == true) {
      data = sensorData
          .where((data) =>
              data.deliveryTime.year == now.year &&
              data.deliveryTime.month == now.month &&
              data.deliveryTime.day == now.day)
          .toList();
      /// this month
    } else if (measurementTimeSelected[1] == true) {
      data = sensorData
          .where((data) =>
              data.deliveryTime.year == now.year &&
              data.deliveryTime.month == now.month)
          .toList();
      /// last 30 days
    } else if (measurementTimeSelected[2] == true) {
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

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _frequencyValueController.dispose();
    _currentSensorDataController.dispose();
    chartWid = null;
    super.dispose();
  }

  onLogOutFailure(String text) {
    final snackBar =
    new SnackBar(content: new Text(text));
    ScaffoldMessenger.of(context).showSnackBar((snackBar));
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
                  icon: Icon(Icons.edit), onPressed: _navigateToEditSensor)
            ]),
            drawer: IdomDrawer(
                storage: widget.storage, parentWidgetType: "SensorDetails", onLogOutFailure: onLogOutFailure),

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
                              left: 30.0, top: 20.0, right: 30.0, bottom: 0.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 17.5),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Text("Ogólne",
                                        style: Theme.of(context)
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
                                  englishToPolishCategories[
                                      _categoryController.text],
                                  style: TextStyle(fontSize: 21.0)))),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 30.0, top: 20.0, right: 30.0, bottom: 0.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_outlined, size: 17.5),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Text(
                                        "Dane z czujnika",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(
                                                fontWeight: FontWeight.normal)),
                                  ),
                                ],
                              ))),
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
                      Padding(
                          padding: EdgeInsets.only(
                              left: 52.5, top: 0.0, right: 30.0, bottom: 0.0),
                          child: SizedBox(
                              child: Row(children: <Widget>[
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(_frequencyValueController.text,
                                      style: TextStyle(fontSize: 21.0)),
                                ]),
                            SizedBox(width: 5.0),
                            Column(children: <Widget>[
                              Text(getProperUnitsName(),
                                  style: TextStyle(fontSize: 21.0)),
                            ])
                          ]))),
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
                      Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 52.5),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(getSensorLastData(),
                                  style: TextStyle(fontSize: 21.0)))),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 30.0, top: 20.0, right: 30.0, bottom: 0.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, size: 17.5),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Text(
                                        "Okres wyświetlanych danych",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(
                                            fontWeight: FontWeight.normal)),
                                  ),
                                ],
                              ))),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 52.5, top: 13.5, right: 30.0, bottom: 13.5),
                        child: ToggleButtons(
                            borderRadius: BorderRadius.circular(30),
                            borderColor: IdomColors.additionalColor,
                            splashColor:Colors.transparent,
                            fillColor: IdomColors.lighten(IdomColors.additionalColor, 0.2),
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
                                          child: Text("Ten miesiąc")))),
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
                                  _time = null;
                                  _measure = null;
                                  if (sensorData != null && sensorData.length > 0) {
                                    drawPlot();
                                  }
                                  chartWid = chartWidget();
                                }

                              });
                            }),
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 30.0, top: 0.0, right: 17.0, bottom: 0.0),
                          child: Container(
                              child: Center(
                                  child: Column(children: <Widget>[
                            SizedBox(width: 355, height: 200, child: chartWid)
                          ])))),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 52.5, top: 20.0, right: 30.0, bottom: 0.0),
                          child: _time != null
                              ? Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Wybrany pomiar z wykresu",
                                style: TextStyle(
                                    color: IdomColors.additionalColor,
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold)),
                          )
                              : SizedBox()),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 52.5, top: 0.0, right: 30.0, bottom: 0.0),
                          child: _time != null
                              ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(getSelectedMeasure(),
                                      style: TextStyle(fontSize: 21.0)),
                                )
                              : SizedBox()),
                    ])))));
  }

  String getProperUnitsName() {
    var lastDigitFrequencyValue = _frequencyValueController.text
        .toString()
        .substring(_frequencyValueController.text.toString().length - 1);
    var firstVersion = "sekundy";
    var secondVersion = "sekund";
    if (RegExp(r"^[0-1|5-9]").hasMatch(lastDigitFrequencyValue))
      return secondVersion;
    else if (RegExp(r"^[2-4]").hasMatch(lastDigitFrequencyValue))
      return firstVersion;
    return "";
  }

  String getSelectedMeasure() {
    var units = widget.sensor.category == "temperature" ? "°C" : "%";
    var date = _time.toString().substring(0, 19);
    var year = date.substring(0, 4);
    var month = date.substring(5, 7);
    var day = date.substring(8, 10);
    var time = date.substring(11, 19);
    return "$day.$month.$year $time  -  ${_measure.toString()} $units";
  }

  String getSensorLastData() {
    if (_currentSensorDataController.text == "null") return "-";
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
            builder: (context) =>
                EditSensor(storage: widget.storage, sensor: widget.sensor),
            fullscreenDialog: true));

    if (result == true) {
      final snackBar =
          new SnackBar(content: new Text("Zapisano dane czujnika."));
      ScaffoldMessenger.of(context).showSnackBar((snackBar));
      await _refreshSensorDetails();
    }
  }

  _refreshSensorDetails() async {
    try {
      setState(() {
        _load = true;
      });
      var res = await api.getSensorDetails(widget.sensor.id, _token);
      if (res['statusCode'] == "200") {
        dynamic body = jsonDecode(res['body']);
        Sensor refreshedSensor = Sensor.fromJson(body);
        getSensorData().then((value) => setState(() {
              _nameController =
                  TextEditingController(text: refreshedSensor.name);
              _categoryController =
                  TextEditingController(text: refreshedSensor.category);
              _frequencyValueController = TextEditingController(
                  text: refreshedSensor.frequency.toString());
              _currentSensorDataController = TextEditingController(
                  text: refreshedSensor.lastData.toString());
              widget.sensor = refreshedSensor;
              if (sensorData != null && sensorData.length > 0) {
                drawPlot();
              }
              chartWid = chartWidget();
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
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
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
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych czujnika. Adres serwera nieprawidłowy."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    }
    setState(() {
      _load = false;
    });
  }

  Widget chartWidget() {
    if (noDataForChart) {
      return Container(
          child: Padding(
        padding: const EdgeInsets.only(left: 22.5),
        child: Text("Brak danych z wybranego okresu.",
            style: TextStyle(fontSize: 16.5)),
      ));
    } else if (dataLoaded) {
      return charts.TimeSeriesChart(
        _seriesData,
        defaultRenderer:
            charts.LineRendererConfig(includeArea: true, stacked: true),
        animate: true,
        behaviors: [
          charts.InitialSelection(selectedDataConfig: [
            new charts.SeriesDatumConfig<DateTime>(
                'timeChart', firstDeliveryTime)
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
    return widget.sensor.category == "temperature" ? "$value °C" : "$value %";
  }
}
