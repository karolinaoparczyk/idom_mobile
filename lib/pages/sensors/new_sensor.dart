import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:idom/api.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/utils/menu_items.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/dialog.dart';

class NewSensor extends StatefulWidget {
  NewSensor({Key key,
    @required this.currentLoggedInToken,
    @required this.currentLoggedInUsername,
    @required this.api})
      : super(key: key);
  final String currentLoggedInToken;
  final String currentLoggedInUsername;
  final Api api;

  @override
  _NewSensorState createState() => new _NewSensorState();
}

class _NewSensorState extends State<NewSensor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _frequencyValueController = TextEditingController();
  var selectedCategory;
  var selectedUnits;

  List<DropdownMenuItem<String>> categories;
  List<DropdownMenuItem<String>> units;
  Map<String, String> englishToPolishUnits ={
    "seconds": "sekundy",
    "minutes": "minuty",
    "hours": "godziny",
    "days": "dni"
  };

  @override
  void initState() {
    super.initState();

    categories = [
      DropdownMenuItem(
          child: Text("Temperatura"),
          value: "temperature",
          key: Key("temperature")),
      DropdownMenuItem(
          child: Text("Wilgotność"), value: "humidity", key: Key("humidity"))
    ];

    units = [
      DropdownMenuItem(
          child: Text("Sekundy"), value: "seconds", key: Key("seconds")),
      DropdownMenuItem(
          child: Text("Minuty"), value: "minutes", key: Key("minutes")),
      DropdownMenuItem(
          child: Text("Godziny"), value: "hours", key: Key("hours")),
      DropdownMenuItem(child: Text("Dni"), value: "days", key: Key("days"))
    ];
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

  void _choiceAction(String choice) {
    if (choice == "Konta") {
      Api api = Api();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Accounts(
                      currentLoggedInToken: widget.currentLoggedInToken,
                      currentLoggedInUsername: widget.currentLoggedInUsername,
                      api: api),
              fullscreenDialog: true));
    } else if (choice == "Wyloguj") {
      _logOut();
    }
  }

  Widget _buildName() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
        child: TextFormField(
            autofocus: true,
            key: Key('name'),
            controller: _nameController,
            decoration: InputDecoration(
                labelText: 'Nazwa',
                labelStyle: TextStyle(color: Colors.black, fontSize: 18)),
            validator: SensorNameFieldValidator.validate));
  }

  Widget _buildCategory() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
        child: DropdownButton(
          key: Key("categoriesButon"),
          items: categories,
          onChanged: (val) {
            setState(() {
              selectedCategory = val;
            });
          },
          value: selectedCategory,
        ));
  }

  Widget _buildFrequencyValue() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        child: TextFormField(
          key: Key('frequencyValue'),
          keyboardType: TextInputType.number,
          controller: _frequencyValueController,
          decoration: InputDecoration(
            labelText: 'Wartość',
            labelStyle: TextStyle(color: Colors.black, fontSize: 18),
          ),
          validator: SensorFrequencyFieldValidator.validate,
        ));
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Dodaj czujnik"),
          actions: <Widget>[
            PopupMenuButton(
                key: Key("menuButton"),
                offset: Offset(0, 100),
                onSelected: _choiceAction,
                itemBuilder: (BuildContext context) {
                  return menuChoices.map((String choice) {
                    return PopupMenuItem(
                        key: Key(choice), value: choice, child: Text(choice));
                  }).toList();
                })
          ],
        ),
        body: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  _buildName(),
                  Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 30.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Kategoria",
                              style: TextStyle(fontSize: 13.5)))),
                  Padding(
                      padding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildCategory())),
                  Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 30.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Częstotliwość pobierania danych",
                              style: TextStyle(fontSize: 13.5)))),
                  Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 30.0),
                      child: SizedBox(
                          child: Row(children: <Widget>[
                            Expanded(flex: 3, child: _buildFrequencyValue()),
                            Expanded(flex: 1, child: SizedBox()),
                            Expanded(
                                flex: 5,
                                child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: _buildUnits())),
                          ]))),
                  Divider(),
                  buttonWidget(context, "Dodaj czujnik", _saveChanges)
                ]))));
  }

  _saveChanges() async {
    final formState = _formKey.currentState;
    var displayText = "";
    if (selectedCategory == null) {
      displayText += "Wybierz kategorię czujnika. \n";
    }
    if (selectedUnits == null) {
      displayText += "Wybierz jednotski częstotliwości pobierania danych.";
    }
    if (displayText != ""){
      await displayDialog(context, "Brak danych", displayText);
    }
    if (formState.validate()) {
      var validFequencyValue = SensorFrequencyFieldValidator
          .isFrequencyValueValid(_frequencyValueController.text, selectedUnits);
      if (!validFequencyValue) {
        await displayDialog(
            context, "Błąd",
            "Poprawne wartości dla jednostki: ${englishToPolishUnits[selectedUnits]} to: ${unitsToMinValues[selectedUnits]} - ${unitsToMaxValues[selectedUnits]}");
        return;
      }
      var frequencyInSeconds = int.parse(_frequencyValueController.text);
      if (selectedUnits != "seconds"){
        if (selectedUnits == "minutes")
          frequencyInSeconds = frequencyInSeconds * 60;
        else if (selectedUnits == "hours")
        frequencyInSeconds = frequencyInSeconds * 60 * 60;
        else if (selectedUnits == "days")
          frequencyInSeconds = frequencyInSeconds * 24 * 60 * 60;
      }
      try {
        var res = await widget.api.addSensor(_nameController.text,
            selectedCategory, frequencyInSeconds, widget.currentLoggedInToken);
        Map valueMap = json.decode(res['bodySen']);
        if (res['statusCodeSen'] == "201") {
          var resFreq = await widget.api.addFrequency(valueMap['id'], frequencyInSeconds, widget.currentLoggedInToken);
          Navigator.of(context).pop(true);
        } else if (res['bodySen']
            .contains("Sensor with provided name already exists")) {
          displayDialog(
              context, "Błąd", "Czujnik o podanej nazwie już istnieje.");
        }
      } catch (e) {
        print(e);
      }
    }
  }
}
