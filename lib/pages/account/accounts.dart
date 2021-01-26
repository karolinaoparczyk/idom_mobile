import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:idom/api.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/login_procedures.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/localization/account/accounts.i18n.dart';

/// displays accounts list
class Accounts extends StatefulWidget {
  Accounts({@required this.storage, this.testApi});

  /// internal storage
  final SecureStorage storage;

  /// api used for tests
  final Api testApi;

  /// handles state of widgets
  @override
  _AccountsState createState() => _AccountsState();
}

/// handles state of widgets
class _AccountsState extends State<Accounts> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final GlobalKey<State> _keyLoaderInvalidToken = new GlobalKey<State>();
  final TextEditingController _searchController = TextEditingController();
  Api api = Api();

  /// account list currently displayed including filtering
  List<Account> _accountList = List<Account>();

  /// account list with all available items
  List<Account> _duplicateAccountList = List<Account>();

  /// true if no accounts exist, false if any exist
  bool zeroFetchedItems = false;

  /// user is admin
  String _isUserStaff;

  /// true if connection with server has been established, false if not
  bool _connectionEstablished;

  /// true if searching is on
  bool _isSearching = false;

  void initState() {
    super.initState();

    /// use test api when in test mode
    if (widget.testApi != null) {
      api = widget.testApi;
    }

    LoginProcedures.init(widget.storage, api);

    checkIfUserIsStaff();
    getAccounts();

    /// builds accounts list based on searched word
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

      /// on success fetching data
      if (res != null && res['statusCode'] == "200") {
        List<dynamic> body = jsonDecode(res['body']);

        setState(() {
          /// display only active
          _accountList = body
              .map((dynamic item) => Account.fromJson(item))
              .where((account) => account.isActive == true)
              .toList();
        });

        /// when no accounts exist
        if (_accountList.length == 0) {
          zeroFetchedItems = true;
        } else {
          zeroFetchedItems = false;
        }
      }

      /// on invalid token log out
      else if (res != null && res['statusCode'] == "401") {
        var message;
        if (widget.testApi != null) {
          message = "error";
        } else {
          message = await LoginProcedures.signInWithStoredData();
        }
        if (message != null) {
          logOut();
        } else {
          var res = await api.getAccounts();

          /// on success fetching data
          if (res != null && res['statusCode'] == "200") {
            List<dynamic> body = jsonDecode(res['body']);

            setState(() {
              /// display only active
              _accountList = body
                  .map((dynamic item) => Account.fromJson(item))
                  .where((account) => account.isActive == true)
                  .toList();
            });

            /// when no accounts exist
            if (_accountList.length == 0) {
              zeroFetchedItems = true;
            } else {
              zeroFetchedItems = false;
            }
          } else if (res != null && res['statusCode'] == "401") {
            logOut();
          } else {
            _connectionEstablished = false;
            setState(() {});
            return null;
          }
        }
      }

      /// on error display message
      else {
        _connectionEstablished = false;
        setState(() {});
        return null;
      }
    } catch (e) {
      _connectionEstablished = false;
      setState(() {});
      print(e.toString());

      /// on timeout while sending request display message
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania użytkowników. Sprawdź połączenie z serwerem i spróbuj ponownie."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }

      /// on invalid server address display message
      if (e.toString().contains("No address associated with hostname")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania użytkowników. Adres serwera nieprawidłowy."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
    setState(() {
      /// refresh accounts list
      _duplicateAccountList.clear();
      _duplicateAccountList.addAll(_accountList);
    });
    return _accountList;
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

  /// deactivates user after confirmation
  _deactivateAccount(Account account) async {
    var decision = await confirmActionDialog(context, "Potwierdź".i18n,
        "Czy na pewno chcesz usunąć konto ".i18n + account.username + "?");

    /// deactivate user only when decision confirmed
    if (decision != null && decision) {
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
        }

        /// on invalid token log out
        else if (statusCode == 401) {
          var message;
          if (widget.testApi != null) {
            message = "error";
          } else {
            message = await LoginProcedures.signInWithStoredData();
          }
          if (message != null) {
            logOut();
          } else {
            displayProgressDialog(
                context: _scaffoldKey.currentContext,
                key: _keyLoader,
                text: "Trwa usuwanie użytkownika...".i18n);
            statusCode = await api.deactivateAccount(account.id);
            Navigator.of(_scaffoldKey.currentContext).pop();

            if (statusCode == 200) {
              setState(() {
                /// refreshes accounts' list
                getAccounts();
              });
            } else if (statusCode == 401) {
              logOut();
            }

            /// on error display message
            else if (statusCode == null) {
              onDeleteUserNullResponse();
            } else {
              onDeleteUserError();
            }
          }
        }

        /// on error display message
        else if (statusCode == null) {
          onDeleteUserNullResponse();
        } else {
          onDeleteUserError();
        }
      } catch (e) {
        print(e.toString());

        /// on timeout while sending request display message
        if (e.toString().contains("TimeoutException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd usuwania użytkownika. Sprawdź połączenie z serwerem i spróbuj ponownie."
                      .i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }

        /// on invalid server address display message
        if (e.toString().contains("SocketException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd usuwania użytkownika. Adres serwera nieprawidłowy."
                      .i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      }
    }
  }

  onDeleteUserNullResponse() {
    final snackBar = new SnackBar(
        content: new Text(
            "Błąd usuwania użytkownika. Sprawdź połączenie z serwerem i spróbuj ponownie."
                .i18n));
    _scaffoldKey.currentState.showSnackBar((snackBar));
  }

  onDeleteUserError() {
    final snackBar = new SnackBar(
        content: new Text(
            "Usunięcie użytkownika nie powiodło się. Spróbuj ponownie.".i18n));
    _scaffoldKey.currentState.showSnackBar((snackBar));
  }

  /// build search field when search icon is clicked
  _buildSearchField() {
    return TextField(
      key: Key("searchField"),
      controller: _searchController,
      onChanged: (value) {
        /// filter through accounts list and refresh it accordingly
        filterSearchResults(value);
      },
      style: TextStyle(
          color: IdomColors.whiteTextLight, fontSize: 20, letterSpacing: 2.0),
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Wyszukaj...".i18n,
        hintStyle: TextStyle(
            color: IdomColors.whiteTextLight, fontSize: 20, letterSpacing: 2.0),
        border: UnderlineInputBorder(
            borderSide: BorderSide(color: IdomColors.additionalColor)),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: IdomColors.additionalColor),
        ),
      ),
    );
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
            appBar: AppBar(
              /// leading icon
              ///
              /// arrow back when searching to go back to main list
              /// menu icon when not searching to open drawer
              leading: _isSearching
                  ? IconButton(
                      key: Key("arrowBack"),
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          _isSearching = false;
                          _searchController.text = "";
                        });
                      })
                  : IconButton(
                      key: Key("drawer"),
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        _scaffoldKey.currentState.openDrawer();
                      },
                    ),

              /// title
              ///
              /// search field when searching
              /// list title when not searching
              title: _isSearching
                  ? _buildSearchField()
                  : Text('Wszystkie konta'.i18n),
              actions: <Widget>[
                /// action one
                ///
                /// nothing when searching
                /// search icon when not searching to display search field
                _isSearching
                    ? SizedBox()
                    : IconButton(
                        icon: Icon(Icons.search, size: 25.0),
                        key: Key("searchButton"),
                        onPressed: () {
                          setState(() {
                            _isSearching = true;
                          });
                        },
                      ),

                /// action two
                ///
                /// close icon when searching to clear text field
                /// search icon when not searching to display search field
                _isSearching
                    ? IconButton(
                        icon: Icon(Icons.close, size: 25.0),
                        key: Key("clearSearchingBox"),
                        onPressed: () {
                          setState(() {
                            _searchController.text = "";
                          });
                        },
                      )
                    : SizedBox(),
              ],
            ),

            /// drawer with menu
            drawer: IdomDrawer(
                storage: widget.storage,
                testApi: widget.testApi,
                parentWidgetType: "Accounts"),

            /// accounts' list builder
            body: Container(child: listAccounts())));
  }

  /// returns accounts list or a message when list is empty
  Widget listAccounts() {
    /// list is empty on server
    if (zeroFetchedItems) {
      return RefreshIndicator(
          backgroundColor: IdomColors.mainBackgroundDark,
          onRefresh: _pullRefresh,
          child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.only(
                      left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Text("Brak kont w systemie.".i18n,
                          style: Theme.of(context).textTheme.subtitle1,
                          textAlign: TextAlign.center)))));
    }

    /// connection to server has not been established
    if (_connectionEstablished != null &&
        _connectionEstablished == false &&
        _accountList.isEmpty) {
      return RefreshIndicator(
          backgroundColor: IdomColors.mainBackgroundDark,
          onRefresh: _pullRefresh,
          child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.only(
                      left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Text("Błąd połączenia z serwerem.".i18n,
                          style: Theme.of(context).textTheme.subtitle1,
                          textAlign: TextAlign.center)))));
    }

    /// search result is empty
    else if (!zeroFetchedItems &&
        _duplicateAccountList.isNotEmpty &&
        _accountList.isEmpty) {
      return Padding(
          padding:
              EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text("Brak wyników wyszukiwania.".i18n,
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.center)));
    }

    /// list is not empty or/and search result is not empty
    else if (_accountList != null && _accountList.length > 0) {
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
                          key: Key("AccountsList"),
                          shrinkWrap: true,
                          itemCount: _accountList.length,
                          itemBuilder: (context, index) => Container(
                              height: 80,
                              child: Card(
                                  child: ListTile(
                                      key: Key(_accountList[index].username),

                                      /// main title on account card
                                      title: Text(_accountList[index].username,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(fontSize: 21.0)),
                                      onTap: () {
                                        /// open account details on tap
                                        navigateToAccountDetails(
                                            _accountList[index]);
                                      },

                                      /// leading icon
                                      leading: SizedBox(
                                          width: 35,
                                          child: Container(
                                              alignment: Alignment.centerRight,
                                              child: SvgPicture.asset(
                                                "assets/icons/man.svg",
                                                matchTextDirection: false,
                                                width: 32,
                                                height: 32,
                                                color:
                                                    IdomColors.additionalColor,
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

  /// fetches data on refresh
  Future<void> _pullRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      /// refreshes accounts' list
      getAccounts();
    });
  }

  /// filters through accounts list based on given word
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

  /// goes to account's details
  navigateToAccountDetails(Account account) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AccountDetail(
            storage: widget.storage, username: account.username)));

    /// refreshes accounts list when goes back
    await getAccounts();
  }

  /// delete account button
  Widget deleteButtonTrailing(Account account) {
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
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
                onPressed: () {
                  setState(() {
                    /// deactivate button
                    _deactivateAccount(account);
                  });
                },
              )));
    } else
      return null;
  }
}
