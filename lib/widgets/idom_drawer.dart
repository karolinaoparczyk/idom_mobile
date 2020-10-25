import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:idom/pages/account/account_detail.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/pages/setup/edit_api_address.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';

class IdomDrawer extends StatefulWidget {
  IdomDrawer(
      {@required this.storage,
      @required this.parentWidgetType, this.onGoBackAction,
      this.accountUsername});

  final SecureStorage storage;
  final String parentWidgetType;
  final Function onGoBackAction;
  final String accountUsername;

  @override
  _IdomDrawerState createState() => _IdomDrawerState();
}

class _IdomDrawerState extends State<IdomDrawer> {
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
          color: IdomColors.mainBackground,
          child: ListView(children: [
            DrawerHeader(
                decoration: BoxDecoration(
                    gradient: RadialGradient(radius: 0.99, colors: [
                  IdomColors.additionalColor,
                  IdomColors.lightBlack
                ])),
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
                    ])),
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
                if (widget.onGoBackAction != null)
                  widget.onGoBackAction();
              }
            }),
            isUserStaff == "true" ?
            customMenuTile(Icons.group_outlined, "Wszystkie konta", () async {
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
            }) : SizedBox(),
            customMenuTile(Icons.highlight_outlined, "Czujniki", () async {
              Navigator.pop(context);
              if (widget.parentWidgetType != "Sensors") {
                await Navigator.of(context).popUntil((route) => route.isFirst);
                if (widget.onGoBackAction != null)
                  widget.onGoBackAction();
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
                if (widget.onGoBackAction != null)
                  widget.onGoBackAction();

              }
            }),
            customMenuTile(Icons.logout, "Wyloguj", () async {
              await widget.storage.resetUserData();
              Navigator.pop(context);
              Navigator.of(context).popUntil((route) => route.isFirst);
            }),
          ]),
        ),
      ),
    );
  }
}
