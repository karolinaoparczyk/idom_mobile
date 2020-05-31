import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/pages/sensors/sensor_details.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/utils/menu_items.dart';
import 'package:idom/widgets/dialog.dart';

/// displays all sensors
class Sensors extends StatefulWidget {
  const Sensors(
      {Key key,
      @required this.currentLoggedInToken,
      @required this.currentLoggedInUsername,
      @required this.api,
      this.testSensors})
      : super(key: key);
  final String currentLoggedInToken;
  final String currentLoggedInUsername;
  final Api api;
  final List<Sensor> testSensors;

  @override
  _SensorsState createState() => _SensorsState();
}

class _SensorsState extends State<Sensors> {
  final String sensorsUrl = "http://10.0.2.2:8000/sensors/list";

  /// returns list of sensors
  Future<List<Sensor>> getSensors() async {
    /// if statement for testing
    if (widget.testSensors != null) {
      return widget.testSensors;
    }

    Response res;
    if (widget.api != null)
      res = await widget.api.getSensors(widget.currentLoggedInToken);
    else {
      Api api = Api();
      res = await api.getSensors(widget.currentLoggedInToken);
    }

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);

      List<Sensor> sensors = body
          .map((dynamic item) => Sensor.fromJson(item))
          .where((sensor) => sensor.isActive == true)
          .toList();

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
          content:
          Text("Czy na pewno chcesz usunąć czujnik ${sensor.name}?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              key: Key("yesButton"),
              child: Text("Tak"),
              onPressed: () async {
                var statusCode;
                if (widget.api != null)
                  statusCode = await widget.api.deactivateSensor(
                      sensor.id, widget.currentLoggedInToken);
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

  void _choiceAction(String choice) {
    if (choice == "Konta") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Accounts(
                  currentLoggedInToken: widget.currentLoggedInToken,
                  currentLoggedInUsername: widget.currentLoggedInUsername,
                  api: widget.api),
              fullscreenDialog: true));
    } else if (choice == "Wyloguj") {
      _logOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            title: Text('IDOM Czujniki'),
            actions: <Widget>[
              PopupMenuButton(
                key: Key("menuButton"),
                  offset: Offset(0, 100),
                  onSelected: _choiceAction,
                  itemBuilder: (BuildContext context) {
                    return menuChoices.map((String choice) {
                      return PopupMenuItem(value: choice, child: Text(choice));
                    }).toList();
                  })
            ],
          ),
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
                                  title: Text(sensor.name),
                                  onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => SensorDetails(
                                              currentLoggedInToken:
                                                  widget.currentLoggedInToken,
                                              currentLoggedInUsername: widget
                                                  .currentLoggedInUsername,
                                              sensor: sensor,
                                              api: widget.api))),
                                    /// delete sensor button
                                    trailing: deleteButtonTrailing(sensor)
                                ),
                              )
                              .toList(),
                        ))),
                    Expanded(flex: 1, child: Divider()),
                  ]);
                }

                /// shows progress indicator while fetching data
                return Center(child: CircularProgressIndicator());
              }),
        ));
  }

  deleteButtonTrailing(Sensor sensor) {
    return FlatButton(
        key: Key("deleteButton"),
        child: Icon(Icons.delete),
        onPressed: () {
          setState(() {
            _deactivateSensor(sensor);
          });
        },
      );
  }
}
