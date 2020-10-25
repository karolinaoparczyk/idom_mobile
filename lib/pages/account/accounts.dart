import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';

/// displays all accounts
class Accounts extends StatefulWidget {
  Accounts({Key key,
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
  final GlobalKey<State> _keyLoaderInvalidToken = new GlobalKey<State>();
  List<Account> _accountList;
  List<Account> _duplicateAccountList = List<Account>();
  bool zeroFetchedItems = false;

  void initState() {
    super.initState();
    getAccounts();
  }

  /// returns list of accounts
  Future<List<Account>> getAccounts() async {
    /// if widget is being tested
    if (widget.testAccounts != null) {
      return widget.testAccounts;
    }
    try {
      var res = await widget.api.getAccounts(widget.currentLoggedInToken);

      if (res != null && res['statusCode'] == "200") {
        List<dynamic> body = jsonDecode(res['body']);

        setState(() {
          _accountList = body
              .map((dynamic item) => Account.fromJson(item))
              .where((account) => account.isActive == true)
              .toList();
        });
        if (_accountList.length == 0) zeroFetchedItems = true;
        zeroFetchedItems = false;
      } else if (res != null && res['statusCode'] == "401") {
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
    } catch (e) {
      print(e.toString());
      if (e.toString().contains("TimeoutException")) {
        final snackBar =
        new SnackBar(content: new Text("Błąd pobierania kont. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
      if (e.toString().contains("No address associated with hostname")) {
        final snackBar =
        new SnackBar(content: new Text("Błąd pobierania kont. Adres serwera nieprawidłowy."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    }
    setState(() {
      _duplicateAccountList.clear();
      _duplicateAccountList.addAll(_accountList);
    });
    return _accountList;
  }

  /// deactivates user after confirmation
  _deactivateAccount(Account account) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Usuwanie konta"),
          content:
          Text("Czy na pewno chcesz usunąć konto ${account.username}?"),
          actions: <Widget>[
            FlatButton(
              key: Key("yesButton"),
              child: Text("Tak"),
              onPressed: () async {
                try {
                  Navigator.of(dialogContext).pop(true);
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
                  } else if (statusCode == 401) {
                    displayProgressDialog(
                        context: _scaffoldKey.currentContext,
                        key: _keyLoaderInvalidToken,
                        text:
                        "Sesja użytkownika wygasła. \nTrwa wylogowywanie...");
                    await new Future.delayed(const Duration(seconds: 3));
                    Navigator.of(_keyLoaderInvalidToken.currentContext,
                        rootNavigator: true)
                        .pop();
                    widget.onSignedOut();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else if (statusCode == null) {
                    final snackBar =
                    new SnackBar(content: new Text("Błąd usuwania konta. Sprawdź połączenie z serwerem i spróbuj ponownie."));
                    ScaffoldMessenger.of(context).showSnackBar((snackBar));
                  } else {
                    final snackBar =
                    new SnackBar(content: new Text("Usunięcie użytkownika nie powiodło się. Spróbuj ponownie."));
                    ScaffoldMessenger.of(context).showSnackBar((snackBar));
                  }
                } catch (e) {
                  print(e.toString());
                  if (e.toString().contains("TimeoutException")) {
                    final snackBar =
                    new SnackBar(content: new Text("Błąd usuwania konta. Sprawdź połączenie z serwerem i spróbuj ponownie."));
                    ScaffoldMessenger.of(context).showSnackBar((snackBar));
                  }
                  if (e
                      .toString()
                      .contains("SocketException")) {
                    final snackBar =
                    new SnackBar(content: new Text("Błąd usuwania konta. Adres serwera nieprawidłowy."));
                    ScaffoldMessenger.of(context).showSnackBar((snackBar));
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
  /// we are already on accounts page,
  /// so if user choses accounts in menu, nothing happens
  void _choiceAction(String choice) async {
    if (choice == "Moje konto") {
      var result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AccountDetail(
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
                            key: Key(choice),
                            value: choice,
                            child: Text(choice));
                      }).toList();
                    })
              ],
            ),
            drawer: IdomDrawer(storage: widget.storage, parentWidgetType: "Accounts"),

            /// accounts' list builder
            body: Container(
                child: Column(children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(
                          left: 5.0, top: 5.0, right: 5.0, bottom: 5.0),
                      child: TextField(
                        onChanged: (value) {
                          filterSearchResults(value);
                        },
                        autofocus: true,
                        decoration: InputDecoration(
                            labelText: "Wyszukaj",
                            hintText: "Wyszukaj",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(30.0)))),
                      )),
                  listSensors()
                ]))));
  }

  Widget listSensors() {
    if (zeroFetchedItems) {
      return Padding(
          padding:
          EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                  "Brak kont w systemie \nlub błąd połączenia z serwerem.",
                  style: TextStyle(fontSize: 13.5),
                  textAlign: TextAlign.center)));
    } else if (!zeroFetchedItems &&
        _accountList != null &&
        _accountList.length == 0) {
      return Padding(
          padding:
          EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text("Brak wyników wyszukiwania.",
                  style: TextStyle(fontSize: 13.5),
                  textAlign: TextAlign.center)));
    } else if (_accountList != null && _accountList.length > 0) {
      return Expanded(
          child: Scrollbar(
              child: RefreshIndicator(
                  onRefresh: _pullRefresh,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _accountList.length,
                    itemBuilder: (context, index) =>
                        Container(
                            height: 80,
                            child: Card(child: ListTile(
                                key: Key(_accountList[index].username),
                                title: Text(_accountList[index].username,
                                    style: TextStyle(fontSize: 20.0)),
                                onTap: () {
                                  navigateToAccountDetails(_accountList[index]);
                                },

                                /// delete sensor button
                                trailing: deleteButtonTrailing(
                                    _accountList[index])))),
                  ))));
    }

    /// shows progress indicator while fetching data
    return Center(child: CircularProgressIndicator());
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      /// refreshes accounts' list
      getAccounts();
    });
  }

  void filterSearchResults(String query) {
    List<Account> dummySearchList = List<Account>();
    dummySearchList.addAll(_duplicateAccountList);
    if (query.isNotEmpty) {
      List<Account> dummyListData = List<Account>();
      dummySearchList.forEach((item) {
        if (item.username.contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        _accountList.clear();
        _accountList.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        _accountList.clear();
        _accountList.addAll(_duplicateAccountList);
      });
    }
  }

  navigateToAccountDetails(Account account) async {
    var result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            AccountDetail(
                currentLoggedInToken: widget.currentLoggedInToken,
                account: account,
                currentUser: widget.currentUser,
                api: widget.api,
                onSignedOut: widget.onSignedOut)));
    setState(() {
      widget.onSignedOut = result;
    });
    await getAccounts();
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
