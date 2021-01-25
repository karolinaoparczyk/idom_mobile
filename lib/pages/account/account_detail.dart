import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/enums/languages.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/edit_account.dart';
import 'package:idom/utils/login_procedures.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/localization/account/account_details.i18n.dart';

/// displays account details
class AccountDetail extends StatefulWidget {
  AccountDetail(
      {@required this.storage, @required this.username, this.testApi});

  /// internal storage
  final SecureStorage storage;

  /// selected user's username
  String username;

  /// api used for tests
  final Api testApi;

  /// handles state of widgets
  @override
  _AccountDetailState createState() => new _AccountDetailState();
}

/// handles state of widgets
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
  String fieldsValidationMessage;

  @override
  void initState() {
    super.initState();

    /// use test api when in test mode
    if (widget.testApi != null) {
      api = widget.testApi;
    }

    LoginProcedures.init(widget.storage, api);

    /// show loading indicator while fetching data
    _load = true;
    getCurrentUserData();
  }

  Future<void> getCurrentUserData() async {
    currentUserData = await widget.storage.getCurrentUserData();
    await getUser();
  }

  Future<void> getUser() async {
    /// if selected user is currently logged in user, use stored data
    if (widget.username == currentUserData['username']) {
      account = Account(
          id: int.parse(currentUserData['id']),
          username: currentUserData['username'],
          email: currentUserData['email'],
          language: currentUserData['language'],
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
        /// stop loading and display data
        _load = false;

        /// set values for notifications switches
        appNotificationsOn = account.appNotifications;
        smsNotificationsOn = account.smsNotifications;
      });
      return;
    }

    /// if selected user not currently logged in, get user data
    var userResult = await api.getUser(widget.username);

    /// on error while fetching user data
    ///
    /// set selected user data and display
    if (userResult[1] == 200) {
      dynamic body = jsonDecode(userResult[0]);
      account = Account.fromJson(body);

      setState(() {
        /// stop loading and display data
        _load = false;

        /// set values for notifications switches
        appNotificationsOn = account.appNotifications;
        smsNotificationsOn = account.smsNotifications;
      });
    }

    /// on invalid token log out
    else if (userResult[1] == 401) {
      final message = await LoginProcedures.signInWithStoredData();
      if (message != null) {
        logOut();
      } else {
        var userResult = await api.getUser(widget.username);

        if (userResult[1] == 200) {
          dynamic body = jsonDecode(userResult[0]);
          account = Account.fromJson(body);

          setState(() {
            /// stop loading and display data
            _load = false;

            /// set values for notifications switches
            appNotificationsOn = account.appNotifications;
            smsNotificationsOn = account.smsNotifications;
          });
        } else if (userResult[1] == 401) {
          logOut();
        } else {
          setState(() {
            _load = false;
          });
          final snackBar = new SnackBar(
              content: new Text("Błąd pobierania danych użytkownika.".i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      }
    }

    /// on error while fetching user data
    ///
    /// stop loading and show error message
    else {
      setState(() {
        _load = false;
      });
      final snackBar = new SnackBar(
          content: new Text("Błąd pobierania danych użytkownika.".i18n));
      _scaffoldKey.currentState.showSnackBar((snackBar));
    }
  }

  Future<void> logOut() async {
    displayProgressDialog(
        context: _scaffoldKey.currentContext,
        key: _keyLoader,
        text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
    await new Future.delayed(const Duration(seconds: 3));
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    await widget.storage.resetUserData();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// on back button clicked goes to previous page
  Future<bool> _onBackButton() async {
    Navigator.pop(context);
    return true;
  }

  /// builds pop-up dialog
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackButton,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(title: Text(widget.username), actions: [
              /// got to edit selected account
              IconButton(
                  key: Key("editAccount"),
                  icon: Icon(Icons.edit),
                  onPressed: _navigateToEditAccount)
            ]),

            /// drawer with menu
            drawer: IdomDrawer(
                storage: widget.storage,
                parentWidgetType: "AccountDetail",
                testApi: widget.testApi,
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

                            /// general info
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
                                            size: 21),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: Text("Ogólne".i18n,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1),
                                        ),
                                      ],
                                    ))),

                            /// username
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 62,
                                    top: 10.0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Nazwa użytkownika".i18n,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 62,
                                    top: 0.0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(account.username,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2))),

                            /// e-mail address
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 62,
                                    top: 10,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Adres e-mail".i18n,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 62, top: 0, right: 30.0, bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(account.email,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2))),

                            /// cell phone number
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 62,
                                    top: 10,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Nr telefonu komórkowego".i18n,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 62,
                                    top: 0.0,
                                    right: 30.0,
                                    bottom: 10),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        account.telephone != null &&
                                                account.telephone != ""
                                            ? account.telephone
                                            : "-",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2))),
                            Divider(),

                            /// notifications
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 10.0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                            Icons.notifications_active_outlined,
                                            size: 21),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: Text("Powiadomienia".i18n,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1),
                                        ),
                                      ],
                                    ))),

                            /// language
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 62,
                                    top: 10,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Język powiadomień".i18n,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 62, top: 0, right: 30.0, bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        Languages.values
                                            .firstWhere((element) =>
                                                element['value'] ==
                                                account.language)['text']
                                            .i18n,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2))),

                            /// switches allowing turning notifications on/off
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 62,
                                    top: 0.0,
                                    right: 0.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        /// push notifications triggered by sensors
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("Aplikacja".i18n,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2),
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

                                        /// sms notifications triggered by sensors
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("Sms",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2),
                                            Switch(
                                              key: Key("smsNotifications"),
                                              value: smsNotificationsOn,
                                              onChanged: (value) async {
                                                if ((account.telephone ==
                                                            null ||
                                                        account.telephone ==
                                                            "") &&
                                                    value) {
                                                  setState(() {
                                                    fieldsValidationMessage =
                                                        "Nalezy dodać numer telefonu."
                                                            .i18n;
                                                  });
                                                  return;
                                                }
                                                setState(() {
                                                  smsNotificationsOn = value;
                                                  fieldsValidationMessage =
                                                      null;
                                                });
                                                await _updateNotifications();
                                              },
                                            )
                                          ],
                                        ),
                                      ],
                                    ))),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 62.0),
                              child: AnimatedCrossFade(
                                crossFadeState:
                                    fieldsValidationMessage != null &&(
                                            account.telephone == null ||
                                            account.telephone == "")
                                        ? CrossFadeState.showFirst
                                        : CrossFadeState.showSecond,
                                duration: Duration(milliseconds: 300),
                                firstChild: fieldsValidationMessage != null
                                    ? Text(fieldsValidationMessage,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1)
                                    : SizedBox(),
                                secondChild: SizedBox(),
                              ),
                            ),
                          ])))));
  }

  /// on turning notifications on/off
  _updateNotifications() async {
    var result = await api.editNotifications(account.id,
        appNotificationsOn.toString(), smsNotificationsOn.toString());

    /// on success set notifications in storage if selected account is current user
    if (result != null &&
        result['statusCode'] == "200" &&
        currentUserData['username'] == widget.username) {
      widget.storage.setAppNotifications(appNotificationsOn.toString());
      widget.storage.setSmsNotifications(smsNotificationsOn.toString());
    }

    /// on error display message
    if (result != null && result['statusCode'] != "200") {
      final snackBar = new SnackBar(
          content: new Text("Błąd edycji powiadomień. Spróbuj ponownie.".i18n));
      _scaffoldKey.currentState.showSnackBar((snackBar));
    }
  }

  /// go to edit account
  _navigateToEditAccount() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditAccount(
                storage: widget.storage,
                account: account,
                testApi: widget.testApi),
            fullscreenDialog: true));

    /// on success editing account display message
    if (result == true) {
      final snackBar =
          new SnackBar(content: new Text("Zapisano dane użytkownika.".i18n));
      _scaffoldKey.currentState.showSnackBar((snackBar));
      await _refreshAccountDetails();
    }
  }

  /// fetch user data and refresh widgets
  _refreshAccountDetails() async {
    try {
      setState(() {
        _load = true;
      });
      var res = await api.getUser(widget.username);

      /// on success set fetched user
      if (res[1] == 200) {
        dynamic body = jsonDecode(res[0]);
        account = Account.fromJson(body);
        setState(() {});

        /// on invalid token log out
      } else if (res[1] == 401) {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoader,
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
        await new Future.delayed(const Duration(seconds: 3));
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        await widget.storage.resetUserData();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

      /// on error display message
      else {
        final snackBar = new SnackBar(
            content: new Text(
                "Odświeżenie danych użytkownika nie powiodło się.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _load = false;
      });

      /// on timeout while sending request display message
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych użytkownika. Sprawdź połączenie z serwerem i spróbuj ponownie."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }

      /// on invalid server address display message
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych użytkownika. Adres serwera nieprawidłowy."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
    setState(() {
      _load = false;
    });
  }
}
