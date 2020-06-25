import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/utils/menu_items.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/dialog.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/widgets/text_color.dart';

/// allows editing account
class EditAccount extends StatefulWidget {
  EditAccount(
      {Key key,
      @required this.currentLoggedInToken,
      @required this.account,
      @required this.currentUser,
      @required this.api,
      @required this.onSignedOut})
      : super(key: key);
  final String currentLoggedInToken;
  Api api;
  final Account account;
  final Account currentUser;
  VoidCallback onSignedOut;

  @override
  _EditAccountState createState() => new _EditAccountState();
}

class _EditAccountState extends State<EditAccount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final GlobalKey<State> _keyLoaderInvalidToken = new GlobalKey<State>();
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
          hintText: "Podaj adres e-mail",
        ),
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
          hintText: "Podaj nr telefonu komórkowego",
        ),
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
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
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
            context: context,
            title: "Błąd",
            text: "Wylogowanie nie powiodło się. Spróbuj ponownie.");
      }
    } catch (e) {
      print(e);
      if (e.toString().contains("TimeoutException")) {
        displayDialog(
            context: context,
            title: "Błąd wylogowania",
            text: "Sprawdź połączenie z serwerem i spróbuj ponownie.");
      }
      if (e.toString().contains("SocketException")) {
        await displayDialog(
            context: context,
            title: "Błąd wylogowania",
            text: "Adres serwera nieprawidłowy.");
        widget.onSignedOut();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  /// navigates according to menu choice
  void _choiceAction(String choice) async {
    if (choice == "Moje konto" &&
        widget.currentUser.username != widget.account.username) {
      var result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditAccount(
                  currentLoggedInToken: widget.currentLoggedInToken,
                  account: widget.currentUser,
                  currentUser: widget.currentUser,
                  api: widget.api,
                  onSignedOut: widget.onSignedOut),
              fullscreenDialog: true));
      setState(() {
        widget.onSignedOut = result;
      });
    } else if (choice == "Konta") {
      Map<String, dynamic> result = {
        'onSignedOut': widget.onSignedOut,
        'dataSaved': false
      };
      Navigator.of(context).pop(result);
    } else if (choice == "Wyloguj") {
      _logOut();
    }
  }

  Future<bool> _onBackButton() async {
    Map<String, dynamic> result = {
      'onSignedOut': widget.onSignedOut,
      'dataSaved': false
    };
    Navigator.of(context).pop(result);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackButton,
        child: Scaffold(
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
            body: Container(
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
                                    left: 30.0,
                                    top: 13.5,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Adres e-mail",
                                        style: TextStyle(
                                            color: textColor,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold)))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 0.0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _buildEmail())),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 0.0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Nr telefonu",
                                        style: TextStyle(
                                            color: textColor,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold)))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 0.0,
                                    right: 30.0,
                                    bottom: 0.0),
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
            ]))));
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
      var res = await widget.api.editAccount(
          widget.account.id, email, telephone, widget.currentLoggedInToken);
      var loginExists = false;
      var emailExists = false;
      var emailInvalid = false;
      var telephoneExists = false;
      var telephoneInvalid = false;

      if (res['statusCode'] == "200") {
        Map<String, dynamic> result = {
          'onSignedOut': widget.onSignedOut,
          'dataSaved': true
        };
        Navigator.of(context).pop(result);
      } else if (res['statusCode'] == "401") {
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
      if (res['body'].contains("Username already exists")) {
        loginExists = true;
      }
      if (res['body'].contains("Email address already exists")) {
        emailExists = true;
      }
      if (res['body'].contains("Enter a valid email address")) {
        emailInvalid = true;
      }
      if (res['body'].contains("Enter a valid phone number")) {
        telephoneInvalid = true;
      }
      if (res['body'].contains("Telephone number already exists")) {
        telephoneExists = true;
      }
      String errorText = "";
      if (loginExists && emailExists && telephoneExists)
        errorText =
            "Konto dla podanego loginu, adresu e-mail i nr telefonu już istnieje.";
      else if (loginExists && emailExists)
        errorText = "Konto dla podanego loginu i adresu e-mail już istnieje.";
      else if (loginExists && telephoneExists)
        errorText = "Konto dla podanego loginu i nr telefonu już istnieje.";
      else if (emailExists && telephoneExists)
        errorText =
            "Konto dla podanego adresu e-mail i nr telefonu już istnieje.";
      else if (emailExists)
        errorText = "Konto dla podanego adresu e-mail już istnieje.";
      else if (loginExists)
        errorText = "Konto dla podanego loginu już istnieje.";
      else if (telephoneExists)
        errorText = "Konto dla podanego nr telefonu już istnieje.";

      if (telephoneInvalid && emailInvalid)
        errorText += "Podaj poprawny adres e-mail i nr telefonu.";
      else if (telephoneInvalid)
        errorText += "Podaj poprawny nr telefonu.";
      else if (emailInvalid) errorText += "Podaj poprawny adres e-mail.";

      if (errorText != "")
        displayDialog(context: context, title: "Błąd", text: errorText);

      setState(() {
        _load = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        _load = false;
      });
      if (e.toString().contains("TimeoutException")) {
        displayDialog(
            context: context,
            title: "Błąd edycji użytkownika",
            text: "Sprawdź połączenie z serwerem i spróbuj ponownie.");
      }
      if (e.toString().contains("SocketException")) {
        await displayDialog(
            context: context,
            title: "Błąd edycji użytkownika",
            text: "Adres serwera nieprawidłowy.");
        widget.onSignedOut();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
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
