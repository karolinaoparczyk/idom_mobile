import 'dart:convert';
import 'package:alarmclock/alarmclock.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idom/dialogs/driver_action_dialog.dart';
import 'package:idom/enums/driver_actions.dart';
import 'package:idom/pages/drivers/driver_details.dart';
import 'package:idom/utils/login_procedures.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';
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

/// allows editing action
class EditAction extends StatefulWidget {
  EditAction(
      {@required this.storage,
      @required this.action,
      this.testApi,
      this.testStartTime,
      this.testEndTime});

  /// internal storage
  final SecureStorage storage;

  /// selected action
  final SensorDriverAction action;

  /// api used for tests
  final Api testApi;
  final String testStartTime;
  final String testEndTime;

  /// handles state of widgets
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
  TextEditingController _driverActionController = TextEditingController();
  Sensor selectedSensor;
  Driver selectedDriver;
  String selectedDriverAction;
  TimeOfDay startTime;
  TimeOfDay endTime;
  Api api = Api();
  bool _load;
  bool setAlarm = false;
  List<Sensor> sensors = List<Sensor>();
  List<Driver> drivers = List<Driver>();
  String fieldsValidationMessage;
  String selectedOperator;
  List<bool> daysOfWeekSelected = List<bool>();
  String selectDriverMessage;
  Color _currentColor;
  Color _shadedColor;
  double _colorSliderPosition = 255;
  double _shadeSliderPosition = (255 / 2);
  final List<Color> _colors = [
    Color.fromARGB(255, 255, 0, 0),
    Color.fromARGB(255, 255, 128, 0),
    Color.fromARGB(255, 255, 255, 0),
    Color.fromARGB(255, 128, 255, 0),
    Color.fromARGB(255, 0, 255, 0),
    Color.fromARGB(255, 0, 255, 128),
    Color.fromARGB(255, 0, 255, 255),
    Color.fromARGB(255, 0, 128, 255),
    Color.fromARGB(255, 0, 0, 255),
    Color.fromARGB(255, 127, 0, 255),
    Color.fromARGB(255, 255, 0, 255),
    Color.fromARGB(255, 255, 0, 127),
    Color.fromARGB(255, 128, 128, 128),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }

    LoginProcedures.init(widget.storage, api);

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
      selectedOperator = Operators.values.firstWhere(
          (element) => element.contains(widget.action.operator.toString()));
      _sensorTriggerOperatorController =
          TextEditingController(text: selectedOperator.i18n);
    }
    var lang = I18n.locale.languageCode;
    var start = DateTime.parse("2020-12-21 " + widget.action.startTime);
    var formattedStart = DateFormat.jm(lang).format(start);
    _startTimeController = TextEditingController(text: formattedStart);
    startTime = TimeOfDay(
        hour: int.parse(widget.action.startTime.split(":")[0]),
        minute: int.parse(widget.action.startTime.split(":")[1]));
    if (widget.action.endTime != null) {
      var end = DateTime.parse("2020-12-21 " + widget.action.endTime);
      var formattedEnd = DateFormat.jm(lang).format(end);
      _endTimeController = TextEditingController(text: formattedEnd);
      endTime = TimeOfDay(
          hour: int.parse(widget.action.endTime.split(":")[0]),
          minute: int.parse(widget.action.endTime.split(":")[1]));
    }
    for (int i = 0; i < 7; i++) {
      if (widget.action.days.contains(i.toString())) {
        daysOfWeekSelected.add(true);
      } else {
        daysOfWeekSelected.add(false);
      }
    }
    if (widget.testStartTime != null) {
      start = DateTime.parse("2020-12-21 " + widget.testStartTime);
      formattedStart = DateFormat.jm(lang).format(start);
      _startTimeController = TextEditingController(text: formattedStart);
      startTime = TimeOfDay(
          hour: int.parse(widget.testStartTime.split(":")[0]),
          minute: int.parse(widget.testStartTime.split(":")[1]));
      _startTimeController = TextEditingController(text: widget.testStartTime);
      if (widget.testEndTime != null) {
        var end = DateTime.parse("2020-12-21 " + widget.testEndTime);
        var formattedEnd = DateFormat.jm(lang).format(end);
        _endTimeController = TextEditingController(text: formattedEnd);
        endTime = TimeOfDay(
            hour: int.parse(widget.testEndTime.split(":")[0]),
            minute: int.parse(widget.testEndTime.split(":")[1]));
      } else {
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
          selectedDriver = drivers
              .firstWhere((element) => element.name == widget.action.driver);
          getAction();
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
            borderSide:
                BorderSide(color: Theme.of(context).textTheme.bodyText2.color),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
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
        labelText: "Akcja".i18n,
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
          if (action['value'] == "set_brightness") {
            _colorSliderPosition = 255;
            _currentColor = _calculateSelectedColor(_colorSliderPosition);
          } else if (action['value'] == "set_color") {
            _shadeSliderPosition = 255 / 2;
            _currentColor = _calculateSelectedColor(_shadeSliderPosition);
          }
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
          var now = DateTime.now();
          final TimeOfDay time = await showTimePicker(
            cancelText: "Anuluj".i18n,
            confirmText: "OK",
            helpText: "Wybierz godzinę".i18n,
            builder: (BuildContext context, Widget child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                      primary: IdomColors.additionalColor,
                      surface: Theme.of(context).backgroundColor,
                      onSurface: Theme.of(context).textTheme.bodyText2.color),
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
        labelText: "Koniec".i18n,
        labelStyle: Theme.of(context).textTheme.headline5,
        suffixIcon: endTime == null
            ? Icon(Icons.arrow_drop_down, color: IdomColors.additionalColor)
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
                colorScheme: ColorScheme.light(
                    primary: IdomColors.additionalColor,
                    surface: Theme.of(context).backgroundColor,
                    onSurface: Theme.of(context).textTheme.bodyText2.color),
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
            appBar: AppBar(title: Text("Edytuj akcję".i18n), actions: [
              IconButton(
                  key: Key('saveActionButton'),
                  icon: Icon(Icons.save),
                  onPressed: _verifyChanges)
            ]),
            drawer: IdomDrawer(
                storage: widget.storage,
                testApi: widget.testApi,
                parentWidgetType: "EditAction"),

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (selectedDriverAction == "set_color")
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragStart: (DragStartDetails details) {
                              _colorChangeHandler(details.localPosition.dx);
                            },
                            onHorizontalDragUpdate:
                                (DragUpdateDetails details) {
                              _colorChangeHandler(details.localPosition.dx);
                            },
                            onTapDown: (TapDownDetails details) {
                              _colorChangeHandler(details.localPosition.dx);
                            },
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Container(
                                width: 255,
                                height: 15,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(colors: _colors),
                                ),
                                child: CustomPaint(
                                  painter: SliderIndicatorPainter(
                                      _colorSliderPosition),
                                ),
                              ),
                            ),
                          ),
                        if (selectedDriverAction == "set_brightness")
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragStart: (DragStartDetails details) {
                              _shadeChangeHandler(details.localPosition.dx);
                            },
                            onHorizontalDragUpdate:
                                (DragUpdateDetails details) {
                              _shadeChangeHandler(details.localPosition.dx);
                            },
                            onTapDown: (TapDownDetails details) {
                              _shadeChangeHandler(details.localPosition.dx);
                            },
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Container(
                                width: 255,
                                height: 15,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(colors: [
                                    Colors.black,
                                    _currentColor,
                                    Colors.white
                                  ]),
                                ),
                                child: CustomPaint(
                                  painter: SliderIndicatorPainter(
                                      _shadeSliderPosition),
                                ),
                              ),
                            ),
                          ),
                        if (selectedDriverAction == "set_color" ||
                            selectedDriverAction == "set_brightness")
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SvgPicture.asset(
                                "assets/icons/light_bulb_filled.svg",
                                matchTextDirection: false,
                                alignment: Alignment.centerRight,
                                width: 20,
                                height: 20,
                                color: _shadedColor,
                                key: Key("assets/icons/light_bulb_filled.svg")),
                          ),
                      ],
                    ),
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
                          left: 30, top: 10, right: 30, bottom: 10),
                      child: Container(
                        alignment: Alignment.center,
                        width: 300.0,
                        child: LayoutBuilder(builder: (context, constraints) {
                          return ToggleButtons(
                              constraints:
                                  BoxConstraints.expand(width: 40, height: 30),
                              borderRadius: BorderRadius.circular(30),
                              borderColor: IdomColors.additionalColor,
                              splashColor: Colors.transparent,
                              fillColor: IdomColors.lighten(
                                  IdomColors.additionalColor, 0.2),
                              selectedColor: IdomColors.blackTextLight,
                              children: [
                                Text(
                                  "pn".i18n,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(
                                          color: daysOfWeekSelected[0]
                                              ? IdomColors.whiteTextDark
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .color),
                                ),
                                Text("wt".i18n,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(
                                            color: daysOfWeekSelected[1]
                                                ? IdomColors.whiteTextDark
                                                : Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    .color)),
                                Text("śr".i18n,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(
                                            color: daysOfWeekSelected[2]
                                                ? IdomColors.whiteTextDark
                                                : Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    .color)),
                                Text("czw".i18n,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(
                                            color: daysOfWeekSelected[3]
                                                ? IdomColors.whiteTextDark
                                                : Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    .color)),
                                Text("pt".i18n,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(
                                            color: daysOfWeekSelected[4]
                                                ? IdomColors.whiteTextDark
                                                : Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    .color)),
                                Text("sb".i18n,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(
                                            color: daysOfWeekSelected[5]
                                                ? IdomColors.whiteTextDark
                                                : Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    .color)),
                                Text("nd".i18n,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(
                                            color: daysOfWeekSelected[6]
                                                ? IdomColors.whiteTextDark
                                                : Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    .color)),
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
                    if (endTime == null)
                      Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 50.0),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Checkbox(
                                activeColor: IdomColors.additionalColor,
                                value: setAlarm,
                                onChanged: (bool value) {
                                  setState(() {
                                    setAlarm = value;
                                  });
                                },
                              ),
                              Text("Ustaw budzik".i18n,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(fontWeight: FontWeight.normal))
                            ],
                          )),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 62.0),
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
                  ])),
            )));
  }

  void getAction() {
    Map<String, String> action;
    final actions = DriverActions.getValues(selectedDriver.category);
    switch (selectedDriver.category) {
      case "clicker":
        action = actions.first;
        break;
      case "bulb":
        if (widget.action.action.red != null) {
          action =
              actions.firstWhere((element) => element['value'] == "set_color");
          _currentColor = Color.fromRGBO(widget.action.action.red,
              widget.action.action.green, widget.action.action.blue, 1);
        } else if (widget.action.action.brightness != null) {
          action = actions
              .firstWhere((element) => element['value'] == "set_brightness");
          _currentColor = Colors.black;
          _shadedColor =
              _shadeChangeHandler(widget.action.action.brightness / 100 * 255);
        } else if (widget.action.action.type == "turn") {
          if (widget.action.action.status == "on") {
            action =
                actions.firstWhere((element) => element['value'] == "turn_on");
          } else {
            action =
                actions.firstWhere((element) => element['value'] == "turn_off");
          }
        }
        break;
      case "roller_blind":
        if (widget.action.action.status == "on") {
          action = actions
              .firstWhere((element) => element['value'] == "raise_blinds");
        } else {
          action = actions
              .firstWhere((element) => element['value'] == "lower_blinds");
        }
        break;
    }
    _driverActionController.text = action['text'].i18n;
    selectedDriverAction = action['value'];
    setState(() {});
  }

  _colorChangeHandler(double position) {
    if (position > 255) {
      position = 255;
    }
    if (position < 0) {
      position = 0;
    }
    setState(() {
      _colorSliderPosition = position;
      _currentColor = _calculateSelectedColor(_colorSliderPosition);
      _shadedColor = _calculateShadedColor(_shadeSliderPosition);
    });
  }

  _shadeChangeHandler(double position) {
    if (position > 255) position = 255;
    if (position < 0) position = 0;
    setState(() {
      _shadeSliderPosition = position;
      _shadedColor = _calculateShadedColor(_shadeSliderPosition);
    });
  }

  Color _calculateSelectedColor(double position) {
    double positionInColorArray = (position / 255 * (_colors.length - 1));
    int index = positionInColorArray.truncate();
    double remainder = positionInColorArray - index;
    if (remainder == 0.0) {
      _currentColor = _colors[index];
    } else {
      int redValue = _colors[index].red == _colors[index + 1].red
          ? _colors[index].red
          : (_colors[index].red +
                  (_colors[index + 1].red - _colors[index].red) * remainder)
              .round();
      int greenValue = _colors[index].green == _colors[index + 1].green
          ? _colors[index].green
          : (_colors[index].green +
                  (_colors[index + 1].green - _colors[index].green) * remainder)
              .round();
      int blueValue = _colors[index].blue == _colors[index + 1].blue
          ? _colors[index].blue
          : (_colors[index].blue +
                  (_colors[index + 1].blue - _colors[index].blue) * remainder)
              .round();
      _currentColor = Color.fromARGB(255, redValue, greenValue, blueValue);
    }
    return _currentColor;
  }

  Color _calculateShadedColor(double position) {
    double ratio = position / 255;
    if (ratio > 0.5) {
      int redVal = _currentColor.red != 255
          ? (_currentColor.red +
                  (255 - _currentColor.red) * (ratio - 0.5) / 0.5)
              .round()
          : 255;
      int greenVal = _currentColor.green != 255
          ? (_currentColor.green +
                  (255 - _currentColor.green) * (ratio - 0.5) / 0.5)
              .round()
          : 255;
      int blueVal = _currentColor.blue != 255
          ? (_currentColor.blue +
                  (255 - _currentColor.blue) * (ratio - 0.5) / 0.5)
              .round()
          : 255;
      return Color.fromARGB(255, redVal, greenVal, blueVal);
    } else if (ratio < 0.5) {
      int redVal = _currentColor.red != 0
          ? (_currentColor.red * ratio / 0.5).round()
          : 0;
      int greenVal = _currentColor.green != 0
          ? (_currentColor.green * ratio / 0.5).round()
          : 0;
      int blueVal = _currentColor.blue != 0
          ? (_currentColor.blue * ratio / 0.5).round()
          : 0;
      return Color.fromARGB(255, redVal, greenVal, blueVal);
    } else {
      return _currentColor;
    }
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

  Map<String, dynamic> getActionJson() {
    Map<String, dynamic> action;
    switch (selectedDriverAction) {
      case "click":
        action = {"status": "on"};
        break;
      case "turn_on":
        action = {"type": "turn", "status": "on"};
        break;
      case "turn_off":
        action = {"type": "turn", "status": "off"};
        break;
      case "set_color":
        action = {
          "type": "colour",
          "red": _currentColor.red,
          "green": _currentColor.green,
          "blue": _currentColor.blue
        };
        break;
      case "set_brightness":
        action = {
          "type": "brightness",
          "brightness": (_shadeSliderPosition / 255 * 100).round()
        };
        break;
      case "raise_blinds":
        action = {"status": "on"};
        break;
      case "lower_blinds":
        action = {"status": "off"};
        break;
    }
    return action;
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
    if (_sensorTriggerController.text.contains(",")) {
      trigger =
          double.tryParse(_sensorTriggerController.text.replaceFirst(",", "."));
    } else {
      trigger = double.tryParse(_sensorTriggerController.text);
    }
    trigger = changedTrigger ? trigger : null;
    operator = changedOperator ? selectedOperator.substring(0, 1) : null;

    if (changedSensor && selectedSensor != null) {
      sensor = selectedSensor.name;
    } else if (changedSensor && selectedSensor == null) {
      sensor = null;
      trigger = null;
      operator = null;
    }

    var driver = changedDriver ? selectedDriver.name : null;
    var days = changedDays ? _getDaysSelectedString() : null;
    var action = changedAction ? getActionJson() : null;
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
        await onEditActionSuccess();
      } else if (res['statusCode'] == "401") {
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
          var res = await api.editAction(widget.action.id, body);
          setState(() {
            _load = false;
          });
          if (res['statusCode'] == "200") {
            await onEditActionSuccess();
          } else if (res['statusCode'] == "401") {
            logOut();
          } else if (res['body']
              .contains("Action with provided name already exists")) {
            fieldsValidationMessage =
                "Akcja o podanej nazwie już istnieje.".i18n;
            setState(() {});
            return;
          } else {
            onEditActionError();
          }
        }
      } else if (res['body']
          .contains("Action with provided name already exists")) {
        fieldsValidationMessage = "Akcja o podanej nazwie już istnieje.".i18n;
        setState(() {});
        return;
      } else {
        onEditActionError();
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _load = false;
      });
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd edytowania akcji. Sprawdź połączenie z serwerem i spróbuj ponownie."
                    .i18n));
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

  onEditActionSuccess() async {
    if (endTime == null && setAlarm && widget.testApi == null) {
      await Alarmclock.setAlarm(
        skipui: true,
        hour: startTime.hour,
        minute: startTime.minute,
        message: "akcja".i18n + " " + _nameController.text,
        monday: daysOfWeekSelected[0],
        tuesday: daysOfWeekSelected[1],
        wednesday: daysOfWeekSelected[2],
        thursday: daysOfWeekSelected[3],
        friday: daysOfWeekSelected[4],
        saturday: daysOfWeekSelected[5],
        sunday: daysOfWeekSelected[6],
      );
    }
    Navigator.pop(context, true);
  }

  onEditActionError() {
    final snackBar = new SnackBar(
        content: new Text(
            "Edytowanie akcji nie powiodło się. Spróbuj ponownie.".i18n));
    _scaffoldKey.currentState.showSnackBar((snackBar));
  }

  Future<void> logOut() async {
    displayProgressDialog(
        context: _scaffoldKey.currentContext,
        key: _keyLoader,
        text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
    await new Future.delayed(const Duration(seconds: 3));
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    await widget.storage.resetUserData();
    Navigator.of(context).popUntil((route) => route.isFirst);
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
      trigger = _sensorTriggerController.text;
      operator = selectedOperator.substring(0, 1);
    }
    var driver = selectedDriver.name;
    var days = _getDaysSelectedString();
    var action = "action";
    var flag = _getFlag();
    var startHour = startTime.hour;
    var startMinute = startTime.minute.toString().length == 1
        ? "0" + startTime.minute.toString()
        : startTime.minute.toString();
    var start = "$startHour:$startMinute";
    var end = "";
    if (endTime != null) {
      var endHour = endTime.hour;
      var endMinute = endTime.minute.toString().length == 1
          ? "0" + endTime.minute.toString()
          : endTime.minute.toString();
      end = "$endHour:$endMinute";
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
        final snackBar = new SnackBar(
            content: new Text("Nie wprowadzono żadnych zmian.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }
}
