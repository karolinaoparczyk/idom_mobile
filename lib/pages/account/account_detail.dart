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

import 'edit_account.dart';

/// displays account details
class AccountDetail extends StatefulWidget {
  AccountDetail({@required this.storage, @required this.username});

  final SecureStorage storage;
  String username;

  @override
  _AccountDetailState createState() => new _AccountDetailState();
}

class _AccountDetailState extends State<AccountDetail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final Api api = Api();
  Account account;
  bool _load;
  Map<String, dynamic> currentUserData;

  @override
  void initState() {
    super.initState();
    _load = true;
    getCurrentUserData();
  }

  Future<void> getCurrentUserData() async {
    currentUserData = await widget.storage.getCurrentUserData();
    await getUser();
  }

  Future<void> getUser() async {
    if (widget.username == currentUserData['username']) {
      account = Account(
          id: int.parse(currentUserData['id']),
          username: currentUserData['username'],
          email: currentUserData['email'],
          telephone: currentUserData['telephone'] != null? currentUserData['telephone'] : "",
          isStaff: currentUserData['isStaff'] == "true" ? true : currentUserData['isStaff'] == "false" ? false : null,
          smsNotifications: currentUserData['smsNotifications'],
          appNotifications: currentUserData['appNotifications'],
          isActive: currentUserData['isActive'] == "true" ? true : currentUserData['isActive'] == "false" ? false : null);
      setState(() {
        _load = false;
      });
      return;
    }
    var userResult =
        await api.getUser(widget.username, currentUserData['token']);
    if (userResult[1] == 200) {
      dynamic body = jsonDecode(userResult[0]);
      account = Account.fromJson(body);

      setState(() {
        _load = false;
      });
    }
    if (userResult[1] == 401) {
      setState(() {
        _load = false;
      });
      final snackBar = new SnackBar(
          content: new Text("Błąd pobierania danych użytkownika."));
      ScaffoldMessenger.of(context).showSnackBar((snackBar));
    }
  }

  /// logs the user out from the app
  _logOut() async {
    try {
      displayProgressDialog(
          context: _scaffoldKey.currentContext,
          key: _keyLoader,
          text: "Trwa wylogowywanie...");
      var statusCode = await api.logOut(currentUserData['token']);
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      if (statusCode == 200 || statusCode == 404 || statusCode == 401) {
        await widget.storage.resetUserData();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (statusCode == null) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd wylogowywania. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      } else {
        final snackBar = new SnackBar(
            content:
                new Text("Wylogowanie nie powiodło się. Spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    } catch (e) {
      print(e);
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd wylogowywania. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content:
                new Text("Błąd wylogowywania. Adres serwera nieprawidłowy."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    }
  }

  Future<bool> _onBackButton() async {
    Navigator.pop(context);
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
                actions: [
                  IconButton(
                      icon: Icon(Icons.edit), onPressed: _navigateToEditAccount)
                ]),
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
                          ])))));
  }

  _navigateToEditAccount() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditAccount(storage: widget.storage, account: account),
            fullscreenDialog: true));

    if (result == true) {
      final snackBar =
          new SnackBar(content: new Text("Zapisano dane użytkownika."));
      ScaffoldMessenger.of(context).showSnackBar((snackBar));
      await _refreshAccountDetails();
    }
  }

  _refreshAccountDetails() async {
    try {
      setState(() {
        _load = true;
      });
      var res = await api.getUser(widget.username, currentUserData['token']);
      if (res[1] == 200) {
        dynamic body = jsonDecode(res[0]);
        account = Account.fromJson(body);
        setState(() {});
      } else if (res[1] == 401) {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoader,
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...");
        await new Future.delayed(const Duration(seconds: 3));
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        await widget.storage.resetUserData();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        final snackBar = new SnackBar(
            content:
                new Text("Odświeżenie danych użytkownika nie powiodło się."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _load = false;
      });
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych użytkownika. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych użytkownika. Adres serwera nieprawidłowy."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    }
  }
}
