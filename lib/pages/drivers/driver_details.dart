import 'dart:convert';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/drivers/edit_driver.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';

/// displays driver details
class DriverDetails extends StatefulWidget {
  DriverDetails({@required this.storage, @required this.driver, this.testApi});

  final SecureStorage storage;
  Driver driver;
  final Api testApi;

  @override
  _DriverDetailsState createState() => new _DriverDetailsState();
}

class _DriverDetailsState extends State<DriverDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  TextEditingController _channelNumberController = TextEditingController();
  Api api = Api();
  bool _load;
  bool digitsVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }
    _load = false;
  }

  onLogOutFailure(String text) {
    final snackBar = new SnackBar(content: new Text(text));
    _scaffoldKey.currentState.showSnackBar((snackBar));
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
            appBar: AppBar(title: Text(widget.driver.name), actions: [
              IconButton(
                  key: Key("editDriver"),
                  icon: Icon(Icons.edit),
                  onPressed: _navigateToEditDriver)
            ]),
            drawer: IdomDrawer(
                storage: widget.storage,
                parentWidgetType: "DriverDetails",
                onLogOutFailure: onLogOutFailure),
            body: SingleChildScrollView(
                child: Form(
              key: _formKey,
              child: AnimatedContainer(
                curve: Curves.easeInToLinear,
                duration: Duration(
                  milliseconds: 10,
                ),
                alignment: Alignment.topCenter,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Align(
                    child: loadingIndicator(_load),
                    alignment: FractionalOffset.center,
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 20.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, size: 17.5),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text("Ogólne",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                            fontWeight: FontWeight.normal)),
                              ),
                            ],
                          ))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 52.5, top: 10.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Nazwa",
                              style: TextStyle(
                                  color: IdomColors.additionalColor,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 52.5, top: 0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(widget.driver.name,
                              style: TextStyle(fontSize: 21.0)))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 20.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(Icons.touch_app_outlined, size: 17.5),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text("Obsługa sterownika",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                            fontWeight: FontWeight.normal)),
                              ),
                            ],
                          ))),
                  if (widget.driver.category == "clicker")
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 52.5, top: 30, right: 52.5, bottom: 0.0),
                      child: Column(
                        children: [
                          SizedBox.fromSize(
                            size: Size(56, 56),
                            child: ClipOval(
                              child: Material(
                                color: IdomColors.brightGreen,
                                child: InkWell(
                                  key: Key("click"),
                                  splashColor: IdomColors.darkGreen,
                                  onTap: _clickDriver,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SvgPicture.asset("assets/icons/play.svg",
                                          matchTextDirection: false,
                                          alignment: Alignment.centerRight,
                                          width: 25,
                                          height: 25,
                                          color: IdomColors.green,
                                          key: Key("assets/icons/play.svg")),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text("Wciśnij przycisk",
                              style: TextStyle(
                                  color: IdomColors.textDark,
                                  fontSize: 21,
                                  fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                  if (widget.driver.category == "remote_control")
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 52.5, top: 30, right: 52.5, bottom: 0.0),
                        child: AnimatedCrossFade(
                            crossFadeState: digitsVisible
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: Duration(milliseconds: 300),
                            firstChild: digitsVisible
                                ? Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                        child: TextFormField(
                                          key: Key('channelNumber'),
                                          readOnly: true,
                                          keyboardType: TextInputType.number,
                                          controller: _channelNumberController,
                                          style: TextStyle(fontSize: 21.0),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Table(
                                        children: [
                                          TableRow(children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 18.0),
                                              child: InkWell(
                                                onTap: () {
                                                  if (_channelNumberController
                                                          .text.length <
                                                      3) {
                                                    setState(() {
                                                      _channelNumberController
                                                          .text += "1";
                                                    });
                                                  }
                                                },
                                                splashColor: IdomColors.lighten(
                                                    IdomColors.additionalColor,
                                                    0.3),
                                                borderRadius:
                                                    BorderRadius.circular(50.0),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      18.0),
                                                  child: Center(
                                                    child: Text("1",
                                                        style: TextStyle(
                                                            color: IdomColors
                                                                .additionalColor,
                                                            fontSize: 21,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        key: Key("1")),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                if (_channelNumberController
                                                        .text.length <
                                                    3) {
                                                  setState(() {
                                                    _channelNumberController
                                                        .text += "2";
                                                  });
                                                }
                                              },
                                              splashColor: IdomColors.lighten(
                                                  IdomColors.additionalColor,
                                                  0.3),
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(18.0),
                                                child: Center(
                                                  child: Text("2",
                                                      style: TextStyle(
                                                          color: IdomColors
                                                              .additionalColor,
                                                          fontSize: 21,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      key: Key("2")),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                if (_channelNumberController
                                                        .text.length <
                                                    3) {
                                                  setState(() {
                                                    _channelNumberController
                                                        .text += "3";
                                                  });
                                                }
                                              },
                                              splashColor: IdomColors.lighten(
                                                  IdomColors.additionalColor,
                                                  0.3),
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(18.0),
                                                child: Center(
                                                  child: Text("3",
                                                      style: TextStyle(
                                                          color: IdomColors
                                                              .additionalColor,
                                                          fontSize: 21,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      key: Key("3")),
                                                ),
                                              ),
                                            ),
                                          ]),
                                          TableRow(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 18.0),
                                                child: InkWell(
                                                  onTap: () {
                                                    if (_channelNumberController
                                                            .text.length <
                                                        3) {
                                                      setState(() {
                                                        _channelNumberController
                                                            .text += "4";
                                                      });
                                                    }
                                                  },
                                                  splashColor:
                                                      IdomColors.lighten(
                                                          IdomColors
                                                              .additionalColor,
                                                          0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.0),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            18.0),
                                                    child: Center(
                                                      child: Text("4",
                                                          style: TextStyle(
                                                              color: IdomColors
                                                                  .additionalColor,
                                                              fontSize: 21,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          key: Key("4")),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  if (_channelNumberController
                                                          .text.length <
                                                      3) {
                                                    setState(() {
                                                      _channelNumberController
                                                          .text += "5";
                                                    });
                                                  }
                                                },
                                                splashColor: IdomColors.lighten(
                                                    IdomColors.additionalColor,
                                                    0.3),
                                                borderRadius:
                                                    BorderRadius.circular(50.0),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      18.0),
                                                  child: Center(
                                                    child: Text("5",
                                                        style: TextStyle(
                                                            color: IdomColors
                                                                .additionalColor,
                                                            fontSize: 21,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        key: Key("5")),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  if (_channelNumberController
                                                          .text.length <
                                                      3) {
                                                    setState(() {
                                                      _channelNumberController
                                                          .text += "6";
                                                    });
                                                  }
                                                },
                                                splashColor: IdomColors.lighten(
                                                    IdomColors.additionalColor,
                                                    0.3),
                                                borderRadius:
                                                    BorderRadius.circular(50.0),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      18.0),
                                                  child: Center(
                                                    child: Text("6",
                                                        style: TextStyle(
                                                            color: IdomColors
                                                                .additionalColor,
                                                            fontSize: 21,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        key: Key("6")),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          TableRow(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 18.0),
                                                child: InkWell(
                                                  onTap: () {
                                                    if (_channelNumberController
                                                            .text.length <
                                                        3) {
                                                      setState(() {
                                                        _channelNumberController
                                                            .text += "7";
                                                      });
                                                    }
                                                  },
                                                  splashColor:
                                                      IdomColors.lighten(
                                                          IdomColors
                                                              .additionalColor,
                                                          0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.0),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            18.0),
                                                    child: Center(
                                                      child: Text("7",
                                                          style: TextStyle(
                                                              color: IdomColors
                                                                  .additionalColor,
                                                              fontSize: 21,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          key: Key("7")),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  if (_channelNumberController
                                                          .text.length <
                                                      3) {
                                                    setState(() {
                                                      _channelNumberController
                                                          .text += "8";
                                                    });
                                                  }
                                                },
                                                splashColor: IdomColors.lighten(
                                                    IdomColors.additionalColor,
                                                    0.3),
                                                borderRadius:
                                                    BorderRadius.circular(50.0),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      18.0),
                                                  child: Center(
                                                    child: Text("8",
                                                        style: TextStyle(
                                                            color: IdomColors
                                                                .additionalColor,
                                                            fontSize: 21,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        key: Key("8")),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  if (_channelNumberController
                                                          .text.length <
                                                      3) {
                                                    setState(() {
                                                      _channelNumberController
                                                          .text += "9";
                                                    });
                                                  }
                                                },
                                                splashColor: IdomColors.lighten(
                                                    IdomColors.additionalColor,
                                                    0.3),
                                                borderRadius:
                                                    BorderRadius.circular(50.0),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      18.0),
                                                  child: Center(
                                                    child: Text("9",
                                                        style: TextStyle(
                                                            color: IdomColors
                                                                .additionalColor,
                                                            fontSize: 21,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        key: Key("9")),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          TableRow(children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 18.0),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (_channelNumberController
                                                        .text.isNotEmpty)
                                                      _channelNumberController
                                                              .text =
                                                          _channelNumberController
                                                              .text
                                                              .substring(
                                                                  0,
                                                                  _channelNumberController
                                                                          .text
                                                                          .length -
                                                                      1);
                                                  });
                                                },
                                                splashColor: IdomColors.lighten(
                                                    IdomColors.additionalColor,
                                                    0.3),
                                                borderRadius:
                                                    BorderRadius.circular(50.0),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 16.0,
                                                          bottom: 16.0),
                                                  child: SvgPicture.asset(
                                                      "assets/icons/left-arrow-long.svg",
                                                      matchTextDirection: false,
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      width: 35,
                                                      height: 35,
                                                      color: IdomColors
                                                          .additionalColor,
                                                      key: Key(
                                                          "assets/icons/left-arrow-long.svg")),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                if (_channelNumberController
                                                        .text.length <
                                                    3) {
                                                  setState(() {
                                                    _channelNumberController
                                                        .text += "0";
                                                  });
                                                }
                                              },
                                              splashColor: IdomColors.lighten(
                                                  IdomColors.additionalColor,
                                                  0.3),
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(18.0),
                                                child: Center(
                                                  child: Text("0",
                                                      style: TextStyle(
                                                          color: IdomColors
                                                              .additionalColor,
                                                          fontSize: 21,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      key: Key("0")),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {},
                                              highlightColor: digitsVisible
                                                  ? IdomColors.grey
                                                  : Colors.transparent,
                                              splashColor: digitsVisible
                                                  ? IdomColors.lighten(
                                                      IdomColors
                                                          .additionalColor,
                                                      0.3)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 16.0,
                                                  bottom: 16.0,
                                                ),
                                                child: SvgPicture.asset(
                                                    "assets/icons/enter.svg",
                                                    matchTextDirection: false,
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    width: 30,
                                                    height: 30,
                                                    color: IdomColors
                                                        .additionalColor,
                                                    key: Key(
                                                        "assets/icons/enter.svg")),
                                              ),
                                            ),
                                          ]),
                                          TableRow(children: [
                                            SizedBox(),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 18.0),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    digitsVisible = false;
                                                    _channelNumberController
                                                        .text = "";
                                                  });
                                                },
                                                splashColor: IdomColors.lighten(
                                                    IdomColors.additionalColor,
                                                    0.3),
                                                borderRadius:
                                                    BorderRadius.circular(50.0),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(8.0),
                                                    child: Text("WRÓĆ",
                                                        style: TextStyle(
                                                            color: IdomColors
                                                                .additionalColor,
                                                            fontSize: 30),
                                                        key: Key(
                                                            "goBack")),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox()
                                          ])
                                        ],
                                      )
                                    ],
                                  )
                                : SizedBox(),
                            secondChild: Table(
                              columnWidths: {
                                0:FlexColumnWidth(1),
                                1:FlexColumnWidth(1),
                                2:FlexColumnWidth(2),
                                3:FlexColumnWidth(1),
                                4:FlexColumnWidth(1),
                              },
                                children: [
                              TableRow(
                                children: [
                                  Center(
                                    child: InkWell(
                                      onTap: () {},
                                      highlightColor: digitsVisible
                                          ? Colors.transparent
                                          : IdomColors.grey,
                                      splashColor: digitsVisible
                                          ? Colors.transparent
                                          : IdomColors.lighten(
                                              IdomColors.additionalColor, 0.3),
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: SvgPicture.asset(
                                            "assets/icons/menu.svg",
                                            matchTextDirection: false,
                                            alignment: Alignment.centerRight,
                                            width: 35,
                                            height: 35,
                                            color: IdomColors.additionalColor,
                                            key: Key("assets/icons/menu.svg")),
                                      ),
                                    ),
                                  ),
                                  SizedBox(),
                                  SizedBox(),
                                  SizedBox(),
                                  Center(
                                    child: InkWell(
                                      onTap: () {},
                                      highlightColor: digitsVisible
                                          ? Colors.transparent
                                          : IdomColors.grey,
                                      splashColor: digitsVisible
                                          ? Colors.transparent
                                          : IdomColors.lighten(
                                              IdomColors.error, 0.3),
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: SvgPicture.asset(
                                            "assets/icons/turn-off.svg",
                                            matchTextDirection: false,
                                            alignment: Alignment.centerRight,
                                            width: 35,
                                            height: 35,
                                            color: IdomColors.error,
                                            key: Key(
                                                "assets/icons/turn-off.svg")),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  SizedBox(),
                                  SizedBox(),
                                  Center(
                                    child: InkWell(
                                      onTap: () {},
                                      highlightColor: digitsVisible
                                          ? Colors.transparent
                                          : IdomColors.grey,
                                      splashColor: digitsVisible
                                          ? Colors.transparent
                                          : IdomColors.lighten(
                                              IdomColors.additionalColor, 0.3),
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: SvgPicture.asset(
                                            "assets/icons/up-arrow.svg",
                                            matchTextDirection: false,
                                            alignment: Alignment.centerRight,
                                            width: 45,
                                            height: 45,
                                            color: IdomColors.additionalColor,
                                            key: Key(
                                                "assets/icons/up-arrow.svg")),
                                      ),
                                    ),
                                  ),
                                  SizedBox(),
                                  SizedBox(),
                                ],
                              ),
                              TableRow(
                                children: [
                                  SizedBox(),
                                  Center(
                                    child: InkWell(
                                      onTap: () {},
                                      highlightColor: digitsVisible
                                          ? Colors.transparent
                                          : IdomColors.grey,
                                      splashColor: digitsVisible
                                          ? Colors.transparent
                                          : IdomColors.lighten(
                                              IdomColors.additionalColor, 0.3),
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: SvgPicture.asset(
                                            "assets/icons/left-arrow.svg",
                                            matchTextDirection: false,
                                            alignment: Alignment.centerRight,
                                            width: 45,
                                            height: 45,
                                            color: IdomColors.additionalColor,
                                            key: Key(
                                                "assets/icons/left-arrow.svg")),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: InkWell(
                                      onTap: () {},
                                      highlightColor: digitsVisible
                                          ? Colors.transparent
                                          : IdomColors.grey,
                                      splashColor: digitsVisible
                                          ? Colors.transparent
                                          : IdomColors.lighten(
                                              IdomColors.additionalColor, 0.3),
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text("OK",
                                            style: TextStyle(
                                                fontSize: 35,
                                                color:
                                                    IdomColors.additionalColor),
                                            key: Key("OK")),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: InkWell(
                                      onTap: () {},
                                      highlightColor: digitsVisible
                                          ? Colors.transparent
                                          : IdomColors.grey,
                                      splashColor: digitsVisible
                                          ? Colors.transparent
                                          : IdomColors.lighten(
                                              IdomColors.additionalColor, 0.3),
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: SvgPicture.asset(
                                            "assets/icons/right-arrow.svg",
                                            matchTextDirection: false,
                                            alignment: Alignment.centerRight,
                                            width: 45,
                                            height: 45,
                                            color: IdomColors.additionalColor,
                                            key: Key(
                                                "assets/icons/right-arrow.svg")),
                                      ),
                                    ),
                                  ),
                                  SizedBox(),
                                ],
                              ),
                              TableRow(
                                children: [
                                  SizedBox(),
                                  SizedBox(),
                                  Center(
                                    child: InkWell(
                                      onTap: () {},
                                      highlightColor: digitsVisible
                                          ? Colors.transparent
                                          : IdomColors.grey,
                                      splashColor: digitsVisible
                                          ? Colors.transparent
                                          : IdomColors.lighten(
                                              IdomColors.additionalColor, 0.3),
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: SvgPicture.asset(
                                            "assets/icons/down-arrow.svg",
                                            matchTextDirection: false,
                                            alignment: Alignment.centerRight,
                                            width: 45,
                                            height: 45,
                                            color: IdomColors.additionalColor,
                                            key: Key(
                                                "assets/icons/down-arrow.svg")),
                                      ),
                                    ),
                                  ),
                                  SizedBox(),
                                  SizedBox(),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Center(
                                    child: InkWell(
                                      onTap: () {},
                                      highlightColor: digitsVisible
                                          ? Colors.transparent
                                          : IdomColors.grey,
                                      splashColor: digitsVisible
                                          ? Colors.transparent
                                          : IdomColors.lighten(
                                              IdomColors.additionalColor, 0.3),
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                                        child: SvgPicture.asset(
                                            "assets/icons/no-sound.svg",
                                            matchTextDirection: false,
                                            alignment: Alignment.centerRight,
                                            width: 35,
                                            height: 35,
                                            color: IdomColors.additionalColor,
                                            key:
                                                Key("assets/icons/no-sound.svg")),
                                      ),
                                    ),
                                  ),
                                  SizedBox(),
                                  SizedBox(),
                                  SizedBox(),
                                  Center(
                                    child: InkWell(
                                      onTap: () {},
                                      highlightColor: digitsVisible
                                          ? Colors.transparent
                                          : IdomColors.grey,
                                      splashColor: digitsVisible
                                          ? Colors.transparent
                                          : IdomColors.lighten(
                                              IdomColors.additionalColor, 0.3),
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                                        child: SvgPicture.asset(
                                            "assets/icons/return.svg",
                                            matchTextDirection: false,
                                            alignment: Alignment.centerRight,
                                            width: 35,
                                            height: 35,
                                            color: IdomColors.additionalColor,
                                            key: Key("assets/icons/return.svg")),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                  children: [
                                    Center(
                                      child: InkWell(
                                        onTap: () {},
                                        highlightColor: digitsVisible
                                            ? Colors.transparent
                                            : IdomColors.grey,
                                        splashColor: digitsVisible
                                            ? Colors.transparent
                                            : IdomColors.lighten(
                                                IdomColors.additionalColor,
                                                0.3),
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: SvgPicture.asset(
                                              "assets/icons/volume-up.svg",
                                              matchTextDirection: false,
                                              alignment:
                                                  Alignment.centerRight,
                                              width: 35,
                                              height: 35,
                                              color:
                                                  IdomColors.additionalColor,
                                              key: Key(
                                                  "assets/icons/volume-up.svg")),
                                        ),
                                      ),
                                    ),
                                    SizedBox(),
                                    Center(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            digitsVisible = true;
                                          });
                                        },
                                        highlightColor: digitsVisible
                                            ? Colors.transparent
                                            : IdomColors.grey,
                                        splashColor: digitsVisible
                                            ? Colors.transparent
                                            : IdomColors.lighten(
                                            IdomColors.additionalColor,
                                            0.3),
                                        borderRadius:
                                        BorderRadius.circular(50.0),
                                        child: SvgPicture.asset(
                                            "assets/icons/cubes.svg",
                                            matchTextDirection: false,
                                            alignment:
                                            Alignment.centerRight,
                                            width: 55,
                                            height: 55,
                                            color:
                                            IdomColors.additionalColor,
                                            key: Key(
                                                "assets/icons/cubes.svg")),
                                      ),
                                    ),
                                    SizedBox(),
                                    Center(
                                      child: InkWell(
                                        onTap: () {},
                                        highlightColor: digitsVisible
                                            ? Colors.transparent
                                            : IdomColors.grey,
                                        splashColor: digitsVisible
                                            ? Colors.transparent
                                            : IdomColors.lighten(
                                            IdomColors.additionalColor,
                                            0.3),
                                        borderRadius:
                                        BorderRadius.circular(50.0),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: SvgPicture.asset(
                                              "assets/icons/next_channel.svg",
                                              matchTextDirection: false,
                                              alignment:
                                              Alignment.centerRight,
                                              width: 35,
                                              height: 35,
                                              color:
                                              IdomColors.additionalColor,
                                              key: Key(
                                                  "assets/icons/next_channel.svg")),
                                        ),
                                      ),
                                    ),
                                  ]),
                              TableRow(
                                children:[
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text("VOL",
                                          style: TextStyle(fontSize: 21.0)),
                                    ),
                                  ),
                                  SizedBox(),
                                  SizedBox(),

                                  SizedBox(),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text("CH",
                                          style: TextStyle(fontSize: 21.0)),
                                    ),
                                  ), ]
                              ),
                              TableRow(children: [
                                Center(
                                  child: InkWell(
                                    onTap: () {},
                                    highlightColor: digitsVisible
                                        ? Colors.transparent
                                        : IdomColors.grey,
                                    splashColor: digitsVisible
                                        ? Colors.transparent
                                        : IdomColors.lighten(
                                        IdomColors.additionalColor,
                                        0.3),
                                    borderRadius:
                                    BorderRadius.circular(50.0),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: SvgPicture.asset(
                                          "assets/icons/volume-down.svg",
                                          matchTextDirection: false,
                                          alignment:
                                          Alignment.centerRight,
                                          width: 35,
                                          height: 35,
                                          color:
                                          IdomColors.additionalColor,
                                          key: Key(
                                              "assets/icons/volume-down.svg")),
                                    ),
                                  ),
                                ),
                                SizedBox(),

                                SizedBox(),
                                SizedBox(),
                                Center(
                                  child: InkWell(
                                    onTap: () {},
                                    highlightColor: digitsVisible
                                        ? Colors.transparent
                                        : IdomColors.grey,
                                    splashColor: digitsVisible
                                        ? Colors.transparent
                                        : IdomColors.lighten(
                                        IdomColors.additionalColor,
                                        0.3),
                                    borderRadius:
                                    BorderRadius.circular(50.0),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: SvgPicture.asset(
                                          "assets/icons/previous_channel.svg",
                                          matchTextDirection: false,
                                          alignment:
                                          Alignment.centerRight,
                                          width: 35,
                                          height: 35,
                                          color:
                                          IdomColors.additionalColor,
                                          key: Key(
                                              "assets/icons/previous_channel.svg")),
                                    ),
                                  ),
                                ),
                              ])
                            ])))
                ]),
              ),
            ))));
  }

  _clickDriver() async {
    var result = await api.startDriver(widget.driver.name);
    var message;
    if (result == 200) {
      message = "Wysłano komendę do sterownika ${widget.driver.name}.";
    } else {
      message =
          "Wysłanie komendy do sterownika ${widget.driver.name} nie powiodło się.";
    }
    _scaffoldKey.currentState.removeCurrentSnackBar();
    final snackBar = new SnackBar(content: new Text(message));
    _scaffoldKey.currentState.showSnackBar((snackBar));
  }

  _navigateToEditDriver() async {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditDriver(storage: widget.storage, driver: widget.driver),
            fullscreenDialog: true));
    if (result == true) {
      final snackBar =
          new SnackBar(content: new Text("Zapisano dane sterownika."));
      _scaffoldKey.currentState.showSnackBar((snackBar));
      await _refreshSensorDetails();
    }
  }

  _refreshSensorDetails() async {
    try {
      setState(() {
        _load = true;
      });
      var res = await api.getDriverDetails(widget.driver.id);
      setState(() {
        _load = false;
      });
      if (res['statusCode'] == "200") {
        dynamic body = jsonDecode(res['body']);
        Driver refreshedDriver = Driver.fromJson(body);
        setState(() {
          widget.driver = refreshedDriver;
        });
      } else if (res['statusCode'] == "401") {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoader,
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...");
        await new Future.delayed(const Duration(seconds: 3));
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        await widget.storage.resetUserData();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        final snackBar = new SnackBar(
            content:
                new Text("Odświeżenie danych sterownika nie powiodło się."));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _load = false;
      });
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych sterownika. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych sterownika. Adres serwera nieprawidłowy."));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
    setState(() {
      _load = false;
    });
  }
}
