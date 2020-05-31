import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/utils/menu_items.dart';
import 'package:idom/widgets/dialog.dart';

/// displays all accounts
class Accounts extends StatefulWidget {
  const Accounts(
      {Key key,
      @required this.currentLoggedInToken,
      @required this.currentLoggedInUsername,
      @required this.api,
      this.testAccounts})
      : super(key: key);
  final String currentLoggedInToken;
  final String currentLoggedInUsername;
  final Api api;
  final List<Account> testAccounts;

  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  final String accountsUrl = "http://10.0.2.2:8000/users/list";
  Account currentUser;

  /// returns list of accounts
  Future<List<Account>> getAccounts() async {
    Response res = await get(accountsUrl);

    /// if statement for testing
    if (widget.testAccounts != null) {
      currentUser = widget.testAccounts
          .where(
              (account) => account.username == widget.currentLoggedInUsername)
          .toList()[0];
      return widget.testAccounts;
    }

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);

      List<Account> accounts = body
          .map((dynamic item) => Account.fromJson(item))
          .where((account) => account.isActive == true)
          .toList();
      currentUser = accounts
          .where(
              (account) => account.username == widget.currentLoggedInUsername)
          .toList()[0];
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
              key: Key("yesButton"),
              child: Text("Tak"),
              onPressed: () async {
                var statusCode;
                if (widget.api != null)
                  statusCode = await widget.api.deactivateAccount(
                      account.id, widget.currentLoggedInToken);
                else {
                  Api api = Api();
                  statusCode = await api.deactivateAccount(
                      account.id, widget.currentLoggedInToken);
                }
                if (statusCode == 200) {
                  setState(() {
                    getAccounts();
                  });
                  Navigator.of(context).pop(true);
                } else {
                  displayDialog(context, "Błąd",
                      "Usunięcie użytkownika nie powiodło się. Spróbuj ponownie.");
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
      var statusCode = await widget.api.logOut(widget.currentLoggedInToken);
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

  void _choiceAction(String choice) {
    if (choice == "Wyloguj") {
      _logOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IDOM Konta w systemie'),
        actions: <Widget>[
          PopupMenuButton(
              offset: Offset(0, 100),
              onSelected: _choiceAction,
              itemBuilder: (BuildContext context) {
                return menuChoices.map((String choice) {
                  return PopupMenuItem(value: choice, child: Text(choice));
                }).toList();
              })
        ],
      ),
      body: FutureBuilder(
          future: getAccounts(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Account>> snapshot) {
            if (snapshot.hasData) {
              List<Account> accounts = snapshot.data;
              return Column(children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Text("Liczba wszystkich kont: ${accounts.length}")),

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
                                            account: account,
                                            api: widget.api))),

                                /// delete account button
                                trailing: deleteButtonTrailing(account)),
                          )
                          .toList(),
                    ))),
                Expanded(flex: 1, child: Divider()),
              ]);
            }

            /// shows progress indicator while fetching data
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  deleteButtonTrailing(Account account) {
    if (currentUser.isStaff) {
      return FlatButton(
        key: Key("deleteButton"),
        child: Icon(Icons.delete),
        onPressed: () {
          setState(() {
            _deactivateAccount(account);
          });
        },
      );
    } else
      return null;
  }
}
