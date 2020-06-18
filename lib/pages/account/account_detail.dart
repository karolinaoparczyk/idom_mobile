import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/utils/menu_items.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/dialog.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/widgets/text_color.dart';

import 'accounts.dart';
import 'edit_account.dart';

/// displays account details
class AccountDetail extends StatefulWidget {
  AccountDetail(
      {Key key,
      @required this.currentLoggedInToken,
      @required this.account,
      @required this.currentUser,
      @required this.api})
      : super(key: key);
  final String currentLoggedInToken;
  final Api api;
  Account account;
  final Account currentUser;

  @override
  _AccountDetailState createState() => new _AccountDetailState();
}

class _AccountDetailState extends State<AccountDetail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _load;

  TextEditingController _emailController;
  TextEditingController _telephoneController;

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
    if (choice == "Moje konto" && widget.currentUser.username != widget.account.username) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AccountDetail(
                  currentLoggedInToken: widget.currentLoggedInToken,
                  account: widget.currentUser,
                  currentUser: widget.currentUser,
                  api: widget.api),
              fullscreenDialog: true));
    } else if (choice == "Konta") {
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
                  return widget.currentUser.isStaff
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
        body: SingleChildScrollView(
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
                          child: Text("Login",
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 13.5, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(widget.account.username,
                              style: TextStyle(fontSize: 17.0)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 10, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Adres E-mail",
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 14, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_emailController.text,
                              style: TextStyle(fontSize: 17.0)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 14, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Nr telefonu",
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 13.5, right: 30.0, bottom: 15.5),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_telephoneController.text,
                              style: TextStyle(fontSize: 17.0)))),
                  buttonWidget(context, "Edytuj konto", _navitageToEditAccount)
                ]))));
  }
  _navitageToEditAccount() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditAccount(
                currentLoggedInToken: widget.currentLoggedInToken,
                currentUser: widget.currentUser,
                account: widget.account,
                api: widget.api),
            fullscreenDialog: true));

    if (result != null && result == true) {
      var snackBar = SnackBar(content: Text("Zapisano dane użytkownika."));
      _scaffoldKey.currentState.showSnackBar(snackBar);

      setState(() {
        _load = true;
      });

      await _refreshAccountDetails();

      setState(() {
        _load = false;
      });
    }
  }

  _refreshAccountDetails() async {
    var res = await widget.api
        .getUser(widget.account.username, widget.currentLoggedInToken);
    if (res[1] == 200) {
      dynamic body = jsonDecode(res[0]);
      Account account = Account.fromJson(body);
      setState(() {
        _emailController = TextEditingController(text: account.email);
        _telephoneController =
            TextEditingController(text: account.telephone);
        widget.account = account;
      });
    } else {
      displayDialog(
          context, "Błąd", "Odświeżenie danych użytkownika nie powiodło się.");
    }
  }
}
