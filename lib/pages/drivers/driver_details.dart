import 'dart:convert';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:idom/localization/drivers/driver_details.i18n.dart';

import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/drivers/edit_driver.dart';
import 'package:idom/remote_control.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';

/// displays driver details
class DriverDetails extends StatefulWidget {
  DriverDetails({@required this.storage, @required this.driver, this.testApi});

  /// internal storage
  final SecureStorage storage;

  /// selected driver
  Driver driver;

  /// api used for tests
  final Api testApi;

  /// handles state of widgets
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
  Color selectedColor;
  final List<Color> _colors = [
    Color.fromARGB(255, 255, 0, 0),
    Color.fromARGB(255, 255, 128, 0),
    Color.fromARGB(255, 255, 255, 0),
    Color.fromARGB(255, 128, 255, 0),
    Color.fromARGB(255, 0, 255, 0),
    Color.fromARGB(255, 0, 255, 128),
    Color.fromARGB(255, 0, 255, 255),
    Color.fromARGB(255, 0, 128, 255),
    Color.fromARGB(255, 0, 0, 255),
    Color.fromARGB(255, 127, 0, 255),
    Color.fromARGB(255, 255, 0, 255),
    Color.fromARGB(255, 255, 0, 127),
    Color.fromARGB(255, 128, 128, 128),
  ];
  double _colorSliderPosition = 255;
  double _shadeSliderPosition;
  Color _currentColor;
  Color _shadedColor;

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }
    _load = false;
    _currentColor = _calculateSelectedColor(_colorSliderPosition);
    _shadeSliderPosition = 255 / 2; //center the shader selector
    _shadedColor = _calculateShadedColor(_shadeSliderPosition);
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
                              Icon(Icons.info_outline_rounded, size: 21),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text("Ogólne".i18n,
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                              ),
                            ],
                          ))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 62, top: 10.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Nazwa".i18n,
                              style: Theme.of(context).textTheme.headline5))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 62, top: 0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(widget.driver.name,
                              style: Theme.of(context).textTheme.bodyText2))),
                  if (widget.driver.category == "bulb")
                    Padding(
                        padding: EdgeInsets.only(
                            left: 62, top: 10.0, right: 30.0, bottom: 0.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Adres IP".i18n,
                                style: Theme.of(context).textTheme.headline5))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 62, top: 0, right: 30.0, bottom: 10.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              widget.driver.ipAddress != null
                                  ? widget.driver.ipAddress
                                  : "-",
                              style: Theme.of(context).textTheme.bodyText2))),
                  Divider(),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 10.0, right: 30.0, bottom: 0.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(Icons.touch_app_outlined, size: 21),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text("Obsługa sterownika".i18n,
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                              ),
                            ],
                          ))),
                  if ((widget.driver.category == "bulb" ||
                          widget.driver.category == "roller_blind") &&
                      widget.driver.data != null)
                    Padding(
                        padding: EdgeInsets.only(
                            left: 62, top: 10.0, right: 30.0, bottom: 0.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Aktualny stan".i18n,
                                style: Theme.of(context).textTheme.headline5))),
                  if ((widget.driver.category == "bulb" ||
                          widget.driver.category == "roller_blind") &&
                      widget.driver.data != null)
                    Padding(
                        padding: EdgeInsets.only(
                            left: 62, top: 0, right: 30.0, bottom: 0.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(_getDataValue(),
                                style: Theme.of(context).textTheme.bodyText2))),
                  if (widget.driver.category == "clicker")
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 62, top: 30, right: 62, bottom: 0.0),
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
                          Text("Wciśnij przycisk".i18n,
                              style: Theme.of(context).textTheme.bodyText2),
                        ],
                      ),
                    ),
                  if (widget.driver.category == "remote_control")
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 62, top: 30, right: 62, bottom: 0.0),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .color),
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AnimatedCrossFade(
                                crossFadeState: digitsVisible
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                duration: Duration(milliseconds: 300),
                                firstChild: digitsVisible
                                    ? Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 30.0),
                                            child: TextFormField(
                                              key: Key('channelNumber'),
                                              readOnly: true,
                                              keyboardType:
                                                  TextInputType.number,
                                              controller:
                                                  _channelNumberController,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(fontSize: 21.0),
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2
                                                          .color),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2
                                                          .color),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          Table(
                                            children: [
                                              TableRow(children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                      child: Text("2",
                                                          style: TextStyle(
                                                              color: IdomColors
                                                                  .additionalColor,
                                                              fontSize: 21,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
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
                                                      child: Text("3",
                                                          style: TextStyle(
                                                              color: IdomColors
                                                                  .additionalColor,
                                                              fontSize: 21,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          key: Key("3")),
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                              TableRow(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
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
                                                            const EdgeInsets
                                                                .all(18.0),
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
                                                    padding:
                                                        const EdgeInsets.only(
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
                                                            const EdgeInsets
                                                                .all(18.0),
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
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                          const EdgeInsets.only(
                                                              top: 16.0,
                                                              bottom: 16.0),
                                                      child: SvgPicture.asset(
                                                          "assets/icons/left-arrow-long.svg",
                                                          matchTextDirection:
                                                              false,
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
                                                      child: Text("0",
                                                          style: TextStyle(
                                                              color: IdomColors
                                                                  .additionalColor,
                                                              fontSize: 21,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          key: Key("0")),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    _sendCommandToRemoteControl(
                                                        "Channel",
                                                        channel: int.tryParse(
                                                            _channelNumberController
                                                                .text));
                                                  },
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
                                                      BorderRadius.circular(
                                                          50.0),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 16.0,
                                                      bottom: 16.0,
                                                    ),
                                                    child: SvgPicture.asset(
                                                        "assets/icons/enter.svg",
                                                        matchTextDirection:
                                                            false,
                                                        alignment: Alignment
                                                            .bottomCenter,
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 18.0),
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        digitsVisible = false;
                                                        _channelNumberController
                                                            .text = "";
                                                      });
                                                    },
                                                    splashColor:
                                                        IdomColors.lighten(
                                                            IdomColors
                                                                .additionalColor,
                                                            0.3),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                    child: Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text("WRÓĆ".i18n,
                                                            style: TextStyle(
                                                                color: IdomColors
                                                                    .additionalColor,
                                                                fontSize: 25),
                                                            key: Key("goBack")),
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
                                secondChild: Table(columnWidths: {
                                  0: FlexColumnWidth(1),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(2),
                                  3: FlexColumnWidth(1),
                                  4: FlexColumnWidth(1),
                                }, children: [
                                  TableRow(
                                    children: [
                                      Center(
                                        child: InkWell(
                                          onTap: () {
                                            _sendCommandToRemoteControl("Menu");
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
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: SvgPicture.asset(
                                                "assets/icons/menu.svg",
                                                matchTextDirection: false,
                                                alignment:
                                                    Alignment.centerRight,
                                                width: 35,
                                                height: 35,
                                                color:
                                                    IdomColors.additionalColor,
                                                key: Key(
                                                    "assets/icons/menu.svg")),
                                          ),
                                        ),
                                      ),
                                      SizedBox(),
                                      SizedBox(),
                                      SizedBox(),
                                      Center(
                                        child: InkWell(
                                          onTap: () {
                                            _sendCommandToRemoteControl(
                                                "Power");
                                          },
                                          highlightColor: digitsVisible
                                              ? Colors.transparent
                                              : IdomColors.grey,
                                          splashColor: digitsVisible
                                              ? Colors.transparent
                                              : IdomColors.lighten(
                                                  IdomColors.error, 0.3),
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: SvgPicture.asset(
                                                "assets/icons/turn-off.svg",
                                                matchTextDirection: false,
                                                alignment:
                                                    Alignment.centerRight,
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
                                          onTap: () {
                                            _sendCommandToRemoteControl("Up");
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
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: SvgPicture.asset(
                                                "assets/icons/up-arrow.svg",
                                                matchTextDirection: false,
                                                alignment:
                                                    Alignment.centerRight,
                                                width: 45,
                                                height: 45,
                                                color:
                                                    IdomColors.additionalColor,
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
                                          onTap: () {
                                            _sendCommandToRemoteControl("Left");
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
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: SvgPicture.asset(
                                                "assets/icons/left-arrow.svg",
                                                matchTextDirection: false,
                                                alignment:
                                                    Alignment.centerRight,
                                                width: 45,
                                                height: 45,
                                                color:
                                                    IdomColors.additionalColor,
                                                key: Key(
                                                    "assets/icons/left-arrow.svg")),
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: InkWell(
                                          onTap: () {
                                            _sendCommandToRemoteControl("OK");
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
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Text("OK",
                                                style: TextStyle(
                                                    fontSize: 35,
                                                    color: IdomColors
                                                        .additionalColor),
                                                key: Key("OK")),
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: InkWell(
                                          onTap: () {
                                            _sendCommandToRemoteControl(
                                                "Right");
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
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: SvgPicture.asset(
                                                "assets/icons/right-arrow.svg",
                                                matchTextDirection: false,
                                                alignment:
                                                    Alignment.centerRight,
                                                width: 45,
                                                height: 45,
                                                color:
                                                    IdomColors.additionalColor,
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
                                          onTap: () {
                                            _sendCommandToRemoteControl("Down");
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
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: SvgPicture.asset(
                                                "assets/icons/down-arrow.svg",
                                                matchTextDirection: false,
                                                alignment:
                                                    Alignment.centerRight,
                                                width: 45,
                                                height: 45,
                                                color:
                                                    IdomColors.additionalColor,
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
                                          onTap: () {
                                            _sendCommandToRemoteControl("Mute");
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
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8.0, bottom: 16.0),
                                            child: SvgPicture.asset(
                                                "assets/icons/no-sound.svg",
                                                matchTextDirection: false,
                                                alignment:
                                                    Alignment.centerRight,
                                                width: 35,
                                                height: 35,
                                                color:
                                                    IdomColors.additionalColor,
                                                key: Key(
                                                    "assets/icons/no-sound.svg")),
                                          ),
                                        ),
                                      ),
                                      SizedBox(),
                                      SizedBox(),
                                      SizedBox(),
                                      Center(
                                        child: InkWell(
                                          onTap: () {
                                            _sendCommandToRemoteControl("Back");
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
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8.0, bottom: 16.0),
                                            child: SvgPicture.asset(
                                                "assets/icons/return.svg",
                                                matchTextDirection: false,
                                                alignment:
                                                    Alignment.centerRight,
                                                width: 35,
                                                height: 35,
                                                color:
                                                    IdomColors.additionalColor,
                                                key: Key(
                                                    "assets/icons/return.svg")),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(children: [
                                    Center(
                                      child: InkWell(
                                        onTap: () {
                                          _sendCommandToRemoteControl("Vol+");
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
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: SvgPicture.asset(
                                              "assets/icons/volume-up.svg",
                                              matchTextDirection: false,
                                              alignment: Alignment.centerRight,
                                              width: 35,
                                              height: 35,
                                              color: IdomColors.additionalColor,
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
                                            alignment: Alignment.centerRight,
                                            width: 55,
                                            height: 55,
                                            color: IdomColors.additionalColor,
                                            key: Key("assets/icons/cubes.svg")),
                                      ),
                                    ),
                                    SizedBox(),
                                    Center(
                                      child: InkWell(
                                        onTap: () {
                                          _sendCommandToRemoteControl("CH+");
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
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: SvgPicture.asset(
                                              "assets/icons/next_channel.svg",
                                              matchTextDirection: false,
                                              alignment: Alignment.centerRight,
                                              width: 35,
                                              height: 35,
                                              color: IdomColors.additionalColor,
                                              key: Key(
                                                  "assets/icons/next_channel.svg")),
                                        ),
                                      ),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Text("VOL",
                                            style: TextStyle(fontSize: 21.0)),
                                      ),
                                    ),
                                    SizedBox(),
                                    SizedBox(),
                                    SizedBox(),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Text("CH",
                                            style: TextStyle(fontSize: 21.0)),
                                      ),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    Center(
                                      child: InkWell(
                                        onTap: () {
                                          _sendCommandToRemoteControl("Vol-");
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
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: SvgPicture.asset(
                                              "assets/icons/volume-down.svg",
                                              matchTextDirection: false,
                                              alignment: Alignment.centerRight,
                                              width: 35,
                                              height: 35,
                                              color: IdomColors.additionalColor,
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
                                        onTap: () {
                                          _sendCommandToRemoteControl("CH-");
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
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: SvgPicture.asset(
                                              "assets/icons/previous_channel.svg",
                                              matchTextDirection: false,
                                              alignment: Alignment.centerRight,
                                              width: 35,
                                              height: 35,
                                              color: IdomColors.additionalColor,
                                              key: Key(
                                                  "assets/icons/previous_channel.svg")),
                                        ),
                                      ),
                                    ),
                                  ])
                                ])),
                          ),
                        )),
                  if (widget.driver.category == "remote_control")
                    SizedBox(height: 20),
                  if (widget.driver.category == "bulb")
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: SizedBox.fromSize(
                        size: Size(56, 56),
                        child: ClipOval(
                            child: Material(
                                color:
                                    IdomColors.lighten(IdomColors.error, 0.55),
                                child: InkWell(
                                    key: Key("assets/icons/turn-off.svg"),
                                    onTap: () {
                                      _switchBulb();
                                    },
                                    borderRadius: BorderRadius.circular(50.0),
                                    splashColor: IdomColors.lighten(
                                        IdomColors.error, 0.2),
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 13.0,
                                            right: 13.0,
                                            top: 15.0,
                                            bottom: 13.0),
                                        child: SvgPicture.asset(
                                            "assets/icons/turn-off.svg",
                                            matchTextDirection: false,
                                            width: 35,
                                            height: 35,
                                            color: IdomColors.error))))),
                      ),
                    ),
                  if (widget.driver.category == "bulb")
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (DragStartDetails details) {
                        _colorChangeHandler(details.localPosition.dx);
                      },
                      onHorizontalDragUpdate: (DragUpdateDetails details) {
                        _colorChangeHandler(details.localPosition.dx);
                      },
                      onTapDown: (TapDownDetails details) {
                        _colorChangeHandler(details.localPosition.dx);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Container(
                          width: 255,
                          height: 15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(colors: _colors),
                          ),
                          child: CustomPaint(
                            painter:
                                _SliderIndicatorPainter(_colorSliderPosition),
                          ),
                        ),
                      ),
                    ),
                  if (widget.driver.category == "bulb")
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox.fromSize(
                              size: Size(56, 56),
                              child: ClipOval(
                                  child: Material(
                                      color: IdomColors.lighten(
                                          IdomColors.additionalColor, 0.4),
                                      child: InkWell(
                                          key: Key("assets/icons/enter.svg"),
                                          onTap: () {
                                            _changeBulbColor();
                                          },
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                          splashColor: IdomColors.lighten(
                                              IdomColors.additionalColor, 0.2),
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15.0,
                                                  right: 15.0,
                                                  top: 15.0,
                                                  bottom: 15.0),
                                              child: SvgPicture.asset(
                                                "assets/icons/enter.svg",
                                                matchTextDirection: false,
                                                width: 15,
                                                height: 15,
                                                color:
                                                    IdomColors.additionalColor,
                                              )))))),
                          Text("Ustaw kolor".i18n,
                              style: Theme.of(context).textTheme.bodyText2),
                        ]),
                  if (widget.driver.category == "bulb")
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (DragStartDetails details) {
                        _shadeChangeHandler(details.localPosition.dx);
                      },
                      onHorizontalDragUpdate: (DragUpdateDetails details) {
                        _shadeChangeHandler(details.localPosition.dx);
                      },
                      onTapDown: (TapDownDetails details) {
                        _shadeChangeHandler(details.localPosition.dx);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Container(
                          width: 255,
                          height: 15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(colors: [
                              Colors.black,
                              _currentColor,
                              Colors.white
                            ]),
                          ),
                          child: CustomPaint(
                            painter:
                                _SliderIndicatorPainter(_shadeSliderPosition),
                          ),
                        ),
                      ),
                    ),
                  if (widget.driver.category == "bulb")
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox.fromSize(
                              size: Size(56, 56),
                              child: ClipOval(
                                  child: Material(
                                      color: IdomColors.lighten(
                                          IdomColors.additionalColor, 0.4),
                                      child: InkWell(
                                          key: Key("assets/icons/enter.svg"),
                                          onTap: () {
                                            _changeBulbBrightness();
                                          },
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                          splashColor: IdomColors.lighten(
                                              IdomColors.additionalColor, 0.2),
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15.0,
                                                  right: 15.0,
                                                  top: 15.0,
                                                  bottom: 15.0),
                                              child: SvgPicture.asset(
                                                "assets/icons/enter.svg",
                                                matchTextDirection: false,
                                                width: 25,
                                                height: 25,
                                                color:
                                                    IdomColors.additionalColor,
                                              )))))),
                          Text("Ustaw jasność".i18n,
                              style: Theme.of(context).textTheme.bodyText2),
                        ]),
                  if (widget.driver.category == "bulb")
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, border: Border.all()),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                              "assets/icons/light_bulb_filled.svg",
                              matchTextDirection: false,
                              alignment: Alignment.centerRight,
                              width: 85,
                              height: 85,
                              color: _shadedColor,
                              key: Key("assets/icons/light_bulb_filled.svg")),
                        ),
                      ),
                    ),
                  if (widget.driver.category == "bulb") SizedBox(height: 20),
                  if (widget.driver.category == "roller_blind")
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 62, top: 30, right: 62, bottom: 0.0),
                      child: Column(children: [
                        SizedBox.fromSize(
                            size: Size(56, 56),
                            child: ClipOval(
                                child: Material(
                                    color: IdomColors.lighten(
                                        IdomColors.additionalColor, 0.4),
                                    child: InkWell(
                                        onTap: () {},
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        splashColor: IdomColors.lighten(
                                            IdomColors.additionalColor, 0.2),
                                        child: Padding(
                                          padding: const EdgeInsets.all(13.0),
                                          child: SvgPicture.asset(
                                              "assets/icons/up-arrow.svg",
                                              matchTextDirection: false,
                                              width: 10,
                                              height: 10,
                                              color: IdomColors.additionalColor,
                                              key: Key(
                                                  "assets/icons/up-arrow.svg")),
                                        ))))),
                        Container(
                          child: Text("Podnieś rolety".i18n,
                              style: Theme.of(context).textTheme.bodyText2),
                        ),
                        SizedBox(height: 30),
                        SizedBox.fromSize(
                            size: Size(56, 56),
                            child: ClipOval(
                                child: Material(
                                    color: IdomColors.lighten(
                                        IdomColors.additionalColor, 0.4),
                                    child: InkWell(
                                        onTap: () {},
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        splashColor: IdomColors.lighten(
                                            IdomColors.additionalColor, 0.2),
                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 13.0,
                                                right: 13.0,
                                                top: 15.0,
                                                bottom: 13.0),
                                            child: SvgPicture.asset(
                                                "assets/icons/down-arrow.svg",
                                                matchTextDirection: false,
                                                width: 10,
                                                height: 10,
                                                color:
                                                    IdomColors.additionalColor,
                                                key: Key(
                                                    "assets/icons/down-arrow.svg"))))))),
                        Container(
                          child: Text("Opuść rolety".i18n,
                              style: Theme.of(context).textTheme.bodyText2),
                        ),
                      ]),
                    )
                ]),
              ),
            ))));
  }

  _getDataValue() {
    if (widget.driver.category == "bulb") {
      return widget.driver.data ? "włączona".i18n : "wyłączona".i18n;
    } else if (widget.driver.category == "roller_blind") {
      return widget.driver.data ? "podniesione".i18n : "opuszczone".i18n;
    }
  }

  _colorChangeHandler(double position) {
    if (position > 255) {
      position = 255;
    }
    if (position < 0) {
      position = 0;
    }
    setState(() {
      _colorSliderPosition = position;
      _currentColor = _calculateSelectedColor(_colorSliderPosition);
      _shadedColor = _calculateShadedColor(_shadeSliderPosition);
    });
  }

  _shadeChangeHandler(double position) {
    if (position > 255) position = 255;
    if (position < 0) position = 0;
    setState(() {
      _shadeSliderPosition = position;
      _shadedColor = _calculateShadedColor(_shadeSliderPosition);
    });
  }

  Color _calculateSelectedColor(double position) {
    double positionInColorArray = (position / 255 * (_colors.length - 1));
    int index = positionInColorArray.truncate();
    double remainder = positionInColorArray - index;
    if (remainder == 0.0) {
      _currentColor = _colors[index];
    } else {
      int redValue = _colors[index].red == _colors[index + 1].red
          ? _colors[index].red
          : (_colors[index].red +
                  (_colors[index + 1].red - _colors[index].red) * remainder)
              .round();
      int greenValue = _colors[index].green == _colors[index + 1].green
          ? _colors[index].green
          : (_colors[index].green +
                  (_colors[index + 1].green - _colors[index].green) * remainder)
              .round();
      int blueValue = _colors[index].blue == _colors[index + 1].blue
          ? _colors[index].blue
          : (_colors[index].blue +
                  (_colors[index + 1].blue - _colors[index].blue) * remainder)
              .round();
      _currentColor = Color.fromARGB(255, redValue, greenValue, blueValue);
    }
    return _currentColor;
  }

  Color _calculateShadedColor(double position) {
    double ratio = position / 255;
    if (ratio > 0.5) {
      int redVal = _currentColor.red != 255
          ? (_currentColor.red +
                  (255 - _currentColor.red) * (ratio - 0.5) / 0.5)
              .round()
          : 255;
      int greenVal = _currentColor.green != 255
          ? (_currentColor.green +
                  (255 - _currentColor.green) * (ratio - 0.5) / 0.5)
              .round()
          : 255;
      int blueVal = _currentColor.blue != 255
          ? (_currentColor.blue +
                  (255 - _currentColor.blue) * (ratio - 0.5) / 0.5)
              .round()
          : 255;
      return Color.fromARGB(255, redVal, greenVal, blueVal);
    } else if (ratio < 0.5) {
      int redVal = _currentColor.red != 0
          ? (_currentColor.red * ratio / 0.5).round()
          : 0;
      int greenVal = _currentColor.green != 0
          ? (_currentColor.green * ratio / 0.5).round()
          : 0;
      int blueVal = _currentColor.blue != 0
          ? (_currentColor.blue * ratio / 0.5).round()
          : 0;
      return Color.fromARGB(255, redVal, greenVal, blueVal);
    } else {
      return _currentColor;
    }
  }

  _changeBulbColor() async {
    if (widget.driver.ipAddress == null) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      final snackBar = new SnackBar(
          content: new Text("Żarówka nie posiada adresu IP.".i18n));
      _scaffoldKey.currentState.showSnackBar((snackBar));
      return;
    }
    var message;
    displayProgressDialog(
        context: context, key: _keyLoader, text: "Wysyłanie komendy...".i18n);
    var result = await api.changeBulbColor(widget.driver.id, _currentColor.red,
        _currentColor.green, _currentColor.blue);
    Navigator.pop(context);
    var serverError = RegExp("50[0-4]");
    if (result == 200) {
      message = "Wysłano komendę zmiany koloru żarówki ".i18n +
          widget.driver.name +
          ".".i18n;
    } else if (result == 404) {
      message = "Nie znaleziono sterownika ".i18n +
          widget.driver.name +
          " na serwerze. Odswież listę sterowników.".i18n;
    } else if (serverError.hasMatch(result.toString())) {
      message = "Nie udało się podłączyć do sterownika ".i18n +
          widget.driver.name +
          ". Sprawdź podłączenie i spróbuj ponownie.".i18n;
    }
    if (message != null) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      final snackBar = new SnackBar(content: new Text(message));
      _scaffoldKey.currentState.showSnackBar((snackBar));
    }
  }

  _changeBulbBrightness() async {
    if (widget.driver.ipAddress == null) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      final snackBar = new SnackBar(
          content: new Text("Żarówka nie posiada adresu IP.".i18n));
      _scaffoldKey.currentState.showSnackBar((snackBar));
      return;
    }
    var message;
    if (_shadeSliderPosition == 0) _shadeSliderPosition = 1;
    int brightness = (_shadeSliderPosition / 255 * 100).round();
    displayProgressDialog(
        context: context, key: _keyLoader, text: "Wysyłanie komendy...".i18n);
    var result = await api.changeBulbBrightness(widget.driver.id, brightness);
    Navigator.pop(context);
    var serverError = RegExp("50[0-4]");
    if (result == 200) {
      message = "Wysłano komendę zmiany jasności żarówki ".i18n +
          widget.driver.name +
          ".".i18n;
    } else if (result == 404) {
      message = "Nie znaleziono sterownika ".i18n +
          widget.driver.name +
          " na serwerze. Odswież listę sterowników.".i18n;
    } else if (serverError.hasMatch(result.toString())) {
      message = "Nie udało się podłączyć do sterownika ".i18n +
          widget.driver.name +
          ". Sprawdź podłączenie i spróbuj ponownie.".i18n;
    }
    if (message != null) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      final snackBar = new SnackBar(content: new Text(message));
      _scaffoldKey.currentState.showSnackBar((snackBar));
    }
  }

  _switchBulb() async {
    if (widget.driver.ipAddress == null) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      final snackBar = new SnackBar(
          content: new Text("Żarówka nie posiada adresu IP.".i18n));
      _scaffoldKey.currentState.showSnackBar((snackBar));
      return;
    }
    var flag = widget.driver.data == null
        ? "on"
        : widget.driver.data
            ? "off"
            : "on";
    var message;
    var result;
    displayProgressDialog(
        context: context, key: _keyLoader, text: "Wysyłanie komendy...".i18n);
    if (widget.driver.category == "bulb") {
      result = await api.switchBulb(widget.driver.id, flag);
    }
    Navigator.pop(context);
    var serverError = RegExp("50[0-4]");
    if (result == 200) {
      if (flag == "on") {
        message = "Wysłano komendę włączenia żarówki ".i18n +
            widget.driver.name +
            ".".i18n;
      } else {
        message = "Wysłano komendę wyłączenia żarówki ".i18n +
            widget.driver.name +
            ".".i18n;
      }
      await _refreshDriverDetails();
    } else if (result == 404) {
      message = "Nie znaleziono żarówki ".i18n +
          widget.driver.name +
          " na serwerze. Odswież listę sterowników.".i18n;
    } else if (serverError.hasMatch(result.toString())) {
      message = "Nie udało się podłączyć do żarówki".i18n +
          widget.driver.name +
          ". Sprawdź podłączenie i spróbuj ponownie.".i18n;
    }
    if (message != null) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      final snackBar = new SnackBar(content: new Text(message));
      _scaffoldKey.currentState.showSnackBar((snackBar));
    }
  }

  _clickDriver() async {
    displayProgressDialog(
        context: context, key: _keyLoader, text: "Wysyłanie komendy...".i18n);
    var result = await api.startDriver(widget.driver.name);
    Navigator.pop(context);
    var message;
    if (result == 200) {
      message =
          "Wysłano komendę do sterownika ".i18n + widget.driver.name + ".".i18n;
    } else {
      message = "Wysłanie komendy do sterownika ".i18n +
          widget.driver.name +
          " nie powiodło się.".i18n;
    }
    _scaffoldKey.currentState.removeCurrentSnackBar();
    final snackBar = new SnackBar(content: new Text(message));
    _scaffoldKey.currentState.showSnackBar((snackBar));
  }

  _sendCommandToRemoteControl(String command, {int channel}) async {
    if (widget.driver.ipAddress == null) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      final snackBar =
          new SnackBar(content: new Text("Pilot nie posiada adresu IP.".i18n));
      _scaffoldKey.currentState.showSnackBar((snackBar));
      return;
    }
    var result;
    displayProgressDialog(
        context: context, key: _keyLoader, text: "Wysyłanie komendy...".i18n);
    try {
      switch (command) {
        case "Mute":
        case "Back":
        case "Vol+":
        case "Vol-":
        case "CH+":
        case "CH-":
        case "OK":
        case "Power":
        case "Menu":
        case "Up":
        case "Down":
        case "Left":
        case "Right":
          result = await RemoteControl.sendCommand(widget.driver, command);
          break;
        case "Channel":
          result = await RemoteControl.sendCommand(widget.driver, command,
              channel: channel);
          break;
      }
      Navigator.pop(context);
      if (result != null) {
        if (result == 200) {
          final snackBar = new SnackBar(
              content: new Text("Komenda wysłana do pilota.".i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        } else {
          final snackBar = new SnackBar(
              content: new Text(
                  "Wysłanie komendy do pilota nie powiodło się.".i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      }
    } catch (e) {
      Navigator.pop(context);
      final snackBar = new SnackBar(
          content:
              new Text("Wysłanie komendy do pilota nie powiodło się.".i18n));
      _scaffoldKey.currentState.showSnackBar((snackBar));
    }
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
          new SnackBar(content: new Text("Zapisano sterownik.".i18n));
      _scaffoldKey.currentState.showSnackBar((snackBar));
      await _refreshDriverDetails();
    }
  }

  _refreshDriverDetails() async {
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

class _SliderIndicatorPainter extends CustomPainter {
  final double position;

  _SliderIndicatorPainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
        Offset(position, size.height / 2), 12, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(_SliderIndicatorPainter old) {
    return true;
  }
}
