import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/utils/menu_items.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/dialog.dart';

class NewSensor extends StatefulWidget {
  NewSensor(
      {Key key,
      @required this.currentLoggedInToken,
      @required this.currentLoggedInUsername,
      @required this.api})
      : super(key: key);
  final String currentLoggedInToken;
  final String currentLoggedInUsername;
  final Api api;

  @override
  _NewSensorState createState() => new _NewSensorState();
}

class _NewSensorState extends State<NewSensor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _editingNameController = TextEditingController();
  var dropdownSelectedItem;

  List<DropdownMenuItem<String>> categories;

  @override
  void initState() {
    super.initState();

    categories = [
      DropdownMenuItem(
          child: Text("Temperatura"),
          value: "temperature",
          key: Key("temperature")),
      DropdownMenuItem(
          child: Text("Wilgotność"), value: "humidity", key: Key("humidity"))
    ];
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
            autofocus: true,
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
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Dodaj czujnik"),
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
                  Divider(),
                  buttonWidget(context, "Dodaj czujnik", _saveChanges)
                ]))));
  }

  _saveChanges() async {
    final formState = _formKey.currentState;
    if (dropdownSelectedItem == null) {
      await displayDialog(
          context, "Brak danych", "Wybierz kategorię czujnika.");
    }
    if (formState.validate()) {
      try {
        var res = await widget.api.addSensor(_editingNameController.text,
            dropdownSelectedItem, widget.currentLoggedInToken);
        if (res['statusCode'] == "201") {
          Navigator.of(context).pop(true);
        } else if (res['body']
            .contains("Sensor with provided name already exists")) {
          displayDialog(
              context, "Błąd", "Czujnik o podanej nazwie już istnieje.");
        }
      } catch (e) {
        print(e);
      }
    }
  }
}
