import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/drivers/driver_details.dart';
import 'package:idom/pages/drivers/edit_driver.dart';
import 'package:idom/pages/drivers/new_driver.dart';
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
  final GlobalKey<State> _keyLoaderInvalidToken = GlobalKey<State>();
  Api api = Api();
  List<Driver> _driverList;
  bool zeroFetchedItems = false;
  bool _connectionEstablished;
  String _token;

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }
    getDrivers();
  }

  Future<void> getUserToken() async {
    _token = await widget.storage.getToken();
  }

  /// returns list of drivers
  Future<void> getDrivers() async {
    await getUserToken();
    try {
      /// gets drivers
      var res = await api.getDrivers(_token);

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
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...");
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
                "Błąd pobierania sterowników. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania sterowników. Adres serwera nieprawidłowy."));
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
          title: Text('Sterowniki'),
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
        body: Container(child: Column(children: <Widget>[listDrivers()])),
      ),
    );
  }

  Widget listDrivers() {
    if (zeroFetchedItems) {
      return Padding(
          padding:
              EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                  "Brak sterowników w systemie \nlub błąd połączenia z serwerem.",
                  style: TextStyle(fontSize: 16.5),
                  textAlign: TextAlign.center)));
    }
    if (_connectionEstablished != null &&
        _connectionEstablished == false &&
        _driverList == null) {
      return Padding(
          padding:
              EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text("Błąd połączenia z serwerem.",
                  style: TextStyle(fontSize: 16.5),
                  textAlign: TextAlign.center)));
    } else if (_driverList != null && _driverList.length > 0) {
      return Expanded(
          child: Scrollbar(
              child: RefreshIndicator(
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
                                      style: TextStyle(fontSize: 21.0)),
                                  onTap: () {
                                    navigateToDriverDetails(_driverList[index]);
                                  },
                                  leading: SizedBox(
                                      width: 35,
                                      child: Container(
                                          alignment: Alignment.centerRight,
                                          child: Icon(
                                            Icons.touch_app_outlined,
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color,
                                            size: 30,
                                          ))),
                                  trailing: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: RaisedButton(
                                      elevation: 15,
                                      child: Icon(Icons.arrow_right_outlined,
                                          color: IdomColors.additionalColor),
                                      onPressed: _clickDriver,
                                    ),
                                  ),
                                ),
                              )))))));
    }

    /// shows progress indicator while fetching data
    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, top: 10, right: 10.0, bottom: 0.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  _clickDriver() async {
    // todo: post to api
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
      final snackBar = new SnackBar(content: new Text("Dodano nowy sterownik."));
      _scaffoldKey.currentState.showSnackBar((snackBar));
      await getDrivers();
    }
  }

  navigateToDriverDetails(Driver driver) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            DriverDetails(storage: widget.storage, driver: driver)));
    await getDrivers();
  }
}
