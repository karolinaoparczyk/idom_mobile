import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/utils/menu_items.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/dialog.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/widgets/text_color.dart';

import '../../models.dart';

/// edits sensor
class EditSensor extends StatefulWidget {
  EditSensor({Key key,
    @required this.currentLoggedInToken,
    @required this.currentUser,
    @required this.sensor,
    @required this.api})
      : super(key: key);
  final String currentLoggedInToken;
  final Account currentUser;
  final Sensor sensor;
  final Api api;

  @override
  _EditSensorState createState() => new _EditSensorState();
}

class _EditSensorState extends State<EditSensor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _frequencyValueController = TextEditingController();
  var selectedCategory;
  var selectedUnits;
  bool _load;

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
    _load = false;

    /// seting current sensor name
    _nameController = TextEditingController(text: widget.sensor.name);

    /// available sensor categories choices
    categories = [
      DropdownMenuItem(
          child: Text("temperatura"),
          value: "temperature",
          key: Key("temperature")),
      DropdownMenuItem(
          child: Text("wilgotność"), value: "humidity", key: Key("humidity"))
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
              builder: (context) =>
                  AccountDetail(
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
              builder: (context) =>
                  Accounts(
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
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(
              left: 0.0, top: 0.0, right: 0.0, bottom: 0.0),
          border: InputBorder.none,
          hintText: "Podaj nazwę",),
        key: Key('name'),
        style: TextStyle(fontSize: 17.0),
        autofocus: true,
        controller: _nameController,
        validator: SensorNameFieldValidator.validate);
  }

  /// builds sensor category dropdown button
  Widget _buildCategory() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
        child: DropdownButtonHideUnderline(child: DropdownButton(
          style: TextStyle(fontSize: 17.0, color: Colors.black),
          key: Key("categoriesButon"),
          items: categories,
          onChanged: (val) {
            setState(() {
              selectedCategory = val;
            });
          },
          value: selectedCategory,
        )));
  }

  /// builds sensor frequency value form field
  Widget _buildFrequencyValue() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        child: TextFormField(
          key: Key('frequencyValue'),
          keyboardType: TextInputType.number,
          controller: _frequencyValueController,
          style: TextStyle(fontSize: 17.0),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Podaj wartość",
          ),
          validator: SensorFrequencyFieldValidator.validate,
        ));
  }

  /// builds frequency units dropdown button
  Widget _buildUnits() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        child: DropdownButtonHideUnderline(child: DropdownButton(
          style: TextStyle(fontSize: 17.0, color: Colors.black),
          key: Key("unitsButton"),
          items: units,
          onChanged: (val) {
            setState(() {
              selectedUnits = val;
            });
          },
          value: selectedUnits,
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.sensor.name),
          actions: <Widget>[

            /// builds menu dropdown button
            PopupMenuButton(
                key: Key("menuButton"),
                offset: Offset(0, 100),
                onSelected: _choiceAction,
                itemBuilder: (BuildContext context) {
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

        /// builds form with sensor properties
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                      child: Form(
                          key: _formKey,
                          child: Column(children: <Widget>[
                            Align(
                              child: loadingIndicator(_load),
                              alignment: FractionalOffset.center,
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 10.0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Nazwa",
                                        style: TextStyle(
                                            color: textColor,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold)))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 0.0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: _buildName()),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 0.0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Kategoria",
                                        style: TextStyle(
                                            color: textColor,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold)))),
                            Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _buildCategory())),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 0.0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        "Częstotliwość pobierania danych",
                                        style: TextStyle(
                                            color: textColor,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold)))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 0.0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: SizedBox(
                                    child: Row(children: <Widget>[
                                      Expanded(flex: 8,
                                          child: _buildFrequencyValue()),
                                      Expanded(flex: 1, child: SizedBox()),
                                      Expanded(
                                          flex: 12,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 0.0,
                                                  top: 0.0,
                                                  right: 0.0,
                                                  bottom: 0.0),
                                              child: Align(
                                                  alignment: Alignment
                                                      .bottomLeft,
                                                  child: _buildUnits()))),
                                    ]))),
                          ])))),
              Expanded(
                  flex: 1,
                  child: AnimatedContainer(
                      curve: Curves.easeInToLinear,
                      duration: Duration(
                        milliseconds: 10,
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Column(children: <Widget>[
                        buttonWidget(context, "Zapisz zmiany", _verifyChanges),
                      ])))
            ])));
  }

  /// saves changes after form fields and dropdown buttons validation
  _saveChanges(bool changedName, bool changedCategory,
      bool changedFrequencyValue, int frequencyInSeconds) async {
    var name = changedName ? _nameController.text : null;
    var category = changedCategory ? selectedCategory : null;
    var frequencyValue = changedFrequencyValue ? frequencyInSeconds : null;
    setState(() {
      _load = true;
    });
    try {
      Navigator.of(context).pop(true);
      var res = await widget.api.editSensor(widget.sensor.id, name, category,
          frequencyValue, widget.currentLoggedInToken);
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
    var name = _nameController.text;
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
