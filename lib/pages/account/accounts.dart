import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:idom/api.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/localization/account/accounts.i18n.dart';

/// displays all accounts
class Accounts extends StatefulWidget {
  Accounts({@required this.storage, this.testApi});

  final SecureStorage storage;
  final Api testApi;

  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final GlobalKey<State> _keyLoaderInvalidToken = new GlobalKey<State>();
  final TextEditingController _searchController = TextEditingController();
  Api api = Api();
  List<Account> _accountList;
  List<Account> _duplicateAccountList = List<Account>();
  bool zeroFetchedItems = false;
  String _isUserStaff;
  bool _connectionEstablished;
  bool _isSearching = false;

  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }
    checkIfUserIsStaff();
    getAccounts();
    _searchController.addListener(() {
      filterSearchResults(_searchController.text);
    });
  }

  Future<void> checkIfUserIsStaff() async {
    _isUserStaff = await widget.storage.getIsUserStaff();
  }

  /// returns list of accounts
  Future<List<Account>> getAccounts() async {
    setState(() {
      _isSearching = false;
      _searchController.text = "";
    });

    try {
      var res = await api.getAccounts();

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
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
        await new Future.delayed(const Duration(seconds: 3));
        Navigator.of(_keyLoaderInvalidToken.currentContext, rootNavigator: true)
            .pop();
        await widget.storage.resetUserData();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      if (res == null) {
        _connectionEstablished = false;
        setState(() {});
        return null;
      }
    } catch (e) {
      print(e.toString());
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania użytkowników. Sprawdź połączenie z serwerem i spróbuj ponownie.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("No address associated with hostname")) {
        final snackBar = new SnackBar(
            content:
                new Text("Błąd pobierania użytkowników. Adres serwera nieprawidłowy.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
    setState(() {
      _duplicateAccountList.clear();
      _duplicateAccountList.addAll(_accountList);
    });
    return _accountList;
  }

  /// deactivates user after confirmation
  _deactivateAccount(Account account) async {
    var decision = await confirmActionDialog(context, "Potwierdź".i18n,
        "Czy na pewno chcesz usunąć konto ".i18n + account.username + "?");
    if (decision) {
      try {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoader,
            text: "Trwa usuwanie użytkownika...".i18n);
        var statusCode = await api.deactivateAccount(account.id);
        Navigator.of(_scaffoldKey.currentContext).pop();

        if (statusCode == 200) {
          setState(() {
            /// refreshes accounts' list
            getAccounts();
          });
        } else if (statusCode == 401) {
          displayProgressDialog(
              context: _scaffoldKey.currentContext,
              key: _keyLoaderInvalidToken,
              text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
          await new Future.delayed(const Duration(seconds: 3));
          Navigator.of(_keyLoaderInvalidToken.currentContext,
                  rootNavigator: true)
              .pop();
          await widget.storage.resetUserData();
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (statusCode == null) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd usuwania użytkownika. Sprawdź połączenie z serwerem i spróbuj ponownie.".i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        } else {
          final snackBar = new SnackBar(
              content: new Text(
                  "Usunięcie użytkownika nie powiodło się. Spróbuj ponownie.".i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      } catch (e) {
        print(e.toString());
        if (e.toString().contains("TimeoutException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd usuwania użytkownika. Sprawdź połączenie z serwerem i spróbuj ponownie.".i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
        if (e.toString().contains("SocketException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd usuwania użytkownika. Adres serwera nieprawidłowy.".i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      }
    }
  }

  _buildSearchField() {
    return TextField(
      key: Key("searchField"),
      controller: _searchController,
      onChanged: (value) {
        filterSearchResults(value);
      },
      style: TextStyle(
          color: IdomColors.whiteTextLight,
          fontSize: 20,
          letterSpacing: 2.0),
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Wyszukaj...".i18n,
        hintStyle: TextStyle(
            color: IdomColors.whiteTextLight,
            fontSize: 20,
            letterSpacing: 2.0),
        border: UnderlineInputBorder(
            borderSide: BorderSide(color: IdomColors.additionalColor)),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: IdomColors.additionalColor),
        ),
      ),
    );
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
              leading: _isSearching
                  ? IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          _isSearching = false;
                          _searchController.text = "";
                        });
                      })
                  : IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        _scaffoldKey.currentState.openDrawer();
                      },
                    ),
              title:
                  _isSearching ? _buildSearchField() : Text('Wszystkie konta'.i18n),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search, size: 25.0),
                  key: Key("searchButton"),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
              ],
            ),
            drawer: IdomDrawer(
                storage: widget.storage,
                parentWidgetType: "Accounts",
                onLogOutFailure: onLogOutFailure),
            /// accounts' list builder
            body:
                Container(child: listAccounts())));
  }

  onLogOutFailure(String text) {
    final snackBar = new SnackBar(content: new Text(text));
    _scaffoldKey.currentState.showSnackBar((snackBar));
  }

  Widget listAccounts() {
    if (zeroFetchedItems) {
      return RefreshIndicator(
          backgroundColor: IdomColors.mainBackgroundDark,
          onRefresh: _pullRefresh,
          child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                  height: MediaQuery.of(context).size.height,
          padding:
              EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                  "Brak kont w systemie.".i18n,
                  style:  Theme.of(context)
                      .textTheme
                      .bodyText1,
                  textAlign: TextAlign.center)))));
    }
    if (_connectionEstablished != null &&
        _connectionEstablished == false &&
        _accountList == null) {
      return RefreshIndicator(
          backgroundColor: IdomColors.mainBackgroundDark,
          onRefresh: _pullRefresh,
          child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                  height: MediaQuery.of(context).size.height,
          padding:
              EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text("Błąd połączenia z serwerem.".i18n,
                  style:  Theme.of(context)
                      .textTheme
                      .bodyText1,
                  textAlign: TextAlign.center)))));
    } else if (!zeroFetchedItems &&
        _accountList != null &&
        _accountList.length == 0) {
      return Padding(
          padding:
              EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text("Brak wyników wyszukiwania.".i18n,
                  style:  Theme.of(context)
                      .textTheme
                      .bodyText1,
                  textAlign: TextAlign.center)));
    } else if (_accountList != null && _accountList.length > 0) {
      return Column(
        children: [
          Expanded(
              child: Scrollbar(
                  child: RefreshIndicator(
                      backgroundColor: IdomColors.mainBackgroundDark,
                      onRefresh: _pullRefresh,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, top: 10, right: 10.0, bottom: 0.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _accountList.length,
                          itemBuilder: (context, index) => Container(
                              height: 80,
                              child: Card(
                                  child: ListTile(
                                      key: Key(_accountList[index].username),
                                      title: Text(_accountList[index].username,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(fontSize: 21.0)),
                                      onTap: () {
                                        navigateToAccountDetails(
                                            _accountList[index]);
                                      },
                                      leading: SizedBox(
                                          width: 35,
                                          child: Container(
                                              alignment: Alignment.centerRight,
                                              child: SvgPicture.asset(
                                                "assets/icons/man.svg",
                                                matchTextDirection: false,
                                                width: 32,
                                                height: 32,
                                                color: IdomColors.additionalColor,
                                              ))),

                                      /// delete sensor button
                                      trailing: deleteButtonTrailing(
                                          _accountList[index])))),
                        ),
                      )))),
        ],
      );
    }

    /// shows progress indicator while fetching data
    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, top: 10, right: 10.0, bottom: 0.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      /// refreshes accounts' list
      getAccounts();
    });
  }

  void filterSearchResults(String query) {
    query = query.toLowerCase();
    List<Account> dummySearchList = List<Account>();
    dummySearchList.addAll(_duplicateAccountList);
    if (query.isNotEmpty) {
      List<Account> dummyListData = List<Account>();
      dummySearchList.forEach((item) {
        if (item.username.toLowerCase().contains(query)) {
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
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AccountDetail(
            storage: widget.storage, username: account.username)));
    await getAccounts();
  }

  /// delete account button
  deleteButtonTrailing(Account account) {
    if (_isUserStaff == "true") {
      return SizedBox(
          width: 35,
          child: Container(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                key: Key("deleteButton"),
                child: SvgPicture.asset(
                  "assets/icons/dustbin.svg",
                  matchTextDirection: false,
                  width: 32,
                  height: 32,
                  color: Theme.of(
                      context)
                      .textTheme
                      .bodyText1
                      .color,
                ),
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
