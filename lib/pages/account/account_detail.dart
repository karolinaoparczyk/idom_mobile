import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/setup/front.dart';
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

  TextEditingController _editingUsernameController;
  TextEditingController _editingEmailController;
  TextEditingController _editingTelephoneController;

  Widget _buildUsername() {
    return TextFormField(
        key: Key('username'),
        controller: _editingUsernameController,
        decoration: InputDecoration(
          labelText: 'Login',
          labelStyle: TextStyle(color: Colors.black, fontSize: 18),
        ),
        maxLength: 25,
        validator: UsernameFieldValidator.validate);
  }

  Widget _buildEmail() {
    return TextFormField(
        key: Key('email'),
        controller: _editingEmailController,
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: TextStyle(color: Colors.black, fontSize: 18),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: EmailFieldValidator.validate);
  }

  Widget _buildTelephone() {
    return TextFormField(
        key: Key('telephone'),
        controller: _editingTelephoneController,
        decoration: InputDecoration(
            labelText: 'Nr telefonu komórkowego',
            labelStyle: TextStyle(color: Colors.black, fontSize: 18)),
        keyboardType: TextInputType.phone,
        validator: TelephoneFieldValidator.validate);
  }

  @override
  void initState() {
    super.initState();
    _editingUsernameController =
        TextEditingController(text: widget.account.username);
    _editingEmailController = TextEditingController(text: widget.account.email);
    _editingTelephoneController =
        TextEditingController(text: widget.account.telephone);
  }

  @override
  void dispose() {
    _editingUsernameController.dispose();
    _editingEmailController.dispose();
    _editingTelephoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text(widget.account.username), actions: <Widget>[
          IconButton(
            key: Key("logOut"),
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              try {
                var statusCode =
                    await widget.api.logOut(widget.currentLoggedInToken);
                if (statusCode == 200) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Front(),
                          fullscreenDialog: true));
                } else {
                  displayDialog(context, "Błąd",
                      "Wylogowanie nie powiodło się. Spróbuj ponownie.");
                }
              } catch (e) {
                print(e);
              }
            },
          ),
        ]),
        body: SingleChildScrollView(
            child: Row(children: <Widget>[
          Expanded(child: SizedBox(width: 1)),
          Expanded(
              flex: 7,
              child: Form(
                  key: _formKey,
                  child: Column(children: <Widget>[
                    _buildUsername(),
                    _buildEmail(),
                    _buildTelephone(),
                    SizedBox(height: 20),
                    buttonWidget(context, "Zapisz zmiany", _verifyChanges)
                  ]))),
          Expanded(child: SizedBox(width: 1))
        ])));
  }

  _saveChanges() async {
    try {
      var res = await widget.api.editAccount(
          widget.account.id,
          _editingUsernameController.text,
          _editingEmailController.text,
          _editingTelephoneController.text);
      if (res == 200){
        var snackBar = SnackBar(content: Text("Zapisano dane konta."));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
      else{
        var snackBar = SnackBar(content: Text("Wystąpił błąd podczas próby zapisu."));
        _scaffoldKey.currentState.showSnackBar(snackBar);
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
                Navigator.of(context).pop(false);
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
    var username = _editingUsernameController.text;
    var email = _editingEmailController.text;
    var telephone = _editingTelephoneController.text;

    final formState = _formKey.currentState;
    if (formState.validate()) {
      /// sends request only if data changed
      if (username != widget.account.username ||
          email != widget.account.email ||
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
