import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/utils/menu_items.dart';
import 'package:idom/widgets/dialog.dart';
import 'package:idom/widgets/text_color.dart';

/// displays all accounts
class Accounts extends StatefulWidget {
  Accounts(
      {Key key,
      @required this.currentLoggedInToken,
      @required this.currentUser,
      @required this.api,
      @required this.onSignedOut,
      this.testAccounts})
      : super(key: key);
  final String currentLoggedInToken;
  final Account currentUser;
  Api api;
  final List<Account> testAccounts;
  VoidCallback onSignedOut;

  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  void initState() {
    super.initState();
    if (widget.api == null) {
      widget.api = Api();
    }
  }

  /// returns list of accounts
  Future<List<Account>> getAccounts() async {
    /// if widget is being tested
    if (widget.testAccounts != null) {
      return widget.testAccounts;
    }
    List<Account> accounts = List<Account>();
    try {
      var res = await widget.api.getAccounts(widget.currentLoggedInToken);

      if (res != null && res['statusCode'] == "200") {
        List<dynamic> body = jsonDecode(res['body']);

        accounts = body
            .map((dynamic item) => Account.fromJson(item))
            .where((account) => account.isActive == true)
            .toList();
      } else {
        throw "Can't get posts";
      }
    } catch (e) {
      print(e.toString());
    }
    return accounts;
  }

  /// deactivates user after confirmation
  _deactivateAccount(Account account) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Usuwanie konta"),
          content:
              Text("Czy na pewno chcesz usunąć konto ${account.username}?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              key: Key("yesButton"),
              child: Text("Tak"),
              onPressed: () async {
                try {
                  Navigator.of(context).pop(true);
                  displayProgressDialog(
                      context: _scaffoldKey.currentContext,
                      key: _keyLoader,
                      text: "Trwa usuwanie konta...");
                  var statusCode = await widget.api.deactivateAccount(
                      account.id, widget.currentLoggedInToken);
                  Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                      .pop();

                  if (statusCode == 200) {
                    setState(() {
                      /// refreshes accounts' list
                      getAccounts();
                    });
                  } else if (statusCode == null) {
                    displayDialog(
                        context: _scaffoldKey.currentContext,
                        title: "Błąd usuwania konta",
                        text:
                            "Sprawdź połączenie z serwerem i spróbuj ponownie.");
                  } else {
                    displayDialog(
                        context: _scaffoldKey.currentContext,
                        title: "Błąd",
                        text:
                            "Usunięcie użytkownika nie powiodło się. Spróbuj ponownie.");
                  }
                } catch (e) {
                  print(e.toString());
                  Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                      .pop();

                  if (e.toString().contains("TimeoutException")) {
                    displayDialog(
                        context: context,
                        title: "Błąd usuwania konta",
                        text:
                            "Sprawdź połączenie z serwerem i spróbuj ponownie.");
                  }
                }
              },
            ),
            FlatButton(
              key: Key("noButton"),
              child: Text("Nie"),
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  /// logs the user out of the app
  _logOut() async {
    try {
      displayProgressDialog(
          context: _scaffoldKey.currentContext,
          key: _keyLoader,
          text: "Trwa wylogowywanie...");
      var statusCode = await widget.api.logOut(widget.currentLoggedInToken);
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      if (statusCode == 200) {
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
    }
  }

  /// navigates according to menu choice
  /// we are already on accounts page,
  /// so if user choses accounts in menu, nothing happens
  void _choiceAction(String choice) async {
    if (choice == "Moje konto") {
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
            title: Text('IDOM Konta w systemie'),
            actions: <Widget>[
              PopupMenuButton(
                  key: Key("menuButton"),
                  offset: Offset(0, 100),
                  onSelected: _choiceAction,
                  itemBuilder: (BuildContext context) {
                    return menuChoicesSuperUser.map((String choice) {
                      return PopupMenuItem(
                          key: Key(choice), value: choice, child: Text(choice));
                    }).toList();
                  })
            ],
          ),

          /// accounts' list builder
          body: FutureBuilder(
              future: getAccounts(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Account>> snapshot) {
                if (snapshot.data != null && snapshot.data.length == 0) {
                  return Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                              "Brak kont w systemie \nlub błąd połączenia z serwerem.",
                              style: TextStyle(fontSize: 13.5),
                              textAlign: TextAlign.center)));
                }
                if (snapshot.hasData) {
                  List<Account> accounts = snapshot.data;
                  return Column(children: <Widget>[
                    /// A widget with the list of accounts
                    Expanded(
                        flex: 16,
                        child: Scrollbar(
                            child: ListView.separated(
                          separatorBuilder: (context, index) => Divider(
                            color: textColor,
                          ),
                          shrinkWrap: true,
                          itemCount: accounts.length,
                          itemBuilder: (context, index) => ListTile(
                              key: Key(accounts[index].username),
                              title: Text(accounts[index].username,
                                  style: TextStyle(fontSize: 20.0)),

                              /// when username tapped, navigates to account's details
                              onTap: () =>
                                  navigateToAccountDetails(accounts[index]),

                              /// delete account button
                              trailing: deleteButtonTrailing(accounts[index])),
                        ))),
                    Expanded(flex: 1, child: Divider()),
                  ]);
                }

                /// shows progress indicator while fetching data
                return Center(child: CircularProgressIndicator());
              }),
        ));
  }

  navigateToAccountDetails(Account account) async {
    var result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AccountDetail(
            currentLoggedInToken: widget.currentLoggedInToken,
            account: account,
            currentUser: widget.currentUser,
            api: widget.api,
            onSignedOut: widget.onSignedOut)));
    setState(() {
      widget.onSignedOut = result;
    });
  }

  /// delete account button
  deleteButtonTrailing(Account account) {
    if (widget.currentUser.isStaff) {
      return SizedBox(
          width: 35,
          child: Container(
              alignment: Alignment.centerRight,
              child: FlatButton(
                key: Key("deleteButton"),
                child: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _deactivateAccount(account);
                  });
                },
              )));
    } else
      return null;
  }
}
