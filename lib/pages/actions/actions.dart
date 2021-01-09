import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/actions/action_details.dart';
import 'package:idom/pages/actions/new_action.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';

/// displays actions list
class ActionsList extends StatefulWidget {
  ActionsList({@required this.storage, this.testApi});

  /// internal storage
  final SecureStorage storage;

  /// api used for tests
  final Api testApi;

  /// handles state of widgets
  @override
  _ActionsListState createState() => _ActionsListState();
}

class _ActionsListState extends State<ActionsList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  final GlobalKey<State> _keyLoaderInvalidToken = GlobalKey<State>();
  Api api = Api();
  List<SensorDriverAction> _actionList;
  bool zeroFetchedItems = false;
  bool _connectionEstablished;

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }
    getActions();
  }

  /// returns list of actions
  Future<void> getActions() async {
    try {
      /// gets actions
      var res = await api.getActions();

      if (res != null && res['statusCode'] == "200") {
        List<dynamic> body = jsonDecode(res['body']);
        setState(() {
          _actionList = body
              .map((dynamic item) => SensorDriverAction.fromJson(item))
              .toList();
        });
        if (_actionList.length == 0)
          zeroFetchedItems = true;
        else
          zeroFetchedItems = false;
      } else if (res != null && res['statusCode'] == "401") {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoaderInvalidToken,
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...");
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
                "Błąd pobierania akcji. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania akcji. Adres serwera nieprawidłowy."));
        _scaffoldKey.currentState.showSnackBar((snackBar));
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
          title: Text('Akcje'),
          actions: [
            IconButton(
              icon: Icon(Icons.add, size: 30.0),
              key: Key("addActionButton"),
              onPressed: navigateToNewAction,
            )
          ],
        ),
        drawer: IdomDrawer(
            storage: widget.storage,
            parentWidgetType: "Actions"),

        /// builds actions' list
        body: Container(child: Column(children: <Widget>[listDrivers()])),
      ),
    );
  }

  Widget listDrivers() {
    if (zeroFetchedItems) {
      return Padding(
          padding:
              EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                  "Brak akcji w systemie \nlub błąd połączenia z serwerem.",
                  style: TextStyle(fontSize: 16.5),
                  textAlign: TextAlign.center)));
    }
    if (_connectionEstablished != null &&
        _connectionEstablished == false &&
        _actionList == null) {
      return Padding(
          padding:
              EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text("Błąd połączenia z serwerem.",
                  style: TextStyle(fontSize: 16.5),
                  textAlign: TextAlign.center)));
    } else if (_actionList != null && _actionList.length > 0) {
      return Expanded(
          child: Scrollbar(
              child: RefreshIndicator(
                  onRefresh: _pullRefresh,
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, top: 10, right: 10.0, bottom: 0.0),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _actionList.length,
                          itemBuilder: (context, index) => Container(
                              height: 80,
                              child: Card(
                                child: ListTile(
                                    key: Key(_actionList[index].name),
                                    title: Text(_actionList[index].name,
                                        style: TextStyle(fontSize: 21.0)),
                                    onTap: () {
                                      navigateToActionDetails(
                                          _actionList[index]);
                                    },
                                    leading: SizedBox(
                                        width: 35,
                                        child: Container(
                                            padding: EdgeInsets.only(top: 5),
                                            alignment: Alignment.centerRight,
                                            child: SvgPicture.asset(
                                                "assets/icons/hammer.svg",
                                                matchTextDirection: false,
                                                width: 32,
                                                height: 32,
                                                color: Theme.of(context)
                                                    .iconTheme
                                                    .color,
                                                key: Key(
                                                    "assets/icons/hammer.svg")))),
                                    trailing: deleteButtonTrailing(
                                        _actionList[index])),
                              )))))));
    }

    /// shows progress indicator while fetching data
    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, top: 10, right: 10.0, bottom: 0.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  _deleteAction(SensorDriverAction action) async {
    var decision = await confirmActionDialog(context, "Potwierdź",
        "Czy na pewno chcesz usunąć akcję ${action.name}?");
    if (decision) {
      try {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoader,
            text: "Trwa usuwanie akcji...");

        int statusCode = await api.deleteAction(action.id);
        Navigator.of(_scaffoldKey.currentContext, rootNavigator: true).pop();
        if (statusCode == 200) {
          setState(() {
            /// refreshes actions' list
            getActions();
          });
        } else if (statusCode == 401) {
          displayProgressDialog(
              context: _scaffoldKey.currentContext,
              key: _keyLoaderInvalidToken,
              text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...");
          await new Future.delayed(const Duration(seconds: 3));
          Navigator.of(_keyLoaderInvalidToken.currentContext).pop();
          await widget.storage.resetUserData();
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (statusCode == null) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd usuwania akcji. Sprawdź połączenie z serwerem i spróbuj ponownie."));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        } else {
          final snackBar = new SnackBar(
              content: new Text(
                  "Usunięcie akcji nie powiodło się. Spróbuj ponownie."));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      } catch (e) {
        Navigator.of(_scaffoldKey.currentContext).pop();

        print(e.toString());
        if (e.toString().contains("TimeoutException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd usuwania akcji. Sprawdź połączenie z serwerem i spróbuj ponownie."));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
        if (e.toString().contains("SocketException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Usunięcie akcji nie powiodło się. Spróbuj ponownie."));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      }
    }
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      /// refreshes actions' list
      getActions();
    });
  }

  /// navigates to adding action page
  navigateToNewAction() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewAction(storage: widget.storage),
            fullscreenDialog: true));

    /// displays success message if action added successfully
    if (result == true) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      final snackBar = new SnackBar(
        content: new Text("Dodano nową akcję."),
        duration: Duration(seconds: 1),
      );
      _scaffoldKey.currentState.showSnackBar((snackBar));
      await getActions();
    }
  }

  navigateToActionDetails(SensorDriverAction action) async {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            ActionDetails(storage: widget.storage, action: action)));
    await getActions();
  }

  /// deletes sensor
  deleteButtonTrailing(SensorDriverAction action) {
    return SizedBox(
        width: 35,
        child: Container(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: Key("deleteButton"),
              child: SizedBox(
                  width: 35,
                  child: Container(
                      padding: EdgeInsets.only(top: 5),
                      alignment: Alignment.topRight,
                      child: SvgPicture.asset(
                        "assets/icons/dustbin.svg",
                        matchTextDirection: false,
                        width: 32,
                        height: 32,
                        color: IdomColors.mainFill,
                      ))),
              onPressed: () {
                setState(() {
                  _deleteAction(action);
                });
              },
            )));
  }
}
