import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/choose_driver_dialog.dart';
import 'package:idom/dialogs/choose_sensor_dialog.dart';
import 'package:idom/dialogs/choose_sensor_trigger_operator.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/enums/operators.dart';
import 'package:idom/models.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/localization/actions/edit_action.i18n.dart';

class EditAction extends StatefulWidget {
  EditAction(
      {@required this.storage,
      @required this.action,
      this.testApi,
      this.testStartTime,
      this.testEndTime});

  final SecureStorage storage;
  final SensorDriverAction action;
  final Api testApi;
  final String testStartTime;
  final String testEndTime;

  @override
  _EditActionState createState() => _EditActionState();
}

class _EditActionState extends State<EditAction> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final FocusNode _sensorFocusNode = FocusNode();
  final FocusNode _endTimeFocusNode = FocusNode();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _sensorController = TextEditingController();
  TextEditingController _driverController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();
  TextEditingController _sensorTriggerController = TextEditingController();
  TextEditingController _sensorTriggerOperatorController =
      TextEditingController();
  Sensor selectedSensor;
  Driver selectedDriver;
  TimeOfDay startTime;
  TimeOfDay endTime;
  Api api = Api();
  bool _load;
  List<Sensor> sensors = List<Sensor>();
  List<Driver> drivers = List<Driver>();
  String fieldsValidationMessage;
  String selectedOperator;
  List<bool> daysOfWeekSelected = List<bool>();

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }
    getSensors();
    getDrivers();
    _load = false;
    if (widget.action.sensor != null) {
      _sensorController.text = widget.action.sensor;
    }
    _driverController.text = widget.action.driver;
    _nameController.text = widget.action.name;
    if (widget.action.trigger != null) {
      _sensorTriggerController =
          TextEditingController(text: widget.action.trigger.toString());
    }
    if (widget.action.operator != null) {
      selectedOperator = Operators.values.firstWhere((element) =>
          element.contains(widget.action.operator.toString()));
      _sensorTriggerOperatorController = TextEditingController(
          text: selectedOperator.i18n);
    }
    startTime = TimeOfDay(
        hour: int.parse(widget.action.startTime.split(":")[0]),
        minute: int.parse(widget.action.startTime.split(":")[1]));
    _startTimeController = TextEditingController(text: widget.action.startTime);
    if (widget.action.endTime != null) {
      endTime = TimeOfDay(
          hour: int.parse(widget.action.endTime.split(":")[0]),
          minute: int.parse(widget.action.endTime.split(":")[1]));
      _endTimeController = TextEditingController(text: widget.action.endTime);
    }
    for (int i = 0; i < 7; i++) {
      if (widget.action.days.contains(i.toString())) {
        daysOfWeekSelected.add(true);
      } else {
        daysOfWeekSelected.add(false);
      }
    }
    if (widget.testStartTime != null) {
      startTime = TimeOfDay(
          hour: int.parse(widget.testStartTime.split(":")[0]),
          minute: int.parse(widget.testStartTime.split(":")[1]));
      _startTimeController =
          TextEditingController(text: widget.testStartTime);
      if (widget.testEndTime != null){
      endTime = TimeOfDay(
          hour: int.parse(widget.testEndTime.split(":")[0]),
            minute: int.parse(widget.testEndTime.split(":")[1]));
        _endTimeController = TextEditingController(text: widget.testEndTime);}
      else{
        endTime = null;
        _endTimeController = TextEditingController(text: "");
      }
    }
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
  Future<void> getSensors() async {
    try {
      /// gets sensors
      var res = await api.getSensors();

      if (res != null && res['statusCodeSensors'] == "200") {
        List<dynamic> bodySensors = jsonDecode(res['bodySensors']);
        setState(() {
          sensors =
              bodySensors.map((dynamic item) => Sensor.fromJson(item)).toList();
          selectedSensor = sensors
              .firstWhere((element) => element.name == widget.action.sensor);
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
                "Błąd pobierania czujników. Sprawdź połączenie z serwerem i spróbuj ponownie.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania czujników. Adres serwera nieprawidłowy.".i18n));
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
          selectedDriver = drivers
              .firstWhere((element) => element.name == widget.action.driver);
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
                "Błąd pobierania sterowników. Sprawdź połączenie z serwerem i spróbuj ponownie.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania sterowników. Adres serwera nieprawidłowy.".i18n));
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  child: Icon(Icons.close, color: IdomColors.brightGrey)),
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
            appBar: AppBar(title: Text("Edytuj akcję".i18n), actions: [
              IconButton(
                  key: Key('saveActionButton'),
                  icon: Icon(Icons.save),
                  onPressed: _verifyChanges)
            ]),
            drawer: IdomDrawer(
                storage: widget.storage,
                parentWidgetType: "EditAction",
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
              "Godzina zakończenia musi być późniejsza od godziny rozpoczęcia.".i18n;
        });
      } else {
        setState(() {
          fieldsValidationMessage = null;
        });
      }
    }
    return isCorrect;
  }

  /// saves changes after form fields validation
  _saveChanges(
      {bool changedName,
      bool changedSensor,
      bool changedTrigger,
      bool changedOperator,
      bool changedDays,
      bool changedAction,
      bool changedFlag,
      bool changedDriver,
      bool changedStartTime,
      bool changedEndTime}) async {
    FocusScope.of(context).unfocus();
    var name = changedName ? _nameController.text : null;
    var sensor;
    var trigger;
    var operator;
    trigger =
        changedTrigger ? int.tryParse(_sensorTriggerController.text) : null;
    operator = !changedOperator
        ? null
        : selectedOperator != null
            ? selectedOperator.substring(0, 1)
            : null;

    if (changedSensor && selectedSensor != null) {
      sensor = selectedSensor.name;
    } else if (changedSensor && selectedSensor == null) {
      sensor = null;
      trigger = null;
      operator = null;
    }

    var driver = changedDriver ? selectedDriver.name : null;
    var days = changedDays ? _getDaysSelectedString() : null;
    var action = changedAction ? "action" : null;
    var flag = changedFlag ? _getFlag() : null;
    var start =
        changedStartTime ? "${startTime.hour}:${startTime.minute}" : null;
    var end;
    if (changedEndTime && endTime != null) {
      end = "${endTime.hour}:${endTime.minute}";
    } else if (changedEndTime && endTime != null) {
      end = "";
    }
    setState(() {
      _load = true;
    });

    Map<String, dynamic> body;

    if (changedSensor && changedEndTime) {
      body = {
        "name": name,
        "sensor": sensor,
        "trigger": trigger,
        "operator": operator,
        "driver": driver,
        "days": days,
        "action": action,
        "flag": flag,
        "start_event": start,
        "end_event": end,
      };
      if (selectedSensor == null && end == null) {
        body.removeWhere((key, value) =>
            value == null &&
            key != "sensor" &&
            key != "trigger" &&
            key != "operator" &&
            key != "end_event");
      } else if (selectedSensor == null) {
        body.removeWhere((key, value) =>
            value == null &&
            key != "sensor" &&
            key != "trigger" &&
            key != "operator");
      } else if (end == null) {
        body.removeWhere((key, value) => value == null && key != "end_event");
      } else {
        body.removeWhere((key, value) => value == null);
      }
    } else if (changedSensor) {
      body = {
        "name": name,
        "sensor": sensor,
        "trigger": trigger,
        "operator": operator,
        "driver": driver,
        "days": days,
        "action": action,
        "flag": flag,
        "start_event": start,
      };
      if (selectedSensor == null) {
        body.removeWhere((key, value) =>
            value == null &&
            key != "sensor" &&
            key != "trigger" &&
            key != "operator");
      } else {
        body.removeWhere((key, value) => value == null);
      }
    } else if (changedEndTime) {
      body = {
        "name": name,
        "driver": driver,
        "days": days,
        "action": action,
        "flag": flag,
        "start_event": start,
        "end_event": end,
      };
      if (end == null) {
        body.removeWhere((key, value) => value == null && key != "end_event");
      } else {
        body.removeWhere((key, value) => value == null);
      }
    } else {
      body = {
        "name": name,
        "trigger": trigger,
        "operator": operator,
        "driver": driver,
        "days": days,
        "action": action,
        "flag": flag,
        "start_event": start,
      };
      body.removeWhere((key, value) => value == null);
    }

    try {
      var res = await api.editAction(widget.action.id, body);
      setState(() {
        _load = false;
      });
      if (res['statusCode'] == "200") {
        Navigator.pop(context, true);
      } else if (res['statusCode'] == "401") {
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
      }  else {
        final snackBar = new SnackBar(
            content: new Text(
                "Edytowanie akcji nie powiodło się. Spróbuj ponownie.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _load = false;
      });
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd edytowania akcji. Sprawdź połączenie z serwerem i spróbuj ponownie.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd edytowania akcji. Adres serwera nieprawidłowy.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }

  /// confirms saving account changes
  _confirmSavingChanges(
      {bool changedName,
      bool changedSensor,
      bool changedTrigger,
      bool changedOperator,
      bool changedDriver,
      bool changedDays,
      bool changedAction,
      bool changedFlag,
      bool changedStartTime,
      bool changedEndTime}) async {
    var decision = await confirmActionDialog(
        context, "Potwierdź".i18n, "Czy na pewno zapisać zmiany?".i18n);
    if (decision) {
      await _saveChanges(
          changedName: changedName,
          changedSensor: changedSensor,
          changedTrigger: changedTrigger,
          changedOperator: changedOperator,
          changedDriver: changedDriver,
          changedDays: changedDays,
          changedAction: changedAction,
          changedFlag: changedFlag,
          changedStartTime: changedStartTime,
          changedEndTime: changedEndTime);
    }
  }

  String _getDaysSelectedString() {
    var daysList = [];
    for (int i = 0; i < daysOfWeekSelected.length; i++) {
      if (daysOfWeekSelected[i]) {
        daysList.add(i);
      }
    }
    var daysString = daysList.join(", ");
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

  /// verifies data changes
  _verifyChanges() async {
    var name = _nameController.text;
    var sensor;
    var trigger;
    var operator;
    if (selectedSensor != null) {
      sensor = selectedSensor.name;
      trigger = int.tryParse(_sensorTriggerController.text);
      operator = selectedOperator.substring(0, 1);
    }
    var driver = selectedDriver.name;
    var days = _getDaysSelectedString();
    var action = "action";
    var flag = _getFlag();
    var start = "${startTime.hour}:${startTime.minute}";
    var end = "";
    if (endTime != null) {
      end = "${endTime.hour}:${endTime.minute}";
    }

    var changedName = false;
    var changedSensor = false;
    var changedTrigger = false;
    var changedOperator = false;
    var changedDriver = false;
    var changedDays = false;
    var changedAction = false;
    var changedFlag = false;
    var changedStartTime = false;
    var changedEndTime = false;

    final formState = _formKey.currentState;
    var timeValidated = _validateTime();
    if (formState.validate() && timeValidated) {
      /// sends request only if data changed
      if (name != widget.action.name) {
        changedName = true;
      }
      if (sensor != widget.action.sensor) {
        changedSensor = true;
      }
      if (trigger != widget.action.trigger) {
        changedTrigger = true;
      }
      if (operator != widget.action.operator) {
        changedOperator = true;
      }
      if (driver != widget.action.driver) {
        changedDriver = true;
      }
      if (days != widget.action.days) {
        changedDays = true;
      }
      if (action != widget.action.action) {
        changedAction = true;
      }
      if (flag != widget.action.flag) {
        changedFlag = true;
      }
      if (start != widget.action.startTime) {
        changedStartTime = true;
      }
      if (end != widget.action.endTime) {
        changedEndTime = true;
      }

      if (changedName ||
          changedSensor ||
          changedTrigger ||
          changedOperator ||
          changedDriver ||
          changedDays ||
          changedAction ||
          changedFlag ||
          changedStartTime ||
          changedEndTime) {
        await _confirmSavingChanges(
            changedName: changedName,
            changedSensor: changedSensor,
            changedTrigger: changedTrigger,
            changedOperator: changedOperator,
            changedDriver: changedDriver,
            changedDays: changedDays,
            changedAction: changedAction,
            changedFlag: changedFlag,
            changedStartTime: changedStartTime,
            changedEndTime: changedEndTime);
      } else {
        final snackBar =
            new SnackBar(content: new Text("Nie wprowadzono żadnych zmian.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }
}
