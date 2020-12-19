import 'dart:convert';
import 'package:idom/localization/drivers/drivers.i18n.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/drivers/driver_details.dart';
import 'package:idom/pages/drivers/new_driver.dart';
import 'package:idom/remote_control.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';

class Drivers extends StatefulWidget {
  Drivers({@required this.storage, this.testApi});

  final SecureStorage storage;
  final Api testApi;

  @override
  _DriversState createState() => _DriversState();
}

class _DriversState extends State<Drivers> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  final GlobalKey<State> _keyLoaderInvalidToken = GlobalKey<State>();
  Api api = Api();
  List<Driver> _driverList;
  bool zeroFetchedItems = false;
  bool _connectionEstablished;

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }
    getDrivers();
  }

  /// returns list of drivers
  Future<void> getDrivers() async {
    try {
      /// gets drivers
      var res = await api.getDrivers();

      if (res != null && res['statusCode'] == "200") {
        List<dynamic> body = jsonDecode(res['body']);
        setState(() {
          _driverList =
              body.map((dynamic item) => Driver.fromJson(item)).toList();
        });
        if (_driverList.length == 0)
          zeroFetchedItems = true;
        else
          zeroFetchedItems = false;
      } else if (res != null && res['statusCode'] == "401") {
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
      if (res == null) {
        _connectionEstablished = false;
        setState(() {});
        return null;
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
        appBar: AppBar(
          title: Text('Sterowniki'.i18n),
          actions: [
            IconButton(
              icon: Icon(Icons.add, size: 30.0),
              key: Key("addDriverButton"),
              onPressed: navigateToNewDriver,
            )
          ],
        ),
        drawer: IdomDrawer(
            storage: widget.storage,
            parentWidgetType: "Drivers",
            onLogOutFailure: onLogOutFailure),

        /// builds cameras' list
        body: Container(child: listDrivers()),
      ),
    );
  }

  Widget listDrivers() {
    if (zeroFetchedItems) {
      return RefreshIndicator(
          backgroundColor: IdomColors.mainBackgroundDark,
          onRefresh: _pullRefresh,
          child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.only(
                      left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Text("Brak sterowników w systemie.".i18n,
                          style: Theme.of(context).textTheme.bodyText1,
                          textAlign: TextAlign.center)))));
    }
    if (_connectionEstablished != null &&
        _connectionEstablished == false &&
        _driverList == null) {
      return RefreshIndicator(
          backgroundColor: IdomColors.mainBackgroundDark,
          onRefresh: _pullRefresh,
          child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.only(
                      left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Text("Błąd połączenia z serwerem.".i18n,
                          style: Theme.of(context).textTheme.bodyText1,
                          textAlign: TextAlign.center)))));
    } else if (_driverList != null && _driverList.length > 0) {
      return Column(
        children: [
          Expanded(
              child: Scrollbar(
                  child: RefreshIndicator(
                      backgroundColor: IdomColors.mainBackgroundDark,
                      onRefresh: _pullRefresh,
                      child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, top: 10, right: 10.0, bottom: 0.0),
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _driverList.length,
                              itemBuilder: (context, index) => Container(
                                    height: 80,
                                    child: Card(
                                      child: ListTile(
                                          key: Key(_driverList[index].name),
                                          title: Text(_driverList[index].name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(fontSize: 21.0)),
                                          onTap: () {
                                            navigateToDriverDetails(
                                                _driverList[index]);
                                          },
                                          leading: SizedBox(
                                              width: 35,
                                              child: Container(
                                                  padding:
                                                      EdgeInsets.only(top: 5),
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: _getDriverImage(
                                                      _driverList[index]))),
                                          trailing:
                                              getTrailing(_driverList[index])),
                                    ),
                                  )))))),
        ],
      );
    }

    /// shows progress indicator while fetching data
    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, top: 10, right: 10.0, bottom: 0.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  getTrailing(Driver driver) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) async {
        _showPopupMenu(details.globalPosition, driver);
      },
      child: Container(
          child: Icon(Icons.more_vert_outlined,
              size: 30, color: Theme.of(context).textTheme.bodyText1.color)),
    );
  }

  _getDriverImage(Driver driver) {
    var imageUrl;
    switch (driver.category) {
      case "clicker":
        imageUrl = "assets/icons/tap.svg";
        break;
      case "remote_control":
        imageUrl = "assets/icons/controller.svg";
        break;
      case "bulb":
        imageUrl = "assets/icons/light-bulb.svg";
        break;
      case "roller_blind":
        imageUrl = "assets/icons/blinds.svg";
        break;
    }
    return SvgPicture.asset(imageUrl,
        matchTextDirection: false,
        width: 32,
        height: 32,
        color: Theme.of(context).iconTheme.color,
        key: Key(imageUrl));
  }

  _showPopupMenu(Offset offset, Driver driver) async {
    double left = offset.dx;
    double top = offset.dy;
    var selected = await showMenu(
      color: Theme.of(context).backgroundColor,
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        PopupMenuItem<String>(
            key: Key("click"),
            child: SizedBox(
              width: 260,
              child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(11),
                  },
                  children: [
                    if (driver.category == "clicker")
                      TableRow(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/play.svg",
                            matchTextDirection: false,
                            alignment: Alignment.centerRight,
                            width: 25,
                            height: 25,
                            color: IdomColors.green,
                          ),
                          SizedBox(width: 5),
                          Text('Wciśnij przycisk'.i18n,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(fontSize: 21.0)),
                        ],
                      ),
                    if (driver.category == "remote_control")
                      TableRow(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/turn-off.svg",
                            matchTextDirection: false,
                            alignment: Alignment.centerRight,
                            width: 25,
                            height: 25,
                            color: IdomColors.error,
                          ),
                          SizedBox(width: 5),
                          Text('Włącz/wyłącz pilot'.i18n,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(fontSize: 21.0)),
                        ],
                      ),
                    if (driver.category == "bulb")
                      TableRow(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/turn-off.svg",
                            matchTextDirection: false,
                            alignment: Alignment.centerRight,
                            width: 25,
                            height: 25,
                            color: IdomColors.error,
                          ),
                          SizedBox(width: 5),
                          Text('Włącz/wyłącz żarówkę'.i18n,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(fontSize: 21.0)),
                        ],
                      ),
                    if (driver.category == "roller_blind")
                      TableRow(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/up-and-down.svg",
                            matchTextDirection: false,
                            alignment: Alignment.centerRight,
                            width: 25,
                            height: 25,
                            color: IdomColors.additionalColor,
                          ),
                          SizedBox(width: 5),
                          Text('Podnieś/opuść rolety'.i18n,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(fontSize: 21.0)),
                        ],
                      ),
                  ]),
            ),
            value: 'click'),
        PopupMenuItem<String>(
            key: Key("delete"),
            child: SizedBox(
                width: 260,
                child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(11),
                    },
                    children: [
                      TableRow(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/dustbin.svg",
                            matchTextDirection: false,
                            alignment: Alignment.centerRight,
                            width: 25,
                            height: 25,
                            color: Theme.of(context).textTheme.bodyText1.color,
                          ),
                          SizedBox(width: 5),
                          Text('Usuń'.i18n,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(fontSize: 21.0)),
                        ],
                      )
                    ])),
            value: 'delete'),
      ],
      elevation: 8.0,
    );
    switch (selected) {
      case "click":
        if (driver.category == "bulb") {
          _switchBulb(driver);
        } else if (driver.category == "clicker") {
          _clickDriver(driver);
        } else if (driver.category == "remote_control") {
          _sendCommandToRemoteControl(driver);
        }
        break;
      case "delete":
        _deleteDriver(driver);
    }
  }

  _sendCommandToRemoteControl(Driver driver) async {
    if (driver.ipAddress == null) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      final snackBar =
          new SnackBar(content: new Text("Pilot nie posiada adresu IP.".i18n));
      _scaffoldKey.currentState.showSnackBar((snackBar));
      return;
    }
    try {
      var result = await RemoteControl.sendCommand(driver, "Power");
      if (result != null) {
        if (result == 200) {
          final snackBar = new SnackBar(
              content: new Text("Komenda wysłana do pilota.".i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        } else {
          final snackBar = new SnackBar(
              content: new Text(
                  "Wysłanie komendy do pilota nie powiodło się.".i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      }
    } catch (e) {
      final snackBar = new SnackBar(
          content:
              new Text("Wysłanie komendy do pilota nie powiodło się.".i18n));
      _scaffoldKey.currentState.showSnackBar((snackBar));
    }
  }

  _clickDriver(Driver driver) async {
    var result = await api.startDriver(driver.name);
    var message;
    if (result == 200) {
      message = "Wysłano komendę do sterownika ".i18n + driver.name + ".".i18n;
    } else {
      message = "Wysłanie komendy do sterownika ".i18n +
          driver.name +
          " nie powiodło się.".i18n;
    }
    _scaffoldKey.currentState.removeCurrentSnackBar();
    final snackBar = new SnackBar(content: new Text(message));
    _scaffoldKey.currentState.showSnackBar((snackBar));
  }

  _switchBulb(Driver driver) async {
    var flag = driver.data == null
        ? "on"
        : driver.data
            ? "off"
            : "on";
    var message;
    var result;
    if (driver.category == "bulb") {
      result = await api.switchBulb(driver.id, flag);
    }
    var serverError = RegExp("50[0-4]");
    if (result == 200) {
      if (flag == "on") {
        message =
            "Wysłano komendę włączenia żarówki ".i18n + driver.name + ".".i18n;
      } else {
        message =
            "Wysłano komendę wyłączenia żarówki ".i18n + driver.name + ".".i18n;
      }
      await getDrivers();
    } else if (result == 404) {
      message = "Nie znaleziono żarówki ".i18n +
          driver.name +
          " na serwerze. Odswież listę sterowników.".i18n;
    } else if (serverError.hasMatch(result.toString())) {
      message = "Nie udało się podłączyć do żarówki ".i18n +
          driver.name +
          ". Sprawdź podłączenie i spróbuj ponownie.".i18n;
    }
    if (message != null) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      final snackBar = new SnackBar(content: new Text(message));
      _scaffoldKey.currentState.showSnackBar((snackBar));
    }
  }

  _deleteDriver(Driver driver) async {
    var decision = await confirmActionDialog(context, "Potwierdź".i18n,
        "Czy na pewno chcesz usunąć sterownik ".i18n + driver.name + "?");
    if (decision) {
      try {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoader,
            text: "Trwa usuwanie sterownika...".i18n);

        int statusCode = await api.deleteDriver(driver.id);
        Navigator.of(_scaffoldKey.currentContext, rootNavigator: true).pop();
        if (statusCode == 200) {
          setState(() {
            /// refreshes drivers' list
            getDrivers();
          });
        } else if (statusCode == 401) {
          displayProgressDialog(
              context: _scaffoldKey.currentContext,
              key: _keyLoaderInvalidToken,
              text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
          await new Future.delayed(const Duration(seconds: 3));
          Navigator.of(_keyLoaderInvalidToken.currentContext).pop();
          await widget.storage.resetUserData();
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (statusCode == null) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd usuwania sterownika. Sprawdź połączenie z serwerem i spróbuj ponownie."
                      .i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        } else {
          final snackBar = new SnackBar(
              content: new Text(
                  "Usunięcie sterownika nie powiodło się. Spróbuj ponownie."
                      .i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      } catch (e) {
        Navigator.of(_scaffoldKey.currentContext).pop();

        print(e.toString());
        if (e.toString().contains("TimeoutException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd usuwania sterownika. Sprawdź połączenie z serwerem i spróbuj ponownie."
                      .i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
        if (e.toString().contains("SocketException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Usunięcie sterownika nie powiodło się. Spróbuj ponownie."
                      .i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      }
    }
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      /// refreshes drivers' list
      getDrivers();
    });
  }

  /// navigates to adding driver page
  navigateToNewDriver() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewDriver(storage: widget.storage),
            fullscreenDialog: true));

    /// displays success message if driver added successfully
    if (result == true) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      final snackBar = new SnackBar(
        content: new Text("Dodano nowy sterownik.".i18n),
        duration: Duration(seconds: 1),
      );
      _scaffoldKey.currentState.showSnackBar((snackBar));
      await getDrivers();
    }
  }

  navigateToDriverDetails(Driver driver) async {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            DriverDetails(storage: widget.storage, driver: driver)));
    await getDrivers();
  }
}
