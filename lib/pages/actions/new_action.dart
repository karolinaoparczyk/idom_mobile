import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/choose_driver_dialog.dart';
import 'package:idom/dialogs/choose_sensor_dialog.dart';
import 'package:idom/dialogs/choose_sensor_trigger_operator.dart';
import 'package:idom/dialogs/driver_action_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/localization/actions/new_action.i18n.dart';

/// allowing adding a new action
class NewAction extends StatefulWidget {
  NewAction({@required this.storage, this.testApi});

  /// internal storage
  final SecureStorage storage;

  /// api used for tests
  final Api testApi;

  /// handles state of widgets
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
  TextEditingController _driverActionController;
  Sensor selectedSensor;
  Driver selectedDriver;
  String selectedDriverAction;
  TimeOfDay startTime;
  TimeOfDay endTime;
  Api api = Api();
  bool _load;
  List<Sensor> sensors = List<Sensor>();
  List<Driver> drivers = List<Driver>();
  String fieldsValidationMessage;
  String selectedOperator;
  List<bool> daysOfWeekSelected = [true, true, true, true, true, true, true];
  bool setAlarm = false;
  String selectDriverMessage;

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
    _driverActionController = TextEditingController();
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
    _driverActionController.dispose();
    super.dispose();
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
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).textTheme.bodyText2.color),
                borderRadius: BorderRadius.circular(10.0)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).textTheme.bodyText2.color),
              borderRadius: BorderRadius.circular(10.0),
            )),
        key: Key('name'),
        style: Theme.of(context).textTheme.bodyText2,
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
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).textTheme.bodyText2.color),
            borderRadius: BorderRadius.circular(10.0)),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).textTheme.bodyText2.color),
          borderRadius: BorderRadius.circular(10.0),
        ),
        labelText: "Czujnik".i18n,
        labelStyle: Theme.of(context).textTheme.headline5,
        suffixIcon: selectedSensor == null
            ? Icon(Icons.arrow_drop_down, color: IdomColors.additionalColor)
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
                child: Icon(Icons.close, color: IdomColors.additionalColor)),
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
      style: Theme.of(context).textTheme.bodyText2,
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
          style: Theme.of(context).textTheme.bodyText2,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).textTheme.bodyText2.color),
                borderRadius: BorderRadius.circular(10.0)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).textTheme.bodyText2.color),
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
        suffixIcon:
            Icon(Icons.arrow_drop_down, color: IdomColors.additionalColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).textTheme.bodyText2.color),
            borderRadius: BorderRadius.circular(10.0)),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).textTheme.bodyText2.color),
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
      style: Theme.of(context).textTheme.bodyText2,
    );
  }

  /// builds driver action field
  Widget _buildDriverActionField() {
    return TextFormField(
      key: Key("driverAction"),
      controller: _driverActionController,
      decoration: InputDecoration(
        labelText: "Akcja",
        labelStyle: Theme.of(context).textTheme.headline5,
        suffixIcon:
            Icon(Icons.arrow_drop_down, color: IdomColors.additionalColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).textTheme.bodyText2.color),
            borderRadius: BorderRadius.circular(10.0)),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).textTheme.bodyText2.color),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onTap: () async {
        if (selectedDriver == null) {
          setState(() {
            selectDriverMessage = "Wybierz sterownik";
          });
          return;
        }
        final Map<String, String> action = await showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: DriverActionDialog(
                  currentAction: selectedDriverAction,
                  driverCategory: selectedDriver.category,
                ),
              );
            });
        if (action != null) {
          _driverActionController.text = action['text'].i18n;
          selectedDriverAction = action['value'];
          setState(() {});
        }
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: DriverActionFieldValidator.validate,
      readOnly: true,
      style: Theme.of(context).textTheme.bodyText2,
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
          suffixIcon:
              Icon(Icons.arrow_drop_down, color: IdomColors.additionalColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).textTheme.bodyText2.color),
              borderRadius: BorderRadius.circular(10.0)),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).textTheme.bodyText2.color),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onTap: () async {
          final Driver driver = await showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: ChooseDriverDialog(
                      drivers: drivers
                          .where(
                              (element) => element.category != "remote_control")
                          .toList(),
                      currentDriver: selectedDriver),
                );
              });
          if (driver != null) {
            _driverController.text = driver.name;
            selectedDriver = driver;
            selectedDriverAction = null;
            _driverActionController.text = "";
            selectDriverMessage = null;
            setState(() {});
          }
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        readOnly: true,
        style: Theme.of(context).textTheme.bodyText2,
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
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).textTheme.bodyText2.color),
                borderRadius: BorderRadius.circular(10.0)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).textTheme.bodyText2.color),
              borderRadius: BorderRadius.circular(10.0),
            )),
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
            var period = time.period;
            print(period);
            startTime = time;
            _startTimeController.text = "${startTime.format(context)}";
            setState(() {});
          }
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        readOnly: true,
        style: Theme.of(context).textTheme.bodyText2,
        validator: TimeFieldValidator.validate);
  }

  /// builds end time field
  Widget _buildEndTimeField() {
    return TextFormField(
      key: Key("endTimeButton"),
      controller: _endTimeController,
      focusNode: _endTimeFocusNode,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).textTheme.bodyText2.color),
            borderRadius: BorderRadius.circular(10.0)),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).textTheme.bodyText2.color),
          borderRadius: BorderRadius.circular(10.0),
        ),
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
          initialTime: endTime ?? TimeOfDay(hour: now.hour, minute: now.minute),
        );
        if (time != null) {
          endTime = time;
          _endTimeController.text = "${endTime.format(context)}";
          setState(() {});
        }
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      readOnly: true,
      style: Theme.of(context).textTheme.bodyText2,
    );
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
                storage: widget.storage, parentWidgetType: "NewAction"),

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
                                          .bodyText1),
                                ),
                              ],
                            ))),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 62.0, top: 10.0, right: 62.0, bottom: 0.0),
                        child: _buildName()),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 62.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildDriverField())),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 62.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildDriverActionField())),
                    AnimatedCrossFade(
                      crossFadeState: selectDriverMessage != null
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 300),
                      firstChild: selectDriverMessage != null
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 62.0),
                              child: Text(selectDriverMessage,
                                  style: Theme.of(context).textTheme.subtitle1),
                            )
                          : SizedBox(),
                      secondChild: SizedBox(),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 62.0),
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
                                            .bodyText1),
                                  ),
                                ],
                              ))),
                    if (selectedSensor != null)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 62.0),
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
                                          .bodyText1),
                                ),
                              ],
                            ))),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 60, top: 10, right: 60, bottom: 10),
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
                              selectedColor:
                                  Theme.of(context).textTheme.bodyText2.color,
                              children: [
                                Text("pn".i18n,
                                    style:
                                        Theme.of(context).textTheme.subtitle1),
                                Text("wt".i18n,
                                    style:
                                        Theme.of(context).textTheme.subtitle1),
                                Text("śr".i18n,
                                    style:
                                        Theme.of(context).textTheme.subtitle1),
                                Text("czw".i18n,
                                    style:
                                        Theme.of(context).textTheme.subtitle1),
                                Text("pt".i18n,
                                    style:
                                        Theme.of(context).textTheme.subtitle1),
                                Text("sb".i18n,
                                    style:
                                        Theme.of(context).textTheme.subtitle1),
                                Text("nd".i18n,
                                    style:
                                        Theme.of(context).textTheme.subtitle1),
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
                    // if (endTime == null)
                    //   Container(
                    //       padding: EdgeInsets.symmetric(
                    //           vertical: 0.0, horizontal: 30.0),
                    //       alignment: Alignment.centerLeft,
                    //       child: Row(
                    //         children: [
                    //           Checkbox(
                    //             activeColor: IdomColors.additionalColor,
                    //             value: setAlarm,
                    //             onChanged: (bool value) {
                    //               setState(() {
                    //                 setAlarm = value;
                    //               });
                    //             },
                    //           ),
                    //           Text("Ustaw budzik".i18n,
                    //               style: Theme.of(context)
                    //                   .textTheme
                    //                   .bodyText1
                    //                   .copyWith(fontWeight: FontWeight.normal))
                    //         ],
                    //       )),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 62.0),
                        child: Row(
                          children: [
                            Flexible(flex: 1, child: _buildStartTimeField()),
                            SizedBox(width: 10),
                            Flexible(flex: 1, child: _buildEndTimeField())
                          ],
                        )),
                    AnimatedCrossFade(
                      crossFadeState: fieldsValidationMessage != null
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 300),
                      firstChild: fieldsValidationMessage != null
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 62.0),
                              child: Text(fieldsValidationMessage,
                                  style: Theme.of(context).textTheme.subtitle1),
                            )
                          : SizedBox(),
                      secondChild: SizedBox(),
                    ),
                  ])),
            )));
  }

  _validateTime() {
    bool isCorrect = true;
    if (startTime != null && endTime != null) {
      var startHour = startTime.hour;
      var endHour = endTime.hour;
      double _doubleStartTime =
          startHour.toDouble() + (startTime.minute.toDouble() / 60);
      double _doubleEndTime =
          endHour.toDouble() + (endTime.minute.toDouble() / 60);
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
        if (fieldsValidationMessage != null) {
          fieldsValidationMessage +=
              "Należy wybrać przynajmniej jeden dzień działania akcji.".i18n;
        } else {
          fieldsValidationMessage =
              "Należy wybrać przynajmniej jeden dzień działania akcji.".i18n;
        }
      });
      return null;
    } else {
      setState(() {
        if (fieldsValidationMessage != null &&
            !(fieldsValidationMessage.contains("rozpoczęcia") ||
                fieldsValidationMessage.contains("start"))) {
          fieldsValidationMessage = null;
        }
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

  Map<String, dynamic> getActionJson() {
    Map<String, dynamic> action;
    switch (selectedDriverAction) {
      case "click":
        action = {"status": true};
        break;
      case "turn_on":
        action = {"type": "turn", "status": true};
        break;
      case "turn_off":
        action = {"type": "turn", "status": true};
        break;
      case "set_color":
        action = {"type": "colour", "red": 0, "green": 0, "blue": 0};
        break;
      case "set_brightness":
        action = {"type": "brightness", "brightness": 0};
        break;
      case "raise_blinds":
        action = {"status": true};
        break;
      case "lower_blinds":
        action = {"status": false};
        break;
    }
    return action;
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
          var endHour = endTime.hour;
          var endMinute = endTime.minute.toString().length == 1
              ? "0" + endTime.minute.toString()
              : endTime.minute.toString();
          endTimeString = "$endHour:$endMinute";
        }
        var startTimeString;
        var startHour = startTime.hour;
        var startMinute = startTime.minute.toString().length == 1
            ? "0" + startTime.minute.toString()
            : startTime.minute.toString();
        startTimeString = "$startHour:$startMinute";
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
        // if (endTime == null && setAlarm) {
        //   await Alarmclock.setAlarm(
        //       hour: startTime.hour,
        //       minute: startTime.minute,
        //       message: "akcja".i18n + _nameController.text);
        // }

        var res = await api.addAction(
            _nameController.text,
            sensor,
            trigger,
            operator,
            selectedDriver.name,
            daysString,
            startTimeString,
            endTimeString,
            jsonEncode(getActionJson()),
            _getFlag());
        setState(() {
          _load = false;
        });
        if (res['statusCode'] == "201") {
          if (endTime == null && setAlarm) {
            var daysList = [];
            for (int i = 0; i < daysOfWeekSelected.length; i++) {
              if (daysOfWeekSelected[i]) {
                daysList.add(i);
              }
            }
            // await Alarmclock.setAlarm(
            //     hour: startTime.hour,
            //     minute: startTime.minute,
            //     message: "akcja".i18n + " ${_nameController.text}");
          }
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
          fieldsValidationMessage = "Akcja o podanej nazwie już istnieje.".i18n;
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
