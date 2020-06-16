import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/utils/menu_items.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/dialog.dart';
import 'package:idom/widgets/loading_indicator.dart';

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
  final Sensor sensor;

  @override
  _SensorDetailsState createState() => new _SensorDetailsState();
}

class _SensorDetailsState extends State<SensorDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _editingNameController;
  TextEditingController _frequencyValueController = TextEditingController();
  var selectedCategory;
  var selectedUnits;
  bool _load;
  List<SensorData> sensorData;
  List<charts.Series<SensorData, DateTime>> _seriesData;
  DateTime _time;
  String _measure;
  String dataMeasuresTime;

  List<DropdownMenuItem<String>> categories;
  List<DropdownMenuItem<String>> units;
  Map<String, String> englishToPolishUnits = {
    "seconds": "sekundy",
    "minutes": "minuty",
    "hours": "godziny",
    "days": "dni"
  };

  @override
  void initState() {
    super.initState();
    _load = true;

    /// seting current sensor name
    _editingNameController = TextEditingController(text: widget.sensor.name);

    /// available sensor categories choices
    categories = [
      DropdownMenuItem(
          child: Text("Temperatura"),
          value: "temperature",
          key: Key("temperature")),
      DropdownMenuItem(
          child: Text("Wilgotność"), value: "humidity", key: Key("humidity"))
    ];

    /// setting current sensor category
    selectedCategory = widget.sensor.category;

    /// available frequency units choices
    units = [
      DropdownMenuItem(
          child: Text("Sekundy"), value: "seconds", key: Key("seconds")),
      DropdownMenuItem(
          child: Text("Minuty"), value: "minutes", key: Key("minutes")),
      DropdownMenuItem(
          child: Text("Godziny"), value: "hours", key: Key("hours")),
      DropdownMenuItem(child: Text("Dni"), value: "days", key: Key("days"))
    ];

    /// setting current sensor units
    selectedUnits = "seconds";

    /// setting current sensor frequency
    _frequencyValueController =
        TextEditingController(text: widget.sensor.frequency.toString());

    _seriesData = List<charts.Series<SensorData, DateTime>>();
    dataMeasuresTime = "today";
    setState(() {
      getSensorData();
    });
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
    if (widget.sensor.category == "temperature") {
      var res = await widget.api
          .getSensorData(widget.currentLoggedInToken, widget.sensor.id);
      if (res['statusSensorData'] == "200") {
        List<dynamic> bodySensorData = jsonDecode(res['bodySensorData']);
        sensorData = List<SensorData>();
        print(bodySensorData);
        for (var i = 0; i < bodySensorData.length; i++) {
          if (bodySensorData[i]['sensor'] == "Temperatura")
            sensorData.add(SensorData.fromJson(bodySensorData[i], i + 1));
        }
        setState(() {
          drawPlot();
        });
        return sensorData;
      } else {
        throw "Can't get sensors";
      }
    }
  }

  drawPlot() {
    if (_seriesData.length != 0)
      _seriesData.removeLast();
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
    _seriesData.add(charts.Series(
        colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xffdaa520)),
        id: "wykres",
        data: data,
        domainFn: (SensorData sensorData, _) => sensorData.deliveryTime,
        measureFn: (SensorData sensorData, _) =>
            double.parse(sensorData.data)));
    _load = false;
  }

  todayPlot() {
    setState(() {
      dataMeasuresTime = "today";
      drawPlot();
    });
  }

  thisMonthPlot() {
    setState(() {
      dataMeasuresTime = "thisMonth";
      drawPlot();
    });
  }

  allTimePlot() {
    setState(() {
      dataMeasuresTime = "allTime";
      drawPlot();
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

  /// builds sensor name form field
  Widget _buildName() {
    return TextFormField(
        key: Key('name'),
        controller: _editingNameController,
        validator: SensorNameFieldValidator.validate);
  }

  /// builds sensor category dropdown button
  Widget _buildCategory() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
        child: DropdownButton(
          key: Key("dropdownbutton"),
          items: categories,
          onChanged: (val) {
            setState(() {
              selectedCategory = val;
            });
          },
          value: selectedCategory,
        ));
  }

  /// builds sensor frequency value form field
  Widget _buildFrequencyValue() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        child: TextFormField(
          key: Key('frequencyValue'),
          keyboardType: TextInputType.number,
          controller: _frequencyValueController,
          decoration: InputDecoration(
            labelStyle: TextStyle(color: Colors.black, fontSize: 18),
          ),
          validator: SensorFrequencyFieldValidator.validate,
        ));
  }

  /// builds frequency units dropdown button
  Widget _buildUnits() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        child: DropdownButton(
          key: Key("unitsButton"),
          items: units,
          onChanged: (val) {
            setState(() {
              selectedUnits = val;
            });
          },
          value: selectedUnits,
        ));
  }

  @override
  void dispose() {
    _editingNameController.dispose();
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
                          left: 30.0, top: 10.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Nazwa",
                              style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 0.0, right: 30.0, bottom: 0.0),
                      child: _buildName()),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 10.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Kategoria",
                              style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold)))),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildCategory())),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 0.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Częstotliwość pobierania danych",
                              style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 0.0, right: 30.0, bottom: 0.0),
                      child: SizedBox(
                          child: Row(children: <Widget>[
                        Expanded(flex: 3, child: _buildFrequencyValue()),
                        Expanded(flex: 1, child: SizedBox()),
                        Expanded(
                            flex: 5,
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: 0.0,
                                    top: 0.0,
                                    right: 90.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: _buildUnits()))),
                      ]))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 7.0, right: 30.0, bottom: 0.0),
                      child: SizedBox(
                          child: Row(children: <Widget>[
                        Expanded(
                            flex: 3,
                            child: Text("Wartość",
                                style: TextStyle(fontSize: 13.5))),
                        Expanded(flex: 1, child: SizedBox()),
                        Expanded(
                            flex: 5,
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: 0.0,
                                    top: 0.0,
                                    right: 90.0,
                                    bottom: 0.0),
                                child: Text("Jednostki",
                                    style: TextStyle(fontSize: 13.5)))),
                      ]))),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Aktualna temperatura",
                            style: TextStyle(
                                fontSize: 13.5, fontWeight: FontWeight.bold)),
                      )),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: getSensorLastData())),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Okres wyświetlanych danych:",
                            style: TextStyle(
                                fontSize: 13.5, fontWeight: FontWeight.bold)),
                      )),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 0.0, right: 30.0, bottom: 0.0),
                      child: SizedBox(
                          child: Row(children: <Widget>[
                        Expanded(
                            flex: 1,
                            child: FlatButton(
                              key: Key("today"),
                              child: Text('Dzisiaj', textAlign: TextAlign.center),
                              onPressed: todayPlot,
                            )),
                        Expanded(
                            flex: 1,
                            child: FlatButton(
                              key: Key("thisMonth"),
                              child: Text('Ten miesiąc', textAlign: TextAlign.center),
                              onPressed: thisMonthPlot,
                            )),
                        Expanded(
                            flex: 1,
                            child: FlatButton(
                              key: Key("allTime"),
                              child: Text('Ostatnie 30 dni', textAlign: TextAlign.center),
                              onPressed: allTimePlot,
                            )),
                      ]))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 0.0, right: 17.0, bottom: 0.0),
                      child: Container(
                          child: Center(
                              child: Column(children: <Widget>[
                        SizedBox(
                            width: 355,
                            height: 200,
                            child: _seriesData != null
                                ? charts.TimeSeriesChart(
                                    _seriesData,
                                    defaultRenderer: charts.LineRendererConfig(
                                        includeArea: true, stacked: true),
                                    animate: false,
//                                animationDuration: Duration(seconds: 1),
                                    primaryMeasureAxis: new charts
                                            .NumericAxisSpec(
                                        tickProviderSpec: new charts
                                                .BasicNumericTickProviderSpec(
                                            zeroBound: false)),
                                    selectionModels: [
                                      new charts.SelectionModelConfig(
                                        type: charts.SelectionModelType.info,
                                        changedListener: _onSelectionChanged,
                                      )
                                    ],
                                  )
                                : Container())
                      ])))),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
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
                  Divider(),
                  buttonWidget(context, "Zapisz zmiany", _verifyChanges),
                  SizedBox(height: 50)
                ]))));
  }

  Widget getSensorLastData() {
    if (widget.sensor.lastData == null)
      return Text("Brak danych", style: TextStyle(fontSize: 17.0));
    return widget.sensor.category == "temperature"
        ? Text("${widget.sensor.lastData} °C", style: TextStyle(fontSize: 17.0))
        : Text("${widget.sensor.lastData} %", style: TextStyle(fontSize: 17.0));
  }

  /// saves changes after form fields and dropdown buttons validation
  _saveChanges(bool changedName, bool changedCategory,
      bool changedFrequencyValue, int frequencyInSeconds) async {
    var name = changedName ? _editingNameController.text : null;
    var category = changedCategory ? selectedCategory : null;
    var frequencyValue = changedFrequencyValue ? frequencyInSeconds : null;
    setState(() {
      _load = true;
    });
    try {
      var res = await widget.api.editSensor(widget.sensor.id, name, category,
          frequencyValue, widget.currentLoggedInToken);
      Navigator.of(context).pop(false);
      if (res['statusCode'] == "200") {
        Navigator.of(context).pop(true);
      } else if (res['body']
          .contains("Sensor with provided name already exists")) {
        displayDialog(
            context, "Błąd", "Czujnik o podanej nazwie już istnieje.");
      }
      setState(() {
        _load = false;
      });
    } catch (e) {
      print(e);
    }
  }

  /// confirms saving account changes
  _confirmSavingChanges(bool changedName, bool changedCategory,
      bool changedFrequencyValue, int frequencyInSeconds) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Potwierdź"),
          content: Text("Czy na pewno zapisać zmiany?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              key: Key("yesButton"),
              child: Text("Tak"),
              onPressed: () async {
                await _saveChanges(changedName, changedCategory,
                    changedFrequencyValue, frequencyInSeconds);
              },
            ),
            FlatButton(
              key: Key("noButton"),
              child: Text("Nie"),
              onPressed: () async {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  /// verifies data changes
  _verifyChanges() async {
    var name = _editingNameController.text;
    var category = selectedCategory;
    var frequencyUnits = selectedUnits;
    var frequencyValue = _frequencyValueController.text;
    var changedName = false;
    var changedCategory = false;
    var changedFrequencyValue = false;
    var frequencyInSeconds;

    final formState = _formKey.currentState;
    if (formState.validate()) {
      /// sends request only if data changed
      if (name != widget.sensor.name) {
        changedName = true;
      }
      if (category != widget.sensor.category) {
        changedCategory = true;
      }
      if (frequencyUnits != 'seconds' ||
          frequencyValue != widget.sensor.frequency.toString()) {
        changedFrequencyValue = true;

        /// validates if frequency value is valid for given frequency units
        var validFrequencyValue =
            SensorFrequencyFieldValidator.isFrequencyValueValid(
                _frequencyValueController.text, selectedUnits);
        if (!validFrequencyValue) {
          await displayDialog(context, "Błąd",
              "Poprawne wartości dla jednostki: ${englishToPolishUnits[selectedUnits]} to: ${unitsToMinValues[selectedUnits]} - ${unitsToMaxValues[selectedUnits]}");
          return;
        }

        /// converts frequency value to seconds
        frequencyInSeconds = int.parse(_frequencyValueController.text);
        if (selectedUnits != "seconds") {
          if (selectedUnits == "minutes")
            frequencyInSeconds = frequencyInSeconds * 60;
          else if (selectedUnits == "hours")
            frequencyInSeconds = frequencyInSeconds * 60 * 60;
          else if (selectedUnits == "days")
            frequencyInSeconds = frequencyInSeconds * 24 * 60 * 60;
        }
      }
      if (changedName || changedCategory || changedFrequencyValue) {
        await _confirmSavingChanges(changedName, changedCategory,
            changedFrequencyValue, frequencyInSeconds);
      } else {
        var snackBar =
            SnackBar(content: Text("Nie wprowadzono żadnych zmian."));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }
  }
}
