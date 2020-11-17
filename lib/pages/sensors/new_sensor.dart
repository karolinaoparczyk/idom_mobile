import 'package:idom/enums/frequency_units.dart';
import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/dialogs/frequency_units_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/dialogs/sensor_category_dialog.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';

/// adds new sensor
class NewSensor extends StatefulWidget {
  NewSensor({@required this.storage, this.testApi});

  final SecureStorage storage;
  final Api testApi;

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
  final GlobalKey<State> _keyLoaderInvalidToken = new GlobalKey<State>();
  Api api = Api();
  String categoryValue;
  String frequencyUnitsValue;
  bool _load;
  String fieldsValidationMessage;
  bool canEditFrequency = true;

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }
    _load = false;
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
                  child: CategoryDialog(
                      currentCategory: categoryValue, type: "sensors"),
                );
              });
          if (selectedCategory != null) {
            _categoryController.text = selectedCategory['text'];
            categoryValue = selectedCategory['value'];
            if (selectedCategory['value'] == "rain_sensor" ||
                selectedCategory['value'] == "water_temp" ||
                selectedCategory['value'] == "breathalyser" ||
                selectedCategory['value'] == "smoke") {
              canEditFrequency = false;
              frequencyUnitsValue = "seconds";
              _frequencyUnitsController.text = FrequencyUnits.values
                  .where((element) => element['value'] == "seconds")
                  .first['text'];
              _frequencyValueController.text = "30";
            } else {
              canEditFrequency = true;
            }
            setState(() {});
          }
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        readOnly: true,
        style: TextStyle(fontSize: 17.0),
        validator: CategoryFieldValidator.validate);
  }

  /// builds sensor frequency value form field
  Widget _buildFrequencyValue() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        child: TextFormField(
          key: Key('frequencyValue'),
          enabled: canEditFrequency,
          keyboardType: TextInputType.number,
          controller: _frequencyValueController,
          style: TextStyle(fontSize: 17.0),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            labelText: "Wartość",
            labelStyle: Theme.of(context).textTheme.headline5.copyWith(
                color: canEditFrequency
                    ? IdomColors.additionalColor
                    : IdomColors.textDark),
          ),
          validator: SensorFrequencyFieldValidator.validate,
        ));
  }

  /// builds frequency units field
  Widget _buildFrequencyUnitsField() {
    return TextFormField(
        key: Key("frequencyUnitsButton"),
        controller: _frequencyUnitsController,
        enabled: canEditFrequency,
        decoration: InputDecoration(
          labelText: "Jednostki",
          labelStyle: Theme.of(context).textTheme.headline5.copyWith(
              color: canEditFrequency
                  ? IdomColors.additionalColor
                  : IdomColors.textDark),
          suffixIcon: Icon(Icons.arrow_drop_down),
          prefixStyle: TextStyle(color: IdomColors.textDark, fontSize: 17.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onTap: () async {
          if (!canEditFrequency) return;
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
        validator: FrequencyUnitsFieldValidator.validate);
  }

  clearFields() {
    _formKey.currentState.reset();
    _nameController.text = "";
    _categoryController.text = "";
    _frequencyValueController.text = "";
    _frequencyUnitsController.text = "";
    categoryValue = null;
    frequencyUnitsValue = null;
    canEditFrequency = true;
    setState(() {});
  }

  onLogOutFailure(String text) {
    final snackBar = new SnackBar(content: new Text(text));
    _scaffoldKey.currentState.showSnackBar((snackBar));
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
                  var decision = await confirmActionDialog(context, "Potwierdź",
                      "Czy na pewno wyczyścić wszystkie pola?");
                  if (decision) {
                    clearFields();
                  }
                },
              ),
              IconButton(
                  key: Key('addSensorButton'),
                  icon: Icon(Icons.save),
                  onPressed: _saveChanges),
            ]),
            drawer: IdomDrawer(
                storage: widget.storage,
                parentWidgetType: "NewSensor",
                onLogOutFailure: onLogOutFailure),

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
                            if (categoryValue != "breathalyser")
                              Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 30.0),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Icon(Icons.access_time_outlined,
                                              size: 17.5),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5.0),
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
                            if (categoryValue != "breathalyser")
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
                            if (categoryValue != "breathalyser")
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 30.0),
                                child: AnimatedCrossFade(
                                  crossFadeState:
                                      fieldsValidationMessage != null
                                          ? CrossFadeState.showFirst
                                          : CrossFadeState.showSecond,
                                  duration: Duration(milliseconds: 300),
                                  firstChild: fieldsValidationMessage != null
                                      ? Text(fieldsValidationMessage,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(
                                                  fontWeight:
                                                      FontWeight.normal))
                                      : SizedBox(),
                                  secondChild: SizedBox(),
                                ),
                              ),
                          ])))),
            ]))));
  }

  /// saves changes after form fields validation
  _saveChanges() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      int valInt = int.tryParse(_frequencyValueController.text);
      if (valInt == null || valInt <= 0) {
        fieldsValidationMessage =
            'Wartość częstotliwości pobierania danych musi być nieujemną liczbą całkowitą.';
        setState(() {});
        return;
      }

      /// validates if frequency value is valid for given frequency units
      var validFrequencyValue =
          SensorFrequencyFieldValidator.isFrequencyValueValid(
              _frequencyValueController.text, frequencyUnitsValue);
      if (!validFrequencyValue) {
        var text =
            "Maksymalna częstotliwość to co ${unitsToMaxValues[frequencyUnitsValue]} ${FrequencyUnits.values.where((element) => element['value'] == frequencyUnitsValue).first['text']}";
        if (frequencyUnitsValue == "seconds")
          text =
              "Minimalna częstotliwość to co ${unitsToMinValues[frequencyUnitsValue]} ${FrequencyUnits.values.where((element) => element['value'] == frequencyUnitsValue).first['text']}, a maksymalna to co ${unitsToMaxValues[frequencyUnitsValue]} ${FrequencyUnits.values.where((element) => element['value'] == frequencyUnitsValue).first['text']}";
        setState(() {
          fieldsValidationMessage = text;
        });
        return;
      } else {
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
            _nameController.text, categoryValue, frequencyInSeconds);

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
          _scaffoldKey.currentState.showSnackBar((snackBar));
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
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
        if (e.toString().contains("SocketException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd dodawania czujnika. Adres serwera nieprawidłowy."));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      }
    }
  }
}
