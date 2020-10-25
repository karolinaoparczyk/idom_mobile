import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';

import 'accounts.dart';
import 'edit_account.dart';

/// displays account details
class AccountDetail extends StatefulWidget {
  AccountDetail(
      {Key key,
      @required this.currentLoggedInToken,
      @required this.account,
      @required this.currentUser,
      @required this.api,
      @required this.onSignedOut})
      : super(key: key);
  final String currentLoggedInToken;
  Api api;
  Account account;
  final Account currentUser;
  VoidCallback onSignedOut;

  @override
  _AccountDetailState createState() => new _AccountDetailState();
}

class _AccountDetailState extends State<AccountDetail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
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
        final snackBar =
        new SnackBar(content: new Text("Błąd wylogowywania. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      } else {
        final snackBar =
        new SnackBar(content: new Text("Wylogowanie nie powiodło się. Spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    } catch (e) {
      print(e);
      if (e.toString().contains("TimeoutException")) {
        final snackBar =
        new SnackBar(content: new Text("Błąd wylogowywania. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar =
        new SnackBar(content: new Text("Błąd wylogowywania. Adres serwera nieprawidłowy."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
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
              builder: (context) => AccountDetail(
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
      var result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Accounts(
                  currentLoggedInToken: widget.currentLoggedInToken,
                  currentUser: widget.currentUser,
                  api: widget.api,
                  onSignedOut: widget.onSignedOut),
              fullscreenDialog: true));
      setState(() {
        widget.onSignedOut = result;
      });
    } else if (choice == "Wyloguj") {
      _logOut();
    }
  }

  Future<bool> _onBackButton() async {
    Navigator.of(context).pop(widget.onSignedOut);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackButton,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(widget.username),
            ),
            drawer: IdomDrawer(
                storage: widget.storage,
                parentWidgetType: "AccountDetail",
                accountUsername: widget.username),
            body: SingleChildScrollView(
                child: Form(
                    key: _formKey,
                    child: account == null
                        ? Align(
                            child: loadingIndicator(_load),
                            alignment: FractionalOffset.center,
                          )
                        : Column(children: <Widget>[
                            Align(
                              child: loadingIndicator(_load),
                              alignment: FractionalOffset.center,
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 20.0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline_rounded,
                                            size: 17.5),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Text("Ogólne",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.normal)),
                                        ),
                                      ],
                                    ))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 52.5,
                                    top: 10.0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Login",
                                        style: TextStyle(
                                            color: IdomColors.additionalColor,
                                            fontSize: 16.5,
                                            fontWeight: FontWeight.bold)))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 52.5,
                                    top: 0.0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(account.username,
                                        style: TextStyle(fontSize: 21.0)))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 52.5,
                                    top: 10,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Adres e-mail",
                                        style: TextStyle(
                                            color: IdomColors.additionalColor,
                                            fontSize: 16.5,
                                            fontWeight: FontWeight.bold)))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 52.5,
                                    top: 0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(account.email,
                                        style: TextStyle(fontSize: 21.0)))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 52.5,
                                    top: 10,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Nr telefonu komórkowego",
                                        style: TextStyle(
                                            color: IdomColors.additionalColor,
                                            fontSize: 16.5,
                                            fontWeight: FontWeight.bold)))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 52.5,
                                    top: 0,
                                    right: 30.0,
                                    bottom: 15.5),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        account.telephone != ""
                                            ? account.telephone
                                            : "-",
                                        style: TextStyle(fontSize: 21.0)))),
                            buttonWidget(
                                context, "Edytuj konto", _navigateToEditAccount)
                          ])))));
  }

  _navigateToEditAccount() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditAccount(
                currentLoggedInToken: widget.currentLoggedInToken,
                currentUser: widget.currentUser,
                account: widget.account,
                api: widget.api,
                onSignedOut: widget.onSignedOut),
            fullscreenDialog: true));

    if (result == true) {
      final snackBar =
      new SnackBar(content: new Text("Zapisano dane użytkownika."));
      ScaffoldMessenger.of(context).showSnackBar((snackBar));
    }

    setState(() {
      if (result != null) {
        widget.onSignedOut = result['onSignedOut'];
      }
      _load = true;
    });

    await _refreshAccountDetails();

    setState(() {
      _load = false;
    });
  }

  _refreshAccountDetails() async {
    try {
      setState(() {
        _load = true;
      });
      var res = await widget.api
          .getUser(widget.account.username, widget.currentLoggedInToken);
      if (res[1] == 200) {
        dynamic body = jsonDecode(res[0]);
        Account account = Account.fromJson(body);
        setState(() {
          _emailController = TextEditingController(text: account.email);
          _telephoneController = TextEditingController(text: account.telephone);
          widget.account = account;
        });
      } else if (res[1] == 401) {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoader,
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...");
        await new Future.delayed(const Duration(seconds: 3));
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        widget.onSignedOut();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        final snackBar =
        new SnackBar(content: new Text("Odświeżenie danych użytkownika nie powiodło się."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _load = false;
      });
      if (e.toString().contains("TimeoutException")) {
        final snackBar =
        new SnackBar(content: new Text("Błąd pobierania danych użytkownika. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar =
        new SnackBar(content: new Text("Błąd pobierania danych użytkownika. Adres serwera nieprawidłowy."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    }
  }
}
