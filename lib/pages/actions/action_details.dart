import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/utils/login_procedures.dart';
import 'package:intl/intl.dart';

import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/actions/edit_action.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/localization/actions/action_details.i18n.dart';

/// displays action details
class ActionDetails extends StatefulWidget {
  ActionDetails({@required this.storage, @required this.action, this.testApi});

  /// internal storage
  final SecureStorage storage;

  /// selected action
  SensorDriverAction action;

  /// api used for tests
  final Api testApi;

  /// handles state of widgets
  @override
  _ActionDetailsState createState() => new _ActionDetailsState();
}

class _ActionDetailsState extends State<ActionDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoaderInvalidToken = new GlobalKey<State>();
  Api api = Api();
  bool _load;
  Driver driver;
  Color setColor;

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }

    LoginProcedures.init(widget.storage, api);

    _load = false;
  }

  Future<bool> _onBackButton() async {
    Navigator.pop(context);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackButton,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(title: Text(widget.action.name), actions: [
              IconButton(
                  key: Key("editAction"),
                  icon: Icon(Icons.edit),
                  onPressed: _navigateToEditAction)
            ]),
            drawer: IdomDrawer(
                storage: widget.storage,
                testApi: widget.testApi,
                parentWidgetType: "ActionDetails"),
            body: SingleChildScrollView(
                child: Form(
              key: _formKey,
              child: AnimatedContainer(
                curve: Curves.easeInToLinear,
                duration: Duration(
                  milliseconds: 10,
                ),
                alignment: Alignment.topCenter,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                              ),
                            ],
                          ))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 62, top: 10.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Nazwa".i18n,
                              style: Theme.of(context).textTheme.headline5))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 62, top: 0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(widget.action.name,
                              style: Theme.of(context).textTheme.bodyText2))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 62, top: 10.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Sterownik".i18n,
                              style: Theme.of(context).textTheme.headline5))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 62, top: 0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(widget.action.driver,
                              style: Theme.of(context).textTheme.bodyText2))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 62, top: 10.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Akcja".i18n,
                              style: Theme.of(context).textTheme.headline5))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 62, top: 0, right: 30.0, bottom: 0.0),
                      child: Row(
                        children: [
                          Text(getAction(),
                              style: Theme.of(context).textTheme.bodyText2),
                          if (widget.action.action.brightness != null ||
                              widget.action.action.red != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: SvgPicture.asset(
                                  "assets/icons/light_bulb_filled.svg",
                                  matchTextDirection: false,
                                  alignment: Alignment.centerRight,
                                  width: 20,
                                  height: 20,
                                  color: setColor,
                                  key: Key(
                                      "assets/icons/light_bulb_filled.svg")),
                            ),
                        ],
                      )),
                  if (widget.action.sensor != null)
                    Padding(
                        padding: EdgeInsets.only(
                            left: 62, top: 10.0, right: 30.0, bottom: 0.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Czujnik".i18n,
                                style: Theme.of(context).textTheme.headline5))),
                  if (widget.action.sensor != null)
                    Padding(
                        padding: EdgeInsets.only(
                            left: 62, top: 0, right: 30.0, bottom: 0.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(widget.action.sensor,
                                style: Theme.of(context).textTheme.bodyText2))),
                  if (widget.action.sensor != null)
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
                                  child: Text("Wyzwalacz".i18n,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1),
                                ),
                              ],
                            ))),
                  if (widget.action.sensor != null)
                    Padding(
                        padding: EdgeInsets.only(
                            left: 62, top: 10.0, right: 30.0, bottom: 0.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Wartość z czujnika".i18n,
                                style: Theme.of(context).textTheme.headline5))),
                  if (widget.action.sensor != null)
                    Padding(
                        padding: EdgeInsets.only(
                            left: 62, top: 0, right: 30.0, bottom: 0.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                "${widget.action.operator} ${_getTriggerValue()}",
                                style: Theme.of(context).textTheme.bodyText2))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 20.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(Icons.access_time, size: 21),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text("Czas działania akcji".i18n,
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                              ),
                            ],
                          ))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 62, top: 10.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Dni tygodnia".i18n,
                              style: Theme.of(context).textTheme.headline5))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 62, top: 0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_getDays(),
                              style: Theme.of(context).textTheme.bodyText2))),
                  if (widget.action.endTime == null)
                    Padding(
                        padding: EdgeInsets.only(
                            left: 62, top: 10.0, right: 30.0, bottom: 0.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Godzina".i18n,
                                style: Theme.of(context).textTheme.headline5))),
                  if (widget.action.endTime != null)
                    Padding(
                        padding: EdgeInsets.only(
                            left: 62, top: 10.0, right: 30.0, bottom: 0.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Godziny".i18n,
                                style: Theme.of(context).textTheme.headline5))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 62, top: 0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_getHours(),
                              style: Theme.of(context).textTheme.bodyText2))),
                ]),
              ),
            ))));
  }

  String getAction() {
    String action = "";
    if (widget.action.action.status != null) {
      if (widget.action.action.status == "on") {
        action = "Włącz".i18n;
      } else {
        action = "Wyłącz".i18n;
      }
    } else if (widget.action.action.brightness != null) {
      int brightness = widget.action.action.brightness;
      setColor =
          _calculateShadedColor((brightness / 100 * 255).roundToDouble());
      action = "Ustaw jasność".i18n + ": $brightness";
    } else if (widget.action.action.red != null) {
      int red = widget.action.action.red;
      int green = widget.action.action.green;
      int blue = widget.action.action.blue;
      setColor = Color.fromRGBO(red, green, blue, 1);
      action = "Ustaw kolor".i18n;
    }

    setState(() {});
    return action;
  }

  Color _calculateShadedColor(double position) {
    Color _currentColor = Colors.black;
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

  String _getTriggerValue() {
    var doubleTrigger = double.parse(widget.action.trigger.toString());
    return doubleTrigger.toStringAsFixed(2);
  }

  String _getDays() {
    var daysList = widget.action.days.split(",");
    var daysString = "";
    for (int i = 0; i < daysList.length; i++) {
      var dayInt = int.parse(daysList[i]);
      switch (dayInt) {
        case 0:
          daysString += "pn".i18n;
          break;
        case 1:
          daysString += "wt".i18n;
          break;
        case 2:
          daysString += "śr".i18n;
          break;
        case 3:
          daysString += "czw".i18n;
          break;
        case 4:
          daysString += "pt".i18n;
          break;
        case 5:
          daysString += "sb".i18n;
          break;
        case 6:
          daysString += "nd".i18n;
          break;
      }
      if (i < daysList.length - 1) {
        daysString += ", ";
      }
    }
    return daysString;
  }

  _getHours() {
    var start = DateTime.parse("2020-12-21 " + widget.action.startTime);
    var lang = I18n.locale.languageCode;

    if (widget.action.endTime != null) {
      var end = DateTime.parse("2020-12-21 " + widget.action.endTime);
      var string =
          "${DateFormat.jm(lang).format(start)} - ${DateFormat.jm(lang).format(end)}";
      return string;
    } else {
      return "${DateFormat.jm(lang).format(start)}";
    }
  }

  _navigateToEditAction() async {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditAction(
                  storage: widget.storage,
                  action: widget.action,
                  testApi: widget.testApi,
                ),
            fullscreenDialog: true));
    if (result == true) {
      final snackBar = new SnackBar(content: new Text("Zapisano akcję.".i18n));
      _scaffoldKey.currentState.showSnackBar((snackBar));
      await _refreshActionDetails();
    }
  }

  _refreshActionDetails() async {
    try {
      setState(() {
        _load = true;
      });
      var res = await api.getActionDetails(widget.action.id);
      if (res['statusCode'] == "200") {
        onRefreshActionSuccess(res['body']);
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
          var res = await api.getActionDetails(widget.action.id);
          setState(() {
            _load = false;
          });

          if (res['statusCode'] == "200") {
            onRefreshActionSuccess(res['body']);
          } else if (res['statusCode'] == "401") {
            logOut();
          } else {
            onRefreshActionError();
          }
        }
      } else {
        onRefreshActionError();
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _load = false;
      });
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych akcji. Sprawdź połączenie z serwerem i spróbuj ponownie."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych akcji. Adres serwera nieprawidłowy."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
    setState(() {
      _load = false;
    });
  }

  onRefreshActionSuccess(String res) {
    dynamic body = jsonDecode(res);
    setState(() {
      widget.action = SensorDriverAction.fromJson(body);
    });
  }

  onRefreshActionError() {
    final snackBar = new SnackBar(
        content: new Text("Odświeżenie danych akcji nie powiodło się.".i18n));
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
}
