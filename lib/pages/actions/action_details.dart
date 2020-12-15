import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/actions/edit_action.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/localization/actions/action_details.i18n.dart';

/// displays action details
class ActionDetails extends StatefulWidget {
  ActionDetails({@required this.storage, @required this.action, this.testApi});

  final SecureStorage storage;
  SensorDriverAction action;
  final Api testApi;

  @override
  _ActionDetailsState createState() => new _ActionDetailsState();
}

class _ActionDetailsState extends State<ActionDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  Api api = Api();
  bool _load;
  Sensor sensor;
  Driver driver;

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }
    _load = false;
  }

  onLogOutFailure(String text) {
    final snackBar = new SnackBar(content: new Text(text));
    _scaffoldKey.currentState.showSnackBar((snackBar));
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
                parentWidgetType: "ActionDetails",
                onLogOutFailure: onLogOutFailure),
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
                          left: 52.5, top: 10.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Nazwa".i18n,
                              style: TextStyle(
                                  color: IdomColors.additionalColor,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 52.5, top: 0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(widget.action.name,
                              style: TextStyle(fontSize: 21.0)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 52.5, top: 10.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Sterownik".i18n,
                              style: TextStyle(
                                  color: IdomColors.additionalColor,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 52.5, top: 0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(widget.action.driver,
                              style: TextStyle(fontSize: 21.0)))),
                  if (widget.action.sensor != null)
                    Padding(
                        padding: EdgeInsets.only(
                            left: 52.5, top: 10.0, right: 30.0, bottom: 0.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Czujnik".i18n,
                                style: TextStyle(
                                    color: IdomColors.additionalColor,
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold)))),
                  if (widget.action.sensor != null)
                    Padding(
                        padding: EdgeInsets.only(
                            left: 52.5, top: 0, right: 30.0, bottom: 0.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(widget.action.sensor,
                                style: TextStyle(fontSize: 21.0)))),
                  if (widget.action.sensor != null)
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
                                  child: Text("Wyzwalacz".i18n,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .copyWith(
                                              fontWeight: FontWeight.normal)),
                                ),
                              ],
                            ))),
                  if (widget.action.sensor != null)
                    Padding(
                        padding: EdgeInsets.only(
                            left: 52.5, top: 10.0, right: 30.0, bottom: 0.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Wartość z czujnika".i18n,
                                style: TextStyle(
                                    color: IdomColors.additionalColor,
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold)))),
                  if (widget.action.sensor != null)
                    Padding(
                        padding: EdgeInsets.only(
                            left: 52.5, top: 0, right: 30.0, bottom: 0.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                "${widget.action.operator} ${widget.action.trigger}",
                                style: TextStyle(fontSize: 21.0)))),
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
                          left: 52.5, top: 10.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Dni tygodnia".i18n,
                              style: TextStyle(
                                  color: IdomColors.additionalColor,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 52.5, top: 0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_getDays(),
                              style: TextStyle(fontSize: 21.0)))),
                  if (widget.action.endTime == null)
                    Padding(
                        padding: EdgeInsets.only(
                            left: 52.5, top: 10.0, right: 30.0, bottom: 0.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Godzina".i18n,
                                style: TextStyle(
                                    color: IdomColors.additionalColor,
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold)))),
                  if (widget.action.endTime != null)
                    Padding(
                        padding: EdgeInsets.only(
                            left: 52.5, top: 10.0, right: 30.0, bottom: 0.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Godziny".i18n,
                                style: TextStyle(
                                    color: IdomColors.additionalColor,
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 52.5, top: 0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_getHours(),
                              style: TextStyle(fontSize: 21.0)))),
                ]),
              ),
            ))));
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
    if (widget.action.endTime != null) {
      return "${widget.action.startTime} - ${widget.action.endTime}";
    } else {
      return "${widget.action.startTime}";
    }
  }

  _navigateToEditAction() async {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditAction(storage: widget.storage, action: widget.action),
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
        dynamic body = jsonDecode(res['body']);
        setState(() {
          widget.action = SensorDriverAction.fromJson(body);
        });
      } else if (res['statusCode'] == "401") {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoader,
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
        await new Future.delayed(const Duration(seconds: 3));
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        await widget.storage.resetUserData();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        final snackBar = new SnackBar(
            content: new Text("Odświeżenie danych akcji nie powiodło się.".i18n));
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
                "Błąd pobierania danych akcji. Sprawdź połączenie z serwerem i spróbuj ponownie.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych akcji. Adres serwera nieprawidłowy.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
    setState(() {
      _load = false;
    });
  }
}
