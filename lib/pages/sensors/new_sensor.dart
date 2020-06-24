import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/utils/menu_items.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/dialog.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/widgets/text_color.dart';

import '../../models.dart';

/// adds new sensor
class NewSensor extends StatefulWidget {
  NewSensor(
      {Key key,
      @required this.currentLoggedInToken,
      @required this.currentUser,
      @required this.api,
      @required this.onSignedOut})
      : super(key: key);
  final String currentLoggedInToken;
  final Account currentUser;
  Api api;
  VoidCallback onSignedOut;

  @override
  _NewSensorState createState() => new _NewSensorState();
}

class _NewSensorState extends State<NewSensor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _frequencyValueController = TextEditingController();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final GlobalKey<State> _keyLoaderInvalidToken = new GlobalKey<State>();
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

    /// available sensor categories choices
    categories = [
      DropdownMenuItem(
          child: Text("Temperatura"),
          value: "temperature",
          key: Key("temperature")),
      DropdownMenuItem(
          child: Text("Wilgotność"), value: "humidity", key: Key("humidity"))
    ];

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
  }

  /// logs the user out of the app
  _logOut() async {
    try {
      displayProgressDialog(
          context: _scaffoldKey.currentContext,
          key: _keyLoader,
          text: "Trwa wylogowywanie...");
      var statusCode = await widget.api.logOut(widget.currentLoggedInToken);
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      if (statusCode == 200 || statusCode == 404 || statusCode == 401) {
        widget.onSignedOut();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (statusCode == null) {
        displayDialog(
            context: _scaffoldKey.currentContext,
            title: "Błąd wylogowywania",
            text: "Sprawdź połączenie z serwerem i spróbuj ponownie.");
      } else {
        displayDialog(
            context: context,
            title: "Błąd",
            text: "Wylogowanie nie powiodło się. Spróbuj ponownie.");
      }
    } catch (e) {
      print(e);
      if (e.toString().contains("TimeoutException")) {
        displayDialog(
            context: context,
            title: "Błąd wylogowania",
            text: "Sprawdź połączenie z serwerem i spróbuj ponownie.");
      }
      if (e.toString().contains("No address associated with hostname")) {
        await displayDialog(
            context: context,
            title: "Błąd wylogowania",
            text: "Adres serwera nieprawidłowy.");
        widget.onSignedOut();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  /// navigates according to menu choice
  void _choiceAction(String choice) async {
    if (choice == "Moje konto") {
      var result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AccountDetail(
                  currentLoggedInToken: widget.currentLoggedInToken,
                  account: widget.currentUser,
                  currentUser: widget.currentUser,
                  api: widget.api,
                  onSignedOut: widget.onSignedOut),
              fullscreenDialog: true));
      setState(() {
        widget.onSignedOut = result;
      });
    } else if (choice == "Konta") {
      var result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Accounts(
                  currentLoggedInToken: widget.currentLoggedInToken,
                  currentUser: widget.currentUser,
                  api: widget.api,
                  onSignedOut: widget.onSignedOut),
              fullscreenDialog: true));
      setState(() {
        widget.onSignedOut = result;
      });
    } else if (choice == "Wyloguj") {
      _logOut();
    }
  }

  /// builds sensor name form field
  Widget _buildName() {
    return TextFormField(
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0),
          border: InputBorder.none,
          hintText: "Podaj nazwę",
        ),
        autofocus: true,
        key: Key('name'),
        style: TextStyle(fontSize: 17.0),
        controller: _nameController,
        validator: SensorNameFieldValidator.validate);
  }

  /// builds sensor category dropdown button
  Widget _buildCategory() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
        child: DropdownButtonHideUnderline(
            child: DropdownButton(
          style: TextStyle(fontSize: 17.0, color: Colors.black),
          hint: Text("Wybierz kategorię..."),
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
        child: DropdownButtonHideUnderline(
            child: DropdownButton(
          style: TextStyle(fontSize: 17.0, color: Colors.black),
          key: Key("unitsButton"),
          items: units,
          hint: Text("Wybierz jednostki..."),
          onChanged: (val) {
            setState(() {
              selectedUnits = val;
            });
          },
          value: selectedUnits,
        )));
  }

  Future<bool> _onBackButton() async {
    Map<String, dynamic> result = {
      'onSignedOut': widget.onSignedOut,
      'dataSaved': false
    };
    Navigator.of(context).pop(result);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackButton,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text("Dodaj czujnik"),
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
                                    top: 13.5,
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
                                  Expanded(
                                      flex: 8, child: _buildFrequencyValue()),
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
                                              alignment: Alignment.bottomLeft,
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
                        buttonWidget(context, "Dodaj czujnik", _saveChanges),
                      ])))
            ]))));
  }

  /// saves changes after form fields and dropdown buttons validation
  _saveChanges() async {
    final formState = _formKey.currentState;
    var displayText = "";
    if (selectedCategory == null) {
      displayText += "Wybierz kategorię czujnika. \n";
    }
    if (selectedUnits == null) {
      displayText += "Wybierz jednostki częstotliwości pobierania danych.";
    }
    if (displayText != "") {
      await displayDialog(
          context: context, title: "Brak danych", text: displayText);
    }
    if (formState.validate()) {
      /// validates if frequency value is valid for given frequency units
      var validFequencyValue =
          SensorFrequencyFieldValidator.isFrequencyValueValid(
              _frequencyValueController.text, selectedUnits);
      if (!validFequencyValue) {
        var text =
            "Maksymalna częstotliwość to co ${unitsToMaxValues[selectedUnits]} ${englishToPolishUnits[selectedUnits]}";
        if (selectedUnits == "seconds")
          text =
              "Minimalna częstotliwość to co ${unitsToMinValues[selectedUnits]} ${englishToPolishUnits[selectedUnits]}, a maksymalna to co ${unitsToMaxValues[selectedUnits]} ${englishToPolishUnits[selectedUnits]}";
        await displayDialog(context: context, title: "Błąd", text: text);
        return;
      }
      setState(() {
        _load = true;
      });

      /// converts frequency value to seconds
      var frequencyInSeconds = int.parse(_frequencyValueController.text);
      if (selectedUnits != "seconds") {
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

        if (res['statusCodeSen'] == "201") {
          setState(() {
            _load = false;
          });
          Map<String, dynamic> result = {
            'onSignedOut': widget.onSignedOut,
            'dataSaved': true
          };
          Navigator.of(context).pop(result);
        } else if (res['statusCodeSen'] == "401") {
          displayProgressDialog(
              context: _scaffoldKey.currentContext,
              key: _keyLoaderInvalidToken,
              text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...");
          await new Future.delayed(const Duration(seconds: 3));
          Navigator.of(_keyLoaderInvalidToken.currentContext,
                  rootNavigator: true)
              .pop();
          widget.onSignedOut();
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (res['bodySen']
            .contains("Sensor with provided name already exists")) {
          displayDialog(
              context: context,
              title: "Błąd",
              text: "Czujnik o podanej nazwie już istnieje.");
          setState(() {
            _load = false;
          });
        }
      } catch (e) {
        print(e);
        setState(() {
          _load = false;
        });
        if (e.toString().contains("TimeoutException")) {
          displayDialog(
              context: context,
              title: "Błąd dodawania czujnika",
              text: "Sprawdź połączenie z serwerem i spróbuj ponownie.");
        }
        if (e.toString().contains("No address associated with hostname")) {
          await displayDialog(
              context: context,
              title: "Błąd dodawania czujnika",
              text: "Adres serwera nieprawidłowy.");
          widget.onSignedOut();
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    }
  }
}
