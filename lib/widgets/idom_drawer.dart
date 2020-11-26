import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/pages/cameras/cameras.dart';
import 'package:idom/pages/data_download/data_download.dart';
import 'package:idom/pages/drivers/drivers.dart';
import 'package:idom/pages/setup/settings.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    checkIfUserIsStaff();
    getCurrentUserId();
    getCurrentUserName();
    super.initState();
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

  Widget customMenuTile(String imageUrl, String title, Function onTap) {
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
                        SizedBox(
                            width: 25,
                            child: Container(
                                padding: EdgeInsets.only(top: 5),
                                alignment: Alignment.topRight,
                                child: SvgPicture.asset(
                                  imageUrl,
                                  matchTextDirection: false,
                                  width: 25,
                                  height: 25,
                                  color: IdomColors.additionalColor,
                                ))),
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
          child: ListView(children: [
            DrawerHeader(
                decoration: BoxDecoration(
                    color: IdomColors.lighten(IdomColors.additionalColor, 0.1)),
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
            customMenuTile("assets/icons/man.svg", "Moje konto", () async {
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
                ? customMenuTile("assets/icons/team.svg", "Wszystkie konta",
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
            customMenuTile("assets/icons/motion-sensor.svg", "Czujniki",
                () async {
              Navigator.pop(context);
              if (widget.parentWidgetType != "Sensors") {
                await Navigator.of(context).popUntil((route) => route.isFirst);
                if (widget.onGoBackAction != null) widget.onGoBackAction();
              }
            }),
            customMenuTile("assets/icons/video-camera.svg", "Kamery", () async {
              Navigator.pop(context);
              if (widget.parentWidgetType != "Cameras") {
                Navigator.of(context).popUntil((route) => route.isFirst);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Cameras(storage: widget.storage)));
                if (widget.onGoBackAction != null) widget.onGoBackAction();
              }
            }),
            customMenuTile("assets/icons/tap.svg", "Sterowniki", () async {
              Navigator.pop(context);
              if (widget.parentWidgetType != "Drivers") {
                Navigator.of(context).popUntil((route) => route.isFirst);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Drivers(storage: widget.storage)));
                if (widget.onGoBackAction != null) widget.onGoBackAction();
              }
            }),
            customMenuTile("assets/icons/settings.svg", "Ustawienia", () async {
              Navigator.pop(context);
              if (widget.parentWidgetType != "EditApiAddress") {
                Navigator.of(context).popUntil((route) => route.isFirst);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Settings(storage: widget.storage)));
                if (widget.onGoBackAction != null) widget.onGoBackAction();
              }
            }),
            customMenuTile("assets/icons/download.svg", "Pobierz dane",
                () async {
              Navigator.pop(context);
              if (widget.parentWidgetType != "DataDownload") {
                Navigator.of(context).popUntil((route) => route.isFirst);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DataDownload(storage: widget.storage)));
                if (widget.onGoBackAction != null) widget.onGoBackAction();
              }
            }),
            customMenuTile("assets/icons/logout.svg", "Wyloguj", () async {
              Navigator.pop(context);
              await _logOut();
            }),
            customMenuTile("assets/icons/info.svg", "O projekcie", () async {
              Navigator.pop(context);
              _navigateToProjectWebPage();
            }),
          ]),
        ),
      ),
    );
  }

  _navigateToProjectWebPage() async {
    try {
      await launch("https://adriannajmrocki.github.io/idom-website/");
    } catch (e) {
      throw 'Could not launch page';
    }
  }

  /// logs the user out of the app
  Future<void> _logOut() async {
    try {
      displayProgressDialog(
          context: context, key: _keyLoader, text: "Trwa wylogowywanie...");
      var statusCode = await api.logOut();
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
