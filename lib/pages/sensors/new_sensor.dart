import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/dialogs/frequency_units_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/dialogs/sensor_category_dialog.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';

/// adds new sensor
class NewSensor extends StatefulWidget {
  NewSensor({@required this.storage});

  final SecureStorage storage;

  @override
  _NewSensorState createState() => new _NewSensorState();
}

class _NewSensorState extends State<NewSensor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _frequencyValueController = TextEditingController();
  TextEditingController _frequencyUnitsController = TextEditingController();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final GlobalKey<State> _keyLoaderInvalidToken = new GlobalKey<State>();
  final Api api = Api();
  String categoryValue;
  String frequencyUnitsValue;
  bool _load;
  String _token;
  String fieldsValidationMessage;

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
    getToken();
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
      var statusCode = await api.logOut(_token);
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      if (statusCode == 200 || statusCode == 404 || statusCode == 401) {
        await widget.storage.resetUserData();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (statusCode == null) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd wylogowywania. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      } else {
        final snackBar = new SnackBar(
            content:
                new Text("Wylogowanie nie powiodło się. Spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    } catch (e) {
      print(e);
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd wylogowywania. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content:
                new Text("Błąd wylogowywania. Adres serwera nieprawidłowy."));
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
        autofocus: true,
        key: Key('name'),
        maxLength: 30,
        style: TextStyle(fontSize: 17.0),
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
          prefixStyle: TextStyle(color: IdomColors.textDark, fontSize: 17.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onTap: () async {
          final Map<String, String> selectedCategory = await showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: CategoryDialog(),
                );
              });
          if (selectedCategory != null) {
            _categoryController.text = selectedCategory['text'];
            categoryValue = selectedCategory['value'];
          }
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        readOnly: true,
        style: TextStyle(fontSize: 17.0),
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
          style: TextStyle(fontSize: 17.0),
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
          prefixStyle: TextStyle(color: IdomColors.textDark, fontSize: 17.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onTap: () async {
          final Map<String, String> selectedFrequencyUnits = await showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: FrequencyUnitsDialog(),
                );
              });
          if (selectedFrequencyUnits != null) {
            _frequencyUnitsController.text = selectedFrequencyUnits['text'];
            frequencyUnitsValue = selectedFrequencyUnits['value'];
          }
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        readOnly: true,
        style: TextStyle(fontSize: 17.0),
        validator: UrlFieldValidator.validate);
  }

  clearFields(){
    _formKey.currentState.reset();
    _nameController.text = "";
    _categoryController.text = "";
    _frequencyValueController.text = "";
    _frequencyUnitsController.text = "";
    categoryValue = null;
    frequencyUnitsValue = null;
    Navigator.pop(context, true);
  }

  Future<bool> _onBackButton() async {
    Navigator.pop(context, false);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackButton,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(title: Text("Dodaj czujnik"), actions: [
              IconButton(
                icon: Icon(Icons.restore_page_rounded),
                onPressed: () async {
                  await confirmActionDialog(context, "Potwierdź",
                      "Czy na pewno wyczyścić wszystkie pola?", clearFields);
                },
              ),
              IconButton(icon: Icon(Icons.save), onPressed: _saveChanges),

            ]),
            drawer: IdomDrawer(
                storage: widget.storage, parentWidgetType: "NewSensor"),

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
                                        Icon(Icons.info_outline_rounded,
                                            size: 17.5),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Text("Ogólne",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.normal)),
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
                                        Icon(Icons.access_time_outlined,
                                            size: 17.5),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Text(
                                              "Częstotliwość pobierania danych",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.normal)),
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
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 30.0),
                              child: AnimatedCrossFade(
                                crossFadeState: fieldsValidationMessage != null
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                duration: Duration(milliseconds: 300),
                                firstChild: fieldsValidationMessage != null
                                    ? Text(fieldsValidationMessage,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                        fontWeight: FontWeight.normal))
                                    : SizedBox(),
                                secondChild: SizedBox(),
                              ),
                            ),
                          ])))),
            ]))));
  }

  /// saves changes after form fields and dropdown buttons validation
  _saveChanges() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      /// validates if frequency value is valid for given frequency units
      var validFequencyValue =
          SensorFrequencyFieldValidator.isFrequencyValueValid(
              _frequencyValueController.text, frequencyUnitsValue);
      if (!validFequencyValue) {
        var text =
            "Maksymalna częstotliwość to co ${unitsToMaxValues[frequencyUnitsValue]} ${englishToPolishUnits[frequencyUnitsValue]}";
        if (frequencyUnitsValue == "seconds")
          text =
              "Minimalna częstotliwość to co ${unitsToMinValues[frequencyUnitsValue]} ${englishToPolishUnits[frequencyUnitsValue]}, a maksymalna to co ${unitsToMaxValues[frequencyUnitsValue]} ${englishToPolishUnits[frequencyUnitsValue]}";
        setState(() {
          fieldsValidationMessage = text;
        });
        return;
      }
      else{
        setState(() {
          fieldsValidationMessage = null;
        });
      }
      setState(() {
        _load = true;
      });

      /// converts frequency value to seconds
      var frequencyInSeconds = int.parse(_frequencyValueController.text);
      if (frequencyUnitsValue != "seconds") {
        if (frequencyUnitsValue == "minutes")
          frequencyInSeconds = frequencyInSeconds * 60;
        else if (frequencyUnitsValue == "hours")
          frequencyInSeconds = frequencyInSeconds * 60 * 60;
        else if (frequencyUnitsValue == "days")
          frequencyInSeconds = frequencyInSeconds * 24 * 60 * 60;
      }
      try {
        var res = await api.addSensor(
            _nameController.text, categoryValue, frequencyInSeconds, _token);

        if (res['statusCodeSen'] == "201") {
          setState(() {
            _load = false;
          });
          Navigator.pop(context, true);
        } else if (res['statusCodeSen'] == "401") {
          displayProgressDialog(
              context: _scaffoldKey.currentContext,
              key: _keyLoaderInvalidToken,
              text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...");
          await new Future.delayed(const Duration(seconds: 3));
          Navigator.of(_keyLoaderInvalidToken.currentContext,
                  rootNavigator: true)
              .pop();
          await widget.storage.resetUserData();
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (res['bodySen']
            .contains("Sensor with provided name already exists")) {
          final snackBar = new SnackBar(
              content: new Text("Czujnik o podanej nazwie już istnieje."));
          ScaffoldMessenger.of(context).showSnackBar((snackBar));
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
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd dodawania czujnika. Sprawdź połączenie z serwerem i spróbuj ponownie."));
          ScaffoldMessenger.of(context).showSnackBar((snackBar));
        }
        if (e.toString().contains("SocketException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd dodawania czujnika. Adres serwera nieprawidłowy."));
          ScaffoldMessenger.of(context).showSnackBar((snackBar));
        }
      }
    }
  }
}
