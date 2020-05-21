import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/pages/account/add_account.dart';
import 'package:idom/pages/setup/front.dart';

/// displays all accounts
class Accounts extends StatefulWidget {
  const Accounts(
      {Key key,
      @required this.currentLoggedInToken,
      @required this.currentLoggedInUsername})
      : super(key: key);
  final String currentLoggedInToken;
  final String currentLoggedInUsername;

  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  final String accountsUrl = "http://10.0.2.2:8000/register/";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Api api = Api();

  /// returns list of accounts
  Future<List<Account>> getAccounts() async {
    Response res = await get(accountsUrl);

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);

      List<Account> accounts = body
          .map((dynamic item) => Account.fromJson(item))
          .where((account) => account.isActive == true)
          .toList();
      return accounts;
    } else {
      throw "Can't get posts";
    }
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
              child: Text("Tak"),
              onPressed: () async {
                var statusCode = await api.deactivateAccount(account.id);
                if (statusCode == 204) print("deleted from db");
                setState(() {
                  getAccounts();
                });
                Navigator.of(context).pop(true);
              },
            ),
            FlatButton(
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
      var statusCode = await api.logOut(widget.currentLoggedInToken);
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

  void displayDialog(BuildContext context, String title, String text) =>
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            leading: Container(),
            title: Text('IDOM Konta w systemie'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: _logOut,
              ),
            ],
          ),
          body: FutureBuilder(
              future: getAccounts(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Account>> snapshot) {
                if (snapshot.hasData) {
                  List<Account> accounts = snapshot.data;
                  return Column(children: <Widget>[
                    Expanded(
                        flex: 1,
                        child:
                            Text("Liczba wszystkich kont: ${accounts.length}")),

                    /// A widget with the list of accounts
                    Expanded(
                        flex: 16,
                        child: Scrollbar(
                            child: ListView(
                          shrinkWrap: true,
                          children: accounts
                              .map(
                                (Account account) => ListTile(
                                    title: Text(account.username),
                                    onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => AccountDetail(
                                                currentLoggedInToken:
                                                    widget.currentLoggedInToken,
                                                account: account))),

                                    /// delete account button
                                    trailing: FlatButton(
                                      child: Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          _deactivateAccount(account);
                                        });
                                      },
                                    )),
                              )
                              .toList(),
                        ))),
                    Expanded(flex: 1, child: Divider()),

                    /// add new account button
                    Expanded(
                        flex: 4,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 250,
                                child: RaisedButton(
                                    onPressed: navigateToNewAccount,
                                    child: Text(
                                      'Dodaj nowe konto',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    color: Colors.black,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    elevation: 10,
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(30.0))),
                              ),
                            ]))
                  ]);
                }

                /// shows progress indicator while fetching data
                return Center(child: CircularProgressIndicator());
              }),
        ));
  }

  /// goes to adding new account page
  Future navigateToNewAccount() async {
    bool result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddAccount(
                currentLoggedInToken: widget.currentLoggedInToken, api: api),
            fullscreenDialog: true));

    /// displays success message when the account is successfuly created
    if (result != null && result == true) {
      final snackBar =
          new SnackBar(content: new Text("Konto zostało utworzone"));

      _scaffoldKey.currentState.showSnackBar((snackBar));
    }
  }
}
