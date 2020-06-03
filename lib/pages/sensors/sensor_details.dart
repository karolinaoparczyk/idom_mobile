import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/utils/menu_items.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/dialog.dart';

class SensorDetails extends StatefulWidget {
  SensorDetails(
      {Key key,
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
  TextEditingController _editingNameController;
  var dropdownSelectedItem;

  List<DropdownMenuItem<String>> categories;

  @override
  void initState() {
    super.initState();
    _editingNameController = TextEditingController(text: widget.sensor.name);

    categories = [
      DropdownMenuItem(
          child: Text("Temperatura"),
          value: "temperature",
          key: Key("temperature")),
      DropdownMenuItem(
          child: Text("Wilgotność"), value: "humidity", key: Key("humidity"))
    ];
    dropdownSelectedItem = widget.sensor.category;
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

  Widget _buildName() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
        child: TextFormField(
            key: Key('name'),
            controller: _editingNameController,
            decoration: InputDecoration(
                labelText: 'Nazwa',
                labelStyle: TextStyle(color: Colors.black, fontSize: 18)),
            validator: SensorNameFieldValidator.validate));
  }

  Widget _buildCategory() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
        child: DropdownButton(
          key: Key("dropdownbutton"),
          items: categories,
          onChanged: (val) {
            setState(() {
              dropdownSelectedItem = val;
            });
          },
          value: dropdownSelectedItem,
        ));
  }

  @override
  void dispose() {
    _editingNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.sensor.name),
          actions: <Widget>[
            PopupMenuButton(
                key: Key("menuButton"),
                offset: Offset(0, 100),
                onSelected: _choiceAction,
                itemBuilder: (BuildContext context) {
                  return menuChoices.map((String choice) {
                    return PopupMenuItem(
                        key: Key(choice), value: choice, child: Text(choice));
                  }).toList();
                })
          ],
        ),
        body: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  _buildName(),
                  Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 30.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Kategoria",
                              style: TextStyle(fontSize: 13.5)))),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildCategory())),
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
                  buttonWidget(context, "Zapisz zmiany", _verifyChanges)
                ]))));
  }

  _saveChanges(bool changedName, bool changedCategory) async {
    var name = changedName ? _editingNameController.text : null;
    var category = changedCategory ? dropdownSelectedItem : null;
    try {
      var res = await widget.api.editSensor(
          widget.sensor.id, name, category, widget.currentLoggedInToken);
      Navigator.of(context).pop(false);
      if (res['statusCode'] == "200") {
        var snackBar = SnackBar(content: Text("Zapisano dane czujnika."));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      } else if (res['body']
          .contains("Sensor with provided name already exists")) {
        displayDialog(
            context, "Błąd", "Czujnik o podanej nazwie już istnieje.");
      }
    } catch (e) {
      print(e);
    }
  }

  /// confirms saving account changes
  _confirmSavingChanges(bool changedName, bool changedCategory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Potwierdź"),
          content: Text("Czy na pewno zapisać zmiany?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              key: Key("yesButton"),
              child: Text("Tak"),
              onPressed: () async {
                await _saveChanges(changedName, changedCategory);
              },
            ),
            FlatButton(
              key: Key("noButton"),
              child: Text("Nie"),
              onPressed: () async {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  /// verifies data changes
  _verifyChanges() async {
    var name = _editingNameController.text;
    var category = dropdownSelectedItem;
    var changedName = false;
    var changedCategory = false;

    final formState = _formKey.currentState;
    if (formState.validate()) {
      /// sends request only if data changed
      if (name != widget.sensor.name) {
        changedName = true;
      }
      if (category != widget.sensor.category) {
        changedCategory = true;
      }
      if (changedName || changedCategory) {
        await _confirmSavingChanges(changedName, changedCategory);
      } else {
        var snackBar =
            SnackBar(content: Text("Nie wprowadzono żadnych zmian."));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }
  }
}
