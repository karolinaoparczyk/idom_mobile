import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/pages/actions/actions.dart';
import 'package:idom/pages/cameras/cameras.dart';
import 'package:idom/pages/data_download/data_download.dart';
import 'package:idom/pages/drivers/drivers.dart';
import 'package:idom/pages/setup/settings.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:idom/localization/widgets/idom_drawer.i18n.dart';

/// displays app menu
class IdomDrawer extends StatefulWidget {
  IdomDrawer({
    @required this.storage,
    @required this.parentWidgetType,
    this.testApi,
    this.accountUsername,
  });

  /// internal storage
  final SecureStorage storage;

  /// on which screen user opened menu
  final String parentWidgetType;

  /// current signed in user's username
  final String accountUsername;

  /// test api
  final Api testApi;

  /// handles state of widgets
  @override
  _IdomDrawerState createState() => _IdomDrawerState();
}

class _IdomDrawerState extends State<IdomDrawer> {
  Api api = Api();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  String isUserStaff;
  List<String> menuItems;
  int currentUserId;
  String currentUsername;

  @override
  void initState() {
    if (widget.testApi != null) {
      api = widget.testApi;
    }
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 25.0),
                              child: Text(title,
                                  style: Theme.of(context).textTheme.bodyText2),
                            ),
                          ),
                        ],
                      ),
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
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                    fontSize: 25.0,
                    color: IdomColors.whiteTextDark,
                    fontWeight: FontWeight.bold))
          ]);
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: ListView(children: [
            DrawerHeader(
                decoration: BoxDecoration(
                    color: IdomColors.lighten(IdomColors.additionalColor, 0.1)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'IDOM',
                                    style: TextStyle(
                                        fontSize: 65.0,
                                        color: IdomColors.blackTextLight),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ]),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'TWÓJ INTELIGENTNY DOM W JEDNYM MIEJSCU'.i18n,
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: IdomColors.blackTextLight,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      userRow(),
                    ])),
            Column(
              key: Key("drawerList"),
              children: [
                customMenuTile("assets/icons/man.svg", "Moje konto".i18n,
                    () async {
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
                  }
                }),
                isUserStaff == "true"
                    ? customMenuTile(
                        "assets/icons/team.svg", "Wszystkie konta".i18n,
                        () async {
                        Navigator.pop(context);
                        if (widget.parentWidgetType != "Accounts") {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Accounts(
                                        storage: widget.storage,
                                        testApi: widget.testApi,
                                      )));
                        }
                      })
                    : SizedBox(),
                customMenuTile(
                    "assets/icons/motion-sensor.svg", "Czujniki".i18n,
                    () async {
                  Navigator.pop(context);
                  if (widget.parentWidgetType != "Sensors") {
                    await Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  }
                }),
                customMenuTile("assets/icons/video-camera.svg", "Kamery".i18n,
                    () async {
                  Navigator.pop(context);
                  if (widget.parentWidgetType != "Cameras") {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Cameras(
                                  storage: widget.storage,
                                  testApi: widget.testApi,
                                )));
                  }
                }),
                customMenuTile("assets/icons/tap.svg", "Sterowniki".i18n,
                    () async {
                  Navigator.pop(context);
                  if (widget.parentWidgetType != "Drivers") {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Drivers(
                                  storage: widget.storage,
                                  testApi: widget.testApi,
                                )));
                  }
                }),
                customMenuTile("assets/icons/hammer.svg", "Akcje".i18n,
                    () async {
                  Navigator.pop(context);
                  if (widget.parentWidgetType != "Actions") {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ActionsList(
                                  storage: widget.storage,
                                  testApi: widget.testApi,
                                )));
                  }
                }),
                customMenuTile("assets/icons/settings.svg", "Ustawienia".i18n,
                    () async {
                  Navigator.pop(context);
                  if (widget.parentWidgetType != "Settings") {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Settings(storage: widget.storage)));
                  }
                }),
                customMenuTile("assets/icons/download.svg", "Pobierz dane".i18n,
                    () async {
                  Navigator.pop(context);
                  if (widget.parentWidgetType != "DataDownload") {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DataDownload(
                                  storage: widget.storage,
                                  testApi: widget.testApi,
                                )));
                  }
                }),
                customMenuTile("assets/icons/logout.svg", "Wyloguj".i18n,
                    () async {
                  Navigator.pop(context);
                  await _logOutProcedure();
                }),
                customMenuTile("assets/icons/info.svg", "O projekcie".i18n,
                    () async {
                  Navigator.pop(context);
                  _navigateToProjectWebPage();
                }),
              ],
            ),
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
  Future<void> _logOutProcedure() async {
    displayProgressDialog(
        context: context, key: _keyLoader, text: "Trwa wylogowywanie...");
    logOutAndResetData();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> logOutAndResetData() async {
    await api.logOut();
    widget.storage.resetUserData();
  }
}
