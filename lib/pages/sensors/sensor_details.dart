import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/utils/menu_items.dart';
import 'package:idom/widgets/dialog.dart';

class SensorDetails extends StatefulWidget {
  SensorDetails({Key key,
    @required this.currentLoggedInToken,
    @required this.currentLoggedInUsername,
    @required this.sensor,
    @required this.api})
      : super(key: key);
  final String currentLoggedInToken;
  final String currentLoggedInUsername;
  final Api api;
  final Sensor sensor;

  @override
  _SensorDetailsState createState() => new _SensorDetailsState();
}

class _SensorDetailsState extends State<SensorDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  void _choiceAction(String choice) {
    if (choice == "Konta") {
      Api api = Api();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Accounts(
                  currentLoggedInToken: widget.currentLoggedInToken,
                  currentLoggedInUsername: widget.currentLoggedInUsername,
                  api: api),
              fullscreenDialog: true));
    } else if (choice == "Wyloguj") {
      _logOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text(widget.sensor.name), actions: <Widget>[
          PopupMenuButton(
              key: Key("menuButton"),
              offset: Offset(0,100),
              onSelected: _choiceAction,
              itemBuilder: (BuildContext context) {
                return menuChoices.map((String choice) {
                  return PopupMenuItem(key: Key(choice), value: choice, child: Text(choice));
                }).toList();
              })
        ],),
        body: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                Padding(
                padding:
                EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0),
                child: ListTile(
                  title: Text("Nazwa", style: TextStyle(fontSize: 13.5)),
                  subtitle: Text(widget.sensor.name,
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                )),
            Padding(
              padding:
              EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0),
              child: ListTile(
                  title:
                  Text("Kategoria", style: TextStyle(fontSize: 13.5)),
                  subtitle: Text(widget.sensor.category == "temperature"
                      ? "Czujnik temperatury"
                      : "Czujnik wilgotności",
                      style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            )),
        Padding(
            padding:
            EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0),
            child: ListTile(
              title: Text("Poziom baterii",
                  style: TextStyle(fontSize: 13.5)),
              subtitle: Text(
                  widget.sensor.batteryLevel == null
                      ? "Brak danych"
                      : widget.sensor.batteryLevel.toString(),
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            )),
        Divider(),
        ])))
    );
  }
}
