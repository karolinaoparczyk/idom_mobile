import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/pages/setup/edit_api_address.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';

class IdomDrawer extends StatefulWidget {
  IdomDrawer({
    @required this.storage,
    @required this.parentWidgetType,
    @required this.onLogOutFailure,
    this.onGoBackAction,
    this.accountUsername,
  });

  final SecureStorage storage;
  final String parentWidgetType;
  final Function onGoBackAction;
  final Function onLogOutFailure;
  final String accountUsername;

  @override
  _IdomDrawerState createState() => _IdomDrawerState();
}

class _IdomDrawerState extends State<IdomDrawer> {
  final Api api = Api();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  String isUserStaff;
  List<String> menuItems;
  int currentUserId;
  String currentUsername;
  String token;

  @override
  void initState() {
    getCurrentUserToken();
    checkIfUserIsStaff();
    getCurrentUserId();
    getCurrentUserName();
    super.initState();
  }

  Future<void> getCurrentUserToken() async {
    token = await widget.storage.getToken();
    setState(() {});
  }

  Future<void> checkIfUserIsStaff() async {
    isUserStaff = await widget.storage.getIsUserStaff();
    setState(() {});
  }

  Future<void> getCurrentUserId() async {
    currentUserId = int.parse(await widget.storage.getUserId());
    setState(() {});
  }

  Future<void> getCurrentUserName() async {
    currentUsername = await widget.storage.getUsername();
    setState(() {});
  }

  Widget customMenuTile(IconData icon, String title, Function onTap) {
    return InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Card(
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 18.0, right: 8, top: 12, bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(icon, size: 25.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                      fontSize: 21.0,
                                      fontWeight: FontWeight.normal)),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_right)
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget userRow() {
    if (currentUsername != null)
      return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.perm_identity_rounded,
                color: IdomColors.mainFill, size: 25.0),
            Text(currentUsername,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontSize: 25.0))
          ]);
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Container(
          decoration: BoxDecoration(
            color:IdomColors.darken(IdomColors.additionalColor, 0.1)),
          child: ListView(children: [
            DrawerHeader(
                child: Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.roofing_rounded,
                              size: 50.0, color: IdomColors.mainFill),
                          Text(
                            'IDOM',
                            style: TextStyle(
                                fontSize: 70.0, color: IdomColors.textDark),
                            textAlign: TextAlign.center,
                          ),
                          Icon(Icons.roofing_rounded,
                              size: 50.0, color: Colors.transparent),
                        ]),
                        Text(
                          'TWÓJ INTELIGENTNY DOM W JEDNYM MIEJSCU',
                          style: TextStyle(
                              fontSize: 13.0,
                              color: IdomColors.textDark,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    userRow(),
                  ]),
            )),
            customMenuTile(Icons.perm_identity_rounded, "Moje konto", () async {
              Navigator.pop(context);
              var toPush = false;
              if (widget.parentWidgetType == "AccountDetail") {
                if (widget.accountUsername != currentUsername) {
                  toPush = true;
                }
              } else
                toPush = true;
              if (toPush) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountDetail(
                            storage: widget.storage,
                            username: currentUsername)));
                if (widget.onGoBackAction != null) widget.onGoBackAction();
              }
            }),
            isUserStaff == "true"
                ? customMenuTile(Icons.group_outlined, "Wszystkie konta",
                    () async {
                    Navigator.pop(context);
                    if (widget.parentWidgetType != "Accounts") {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Accounts(storage: widget.storage)));
                      if (widget.onGoBackAction != null)
                        widget.onGoBackAction();
                    }
                  })
                : SizedBox(),
            customMenuTile(Icons.highlight_outlined, "Czujniki", () async {
              Navigator.pop(context);
              if (widget.parentWidgetType != "Sensors") {
                await Navigator.of(context).popUntil((route) => route.isFirst);
                if (widget.onGoBackAction != null) widget.onGoBackAction();
              }
            }),
            customMenuTile(Icons.settings_outlined, "Ustawienia", () async {
              Navigator.pop(context);
              if (widget.parentWidgetType != "EditApiAddress") {
                Navigator.of(context).popUntil((route) => route.isFirst);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EditApiAddress(storage: widget.storage)));
                if (widget.onGoBackAction != null) widget.onGoBackAction();
              }
            }),
            customMenuTile(Icons.logout, "Wyloguj", () async {
              Navigator.pop(context);
               await _logOut();
            }),
          ]),
        ),
      ),
    );
  }

  /// logs the user out of the app
  Future<void> _logOut() async {
    try {
      displayProgressDialog(context: context, key: _keyLoader, text: "Trwa wylogowywanie...");
      var statusCode = await api.logOut(token);
      if (statusCode == 200 || statusCode == 404 || statusCode == 401) {
        await widget.storage.resetUserData();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (statusCode == null) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        widget.onLogOutFailure(
            "Błąd wylogowywania. Sprawdź połączenie z serwerem i spróbuj ponownie.");
      } else {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        widget
            .onLogOutFailure("Wylogowanie nie powiodło się. Spróbuj ponownie.");
      }
    } catch (e) {
      print(e);
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      if (e.toString().contains("TimeoutException")) {
        widget.onLogOutFailure(
            "Błąd wylogowania. Sprawdź połączenie z serwerem i spróbuj ponownie.");
      }
      if (e.toString().contains("SocketException")) {
        widget
            .onLogOutFailure("Błąd wylogowania. Adres serwera nieprawidłowy.");
      }
    }
  }
}
