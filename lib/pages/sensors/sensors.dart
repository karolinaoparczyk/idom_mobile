import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/pages/sensors/new_sensor.dart';
import 'package:idom/pages/sensors/sensor_details.dart';
import 'package:idom/utils/menu_items.dart';
import 'package:idom/widgets/dialog.dart';
import 'package:idom/widgets/text_color.dart';

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
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final GlobalKey<State> _keyLoaderInvalidToken = new GlobalKey<State>();
  List<String> menuItems;

  @override
  void initState() {
    super.initState();

    if (widget.api == null) widget.api = Api();

    /// displays appropriate menu choices according to user data
    menuItems = widget.currentUser.isStaff
        ? menuChoicesSuperUser
        : menuChoicesNormalUser;
  }

  /// returns list of sensors
  Future<List<Sensor>> getSensors() async {
    /// if statement for testing
    if (widget.testSensors != null) {
      return widget.testSensors;
    }
    List<Sensor> sensors = List<Sensor>();

    try {
      /// gets sensors
      var res = await widget.api.getSensors(widget.currentLoggedInToken);

      if (res != null && res['statusCodeSensors'] == "200") {
        List<dynamic> bodySensors = jsonDecode(res['bodySensors']);
        sensors =
            bodySensors.map((dynamic item) => Sensor.fromJson(item)).toList();
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
    }
    return sensors;
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
        displayDialog(
            context: _scaffoldKey.currentContext,
            title: "Błąd wylogowywania",
            text: "Sprawdź połączenie z serwerem i spróbuj ponownie.");
      } else {
        displayDialog(
            context: _scaffoldKey.currentContext,
            title: "Błąd",
            text: "Wylogowanie nie powiodło się. Spróbuj ponownie.");
      }
    } catch (e) {
      print(e);
      if (e.toString().contains("TimeoutException")) {
        displayDialog(
            context: _scaffoldKey.currentContext,
            title: "Błąd wylogowania",
            text: "Sprawdź połączenie z serwerem i spróbuj ponownie.");
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
                    displayDialog(
                        context: _scaffoldKey.currentContext,
                        title: "Błąd usuwania czujnika",
                        text:
                            "Sprawdź połączenie z serwerem i spróbuj ponownie.");
                  } else {
                    displayDialog(
                        context: _scaffoldKey.currentContext,
                        title: "Błąd",
                        text:
                            "Usunięcie czujnika nie powiodło się. Spróbuj ponownie.");
                  }
                } catch (e) {
                  Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                      .pop();

                  print("error deleting sensor");
                  print(e.toString());
                  if (e.toString().contains("TimeoutException")) {
                    displayDialog(
                        context: _scaffoldKey.currentContext,
                        title: "Błąd usuwania czujnika",
                        text:
                            "Sprawdź połączenie z serwerem i spróbuj ponownie.");
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

  /// navigates according to menu choice
  void _choiceAction(String choice) async {
    if (choice == "Moje konto") {
      var result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AccountDetail(
                  currentLoggedInToken: widget.currentLoggedInToken,
                  account: widget.currentUser,
                  currentUser: widget.currentUser,
                  api: widget.api,
                  onSignedOut: widget.onSignedOut),
              fullscreenDialog: true));
      setState(() {
        widget.onSignedOut = result;
      });
    }
    if (choice == "Konta") {
      var result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Accounts(
                  currentLoggedInToken: widget.currentLoggedInToken,
                  currentUser: widget.currentUser,
                  api: widget.api,
                  onSignedOut: widget.onSignedOut),
              fullscreenDialog: true));
      setState(() {
        widget.onSignedOut = result;
      });
    } else if (choice == "Wyloguj") {
      _logOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      /// adds sensor adding button
      floatingActionButton: Container(
          height: 80.0,
          width: 80.0,
          child: FittedBox(
              child: FloatingActionButton(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            key: Key("addSensorButton"),
            onPressed: navigateToNewSensor,
            child: Icon(Icons.add, size: 30),
            //backgroundColor: Colors.green,
          ))),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('IDOM Czujniki'),
        actions: <Widget>[
          /// menu dropdown button
          PopupMenuButton(
              key: Key("menuButton"),
              offset: Offset(0, 100),
              onSelected: _choiceAction,

              /// menu choices from utils/menu_items.dart
              itemBuilder: (BuildContext context) {
                return menuItems.map((String choice) {
                  return PopupMenuItem(
                      key: Key(choice), value: choice, child: Text(choice));
                }).toList();
              })
        ],
      ),

      /// builds sensor's list
      body: FutureBuilder(
          future: getSensors(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Sensor>> snapshot) {
            if (snapshot.data != null && snapshot.data.length == 0) {
              return Padding(
                  padding: EdgeInsets.only(
                      left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                          "Brak czujników w systemie \nlub błąd połączenia z serwerem.",
                          style: TextStyle(fontSize: 13.5),
                          textAlign: TextAlign.center)));
            }
            if (snapshot.hasData) {
              List<Sensor> sensors = snapshot.data;
              return Column(children: <Widget>[
                /// A widget with the list of sensors
                Expanded(
                    flex: 16,
                    child: Scrollbar(
                        child: ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                        color: textColor,
                      ),
                      shrinkWrap: true,
                      itemCount: sensors.length,
                      itemBuilder: (context, index) => ListTile(
                          key: Key(sensors[index].name),
                          title: Text(sensors[index].name,
                              style: TextStyle(fontSize: 20.0)),
                          subtitle: sensorData(sensors[index]),
                          onTap: () {
                            navigateToSensorDetails(sensors[index]);
                          },

                          /// delete sensor button
                          trailing: deleteButtonTrailing(sensors[index])),
                    ))),
              ]);
            }

            /// shows progress indicator while fetching data
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  Widget sensorData(Sensor sensor) {
    if (sensor.lastData == null) return Text("");
    return sensor.category == "temperature"
        ? Text("${sensor.lastData} °C",
            style: TextStyle(
                fontSize: 17.0, color: textColor, fontWeight: FontWeight.bold))
        : Text("${sensor.lastData} %",
            style: TextStyle(
                fontSize: 17.0, color: textColor, fontWeight: FontWeight.bold));
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
    if (result != null) {
      if (result['dataSaved'] == true) {
        var snackBar = SnackBar(content: Text("Dodano nowy czujnik."));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
      setState(() {
        widget.onSignedOut = result['onSignedOut'];
        getSensors();
      });
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
      getSensors();
    });
  }

  /// deletes sensor
  deleteButtonTrailing(Sensor sensor) {
    return SizedBox(
        width: 35,
        child: Container(
            alignment: Alignment.centerRight,
            child: FlatButton(
              key: Key("deleteButton"),
              child: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _deactivateSensor(sensor);
                });
              },
            )));
  }
}
