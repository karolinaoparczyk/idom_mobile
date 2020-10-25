import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/dialogs/frequency_units_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/dialogs/sensor_category_dialog.dart';
import 'package:idom/enums/categories.dart';
import 'package:idom/enums/frequency_units.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';

import '../../models.dart';

/// edits sensor
class EditSensor extends StatefulWidget {
  EditSensor({Key key,
    @required this.currentLoggedInToken,
    @required this.currentUser,
    @required this.sensor,
    @required this.api,
    @required this.onSignedOut})
      : super(key: key);
  final String currentLoggedInToken;
  final Account currentUser;
  final Sensor sensor;
  Api api;
  VoidCallback onSignedOut;

  @override
  _EditSensorState createState() => new _EditSensorState();
}

class _EditSensorState extends State<EditSensor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _frequencyValueController = TextEditingController();
  TextEditingController _frequencyUnitsController = TextEditingController();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final GlobalKey<State> _keyLoaderInvalidToken = new GlobalKey<State>();
  String categoryValue;
  String frequencyUnitsValue;
  final Api api = Api();
  bool _load;

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

    /// setting current sensor category
    _categoryController = TextEditingController(
        text: Categories.values.firstWhere(
            (element) => element["value"] == widget.sensor.category)['text']);
    categoryValue = widget.sensor.category;

    /// setting current sensor frequency
    _frequencyValueController =
        TextEditingController(text: widget.sensor.frequency.toString());

    /// setting current sensor frequency
    _frequencyUnitsController = TextEditingController(
        text: FrequencyUnits.values
            .firstWhere((element) => element['value'] == "seconds")['text']);
    frequencyUnitsValue = "seconds";
  }

  Future<void> getToken() async {
    _token = await widget.storage.getToken();
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
        final snackBar =
        new SnackBar(content: new Text("Błąd wylogowywania. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      } else {
        final snackBar =
        new SnackBar(content: new Text("Wylogowanie nie powiodło się. Spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    } catch (e) {
      print(e);
      setState(() {
        _load = false;
      });
      if (e.toString().contains("TimeoutException")) {
        final snackBar =
        new SnackBar(content: new Text("Błąd wylogowania. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar =
        new SnackBar(content: new Text("Błąd wylogowania. Adres serwera nieprawidłowy."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    }
  }
  /// builds sensor name form field
  Widget _buildName() {
    return TextFormField(
        decoration: InputDecoration(
          labelText: "Nazwa",
          labelStyle: Theme.of(context).textTheme.headline5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        key: Key('name'),
        style: TextStyle(fontSize: 21.0),
        autofocus: true,
        controller: _nameController,
        validator: SensorNameFieldValidator.validate);
  }

  /// builds sensor category field
  Widget _buildCategoryField() {
    return TextFormField(
        key: Key("categoriesButton"),
        controller: _categoryController,
        decoration: InputDecoration(
          labelText: "Kategoria",
          labelStyle: Theme.of(context).textTheme.headline5,
          suffixIcon: Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onTap: () async {
          final Map<String, String> selectedCategory = await showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: CategoryDialog(currentCategory: categoryValue),
                );
              });
          if (selectedCategory != null) {
            _categoryController.text = selectedCategory['text'];
            categoryValue = selectedCategory['value'];
          }
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        readOnly: true,
        style: TextStyle(fontSize: 21.0),
        validator: UrlFieldValidator.validate);
  }

  /// builds sensor frequency value form field
  Widget _buildFrequencyValue() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        child: TextFormField(
          key: Key('frequencyValue'),
          keyboardType: TextInputType.number,
          controller: _frequencyValueController,
          style: TextStyle(fontSize: 21.0),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            labelText: "Wartość",
            labelStyle: Theme.of(context).textTheme.headline5,
          ),
          validator: SensorFrequencyFieldValidator.validate,
        ));
  }

  /// builds frequency units field
  Widget _buildFrequencyUnitsField() {
    return TextFormField(
        key: Key("frequencyUnitsButton"),
        controller: _frequencyUnitsController,
        decoration: InputDecoration(
          labelText: "Jednostki",
          labelStyle: Theme.of(context).textTheme.headline5,
          suffixIcon: Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onTap: () async {
          final Map<String, String> selectedFrequencyUnits = await showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: FrequencyUnitsDialog(
                    currentFrequencyUnits: frequencyUnitsValue,
                  ),
                );
              });
          if (selectedFrequencyUnits != null) {
            _frequencyUnitsController.text = selectedFrequencyUnits['text'];
            frequencyUnitsValue = selectedFrequencyUnits['value'];
          }
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        readOnly: true,
        style: TextStyle(fontSize: 21.0),
        validator: UrlFieldValidator.validate);
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
              title: Text(widget.sensor.name),
            ),
            drawer: IdomDrawer(storage: widget.storage, parentWidgetType: "EditSensor"),

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
                                    top: 20.0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline_rounded , size: 17.5),
                                        Padding(
                                          padding: const EdgeInsets.only(left:5.0),
                                          child: Text(
                                              "Ogólne",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1.copyWith(fontWeight: FontWeight.normal)),
                                        ),
                                      ],
                                    ))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 10.0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: _buildName()),
                            Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 30.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _buildCategoryField())),
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
                                        Icon(Icons.access_time_outlined, size: 17.5),
                                        Padding(
                                          padding: const EdgeInsets.only(left:5.0),
                                          child: Text(
                                              "Częstotliwość pobierania danych",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1.copyWith(fontWeight: FontWeight.normal)),
                                        ),
                                      ],
                                    ))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 10.0,
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
                                              child:
                                                  _buildFrequencyUnitsField()))),
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
            ]))));
  }

  /// saves changes after form fields and dropdown buttons validation
  _saveChanges(bool changedName, bool changedCategory,
      bool changedFrequencyValue, int frequencyInSeconds) async {
    var name = changedName ? _nameController.text : null;
    var category = changedCategory ? categoryValue : null;
    var frequencyValue = changedFrequencyValue ? frequencyInSeconds : null;
    setState(() {
      _load = true;
    });
    try {
      Navigator.of(context).pop(true);
      var res = await widget.api.editSensor(widget.sensor.id, name, category,
          frequencyValue, widget.currentLoggedInToken);
      if (res['statusCode'] == "200") {
        Map<String, dynamic> result = {
          'onSignedOut': widget.onSignedOut,
          'dataSaved': true
        };
        Navigator.of(context).pop(result);
      } else if (res['statusCode'] == "401") {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoaderInvalidToken,
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...");
        await new Future.delayed(const Duration(seconds: 3));
        Navigator.of(_keyLoaderInvalidToken.currentContext, rootNavigator: true)
            .pop();
        widget.onSignedOut();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (res['body']
          .contains("Sensor with provided name already exists")) {
        final snackBar =
        new SnackBar(content: new Text("Czujnik o podanej nazwie już istnieje."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
        setState(() {
          _load = false;
        });
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _load = false;
      });
      if (e.toString().contains("TimeoutException")) {
        final snackBar =
        new SnackBar(content: new Text("Błąd edytowania czujnika. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar =
        new SnackBar(content: new Text("Błąd edytowania czujnika. Adres serwera nieprawidłowy."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    }
  }

  /// confirms saving account changes
  _confirmSavingChanges(bool changedName, bool changedCategory,
      bool changedFrequencyValue, int frequencyInSeconds) async {
    await confirmActionDialog(
      context,
      "Potwierdź",
      "Czy na pewno zapisać zmiany?",
      () async {
        await _saveChanges(changedName, changedCategory, changedFrequencyValue,
            frequencyInSeconds);
      },
    );
  }

  /// verifies data changes
  _verifyChanges() async {
    var name = _nameController.text;
    var category = categoryValue;
    var frequencyUnits = frequencyUnitsValue;
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
                _frequencyValueController.text, frequencyUnitsValue);
        if (!validFrequencyValue) {
          await displayDialog(
              context: context,
              title: "Błąd",
              text:
                  "Poprawne wartości dla jednostki: ${englishToPolishUnits[frequencyUnitsValue]} to: ${unitsToMinValues[frequencyUnitsValue]} - ${unitsToMaxValues[frequencyUnitsValue]}");
          return;
        }

        /// converts frequency value to seconds
        frequencyInSeconds = int.parse(_frequencyValueController.text);
        if (frequencyUnitsValue != "seconds") {
          if (frequencyUnitsValue == "minutes")
            frequencyInSeconds = frequencyInSeconds * 60;
          else if (frequencyUnitsValue == "hours")
            frequencyInSeconds = frequencyInSeconds * 60 * 60;
          else if (frequencyUnitsValue == "days")
            frequencyInSeconds = frequencyInSeconds * 24 * 60 * 60;
        }
      }
      if (changedName || changedCategory || changedFrequencyValue) {
        await _confirmSavingChanges(changedName, changedCategory,
            changedFrequencyValue, frequencyInSeconds);
      } else {
        final snackBar =
        new SnackBar(content: new Text("Nie wprowadzono żadnych zmian."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    }
  }
}
