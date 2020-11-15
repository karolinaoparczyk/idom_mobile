import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';

import 'edit_account.dart';

/// displays account details
class AccountDetail extends StatefulWidget {
  AccountDetail({@required this.storage, @required this.username, this.testApi});

  final SecureStorage storage;
  String username;
  final Api testApi;

  @override
  _AccountDetailState createState() => new _AccountDetailState();
}

class _AccountDetailState extends State<AccountDetail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  Api api = Api();
  Account account;
  bool _load;
  Map<String, dynamic> currentUserData;
  bool appNotificationsOn;
  bool smsNotificationsOn;

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null){
      api = widget.testApi;
    }
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
          telephone: currentUserData['telephone'] != null
              ? currentUserData['telephone']
              : "",
          isStaff: currentUserData['isStaff'] == "true"
              ? true
              : currentUserData['isStaff'] == "false"
                  ? false
                  : null,
          smsNotifications:
              currentUserData['smsNotifications'] == "true" ? true : false,
          appNotifications:
              currentUserData['appNotifications'] == "true" ? true : false,
          isActive: currentUserData['isActive'] == "true"
              ? true
              : currentUserData['isActive'] == "false"
                  ? false
                  : null);
      setState(() {
        _load = false;
        appNotificationsOn = account.appNotifications;
        smsNotificationsOn = account.smsNotifications;
      });
      return;
    }
    var userResult =
        await api.getUser(widget.username);
    if (userResult[1] == 200) {
      dynamic body = jsonDecode(userResult[0]);
      account = Account.fromJson(body);

      setState(() {
        _load = false;
        appNotificationsOn = account.appNotifications;
        smsNotificationsOn = account.smsNotifications;
      });
    }
    if (userResult[1] == 401) {
      setState(() {
        _load = false;
      });
      final snackBar = new SnackBar(
          content: new Text("Błąd pobierania danych użytkownika."));
      _scaffoldKey.currentState.showSnackBar((snackBar));
    }
  }

  onLogOutFailure(String text) {
    final snackBar = new SnackBar(content: new Text(text));
    _scaffoldKey.currentState.showSnackBar((snackBar));
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
            appBar: AppBar(title: Text(widget.username), actions: [
              IconButton(
                  icon: Icon(Icons.edit), onPressed: _navigateToEditAccount)
            ]),
            drawer: IdomDrawer(
                storage: widget.storage,
                parentWidgetType: "AccountDetail",
                accountUsername: widget.username,
                onLogOutFailure: onLogOutFailure),
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
                                    top: 0.0,
                                    right: 30.0,
                                    bottom: 0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        account.telephone != ""
                                            ? account.telephone
                                            : "-",
                                        style: TextStyle(fontSize: 21.0)))),
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
                                        Icon(
                                            Icons.notifications_active_outlined,
                                            size: 17.5),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Text("Powiadomienia",
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
                                    top: 0.0,
                                    right: 0.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("Aplikacja",
                                                style: TextStyle(
                                                    color: IdomColors.textDark,
                                                    fontSize: 16.5,
                                                    fontWeight:
                                                        FontWeight.normal)),
                                            Switch(
                                              key: Key("appNotifications"),
                                              value: appNotificationsOn,
                                              onChanged: (value) async {
                                                setState(() {
                                                  appNotificationsOn = value;
                                                });
                                                await _updateNotifications();
                                              },
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("Sms",
                                                style: TextStyle(
                                                    color: IdomColors.textDark,
                                                    fontSize: 16.5,
                                                    fontWeight:
                                                        FontWeight.normal)),
                                            Switch(
                                              key: Key("smsNotifications"),
                                              value: smsNotificationsOn,
                                              onChanged: (value) async {
                                                setState(() {
                                                  smsNotificationsOn = value;
                                                });
                                                await _updateNotifications();
                                              },
                                            )
                                          ],
                                        )
                                      ],
                                    ))),
                          ])))));
  }

  _updateNotifications() async {
    var result = await api.editNotifications(
        account.id, appNotificationsOn.toString(), smsNotificationsOn.toString());
    if (result != null && result['statusCode'] != "200") {
      final snackBar = new SnackBar(
          content: new Text("Błąd edycji powiadomień. Spróbuj ponownie."));
      _scaffoldKey.currentState.showSnackBar((snackBar));
    }
    widget.storage.setAppNotifications(appNotificationsOn.toString());
    widget.storage.setSmsNotifications(smsNotificationsOn.toString());
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
      _scaffoldKey.currentState.showSnackBar((snackBar));
      await _refreshAccountDetails();
    }
  }

  _refreshAccountDetails() async {
    try {
      setState(() {
        _load = true;
      });
      var res = await api.getUser(widget.username);
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
        _scaffoldKey.currentState.showSnackBar((snackBar));
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
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych użytkownika. Adres serwera nieprawidłowy."));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
    setState(() {
      _load = false;
    });
  }
}
