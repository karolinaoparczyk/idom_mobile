import 'dart:convert';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:idom/enums/categories.dart';
import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/drivers/edit_driver.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';

/// displays driver details
class DriverDetails extends StatefulWidget {
  DriverDetails({@required this.storage, @required this.driver});

  final SecureStorage storage;
  Driver driver;

  @override
  _DriverDetailsState createState() => new _DriverDetailsState();
}

class _DriverDetailsState extends State<DriverDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final Api api = Api();
  bool _load;
  String _token;

  @override
  void initState() {
    super.initState();
    _load = false;
    getToken();
  }

  Future<void> getToken() async {
    _token = await widget.storage.getToken();
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
            appBar: AppBar(title: Text(widget.driver.name), actions: [
              IconButton(
                  key: Key("editDriver"),
                  icon: Icon(Icons.edit),
                  onPressed: _navigateToEditDriver)
            ]),
            drawer: IdomDrawer(
                storage: widget.storage,
                parentWidgetType: "DriverDetails",
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
                                child: Text("Ogólne",
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
                          child: Text("Nazwa",
                              style: TextStyle(
                                  color: IdomColors.additionalColor,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 52.5, top: 0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(widget.driver.name,
                              style: TextStyle(fontSize: 21.0)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 52.5, top: 10.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Kategoria",
                              style: TextStyle(
                                  color: IdomColors.additionalColor,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 52.5, top: 0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              DriverCategories.values
                                  .where((element) =>
                                      element['value'] ==
                                      widget.driver.category)
                                  .first['text'],
                              style: TextStyle(fontSize: 21.0)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 20.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(Icons.touch_app_outlined, size: 17.5),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text("Obsługa sterownika",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                        fontWeight: FontWeight.normal)),
                              ),
                            ],
                          ))),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 52.5, top: 30, right: 52.5, bottom: 0.0),
                    child: Column(
                      children: [
                        SizedBox.fromSize(
                          size: Size(56, 56),
                          child: ClipOval(
                            child: Material(
                              color: IdomColors.brightGreen,
                              child: InkWell(
                                key: Key("click"),
                                splashColor: IdomColors.darkGreen,
                                onTap: _clickDriver,
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      "assets/icons/play.svg",
                                      matchTextDirection: false,alignment: Alignment.centerRight,
                                      width: 25,
                                      height: 25,
                                      color: IdomColors.green,
                                      key: Key("assets/icons/play.svg")
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text("Wciśnij przycisk",
                            style: TextStyle(
                                color: IdomColors.textDark,
                                fontSize: 21,
                                fontWeight: FontWeight.normal)),
                      ],
                    ),
                  )
                ]),
              ),
            ))));
  }

  _clickDriver() async {
    // todo: post to api
    final snackBar =
    new SnackBar(content: new Text("Wysłano komendę do sterownika ${widget.driver.name}."));
    _scaffoldKey.currentState.showSnackBar((snackBar));
  }

  _navigateToEditDriver() async {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditDriver(storage: widget.storage, driver: widget.driver),
            fullscreenDialog: true));
    if (result == true) {
      final snackBar =
          new SnackBar(content: new Text("Zapisano dane sterownika."));
      _scaffoldKey.currentState.showSnackBar((snackBar));
      await _refreshSensorDetails();
    }
  }

  _refreshSensorDetails() async {
    try {
      setState(() {
        _load = true;
      });
      await getToken();
      var res = await api.getDriverDetails(widget.driver.id, _token);
      if (res['statusCode'] == "200") {
        dynamic body = jsonDecode(res['body']);
        Driver refreshedDriver = Driver.fromJson(body);
        setState(() {
          widget.driver = refreshedDriver;
        });
      } else if (res['statusCode'] == "401") {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoader,
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...");
        await new Future.delayed(const Duration(seconds: 3));
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        await widget.storage.resetUserData();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        final snackBar = new SnackBar(
            content:
                new Text("Odświeżenie danych sterownika nie powiodło się."));
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
                "Błąd pobierania danych sterownika. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych sterownika. Adres serwera nieprawidłowy."));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
    setState(() {
      _load = false;
    });
  }
}
