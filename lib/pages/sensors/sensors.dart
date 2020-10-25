import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/pages/sensors/new_sensor.dart';
import 'package:idom/pages/sensors/sensor_details.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';

import '../../api.dart';

/// displays all sensors
class Sensors extends StatefulWidget {
  Sensors(
      {Key key,
      @required this.currentLoggedInToken,
      @required this.currentUser,
      @required this.api,
      @required this.onSignedOut,
      this.testSensors})
      : super(key: key);
  final String currentLoggedInToken;
  final Account currentUser;
  Api api;
  final List<Sensor> testSensors;
  VoidCallback onSignedOut;

  @override
  _SensorsState createState() => _SensorsState();
}

class _SensorsState extends State<Sensors> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  final GlobalKey<State> _keyLoaderInvalidToken = GlobalKey<State>();
  final TextEditingController _searchController = TextEditingController();
  final Api api = Api();
  List<String> menuItems;
  List<Sensor> _sensorList;
  List<Sensor> _duplicateSensorList = List<Sensor>();
  bool zeroFetchedItems = false;
  String _token;
  bool _connectionEstablished;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    getSensors();
    _searchController.addListener(() {
      filterSearchResults(_searchController.text);
    });
  }

  /// returns list of sensors
  Future<List<Sensor>> getSensors() async {
    /// if statement for testing
    if (widget.testSensors != null) {
      return widget.testSensors;
    }
    try {
      /// gets sensors
      var res = await widget.api.getSensors(widget.currentLoggedInToken);

      if (res != null && res['statusCodeSensors'] == "200") {
        List<dynamic> bodySensors = jsonDecode(res['bodySensors']);
        setState(() {
          _sensorList =
              bodySensors.map((dynamic item) => Sensor.fromJson(item)).toList();
        });
        if (_sensorList.length == 0)
          zeroFetchedItems = true;
        else
          zeroFetchedItems = false;
      } else if (res != null && res['statusCodeSensors'] == "401") {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoaderInvalidToken,
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...");
        await new Future.delayed(const Duration(seconds: 3));
        Navigator.of(_keyLoaderInvalidToken.currentContext, rootNavigator: true)
            .pop();
        widget.onSignedOut();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      print(e.toString());
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania czujników. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania czujników. Adres serwera nieprawidłowy."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    }
    setState(() {
      _duplicateSensorList.clear();
      _duplicateSensorList.addAll(_sensorList);
    });
    return _sensorList;
  }

  /// logs the user out of the app
  _logOut() async {
    try {
      displayProgressDialog(
          context: _scaffoldKey.currentContext,
          key: _keyLoader,
          text: "Trwa wylogowywanie...");
      var statusCode = await widget.api.logOut(widget.currentLoggedInToken);
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      if (statusCode == 200 || statusCode == 404 || statusCode == 401) {
        widget.onSignedOut();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (statusCode == null) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd wylogowywania. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      } else {
        final snackBar = new SnackBar(
            content:
                new Text("Wylogowanie nie powiodło się. Spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    } catch (e) {
      print(e);
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd wylogowania. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content:
                new Text("Błąd wylogowania. Adres serwera nieprawidłowy."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    }
  }

  /// deactivates sensor after confirmation
  _deactivateSensor(Sensor sensor) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Usuwanie czujnika"),
          content: Text("Czy na pewno chcesz usunąć czujnik ${sensor.name}?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              key: Key("yesButton"),
              child: Text("Tak"),
              onPressed: () async {
                try {
                  Navigator.of(context).pop(true);
                  displayProgressDialog(
                      context: _scaffoldKey.currentContext,
                      key: _keyLoader,
                      text: "Trwa usuwanie czujnika...");

                  int statusCode = await widget.api
                      .deactivateSensor(sensor.id, widget.currentLoggedInToken);
                  Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                      .pop();
                  if (statusCode == 200) {
                    setState(() {
                      /// refreshes sensors' list
                      getSensors();
                    });
                  } else if (statusCode == 401) {
                    displayProgressDialog(
                        context: _scaffoldKey.currentContext,
                        key: _keyLoaderInvalidToken,
                        text:
                            "Sesja użytkownika wygasła. \nTrwa wylogowywanie...");
                    await new Future.delayed(const Duration(seconds: 3));
                    Navigator.of(_keyLoaderInvalidToken.currentContext,
                            rootNavigator: true)
                        .pop();
                    widget.onSignedOut();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else if (statusCode == null) {
                    final snackBar = new SnackBar(
                        content: new Text(
                            "Błąd usuwania czujnika. Sprawdź połączenie z serwerem i spróbuj ponownie."));
                    ScaffoldMessenger.of(context).showSnackBar((snackBar));
                  } else {
                    final snackBar = new SnackBar(
                        content: new Text(
                            "Błąd. Usunięcie czujnika nie powiodło się. Spróbuj ponownie."));
                    ScaffoldMessenger.of(context).showSnackBar((snackBar));
                  }
                } catch (e) {
                  Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                      .pop();

                  print(e.toString());
                  if (e.toString().contains("TimeoutException")) {
                    final snackBar = new SnackBar(
                        content: new Text(
                            "Błąd usuwania czujnika. Sprawdź połączenie z serwerem i spróbuj ponownie."));
                    ScaffoldMessenger.of(context).showSnackBar((snackBar));
                  }
                  if (e.toString().contains("SocketException")) {
                    final snackBar = new SnackBar(
                        content: new Text(
                            "Błąd. Usunięcie czujnika nie powiodło się. Spróbuj ponownie."));
                    ScaffoldMessenger.of(context).showSnackBar((snackBar));
                  }
                }
              },
            ),
            FlatButton(
              key: Key("noButton"),
              child: Text("Nie"),
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
  _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: Theme
          .of(context)
          .appBarTheme
          .textTheme
          .headline6,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Wyszukaj...",
        hintStyle: Theme
            .of(context)
            .appBarTheme
            .textTheme
            .headline6,
        border: UnderlineInputBorder(borderSide: BorderSide(
            color: IdomColors.additionalColor
        )),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: IdomColors.additionalColor),
        ),),
    );
  }

  Future<bool> _onBackButton() async {
    var decision = await confirmActionDialog(
        context, "Potwierdź", "Na pewno wyjść z aplikacji?", () {
      Navigator.pop(context, true);
    });
    return Future.value(decision);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackButton,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: _isSearching ? IconButton(
              icon: Icon(Icons.arrow_back), onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.text = "";
            });
          }) : IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();
            },
          ),
          title: _isSearching ? _buildSearchField() : Text('Czujniki'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search, size: 25.0),
              key: Key("searchButton"),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
            _isSearching
                ? SizedBox()
                : IconButton(
              icon: Icon(Icons.add, size: 30.0),
              key: Key("addSensorButton"),
              onPressed: navigateToNewSensor,
            )
          ],
        ),
        drawer: IdomDrawer(
            storage: widget.storage,
            parentWidgetType: "Sensors",
            onGoBackAction: () async {
              await getSensors();
            }),

        /// builds sensor's list
        body: Container(
            child: Column(children: <Widget>[
              listSensors()
            ])),
      ),
    );
  }

  Widget listSensors() {
    if (zeroFetchedItems) {
      return Padding(
          padding:
          EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                  "Brak czujników w systemie \nlub błąd połączenia z serwerem.",
                  style: TextStyle(fontSize: 13.5),
                  textAlign: TextAlign.center)));
    } else if (!zeroFetchedItems &&
        _sensorList != null &&
        _sensorList.length == 0) {
      return Padding(
          padding:
          EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text("Brak wyników wyszukiwania.",
                  style: TextStyle(fontSize: 16.5),
                  textAlign: TextAlign.center)));
    } else if (_sensorList != null && _sensorList.length > 0) {
      return Expanded(
          child: Scrollbar(
              child: RefreshIndicator(
                  onRefresh: _pullRefresh,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, top: 10, right: 10.0, bottom: 0.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _sensorList.length,
                      itemBuilder: (context, index) =>
                          Container(
                              height: 80,
                              child: Card(
                                  child: ListTile(
                                      key: Key(_sensorList[index].name),
                                      title: Text(_sensorList[index].name,
                                          style: TextStyle(fontSize: 21.0)),
                                      subtitle: Text(
                                          "ostatnia dana: " +
                                              sensorData(_sensorList[index]),
                                          style: TextStyle(
                                              fontSize: 16.5,
                                              color: IdomColors.textDark)),
                                      onTap: () {
                                        navigateToSensorDetails(
                                            _sensorList[index]);
                                      },
                                      leading: Icon(
                                        getSensorIcon(_sensorList[index]),
                                        color: Theme
                                            .of(context)
                                            .iconTheme
                                            .color,
                                      ),

                                      /// delete sensor button
                                      trailing:
                                      deleteButtonTrailing(
                                          _sensorList[index])))),
                    ),
                  ))));
    }

    /// shows progress indicator while fetching data
    return Padding(
      padding: const EdgeInsets.only(
          left: 10.0, top: 10, right: 10.0, bottom: 0.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  IconData getSensorIcon(Sensor sensor) {
    if (sensor.category == "temperature")
      return Icons.thermostat_outlined;
    else if (sensor.category == "humidity") return Icons.spa_rounded;
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      /// refreshes sensors' list
      getSensors();
    });
  }

  void filterSearchResults(String query) {
    List<Sensor> dummySearchList = List<Sensor>();
    dummySearchList.addAll(_duplicateSensorList);
    if (query.isNotEmpty) {
      List<Sensor> dummyListData = List<Sensor>();
      dummySearchList.forEach((item) {
        if (item.name.contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        _sensorList.clear();
        _sensorList.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        _sensorList.clear();
        _sensorList.addAll(_duplicateSensorList);
      });
    }
  }

  String sensorData(Sensor sensor) {
    if (sensor.lastData == null) return "-";
    switch (sensor.category) {
      case "temperature":
        return "${sensor.lastData} °C";
        break;
      case "humidity":
        return "${sensor.lastData} %";
        break;
    }
    return "-";
  }

  /// navigates to adding sensor page
  navigateToNewSensor() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewSensor(
                currentLoggedInToken: widget.currentLoggedInToken,
                currentUser: widget.currentUser,
                api: widget.api,
                onSignedOut: widget.onSignedOut),
            fullscreenDialog: true));

    /// displays success message if sensor added succesfully
    if (result == true) {
      final snackBar = new SnackBar(content: new Text("Dodano nowy czujnik."));
      ScaffoldMessenger.of(context).showSnackBar((snackBar));
      await getSensors();
    }
  }

  /// navigates to sensor's details
  navigateToSensorDetails(Sensor sensor) async {
    var result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SensorDetails(
            currentLoggedInToken: widget.currentLoggedInToken,
            currentUser: widget.currentUser,
            sensor: sensor,
            api: widget.api,
            onSignedOut: widget.onSignedOut)));

    setState(() {
      widget.onSignedOut = result;
    });
    await getSensors();
  }

  /// deletes sensor
  deleteButtonTrailing(Sensor sensor) {
    return SizedBox(
        width: 35,
        child: Container(
            alignment: Alignment.centerRight,
            child: FlatButton(
              key: Key("deleteButton"),
              child: Icon(Icons.delete, color: IdomColors.mainFill),
              onPressed: () {
                setState(() {
                  _deactivateSensor(sensor);
                });
              },
            )));
  }
}
