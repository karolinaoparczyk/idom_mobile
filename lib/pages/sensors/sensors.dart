import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/api.dart';

import 'package:idom/localization/sensors/sensors.i18n.dart';
import 'package:idom/main.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/sensors/new_sensor.dart';
import 'package:idom/pages/sensors/sensor_details.dart';
import 'package:idom/push_notifications.dart';
import 'package:idom/utils/app_state_notifier.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/login_procedures.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// displays sensors list
class Sensors extends StatefulWidget {
  Sensors({@required this.storage, this.testApi});

  /// internal storage
  final SecureStorage storage;

  /// api used for tests
  final Api testApi;

  /// handles state of widgets
  @override
  _SensorsState createState() => _SensorsState();
}

class _SensorsState extends State<Sensors> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  final GlobalKey<State> _keyLoaderInvalidToken = GlobalKey<State>();
  final TextEditingController _searchController = TextEditingController();
  Api api = Api();
  List<String> menuItems;
  List<Sensor> _sensorList = List<Sensor>();
  List<Sensor> _duplicateSensorList = List<Sensor>();
  bool zeroFetchedItems = false;
  bool _connectionEstablished;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }

    LoginProcedures.init(widget.storage, api);

    initFM();
    getSensors();
    _searchController.addListener(() {
      filterSearchResults(_searchController.text);
    });
  }

  initFM() async {
    final pushNotificationsManager = PushNotificationsManager();
    await pushNotificationsManager.init();
    pushNotificationsManager.getFM().configure(
        onMessage: (Map<String, dynamic> message) async {
      print("onMessage: $message");
      notifyMessage = message;

      Provider.of<AppStateNotifier>(context, listen: false).updateState();
      return null;
    });
  }

  /// returns list of sensors
  Future<List<Sensor>> getSensors() async {
    if (!mounted) {
      return null;
    }
    setState(() {
      _isSearching = false;
      _searchController.text = "";
    });

    try {
      /// gets sensors
      var res = await api.getSensors();

      if (res != null && res['statusCodeSensors'] == "200") {
        List<dynamic> bodySensors = jsonDecode(res['bodySensors']);
        setState(() {
          _sensorList =
              bodySensors.map((dynamic item) => Sensor.fromJson(item)).toList();
        });
        if (_sensorList.length == 0)
          zeroFetchedItems = true;
        else
          zeroFetchedItems = false;
      } else if (res != null && res['statusCodeSensors'] == "401") {
        final message = await LoginProcedures.signInWithStoredData();
        if (message != null) {
          logOut();
        } else {
          var res = await api.getSensors();

          /// on success fetching data
          if (res != null && res['statusCodeSensors'] == "200") {
            List<dynamic> bodySensors = jsonDecode(res['bodySensors']);
            setState(() {
              _sensorList = bodySensors
                  .map((dynamic item) => Sensor.fromJson(item))
                  .toList();
            });
            if (_sensorList.length == 0)
              zeroFetchedItems = true;
            else
              zeroFetchedItems = false;
          } else if (res != null && res['statusCodeSensors'] == "401") {
            logOut();
          } else {
            _connectionEstablished = false;
            setState(() {});
            return null;
          }
        }
      } else {
        _connectionEstablished = false;
        setState(() {});
        return null;
      }
    } catch (e) {
      setState(() {});
      print(e.toString());
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania czujników. Sprawdź połączenie z serwerem i spróbuj ponownie."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania czujników. Adres serwera nieprawidłowy."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
    setState(() {
      _duplicateSensorList.clear();
      _duplicateSensorList.addAll(_sensorList);
    });
    return _sensorList;
  }

  /// deactivates sensor after confirmation
  _deactivateSensor(Sensor sensor) async {
    var decision = await confirmActionDialog(context, "Potwierdź".i18n,
        "Czy na pewno chcesz usunąć czujnik ".i18n + sensor.name + "?");
    if (decision) {
      try {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoader,
            text: "Trwa usuwanie czujnika...".i18n);

        int statusCode = await api.deactivateSensor(sensor.id);
        Navigator.of(_scaffoldKey.currentContext, rootNavigator: true).pop();
        if (statusCode == 200) {
          setState(() {
            /// refreshes sensors' list
            getSensors();
          });
        } else if (statusCode == 401) {
          var message;
          if (widget.testApi != null) {
            message = "error";
          } else {
            message = await LoginProcedures.signInWithStoredData();
          }
          if (message != null) {
            logOut();
          } else {
            statusCode = await api.deactivateSensor(sensor.id);

            /// on success fetching data
            if (statusCode == 200) {
              setState(() {
                /// refreshes sensors' list
                getSensors();
              });
            } else if (statusCode == 401) {
              logOut();
            } else if (statusCode == null) {
              onDeleteSensorNullResponse();
            } else {
              onDeleteSensorError();
            }
          }
        } else if (statusCode == null) {
          onDeleteSensorNullResponse();
        } else {
          onDeleteSensorError();
        }
      } catch (e) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        print(e.toString());
        if (e.toString().contains("TimeoutException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd usuwania czujnika. Sprawdź połączenie z serwerem i spróbuj ponownie."
                      .i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
        if (e.toString().contains("SocketException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Usunięcie czujnika nie powiodło się. Spróbuj ponownie."
                      .i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      }
    }
  }

  onDeleteSensorNullResponse() {
    final snackBar = new SnackBar(
        content: new Text(
            "Błąd usuwania czujnika. Sprawdź połączenie z serwerem i spróbuj ponownie."
                .i18n));
    _scaffoldKey.currentState.showSnackBar((snackBar));
  }

  onDeleteSensorError() {
    final snackBar = new SnackBar(
        content: new Text(
            "Usunięcie czujnika nie powiodło się. Spróbuj ponownie.".i18n));
    _scaffoldKey.currentState.showSnackBar((snackBar));
  }

  Future<void> logOut() async {
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

  _buildSearchField() {
    return TextField(
      key: Key('searchField'),
      controller: _searchController,
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

  Future<bool> _onBackButton() async {
    var decision = await confirmActionDialog(
        context, "Potwierdź".i18n, "Na pewno wyjść z aplikacji?".i18n);
    return Future.value(decision);
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
          title: _isSearching ? _buildSearchField() : Text('Czujniki'.i18n),
          actions: <Widget>[
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
            _isSearching
                ? SizedBox()
                : IconButton(
                    icon: Icon(Icons.add, size: 30.0),
                    key: Key("addSensorButton"),
                    onPressed: navigateToNewSensor,
                  )
          ],
        ),
        drawer: IdomDrawer(
            storage: widget.storage,
            testApi: widget.testApi,
            parentWidgetType: "Sensors"),

        /// builds sensor's list
        body: Container(child: listSensors()),
      ),
    );
  }

  Widget listSensors() {
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
                      child: Text("Brak czujników w systemie.".i18n,
                          style: Theme.of(context).textTheme.bodyText2,
                          textAlign: TextAlign.center)))));
    }
    if (_connectionEstablished != null &&
        _connectionEstablished == false &&
        _sensorList.isEmpty) {
      return RefreshIndicator(
        backgroundColor: IdomColors.mainBackgroundDark,
        onRefresh: _pullRefresh,
        child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.only(
                    left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
                alignment: Alignment.topCenter,
                child: Text("Błąd połączenia z serwerem.".i18n,
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.center))),
      );
    } else if (!zeroFetchedItems &&
        _duplicateSensorList.isNotEmpty &&
        _sensorList.isEmpty) {
      return Padding(
          padding:
              EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text("Brak wyników wyszukiwania.".i18n,
                  style: Theme.of(context).textTheme.bodyText2,
                  textAlign: TextAlign.center)));
    } else if (_sensorList.isNotEmpty && _sensorList.length > 0) {
      return Column(children: [
        Expanded(
            child: Scrollbar(
                child: RefreshIndicator(
                    backgroundColor: IdomColors.mainBackgroundDark,
                    onRefresh: _pullRefresh,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, top: 10, right: 10.0, bottom: 0.0),
                      child: ListView.builder(
                        key: Key("SensorsList"),
                        shrinkWrap: true,
                        itemCount: _sensorList.length,
                        itemBuilder: (BuildContext buildContext, index) =>
                            Container(
                                height: 80,
                                child: Card(
                                    child: ListTile(
                                        key: Key(_sensorList[index].name),
                                        title: Text(
                                          _sensorList[index].name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(fontSize: 21.0),
                                        ),
                                        subtitle: Text(
                                          sensorData(_sensorList[index]),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                  fontSize: 16.5,
                                                  fontWeight:
                                                      FontWeight.normal),
                                        ),
                                        onTap: () {
                                          navigateToSensorDetails(
                                              _sensorList[index]);
                                        },
                                        leading: getCategoryImage(
                                            _sensorList[index]),

                                        /// delete sensor button
                                        trailing: getTrailing(buildContext,
                                            _sensorList[index])))),
                      ),
                    ))))
      ]);
    }

    /// shows progress indicator while fetching data
    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, top: 10, right: 10.0, bottom: 0.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget getCategoryImage(Sensor sensor) {
    var imageUrl;
    switch (sensor.category) {
      case "atmo_pressure":
        imageUrl = "assets/icons/barometer.svg";
        break;
      case "water_temp":
        imageUrl = "assets/icons/temperature.svg";
        break;
      case "breathalyser":
        imageUrl = "assets/icons/breathalyser.svg";
        break;
      case "gas":
        imageUrl = "assets/icons/gas-bottle.svg";
        break;
      case "smoke":
        imageUrl = "assets/icons/smoke.svg";
        break;
      case "air_humidity":
        imageUrl = "assets/icons/humidity.svg";
        break;
      case "humidity":
        imageUrl = "assets/icons/pot.svg";
        break;
      case "temperature":
        imageUrl = "assets/icons/thermometer.svg";
        break;
      case "rain_sensor":
        imageUrl = "assets/icons/rain.svg";
        break;
      case "motion_sensor":
        imageUrl = "assets/icons/motion.svg";
        break;
    }
    return SizedBox(
        width: 35,
        child: Container(
            padding: EdgeInsets.only(top: 5),
            alignment: Alignment.centerRight,
            child: SvgPicture.asset(imageUrl,
                matchTextDirection: false,
                width: 32,
                height: 32,
                color: Theme.of(context).iconTheme.color,
                key: Key(imageUrl))));
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      /// refreshes sensors' list
      getSensors();
    });
  }

  void filterSearchResults(String query) {
    query = query.toLowerCase();
    List<Sensor> dummySearchList = List<Sensor>();
    dummySearchList.addAll(_duplicateSensorList);
    if (query.isNotEmpty) {
      List<Sensor> dummyListData = List<Sensor>();
      dummySearchList.forEach((item) {
        if (item.name.toLowerCase().contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        _sensorList.clear();
        _sensorList.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        _sensorList.clear();
        _sensorList.addAll(_duplicateSensorList);
      });
    }
  }

  String sensorData(Sensor sensor) {
    var doubleData;
    var stringData;
    if (sensor.lastData != null) {
      doubleData = double.tryParse(sensor.lastData);
      if (doubleData == null) {
        return "";
      }
      stringData = doubleData.toStringAsFixed(2);
    }
    var lastDataLabel = "ostatnia dana".i18n;
    switch (sensor.category) {
      case "water_temp":
      case "temperature":
        if (sensor.lastData == null) return "$lastDataLabel: -";
        return "$lastDataLabel: " + "$stringData °C";
        break;
      case "air_humidity":
      case "humidity":
        if (sensor.lastData == null) return "$lastDataLabel: -";
        return "$lastDataLabel: " + "$stringData %";
        break;
      case "breathalyser":
        if (sensor.lastData == null) return "$lastDataLabel: -";
        return "$lastDataLabel: " + "$stringData ‰";
        break;
      case "atmo_pressure":
        if (sensor.lastData == null) return "$lastDataLabel: -";
        return "$lastDataLabel: " + "$stringData hPa";
        break;
      case "smoke":
      case "gas":
      case "rain_sensor":
      case "motion_sensor":
        return "";
    }
  }

  /// navigates to adding sensor page
  navigateToNewSensor() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                NewSensor(storage: widget.storage, testApi: widget.testApi),
            fullscreenDialog: true));

    /// displays success message if sensor added succesfully
    if (result == true) {
      final snackBar =
          new SnackBar(content: new Text("Dodano nowy czujnik.".i18n));
      _scaffoldKey.currentState.showSnackBar((snackBar));
      await getSensors();
    }
  }

  /// navigates to sensor's details
  navigateToSensorDetails(Sensor sensor) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SensorDetails(
            storage: widget.storage, sensor: sensor, testApi: widget.testApi)));
    await getSensors();
  }

  getTrailing(BuildContext buildContext, Sensor sensor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (sensor.category == "temperature" ||
            sensor.category == "water_temp" ||
            sensor.category == "atmo_pressure" ||
            sensor.category == "air_humidity" ||
            sensor.category == "humidity")
          SizedBox(
              width: 40,
              child: Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                      width: 40,
                      child: Stack(children: [
                        Container(
                            padding: EdgeInsets.all(5),
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              "assets/icons/battery.svg",
                              key: Key("assets/icons/battery.svg"),
                              matchTextDirection: false,
                              width: 36,
                              height: 36,
                              color: IdomColors.additionalColor,
                            )),
                        Container(
                            alignment: Alignment.center,
                            child: Text(
                                sensor.batteryLevel != null
                                    ? sensor.batteryLevel.toString() + "%"
                                    : "-%",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(fontSize: 13.5)))
                      ])))),
        SizedBox(
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
                            color: Theme.of(context).textTheme.bodyText1.color,
                          ))),
                  onPressed: () {
                    setState(() {
                      _deactivateSensor(sensor);
                    });
                  },
                ))),
      ],
    );
  }
}
