import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/utils/menu_items.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/dialog.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/widgets/text_color.dart';

/// allows editing account
class EditAccount extends StatefulWidget {
  EditAccount({Key key,
    @required this.currentLoggedInToken,
    @required this.account,
    @required this.currentUser,
    @required this.api})
      : super(key: key);
  final String currentLoggedInToken;
  final Api api;
  final Account account;
  final Account currentUser;

  @override
  _EditAccountState createState() => new _EditAccountState();
}

class _EditAccountState extends State<EditAccount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _load;

  TextEditingController _emailController;
  TextEditingController _telephoneController;

  /// builds email form field
  Widget _buildEmail() {
    return TextFormField(
        key: Key('email'),
        controller: _emailController,
        autofocus: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Podaj adres e-mail",),
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(fontSize: 17.0),
        validator: EmailFieldValidator.validate);
  }

  /// builds telephone form field
  Widget _buildTelephone() {
    return TextFormField(
            key: Key('telephone'),
            style: TextStyle(fontSize: 17.0),
            controller: _telephoneController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Podaj nr telefonu komórkowego",),
            keyboardType: TextInputType.phone,
            validator: TelephoneFieldValidator.validate);
  }

  @override
  void initState() {
    super.initState();
    _load = false;
    _emailController = TextEditingController(text: widget.account.email);
    _telephoneController =
        TextEditingController(text: widget.account.telephone);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  /// logs the user out from the app
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

  /// navigates according to menu choice
  void _choiceAction(String choice) {
    if (choice == "Moje konto" &&
        widget.currentUser.username != widget.account.username) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  EditAccount(
                      currentLoggedInToken: widget.currentLoggedInToken,
                      account: widget.currentUser,
                      currentUser: widget.currentUser,
                      api: widget.api),
              fullscreenDialog: true));
    } else if (choice == "Konta") {
      Navigator.pop(context);
    } else if (choice == "Wyloguj") {
      _logOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.account.username),
          actions: <Widget>[

            /// menu dropdown button
            PopupMenuButton(
                key: Key("menuButton"),
                offset: Offset(0, 100),
                onSelected: _choiceAction,
                itemBuilder: (BuildContext context) {
                  /// menu choices from utils/menu_items.dart
                  return widget.account.isStaff
                      ? menuChoicesSuperUser.map((String choice) {
                    return PopupMenuItem(
                        key: Key(choice),
                        value: choice,
                        child: Text(choice));
                  }).toList()
                      : menuChoicesNormalUser.map((String choice) {
                    return PopupMenuItem(
                        key: Key(choice),
                        value: choice,
                        child: Text(choice));
                  }).toList();
                })
          ],
        ),
        body:  Container(
        child: Column(children: <Widget>[
        Expanded(
        flex: 4,
        child: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  Align(
                    child: loadingIndicator(_load),
                    alignment: FractionalOffset.center,
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 13.5, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Adres E-mail",
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold)))),

                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 0.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildEmail())),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 0.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Nr telefonu",
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 0.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildTelephone())),
                ])))),
          Expanded(
              flex: 1,
              child: AnimatedContainer(
                  curve: Curves.easeInToLinear,
                  duration: Duration(
                    milliseconds: 10,
                  ),
                  alignment: Alignment.bottomCenter,
                  child: Column(children: <Widget>[
                    buttonWidget(context, "Zapisz zmiany", _verifyChanges),
                  ])))
        ])));
  }

  /// saves changes or displays error dialogs
  _saveChanges(bool changedEmail, bool changedTelephone) async {
    var email = changedEmail ? _emailController.text : null;
    var telephone = changedTelephone ? _telephoneController.text : null;
    setState(() {
      _load = true;
    });
    try {
      Navigator.of(context).pop(true);
      var res =
      await widget.api.editAccount(widget.account.id, email, telephone, widget.currentLoggedInToken);
      if (res['statusCode'] == "200") {
        Navigator.of(context).pop(true);
      } else if (res['body'].contains("User with given email already exists")) {
        displayDialog(
            context, "Błąd", "Konto dla podanego adresu email już istnieje.");
      } else if (res['body'].contains("Enter a valid phone number")) {
        displayDialog(context, "Błąd", "Numer telefonu jest niepoprawny.");
      } else if (res['body']
          .contains("User with given telephone number already exists")) {
        displayDialog(context, "Błąd",
            "Konto dla podanego numeru telefonu już istnieje.");
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      _load = false;
    });
  }

  /// confirms saving account changes
  _confirmSavingChanges(bool changedEmail, bool changedTelephone) {
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
                await _saveChanges(changedEmail, changedTelephone);
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
    var email = _emailController.text;
    var telephone = _telephoneController.text;
    var changedEmail = false;
    var changedTelephone = false;

    final formState = _formKey.currentState;
    if (formState.validate()) {
      /// sends request only if data has changed
      if (email != widget.account.email) {
        changedEmail = true;
      }
      if (telephone != widget.account.telephone) {
        changedTelephone = true;
      }
      if (changedEmail || changedTelephone) {
        await _confirmSavingChanges(changedEmail, changedTelephone);
      } else {
        var snackBar =
        SnackBar(content: Text("Nie wprowadzono żadnych zmian."));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }
  }
}
