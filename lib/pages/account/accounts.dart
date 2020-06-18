import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/utils/menu_items.dart';
import 'package:idom/widgets/dialog.dart';
import 'package:idom/widgets/text_color.dart';

/// displays all accounts
class Accounts extends StatefulWidget {
  const Accounts(
      {Key key,
      @required this.currentLoggedInToken,
      @required this.currentUser,
      @required this.api,
      this.testAccounts})
      : super(key: key);
  final String currentLoggedInToken;
  final Account currentUser;
  final Api api;
  final List<Account> testAccounts;

  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  /// returns list of accounts
  Future<List<Account>> getAccounts() async {
    /// if widget is being tested
    if (widget.testAccounts != null) {
      return widget.testAccounts;
    }

    var res = await widget.api.getAccounts(widget.currentLoggedInToken);

    if (res['statusCode'] == "200") {
      List<dynamic> body = jsonDecode(res['body']);

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
                    /// refreshes accounts' list
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

  /// navigates according to menu choice
  /// we are already on accounts page,
  /// so if user choses accounts in menu, nothing happens
  void _choiceAction(String choice) {
    if (choice == "Moje konto") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AccountDetail(
                  currentLoggedInToken: widget.currentLoggedInToken,
                  account: widget.currentUser,
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
          builder:
              (BuildContext context, AsyncSnapshot<List<Account>> snapshot) {
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
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => AccountDetail(
                                            currentLoggedInToken:
                                                widget.currentLoggedInToken,
                                            account: accounts[index],
                                            currentUser: widget.currentUser,
                                            api: widget.api))),

                                /// delete account button
                                trailing: deleteButtonTrailing(accounts[index])),
                          )
                    )),
                Expanded(flex: 1, child: Divider()),
              ]);
            }

            /// shows progress indicator while fetching data
            return Center(child: CircularProgressIndicator());
          }),
    );
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
