import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';

import 'package:idom/models.dart';
import 'package:idom/pages/sensors/new_sensor.dart';
import 'package:idom/pages/sensors/sensor_details.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// displays all sensors
class Sensors extends StatefulWidget {
  Sensors({@required this.storage, this.testApi});

  final SecureStorage storage;
  final Api testApi;

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
  List<Sensor> _sensorList;
  List<Sensor> _duplicateSensorList = List<Sensor>();
  bool zeroFetchedItems = false;
  String _token;
  bool _connectionEstablished;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }
    getSensors();
    _searchController.addListener(() {
      filterSearchResults(_searchController.text);
    });
  }

  Future<void> getUserToken() async {
    _token = await widget.storage.getToken();
  }

  /// returns list of sensors
  Future<List<Sensor>> getSensors() async {
    setState(() {
      _isSearching = false;
      _searchController.text = "";
    });

    await getUserToken();
    try {
      /// gets sensors
      var res = await api.getSensors(_token);

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
                "Błąd pobierania czujników. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania czujników. Adres serwera nieprawidłowy."));
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
    var decision = await confirmActionDialog(context, "Potwierdź",
        "Czy na pewno chcesz usunąć czujnik ${sensor.name}?");
    if (decision) {
      try {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoader,
            text: "Trwa usuwanie czujnika...");

        int statusCode = await api.deactivateSensor(sensor.id, _token);
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (statusCode == 200) {
          setState(() {
            /// refreshes sensors' list
            getSensors();
          });
        } else if (statusCode == 401) {
          displayProgressDialog(
              context: _scaffoldKey.currentContext,
              key: _keyLoaderInvalidToken,
              text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...");
          await new Future.delayed(const Duration(seconds: 3));
          Navigator.of(_keyLoaderInvalidToken.currentContext,
                  rootNavigator: true)
              .pop();
          await widget.storage.resetUserData();
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (statusCode == null) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd usuwania czujnika. Sprawdź połączenie z serwerem i spróbuj ponownie."));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        } else {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd. Usunięcie czujnika nie powiodło się. Spróbuj ponownie."));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      } catch (e) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

        print(e.toString());
        if (e.toString().contains("TimeoutException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd usuwania czujnika. Sprawdź połączenie z serwerem i spróbuj ponownie."));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
        if (e.toString().contains("SocketException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd. Usunięcie czujnika nie powiodło się. Spróbuj ponownie."));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      }
    }
  }

  _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: Theme.of(context).appBarTheme.textTheme.headline6,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Wyszukaj...",
        hintStyle: Theme.of(context).appBarTheme.textTheme.headline6,
        border: UnderlineInputBorder(
            borderSide: BorderSide(color: IdomColors.additionalColor)),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: IdomColors.additionalColor),
        ),
      ),
    );
  }

  onLogOutFailure(String text) {
    final snackBar = new SnackBar(content: new Text(text));
    _scaffoldKey.currentState.showSnackBar((snackBar));
  }

  Future<bool> _onBackButton() async {
    var decision = await confirmActionDialog(
        context, "Potwierdź", "Na pewno wyjść z aplikacji?");
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
          title: _isSearching ? _buildSearchField() : Text('Czujniki'),
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
            parentWidgetType: "Sensors",
            onGoBackAction: () async {
              if (_token != null && _token.isNotEmpty) {
                await getSensors();
              }
            },
            onLogOutFailure: onLogOutFailure),

        /// builds sensor's list
        body: Container(child: Column(children: <Widget>[listSensors()])),
      ),
    );
  }

  Widget listSensors() {
    if (zeroFetchedItems) {
      return Padding(
          padding:
              EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text("Brak czujników w systemie.",
                  style: TextStyle(fontSize: 16.5),
                  textAlign: TextAlign.center)));
    }
    if (_connectionEstablished != null &&
        _connectionEstablished == false &&
        _sensorList == null) {
      return Padding(
          padding:
              EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text("Błąd połączenia z serwerem.",
                  style: TextStyle(fontSize: 16.5),
                  textAlign: TextAlign.center)));
    } else if (!zeroFetchedItems &&
        _sensorList != null &&
        _sensorList.length == 0) {
      return Padding(
          padding:
              EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text("Brak wyników wyszukiwania.",
                  style: TextStyle(fontSize: 16.5),
                  textAlign: TextAlign.center)));
    } else if (_sensorList != null && _sensorList.length > 0) {
      return Expanded(
          child: Scrollbar(
              child: RefreshIndicator(
                  onRefresh: _pullRefresh,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, top: 10, right: 10.0, bottom: 0.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _sensorList.length,
                      itemBuilder: (context, index) => Container(
                          height: 80,
                          child: Card(
                              child: ListTile(
                                  key: Key(_sensorList[index].name),
                                  title: Text(_sensorList[index].name,
                                      style: TextStyle(fontSize: 21.0)),
                                  subtitle: Text(sensorData(_sensorList[index]),
                                      style: TextStyle(
                                          fontSize: 16.5,
                                          color: IdomColors.textDark)),
                                  onTap: () {
                                    navigateToSensorDetails(_sensorList[index]);
                                  },
                                  leading: getSensorImage(_sensorList[index]),

                                  /// delete sensor button
                                  trailing: deleteButtonTrailing(
                                      _sensorList[index])))),
                    ),
                  ))));
    }

    /// shows progress indicator while fetching data
    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, top: 10, right: 10.0, bottom: 0.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget getSensorImage(Sensor sensor) {
    switch (sensor.category) {
      case "water_temp":
        return SvgPicture.asset(
          "assets/icons/water-temperature.svg",
          matchTextDirection: false,
          width: 30,
          height: 30,
          color: Theme.of(context).iconTheme.color,
        );
        break;
      case "temperature":
      case "humidity":
      case "smoke":
      case "rain":
        return Icon(getCategoryIcon(sensor.category),
            color: Theme.of(context).iconTheme.color);
        break;
    }
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case "temperature":
        return WeatherIcons.thermometer;
      case "humidity":
        return WeatherIcons.humidity;
        break;
      case "smoke":
        return WeatherIcons.smog;
        break;
      case "rain":
        return WeatherIcons.showers;
        break;
    }
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      /// refreshes sensors' list
      getSensors();
    });
  }

  void filterSearchResults(String query) {
    List<Sensor> dummySearchList = List<Sensor>();
    dummySearchList.addAll(_duplicateSensorList);
    if (query.isNotEmpty) {
      List<Sensor> dummyListData = List<Sensor>();
      dummySearchList.forEach((item) {
        if (item.name.contains(query)) {
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
    switch (sensor.category) {
      case "water_temp":
      case "temperature":
        if (sensor.lastData == null) return "ostatnia dana: -";
        return "ostatnia dana: " + "${sensor.lastData} °C";
        break;
      case "humidity":
        if (sensor.lastData == null) return "ostatnia dana: -";
        return "ostatnia dana: " + "${sensor.lastData} %";
        break;
      case "smoke":
      case "rain":
        return "";
    }
  }

  /// navigates to adding sensor page
  navigateToNewSensor() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewSensor(storage: widget.storage),
            fullscreenDialog: true));

    /// displays success message if sensor added succesfully
    if (result == true) {
      final snackBar = new SnackBar(content: new Text("Dodano nowy czujnik."));
      _scaffoldKey.currentState.showSnackBar((snackBar));
      await getSensors();
    }
  }

  /// navigates to sensor's details
  navigateToSensorDetails(Sensor sensor) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            SensorDetails(storage: widget.storage, sensor: sensor)));
    await getSensors();
  }

  /// deletes sensor
  deleteButtonTrailing(Sensor sensor) {
    return SizedBox(
        width: 35,
        child: Container(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: Key("deleteButton"),
              child: Icon(Icons.delete, color: IdomColors.mainFill),
              onPressed: () {
                setState(() {
                  _deactivateSensor(sensor);
                });
              },
            )));
  }
}
