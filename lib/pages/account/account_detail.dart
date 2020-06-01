import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/utils/menu_items.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/dialog.dart';

class AccountDetail extends StatefulWidget {
  AccountDetail(
      {Key key,
      @required this.currentLoggedInToken,
      @required this.account,
      @required this.api})
      : super(key: key);
  final String currentLoggedInToken;
  final Api api;
  final Account account;

  @override
  _AccountDetailState createState() => new _AccountDetailState();
}

class _AccountDetailState extends State<AccountDetail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _editingEmailController;
  TextEditingController _editingTelephoneController;

  Widget _buildEmail() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
        child: TextFormField(
            key: Key('email'),
            controller: _editingEmailController,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.black, fontSize: 18),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: EmailFieldValidator.validate));
  }

  Widget _buildTelephone() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
        child: TextFormField(
            key: Key('telephone'),
            controller: _editingTelephoneController,
            decoration: InputDecoration(
                labelText: 'Nr telefonu komórkowego',
                labelStyle: TextStyle(color: Colors.black, fontSize: 18)),
            keyboardType: TextInputType.phone,
            validator: TelephoneFieldValidator.validate));
  }

  @override
  void initState() {
    super.initState();
    _editingEmailController = TextEditingController(text: widget.account.email);
    _editingTelephoneController =
        TextEditingController(text: widget.account.telephone);
  }

  @override
  void dispose() {
    _editingEmailController.dispose();
    _editingTelephoneController.dispose();
    super.dispose();
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
      Navigator.pop(context);
    } else if (choice == "Wyloguj") {
      _logOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text(widget.account.username),
          actions: <Widget>[
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
                        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0),
                        child: ListTile(
                      title: Text("Login", style: TextStyle(fontSize: 13.5)),
                      subtitle: Text(widget.account.username,style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    )),
                    _buildEmail(),
                    _buildTelephone(),
                    Divider(),
                    buttonWidget(context, "Zapisz zmiany", _verifyChanges)
                  ])))
        );
  }

  _saveChanges() async {
    try {
      var res = await widget.api.editAccount(widget.account.id,
          _editingEmailController.text, _editingTelephoneController.text);
      Navigator.of(context).pop(false);
      if (res['statusCode'] == "200") {
        var snackBar = SnackBar(content: Text("Zapisano dane konta."));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      } else if (res['body']
          .contains("User with given email already exists")) {
        displayDialog(
            context, "Błąd", "Konto dla podanego adresu email już istnieje.");
      } else if (res['body'].contains("Enter a valid phone number")) {
        displayDialog(context, "Błąd", "Numer telefonu jest niepoprawny.");
      } else if (res['body'].contains("User with given telephone number already exists")) {
        displayDialog(context, "Błąd", "Konto dla podanego numeru telefonu już istnieje.");
      }
    } catch (e) {
      print(e);
    }
  }

  /// confirms saving account changes
  _confirmSavingChanges() {
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
                await _saveChanges();
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
    var email = _editingEmailController.text;
    var telephone = _editingTelephoneController.text;

    final formState = _formKey.currentState;
    if (formState.validate()) {
      /// sends request only if data changed
      if (email != widget.account.email ||
          telephone != widget.account.telephone) {
        await _confirmSavingChanges();
      } else {
        var snackBar =
            SnackBar(content: Text("Nie wprowadzono żadnych zmian."));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }
  }
}
