import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/choose_multiple_sensor_categories.dart';
import 'package:idom/dialogs/choose_sensors_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:idom/localization/data_download/data_download.i18n.dart';

class DataDownload extends StatefulWidget {
  DataDownload({@required this.storage, this.testApi});

  final SecureStorage storage;
  final Api testApi;

  @override
  _DataDownloadState createState() => _DataDownloadState();
}

class _DataDownloadState extends State<DataDownload> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  TextEditingController _rangeDateController = TextEditingController();
  Api api = Api();
  List<Sensor> sensors = List<Sensor>();
  List<Sensor> selectedSensors = List<Sensor>();
  List<Map<String, String>> selectedCategories = List<Map<String, String>>();
  String categoriesMessage;
  String sensorsMessage;
  int selectedDays;

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }
    getSensors();
  }

  /// returns list of sensors
  Future<void> getSensors() async {
    try {
      /// gets sensors
      var res = await api.getSensors();

      if (res != null && res['statusCodeSensors'] == "200") {
        List<dynamic> bodySensors = jsonDecode(res['bodySensors']);
        setState(() {
          sensors =
              bodySensors.map((dynamic item) => Sensor.fromJson(item)).toList();
        });
      } else if (res != null && res['statusCodeSensors'] == "401") {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoader,
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
        await new Future.delayed(const Duration(seconds: 3));
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        await widget.storage.resetUserData();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
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
  }

  /// builds range date field
  Widget _buildRangeDateField() {
    return TextFormField(
        key: Key("lastDaysAmountButton"),
        controller: _rangeDateController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).textTheme.bodyText2.color),
              borderRadius: BorderRadius.circular(10.0)),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).textTheme.bodyText2.color),
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Ilość ostatnich dni".i18n,
          labelStyle: Theme.of(context).textTheme.headline5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 21.0),
        validator: LastDaysAmountFieldValidator.validate);
  }

  onLogOutFailure(String text) {
    final snackBar = new SnackBar(content: new Text(text));
    _scaffoldKey.currentState.showSnackBar((snackBar));
  }

  Future<bool> _onBackButton() async {
    Navigator.pop(context, false);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackButton,
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: Text('Pobierz dane'.i18n)),
          drawer: IdomDrawer(
              storage: widget.storage,
              parentWidgetType: "DataDownload",
              onLogOutFailure: onLogOutFailure),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.5, top: 30, right: 15.5),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  Text(
                      "Uzupełnij filtry, aby wygenerować plik .csv z danymi"
                          .i18n,
                      style: Theme.of(context).textTheme.subtitle1),
                  SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(
                            "Czujniki".i18n,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.left,
                          ),
                          Spacer(),
                          if (selectedSensors.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    selectedSensors.clear();
                                    categoriesMessage = null;
                                  });
                                },
                                child: SvgPicture.asset(
                                    "assets/icons/dustbin.svg",
                                    matchTextDirection: false,
                                    width: 21,
                                    height: 21,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color,
                                    key: Key("deleteSensors")),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 38.0, right: 18.0, top: 10.0),
                    child: SizedBox(
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(),
                          1: IntrinsicColumnWidth()
                        },
                        children: selectedSensors
                                ?.map((sensor) => TableRow(children: <Widget>[
                                      Container(
                                          padding: EdgeInsets.only(bottom: 15),
                                          child: Text(sensor.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2)),
                                      GestureDetector(
                                        onTap: () => setState(() {
                                          selectedSensors.remove(sensor);
                                          if (selectedSensors.isEmpty) {
                                            categoriesMessage = null;
                                          }
                                        }),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: SvgPicture.asset(
                                              "assets/icons/minus.svg",
                                              matchTextDirection: false,
                                              width: 21,
                                              height: 21,
                                              color: IdomColors.error,
                                              key: Key("deleteSensor")),
                                        ),
                                      ),
                                    ]))
                                ?.toList() ??
                            [],
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      if (selectedCategories.isNotEmpty) {
                        sensorsMessage =
                            "Usuń wybrane kategorie, aby wybrać czujniki.".i18n;
                        setState(() {});
                        return;
                      }
                      final selSensors = await showDialog<List<Sensor>>(
                          context: context,
                          builder: (context) {
                            return Dialog(
                                backgroundColor:
                                    Theme.of(context).dialogBackgroundColor,
                                child: StatefulBuilder(
                                    builder: (BuildContext context,
                                            StateSetter setState) =>
                                        ChooseMultipleSensorsDialog(
                                            sensors: sensors,
                                            selectedSensors: selectedSensors)));
                          });
                      if (selSensors != null) {
                        selectedSensors.clear();
                        selectedSensors.addAll(selSensors);
                      }
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 38.0, right: 18.0),
                      child: Row(
                        children: <Widget>[
                          SvgPicture.asset("assets/icons/add.svg",
                              matchTextDirection: false,
                              width: 21,
                              height: 21,
                              color: selectedCategories.isEmpty
                                  ? IdomColors.additionalColor
                                  : IdomColors.darken(
                                      IdomColors.additionalColor, 0.2),
                              key: Key("addSensors")),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "Dodaj".i18n,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: AnimatedCrossFade(
                      crossFadeState: sensorsMessage != null
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 300),
                      firstChild: sensorsMessage != null
                          ? Text(sensorsMessage,
                              style: Theme.of(context).textTheme.subtitle1)
                          : SizedBox(),
                      secondChild: SizedBox(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(
                            "Kategorie".i18n,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.left,
                          ),
                          Spacer(),
                          if (selectedCategories.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    selectedCategories.clear();
                                    sensorsMessage = null;
                                  });
                                },
                                child: SvgPicture.asset(
                                    "assets/icons/dustbin.svg",
                                    matchTextDirection: false,
                                    width: 21,
                                    height: 21,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color,
                                    key: Key("deleteCategories")),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 38.0, right: 18.0, top: 10.0),
                    child: SizedBox(
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(),
                          1: IntrinsicColumnWidth()
                        },
                        children: selectedCategories
                                ?.map((category) => TableRow(children: <Widget>[
                                      Container(
                                          padding: EdgeInsets.only(bottom: 15),
                                          child: Text(category['text'].i18n,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2)),
                                      GestureDetector(
                                        onTap: () => setState(() {
                                          selectedCategories.remove(category);
                                          if (selectedCategories.isEmpty) {
                                            sensorsMessage = null;
                                          }
                                        }),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: SvgPicture.asset(
                                              "assets/icons/minus.svg",
                                              matchTextDirection: false,
                                              width: 21,
                                              height: 21,
                                              color: IdomColors.error,
                                              key: Key("deleteCategory")),
                                        ),
                                      ),
                                    ]))
                                ?.toList() ??
                            [],
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      if (selectedSensors.isNotEmpty) {
                        categoriesMessage =
                            "Usuń wybrane czujniki, aby wybrać kategorie.".i18n;
                        setState(() {});
                        return;
                      }
                      final selCategories =
                          await showDialog<List<Map<String, String>>>(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                    backgroundColor:
                                        Theme.of(context).dialogBackgroundColor,
                                    child: StatefulBuilder(
                                        builder: (BuildContext context,
                                                StateSetter setState) =>
                                            ChooseMultipleSensorCategoriesDialog(
                                                selectedCategories:
                                                    selectedCategories)));
                              });
                      if (selCategories != null) {
                        selectedCategories.clear();
                        selectedCategories.addAll(selCategories);
                      }
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 38.0, right: 18.0),
                      child: Row(
                        children: <Widget>[
                          SvgPicture.asset("assets/icons/add.svg",
                              matchTextDirection: false,
                              width: 21,
                              height: 21,
                              color: selectedSensors.isEmpty
                                  ? IdomColors.additionalColor
                                  : IdomColors.darken(
                                      IdomColors.additionalColor, 0.2),
                              key: Key("addCategories")),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "Dodaj".i18n,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: AnimatedCrossFade(
                      crossFadeState: categoriesMessage != null
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 300),
                      firstChild: categoriesMessage != null
                          ? Text(categoriesMessage,
                              style: Theme.of(context).textTheme.subtitle1)
                          : SizedBox(),
                      secondChild: SizedBox(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: _buildRangeDateField(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: buttonWidget(
                        context, "Generuj plik".i18n, _generateFile),
                  )
                ]),
              ),
            ),
          )),
    );
  }

  requestWritePermission() async {
    var status = await Permission.storage.request();

    if (status.isGranted) {
      return true;
    }
    return false;
  }

  _generateFile() async {
    if (_formKey.currentState.validate()) {
      List<String> selectedSensorsIds = List<String>();
      List<String> selectedCategoriesValues = List<String>();
      if (selectedSensors.isNotEmpty) {
        selectedSensors.forEach((sensor) {
          selectedSensorsIds.add(sensor.id.toString());
        });
      }
      if (selectedCategories.isNotEmpty) {
        selectedCategories.forEach((category) {
          selectedCategoriesValues.add(category['value']);
        });
      }
      var days = int.parse(_rangeDateController.text);
      var result = await api.generateFile(
          selectedSensorsIds.isNotEmpty ? selectedSensorsIds : null,
          selectedCategoriesValues.isNotEmpty ? selectedCategoriesValues : null,
          days);
      String data = result["body"];
      if (result != null && result["statusCode"] == 200) {
        if (await requestWritePermission()) {
          try {
            final externalDirectory = await getExternalStorageDirectory();
            var path = externalDirectory.path
                .replaceAll("Android/data/com.project.idom/files", "");
            var now = DateTime.now();
            var file = File(
                '$path/sensors_data_${DateFormat("yyy-MM-dd_hh:mm:ss").format(now)}.csv');
            await file.writeAsString(data);
            final snackBar = new SnackBar(
                content: new Text("Plik ".i18n +
                    "sensors_data_${DateFormat("yyy-MM-dd_hh:mm:ss").format(now)}.csv " +
                    "został wygenerowany i zapisany w plikach urządzenia."
                        .i18n));
            _scaffoldKey.currentState.showSnackBar((snackBar));
          } catch (e) {
            final snackBar = new SnackBar(
                content: new Text(
                    "Nie udało się wygenerować pliku. Spróbuj ponownie.".i18n));
            _scaffoldKey.currentState.showSnackBar((snackBar));
          }
        }
      } else {
        final snackBar = new SnackBar(
            content: new Text(
                "Nie udało się wygenerować pliku. Spróbuj ponownie.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }
}
