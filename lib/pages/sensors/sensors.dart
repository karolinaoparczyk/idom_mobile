import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/pages/sensors/new_sensor.dart';
import 'package:idom/pages/sensors/sensor_details.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/utils/menu_items.dart';
import 'package:idom/widgets/dialog.dart';

/// displays all sensors
class Sensors extends StatefulWidget {
  Sensors(
      {Key key,
      @required this.currentLoggedInToken,
      @required this.currentUser,
      @required this.api,
      this.testSensors})
      : super(key: key);
  final String currentLoggedInToken;
  final Account currentUser;
  Api api;
  final List<Sensor> testSensors;

  @override
  _SensorsState createState() => _SensorsState();
}

class _SensorsState extends State<Sensors> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> menuItems;

  /// displays appropriate menu choices according to user data
  @override
  void initState() {
    super.initState();
    if (widget.api == null)
      widget.api = Api();

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

    /// gets sensors
    Map<String, String> res;
    if (widget.api != null) {
      res = await widget.api.getSensors(widget.currentLoggedInToken);
    } else {
      Api api = Api();
      res = await api.getSensors(widget.currentLoggedInToken);
    }

    if (res['statusCodeSensors'] == "200") {
      List<dynamic> bodySensors = jsonDecode(res['bodySensors']);
      List<Sensor> sensors =
          bodySensors.map((dynamic item) => Sensor.fromJson(item)).toList();

      return sensors;
    } else {
      throw "Can't get sensors";
    }
  }

  /// logs the user out of the app
  _logOut() async {
    try {
      var statusCode;
      if (widget.api != null)
        statusCode = await widget.api.logOut(widget.currentLoggedInToken);
      else {
        Api api = Api();
        statusCode = await api.logOut(widget.currentLoggedInToken);
      }
      if (statusCode == 200) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Front(), fullscreenDialog: true));
      } else {
        displayDialog(
            context, "Błąd", "Wylogowanie nie powiodło się. Spróbuj ponownie.");
      }
    } catch (e) {
      print(e);
    }
  }

  /// deactivates ensor after confirmation
  _deactivateSensor(Sensor sensor) {
    showDialog(
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
                var statusCode;
                if (widget.api != null)
                  statusCode = await widget.api
                      .deactivateSensor(sensor.id, widget.currentLoggedInToken);
                else {
                  Api api = Api();
                  statusCode = await api.deactivateSensor(
                      sensor.id, widget.currentLoggedInToken);
                }
                if (statusCode == 200) {
                  setState(() {
                    getSensors();
                  });
                  Navigator.of(context).pop(true);
                } else {
                  Navigator.of(context).pop(true);
                  displayDialog(context, "Błąd",
                      "Usunięcie czujnika nie powiodło się. Spróbuj ponownie.");
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
  void _choiceAction(String choice) {
    if (choice == "Moje konto") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AccountDetail(
                  currentLoggedInToken: widget.currentLoggedInToken,
                  account: widget.currentUser,
                  currentUser: widget.currentUser,
                  api: widget.api),
              fullscreenDialog: true));
    }
    if (choice == "Konta") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Accounts(
                  currentLoggedInToken: widget.currentLoggedInToken,
                  currentUser: widget.currentUser,
                  api: widget.api),
              fullscreenDialog: true));
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
                if (snapshot.hasData) {
                  List<Sensor> sensors = snapshot.data;
                  return Column(children: <Widget>[
                    /// A widget with the list of sensors
                    Expanded(
                        flex: 16,
                        child: Scrollbar(
                            child: ListView(
                          shrinkWrap: true,
                          children: sensors
                              .map(
                                (Sensor sensor) => ListTile(
                                    key: Key(sensor.name),
                                    title: Text(sensor.name,
                                        style: TextStyle(fontSize: 20.0)),
                                    subtitle: sensorData(sensor),
                                    onTap: () {
                                      navigateToSensorDetails(sensor);
                                    },

                                    /// delete sensor button
                                    trailing: deleteButtonTrailing(sensor)),
                              )
                              .toList(),
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
        ? Text("${sensor.lastData} °C", style: TextStyle(fontSize: 17.0))
        : Text("${sensor.lastData} %", style: TextStyle(fontSize: 17.0));
  }

  /// navigates to adding sensor page
  navigateToNewSensor() async {
    bool result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewSensor(
                currentLoggedInToken: widget.currentLoggedInToken,
                currentUser: widget.currentUser,
                api: widget.api),
            fullscreenDialog: true));

    /// displays success message if sensor added succesfully
    if (result != null && result == true) {
      var snackBar = SnackBar(content: Text("Dodano nowy czujnik."));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
    setState(() {
      getSensors();
    });
  }

  /// navigates to sensor's details
  navigateToSensorDetails(Sensor sensor) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SensorDetails(
            currentLoggedInToken: widget.currentLoggedInToken,
            currentUser: widget.currentUser,
            sensor: sensor,
            api: widget.api)));

    setState(() {
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
