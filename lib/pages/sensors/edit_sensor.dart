import 'package:idom/utils/idom_colors.dart';
import 'package:flutter/material.dart';

import 'package:idom/localization/sensors/edit_sensor.i18n.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/dialogs/frequency_units_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/dialogs/category_dialog.dart';
import 'package:idom/enums/categories.dart';
import 'package:idom/enums/frequency_units.dart';
import 'package:idom/utils/login_procedures.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';

import '../../models.dart';

/// allows editing sensor
class EditSensor extends StatefulWidget {
  EditSensor({@required this.storage, @required this.sensor, this.testApi});

  /// internal storage
  final SecureStorage storage;

  /// selected sensor
  final Sensor sensor;

  /// api used for tests
  final Api testApi;

  /// handles state of widgets
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
  final GlobalKey<State> _keyLoaderInvalidToken = new GlobalKey<State>();
  String categoryValue;
  String frequencyUnitsValue;
  Api api = Api();
  bool _load;
  String fieldsValidationMessage;
  String nameValidationMessage;
  bool canEditFrequency = true;

  List<DropdownMenuItem<String>> units;
  Map<String, String> englishToPolishUnits = {
    "seconds": "sekundy".i18n,
    "minutes": "minuty".i18n,
    "hours": "godziny".i18n,
    "days": "dni".i18n
  };

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }

    LoginProcedures.init(widget.storage, api);

    _load = false;

    /// seting current sensor name
    _nameController = TextEditingController(text: widget.sensor.name);

    /// setting current sensor category
    _categoryController = TextEditingController(
        text: SensorCategories.values
            .firstWhere(
                (element) => element["value"] == widget.sensor.category)['text']
            .i18n);
    categoryValue = widget.sensor.category;
    if (categoryValue == "rain_sensor" ||
        categoryValue == "water_temp" ||
        categoryValue == "breathalyser" ||
        categoryValue == "smoke" ||
        categoryValue == "gas" ||
        categoryValue == "motion_sensor") {
      canEditFrequency = false;
      frequencyUnitsValue = "seconds";
      _frequencyUnitsController.text = FrequencyUnits.values
          .where((element) => element['value'] == "seconds")
          .first['text']
          .i18n;
      _frequencyValueController.text = "30";
    } else {
      canEditFrequency = true;
    }

    /// setting current sensor frequency
    _frequencyValueController =
        TextEditingController(text: widget.sensor.frequency.toString());

    /// setting current sensor frequency
    _frequencyUnitsController = TextEditingController(
        text: FrequencyUnits.values
            .firstWhere((element) => element['value'] == "seconds")['text']);
    frequencyUnitsValue = "seconds";
  }

  /// builds sensor name form field
  Widget _buildName() {
    return TextFormField(
        decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).textTheme.bodyText2.color),
                borderRadius: BorderRadius.circular(10.0)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).textTheme.bodyText2.color),
              borderRadius: BorderRadius.circular(10.0),
            ),
            labelText: "Nazwa".i18n,
            labelStyle: Theme.of(context).textTheme.headline5,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            counterStyle:
                Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 12.5)),
        key: Key('name'),
        style: Theme.of(context).textTheme.bodyText2,
        autofocus: true,
        maxLength: 30,
        controller: _nameController,
        validator: SensorNameFieldValidator.validate);
  }

  /// builds sensor category field
  Widget _buildCategoryField() {
    return TextFormField(
        key: Key("categoriesButton"),
        controller: _categoryController,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).textTheme.bodyText2.color),
              borderRadius: BorderRadius.circular(10.0)),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).textTheme.bodyText2.color),
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Kategoria".i18n,
          labelStyle: Theme.of(context).textTheme.headline5,
          suffixIcon:
              Icon(Icons.arrow_drop_down, color: IdomColors.additionalColor),
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
                selectedCategory['value'] == "smoke" ||
                selectedCategory['value'] == "gas" ||
                selectedCategory['value'] == "motion_sensor") {
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
        style: Theme.of(context).textTheme.bodyText2,
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
          style: Theme.of(context).textTheme.bodyText2,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).textTheme.bodyText2.color),
                borderRadius: BorderRadius.circular(10.0)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).textTheme.bodyText2.color),
              borderRadius: BorderRadius.circular(10.0),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            labelText: "Wartość".i18n,
            labelStyle: Theme.of(context).textTheme.headline5.copyWith(
                color: canEditFrequency
                    ? IdomColors.additionalColor
                    : Theme.of(context).textTheme.bodyText1.color),
          ),
          validator: SensorFrequencyFieldValidator.validate,
        ));
  }

  /// builds frequency units field
  Widget _buildFrequencyUnitsField() {
    return TextFormField(
        key: Key("frequencyUnitsButton"),
        enabled: canEditFrequency,
        controller: _frequencyUnitsController,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).textTheme.bodyText2.color),
              borderRadius: BorderRadius.circular(10.0)),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).textTheme.bodyText2.color),
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Jednostki".i18n,
          labelStyle: Theme.of(context).textTheme.headline5.copyWith(
              color: canEditFrequency
                  ? IdomColors.additionalColor
                  : Theme.of(context).textTheme.bodyText1.color),
          suffixIcon:
              Icon(Icons.arrow_drop_down, color: IdomColors.additionalColor),
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
        style: Theme.of(context).textTheme.bodyText2,
        validator: UrlFieldValidator.validate);
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
            appBar: AppBar(title: Text(widget.sensor.name), actions: [
              IconButton(
                  key: Key('editSensorButton'),
                  icon: Icon(Icons.save),
                  onPressed: _verifyChanges)
            ]),
            drawer: IdomDrawer(
                storage: widget.storage,
                testApi: widget.testApi,
                parentWidgetType: "EditSensor"),

            /// builds form with sensor properties
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
                                Icon(Icons.info_outline_rounded, size: 21),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text("Ogólne".i18n,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1),
                                ),
                              ],
                            ))),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 62.0, top: 10.0, right: 62.0, bottom: 0.0),
                        child: _buildName()),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 62.0, top: 10.0, right: 62.0, bottom: 0.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildCategoryField())),
                    if (categoryValue != "breathalyser")
                      Padding(
                          padding: EdgeInsets.only(
                              left: 30.0, top: 20.0, right: 30.0, bottom: 0.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_outlined, size: 21),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Text(
                                        "Częstotliwość pobierania danych".i18n,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1),
                                  ),
                                ],
                              ))),
                    if (categoryValue != "breathalyser")
                      Padding(
                          padding: EdgeInsets.only(
                              left: 62.0, top: 10.0, right: 62.0, bottom: 0.0),
                          child: SizedBox(
                              child: Row(children: <Widget>[
                            Expanded(flex: 8, child: _buildFrequencyValue()),
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
                                        child: _buildFrequencyUnitsField()))),
                          ]))),
                    if (categoryValue != "breathalyser")
                      Padding(
                        padding: EdgeInsets.only(
                            left: 62.0, top: 10.0, right: 62.0, bottom: 10.0),
                        child: AnimatedCrossFade(
                          crossFadeState: fieldsValidationMessage != null
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: Duration(milliseconds: 300),
                          firstChild: fieldsValidationMessage != null
                              ? Text(fieldsValidationMessage,
                                  style: Theme.of(context).textTheme.subtitle1)
                              : SizedBox(),
                          secondChild: SizedBox(),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 62.0, top: 10.0, right: 62.0, bottom: 10.0),
                      child: AnimatedCrossFade(
                        crossFadeState: nameValidationMessage != null
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: Duration(milliseconds: 300),
                        firstChild: nameValidationMessage != null
                            ? Text(nameValidationMessage,
                                style: Theme.of(context).textTheme.subtitle1)
                            : SizedBox(),
                        secondChild: SizedBox(),
                      ),
                    ),
                  ])),
            )));
  }

  /// saves changes after form fields and dropdown buttons validation
  _saveChanges(bool changedName, bool changedCategory,
      bool changedFrequencyValue, int frequencyInSeconds) async {
    FocusScope.of(context).unfocus();
    var name = changedName ? _nameController.text : null;
    var category = changedCategory ? categoryValue : null;
    var frequencyValue = changedFrequencyValue ? frequencyInSeconds : null;
    setState(() {
      _load = true;
    });
    try {
      var res = await api.editSensor(
          widget.sensor.id, name, category, frequencyValue);
      setState(() {
        _load = false;
      });
      if (res['statusCode'] == "200") {
        onEditSensorSuccess();
      } else if (res['statusCode'] == "401") {
        nameValidationMessage = null;
        setState(() {});
        var message;
        if (widget.testApi != null) {
          message = "error";
        } else {
          message = await LoginProcedures.signInWithStoredData();
        }
        if (message != null) {
          logOut();
        } else {
          setState(() {
            _load = true;
          });
          var res = await api.editSensor(
              widget.sensor.id, name, category, frequencyValue);
          setState(() {
            _load = false;
          });

          /// on success fetching data
          if (res['statusCode'] == "200") {
            onEditSensorSuccess();
          } else if (res != null && res['statusCode'] == "401") {
            nameValidationMessage = null;
            setState(() {});
            logOut();
          } else if (res['body']
              .contains("Sensor with provided name already exists")) {
            nameValidationMessage =
                "Czujnik o podanej nazwie już istnieje.".i18n;
            setState(() {});
            return;
          } else {
            onEditSensorError();
          }
        }
      } else if (res['body']
          .contains("Sensor with provided name already exists")) {
        nameValidationMessage = "Czujnik o podanej nazwie już istnieje.".i18n;
        setState(() {});
        return;
      } else {
        onEditSensorError();
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        nameValidationMessage = null;
        _load = false;
      });
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd edytowania czujnika. Sprawdź połączenie z serwerem i spróbuj ponownie."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd edytowania czujnika. Adres serwera nieprawidłowy.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }

  onEditSensorSuccess() {
    nameValidationMessage = null;
    setState(() {});
    Navigator.pop(context, true);
  }

  onEditSensorError() {
    nameValidationMessage = null;
    setState(() {});
    final snackBar = new SnackBar(
        content: new Text(
            "Edycja czujnika nie powiodła się. Spróbuj ponownie.".i18n));
    _scaffoldKey.currentState.showSnackBar((snackBar));
  }

  Future<void> logOut() async {
    displayProgressDialog(
        context: _scaffoldKey.currentContext,
        key: _keyLoaderInvalidToken,
        text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
    await new Future.delayed(const Duration(seconds: 3));
    Navigator.of(_keyLoaderInvalidToken.currentContext, rootNavigator: true)
        .pop();
    await widget.storage.resetUserData();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// confirms saving changes
  _confirmSavingChanges(bool changedName, bool changedCategory,
      bool changedFrequencyValue, int frequencyInSeconds) async {
    var decision = await confirmActionDialog(
        context, "Potwierdź".i18n, "Czy na pewno zapisać zmiany?".i18n);
    if (decision != null && decision) {
      await _saveChanges(changedName, changedCategory, changedFrequencyValue,
          frequencyInSeconds);
    }
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
      if (widget.sensor.category != "smoke" &&
          (frequencyUnits != 'seconds' ||
              frequencyValue != widget.sensor.frequency.toString())) {
        changedFrequencyValue = true;

        int valInt = int.tryParse(_frequencyValueController.text);
        if (valInt == null) {
          fieldsValidationMessage =
              'Wartość częstotliwości pobierania danych musi być nieujemną liczbą całkowitą.'
                  .i18n;
          setState(() {});
          return;
        }

        /// validates if frequency value is valid for given frequency units
        var validFrequencyValue =
            SensorFrequencyFieldValidator.isFrequencyValueValid(
                _frequencyValueController.text, frequencyUnitsValue);
        if (!validFrequencyValue) {
          setState(() {
            fieldsValidationMessage = "Poprawne wartości dla jednostki ".i18n +
                englishToPolishUnits[frequencyUnitsValue] +
                " to ".i18n +
                unitsToMinValues[frequencyUnitsValue].toString() +
                " - " +
                unitsToMaxValues[frequencyUnitsValue].toString();
          });
        } else {
          setState(() {
            fieldsValidationMessage = null;
          });
        }
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
      if (fieldsValidationMessage == null) {
        if (changedName || changedCategory || changedFrequencyValue) {
          await _confirmSavingChanges(changedName, changedCategory,
              changedFrequencyValue, frequencyInSeconds);
        } else {
          final snackBar = new SnackBar(
              content: new Text("Nie wprowadzono żadnych zmian.".i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      }
    }
  }
}
