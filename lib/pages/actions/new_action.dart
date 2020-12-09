import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/choose_driver_dialog.dart';
import 'package:idom/dialogs/choose_sensor_dialog.dart';
import 'package:idom/dialogs/choose_sensor_trigger_operator.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/localization/actions/new_action.i18n.dart';

class NewAction extends StatefulWidget {
  NewAction({@required this.storage, this.testApi});

  final SecureStorage storage;
  final Api testApi;

  @override
  _NewActionState createState() => _NewActionState();
}

class _NewActionState extends State<NewAction> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final FocusNode _sensorFocusNode = FocusNode();
  final FocusNode _endTimeFocusNode = FocusNode();
  TextEditingController _nameController;
  TextEditingController _sensorController;
  TextEditingController _driverController;
  TextEditingController _startTimeController;
  TextEditingController _endTimeController;
  TextEditingController _sensorTriggerController;
  TextEditingController _sensorTriggerOperatorController;
  Sensor selectedSensor;
  Driver selectedDriver;
  TimeOfDay startTime;
  TimeOfDay endTime;
  Api api = Api();
  bool _load;
  List<Sensor> sensors;
  List<Driver> drivers;
  String fieldsValidationMessage;
  String selectedOperator;
  List<bool> daysOfWeekSelected = [true, true, true, true, true, true, true];

  @override
  void initState() {
    super.initState();
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
    if (widget.testApi != null) {
      api = widget.testApi;
      startTime = TimeOfDay(hour: 13, minute: 40);
      _startTimeController =
          TextEditingController(text: "${startTime.hour}:${startTime.minute}");
      endTime = TimeOfDay(hour: 15, minute: 40);
      _endTimeController =
          TextEditingController(text: "${endTime.hour}:${endTime.minute}");
    }
    getSensors();
    getDrivers();
    _load = false;
    _nameController = TextEditingController();
    _sensorController = TextEditingController();
    _driverController = TextEditingController();
    _sensorTriggerController = TextEditingController();
    _sensorTriggerOperatorController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sensorController.dispose();
    _driverController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _sensorTriggerController.dispose();
    _sensorTriggerOperatorController.dispose();
    super.dispose();
  }

  onLogOutFailure(String text) {
    final snackBar = new SnackBar(content: new Text(text));
    _scaffoldKey.currentState.showSnackBar((snackBar));
  }

  Future<bool> _onBackButton() async {
    Navigator.pop(context);
    return true;
  }

  /// returns list of sensors
  getSensors() async {
    try {
      /// gets sensors
      var res = await api.getSensors();

      if (res != null && res['statusCodeSensors'] == "200") {
        List<dynamic> bodySensors = jsonDecode(res['bodySensors']);
        setState(() {
          sensors =
              bodySensors.map((dynamic item) => Sensor.fromJson(item)).toList();
        });
      } else if (res != null && res['statusCodeSensors'] == "401") {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoader,
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
        await new Future.delayed(const Duration(seconds: 3));
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        await widget.storage.resetUserData();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      print(e.toString());
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania czujników. Sprawdź połączenie z serwerem i spróbuj ponownie."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania czujników. Adres serwera nieprawidłowy."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }

  /// returns list of drivers
  getDrivers() async {
    try {
      /// gets drivers
      var res = await api.getDrivers();

      if (res != null && res['statusCode'] == "200") {
        List<dynamic> body = jsonDecode(res['body']);
        setState(() {
          drivers = body.map((dynamic item) => Driver.fromJson(item)).toList();
        });
      } else if (res != null && res['statusCode'] == "401") {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoader,
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
        await new Future.delayed(const Duration(seconds: 3));
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        await widget.storage.resetUserData();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      print(e.toString());
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania sterowników. Sprawdź połączenie z serwerem i spróbuj ponownie."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania sterowników. Adres serwera nieprawidłowy."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }

  /// builds action name form field
  Widget _buildName() {
    return TextFormField(
        decoration: InputDecoration(
          labelText: "Nazwa".i18n,
          labelStyle: Theme.of(context).textTheme.headline5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        key: Key('name'),
        style: TextStyle(fontSize: 21.0),
        autofocus: true,
        maxLength: 30,
        controller: _nameController,
        validator: DriverNameFieldValidator.validate);
  }

  /// builds sensor field
  Widget _buildSensorField() {
    return TextFormField(
      key: Key("sensorsButton"),
      controller: _sensorController,
      focusNode: _sensorFocusNode,
      decoration: InputDecoration(
        labelText: "Czujnik".i18n,
        labelStyle: Theme.of(context).textTheme.headline5,
        suffixIcon: selectedSensor == null
            ? Icon(Icons.arrow_drop_down, color: IdomColors.brightGrey)
            : InkWell(
                onTap: () {
                  setState(() {
                    _sensorFocusNode.unfocus();
                    _sensorFocusNode.canRequestFocus = false;
                    selectedSensor = null;
                    _sensorController.text = "";
                    Future.delayed(Duration(milliseconds: 100), () {
                      _sensorFocusNode.canRequestFocus = true;
                    });
                  });
                },
                child: Icon(Icons.close, color: IdomColors.brightGrey)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onTap: () async {
        if (!_sensorFocusNode.canRequestFocus) {
          return;
        }
        final Sensor sensor = await showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: ChooseSensorDialog(
                    sensors: sensors, currentSensor: selectedSensor),
              );
            });
        if (sensor != null) {
          _sensorController.text = sensor.name;
          selectedSensor = sensor;
          setState(() {});
        }
      },
      readOnly: true,
      style: TextStyle(fontSize: 21.0),
    );
  }

  /// builds sensor trigger form field
  Widget _buildSensorTriggerValue() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        child: TextFormField(
          key: Key('sensorTrigger'),
          keyboardType: TextInputType.number,
          controller: _sensorTriggerController,
          style: TextStyle(fontSize: 21.0),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            labelText: "Wartość".i18n,
            labelStyle: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(color: IdomColors.additionalColor),
          ),
          validator: (String value) {
            if (selectedSensor != null && value.isEmpty) {
              return "Pole wymagane".i18n;
            }
            if (value.contains(',')) {
              value = value.replaceFirst(',', '.');
            }
            var doubleValue = double.tryParse(value);
            if (doubleValue == null) {
              return "Podaj liczbę".i18n;
            }
            return null;
          },
        ));
  }

  /// builds trigger value operator field
  Widget _buildTriggerValueOperatorField() {
    return TextFormField(
      key: Key("triggerValueOperator"),
      controller: _sensorTriggerOperatorController,
      decoration: InputDecoration(
        labelText: "Operator",
        labelStyle: Theme.of(context).textTheme.headline5,
        suffixIcon: Icon(Icons.arrow_drop_down),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onTap: () async {
        final String operator = await showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: SensorTriggerOperatorDialog(
                    currentOperator: selectedOperator),
              );
            });
        if (operator != null) {
          _sensorTriggerOperatorController.text = operator.i18n;
          selectedOperator = operator.substring(0, 1);
          setState(() {});
        }
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: TriggerValueOperatorFieldValidator.validate,
      readOnly: true,
      style: TextStyle(fontSize: 21.0),
    );
  }

  /// builds driver field
  Widget _buildDriverField() {
    return TextFormField(
        key: Key("driversButton"),
        controller: _driverController,
        decoration: InputDecoration(
          labelText: "Sterownik".i18n,
          labelStyle: Theme.of(context).textTheme.headline5,
          suffixIcon: Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onTap: () async {
          final Driver driver = await showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: ChooseDriverDialog(
                      drivers: drivers, currentDriver: selectedDriver),
                );
              });
          if (driver != null) {
            _driverController.text = driver.name;
            selectedDriver = driver;
          }
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        readOnly: true,
        style: TextStyle(fontSize: 21.0),
        validator: DriverFieldValidator.validate);
  }

  /// builds start time field
  Widget _buildStartTimeField() {
    return TextFormField(
        key: Key("startTimeButton"),
        controller: _startTimeController,
        decoration: InputDecoration(
          labelText: "Start",
          labelStyle: Theme.of(context).textTheme.headline5,
          suffixIcon: Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onTap: () async {
          var now = DateTime.now();
          final TimeOfDay time = await showTimePicker(
            cancelText: "Anuluj".i18n,
            confirmText: "OK",
            helpText: "Wybierz godzinę".i18n,
            builder: (BuildContext context, Widget child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  primaryColor: IdomColors.additionalColor,
                  accentColor: IdomColors.additionalColor,
                  colorScheme:
                      ColorScheme.light(primary: IdomColors.additionalColor),
                  buttonTheme:
                      ButtonThemeData(textTheme: ButtonTextTheme.primary),
                ),
                child: child,
              );
            },
            context: context,
            initialTime:
                startTime ?? TimeOfDay(hour: now.hour, minute: now.minute),
          );
          if (time != null) {
            startTime = time;
            _startTimeController.text = "${startTime.format(context)}";
            setState(() {});
          }
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        readOnly: true,
        style: TextStyle(fontSize: 21.0),
        validator: TimeFieldValidator.validate);
  }

  /// builds end time field
  Widget _buildEndTimeField() {
    return TextFormField(
        key: Key("endTimeButton"),
        controller: _endTimeController,
        focusNode: _endTimeFocusNode,
        decoration: InputDecoration(
          labelText: "Koniec".i18n,
          labelStyle: Theme.of(context).textTheme.headline5,
          suffixIcon: endTime == null
              ? Icon(Icons.arrow_drop_down)
              : InkWell(
                  onTap: () {
                    setState(() {
                      _endTimeFocusNode.unfocus();
                      _endTimeFocusNode.canRequestFocus = false;
                      endTime = null;
                      _endTimeController.text = "";
                      Future.delayed(Duration(milliseconds: 100), () {
                        _endTimeFocusNode.canRequestFocus = true;
                      });
                    });
                  },
                  child: Icon(Icons.close,
                      color: IdomColors.brightGrey, key: Key("removeEndTime"))),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onTap: () async {
          if (!_endTimeFocusNode.canRequestFocus) {
            return;
          }
          var now = DateTime.now();
          final TimeOfDay time = await showTimePicker(
            cancelText: "Anuluj".i18n,
            confirmText: "OK",
            helpText: "Wybierz godzinę".i18n,
            builder: (BuildContext context, Widget child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  primaryColor: IdomColors.additionalColor,
                  accentColor: IdomColors.additionalColor,
                  colorScheme:
                      ColorScheme.light(primary: IdomColors.additionalColor),
                  buttonTheme:
                      ButtonThemeData(textTheme: ButtonTextTheme.primary),
                ),
                child: child,
              );
            },
            context: context,
            initialTime:
                endTime ?? TimeOfDay(hour: now.hour, minute: now.minute),
          );
          if (time != null) {
            endTime = time;
            _endTimeController.text = "${endTime.format(context)}";
            setState(() {});
          }
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        readOnly: true,
        style: TextStyle(fontSize: 21.0));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackButton,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(title: Text("Dodaj akcję".i18n), actions: [
              IconButton(
                  key: Key('saveActionButton'),
                  icon: Icon(Icons.save),
                  onPressed: _saveChanges)
            ]),
            drawer: IdomDrawer(
                storage: widget.storage,
                parentWidgetType: "NewAction",
                onLogOutFailure: onLogOutFailure),

            /// builds form with action's properties
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
                                  child: Text("Ogólne".i18n,
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
                            left: 30.0, top: 10.0, right: 30.0, bottom: 0.0),
                        child: _buildName()),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 30.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildDriverField())),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 30.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildSensorField())),
                    if (selectedSensor != null)
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
                                    child: Text("Wyzwalacz na czujniku".i18n,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(
                                                fontWeight: FontWeight.normal)),
                                  ),
                                ],
                              ))),
                    if (selectedSensor != null)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 30.0),
                        child: Row(
                          children: [
                            Flexible(
                                flex: 2,
                                child: _buildTriggerValueOperatorField()),
                            SizedBox(width: 10),
                            Flexible(
                                flex: 1, child: _buildSensorTriggerValue()),
                          ],
                        ),
                      ),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 30.0, top: 20.0, right: 30.0, bottom: 0.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Icon(Icons.access_time, size: 17.5),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: Text("Czas działania akcji".i18n,
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
                          left: 30.5, top: 10, right: 20.0, bottom: 10),
                      child: Container(
                        width: 300.0, // hardcoded for testing purpose
                        child: LayoutBuilder(builder: (context, constraints) {
                          return ToggleButtons(
                              constraints:
                                  BoxConstraints.expand(width: 40, height: 30),
                              borderRadius: BorderRadius.circular(30),
                              borderColor: IdomColors.additionalColor,
                              splashColor: Colors.transparent,
                              fillColor: IdomColors.lighten(
                                  IdomColors.additionalColor, 0.2),
                              selectedColor: IdomColors.textDark,
                              children: [
                                Text("pn".i18n,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                            fontWeight: FontWeight.normal)),
                                Text("wt".i18n,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                            fontWeight: FontWeight.normal)),
                                Text("śr".i18n,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                            fontWeight: FontWeight.normal)),
                                Text("czw".i18n,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                            fontWeight: FontWeight.normal)),
                                Text("pt".i18n,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                            fontWeight: FontWeight.normal)),
                                Text("sb".i18n,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                            fontWeight: FontWeight.normal)),
                                Text("nd".i18n,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                            fontWeight: FontWeight.normal)),
                              ],
                              isSelected: daysOfWeekSelected,
                              onPressed: (int index) {
                                setState(() {
                                  daysOfWeekSelected[index] =
                                      !daysOfWeekSelected[index];
                                });
                              });
                        }),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 30.0),
                        child: Row(
                          children: [
                            Flexible(flex: 1, child: _buildStartTimeField()),
                            SizedBox(width: 10),
                            Flexible(flex: 1, child: _buildEndTimeField())
                          ],
                        )),
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
                                    .copyWith(fontWeight: FontWeight.normal))
                            : SizedBox(),
                        secondChild: SizedBox(),
                      ),
                    ),
                  ])),
            )));
  }

  _validateTime() {
    bool isCorrect = true;
    if (startTime != null && endTime != null) {
      double _doubleStartTime =
          startTime.hour.toDouble() + (startTime.minute.toDouble() / 60);
      double _doubleEndTime =
          endTime.hour.toDouble() + (endTime.minute.toDouble() / 60);
      isCorrect = _doubleStartTime < _doubleEndTime;
      if (!isCorrect) {
        setState(() {
          fieldsValidationMessage =
              "Godzina zakończenia musi być późniejsza od godziny rozpoczęcia."
                  .i18n;
        });
      } else {
        setState(() {
          fieldsValidationMessage = null;
        });
      }
    }
    return isCorrect;
  }

  String _getDaysSelectedString() {
    var daysList = [];
    for (int i = 0; i < daysOfWeekSelected.length; i++) {
      if (daysOfWeekSelected[i]) {
        daysList.add(i);
      }
    }
    var daysString = daysList.join(", ");
    if (daysList.isEmpty) {
      setState(() {
        fieldsValidationMessage =
            "Należy wybrać przynajmniej jeden dzień działania akcji.".i18n;
      });
      return null;
    } else {
      setState(() {
        fieldsValidationMessage = null;
      });
    }
    return daysString;
  }

  int _getFlag() {
    int flag;
    if (selectedSensor == null && endTime == null) {
      flag = 1;
    } else if (selectedSensor == null && endTime != null) {
      flag = 2;
    } else if (selectedSensor != null && endTime == null) {
      flag = 3;
    } else if (selectedSensor != null && endTime != null) {
      flag = 4;
    }
    return flag;
  }

  /// saves changes after form fields validation
  _saveChanges() async {
    FocusScope.of(context).unfocus();
    final formState = _formKey.currentState;
    var timeValidated = _validateTime();
    var daysString = _getDaysSelectedString();
    if (formState.validate() && timeValidated && daysString != null) {
      setState(() {
        _load = true;
      });
      try {
        var endTimeString;
        if (endTime != null) {
          endTimeString = "${endTime.hour}:${endTime.minute}";
        }
        var sensor;
        var operator;
        var trigger;
        if (selectedSensor == null) {
          sensor = null;
          operator = null;
          trigger = null;
        } else {
          sensor = selectedSensor.name;
          operator = selectedOperator;
          trigger = int.tryParse(_sensorTriggerController.text);
        }

        var res = await api.addAction(
            _nameController.text,
            sensor,
            trigger,
            operator,
            selectedDriver.name,
            daysString,
            "${startTime.hour}:${startTime.minute}",
            endTimeString,
            "action",
            _getFlag());
        setState(() {
          _load = false;
        });
        if (res['statusCode'] == "201") {
          fieldsValidationMessage = null;
          setState(() {});
          Navigator.pop(context, true);
        } else if (res['statusCode'] == "401") {
          fieldsValidationMessage = null;
          setState(() {});
          displayProgressDialog(
              context: _scaffoldKey.currentContext,
              key: _keyLoader,
              text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
          await new Future.delayed(const Duration(seconds: 3));
          Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
          await widget.storage.resetUserData();
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (res['body']
            .contains("Action with provided name already exists")) {
          fieldsValidationMessage =
              "Akcja o podanej nazwie już istnieje.".i18n;
          setState(() {});
          return;
        } else {
          fieldsValidationMessage = null;
          setState(() {});
          final snackBar = new SnackBar(
              content: new Text(
                  "Dodawanie akcji nie powiodło się. Spróbuj ponownie.".i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      } catch (e) {
        print(e.toString());
        setState(() {
          fieldsValidationMessage = null;
          _load = false;
        });
        if (e.toString().contains("TimeoutException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd dodawania akcji. Sprawdź połączenie z serwerem i spróbuj ponownie."
                      .i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
        if (e.toString().contains("SocketException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd dodawania akcji. Adres serwera nieprawidłowy.".i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      }
    }
  }
}
