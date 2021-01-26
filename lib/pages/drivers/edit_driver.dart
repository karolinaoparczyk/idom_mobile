import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/dialogs/category_dialog.dart';
import 'package:idom/enums/categories.dart';
import 'package:idom/models.dart';
import 'package:idom/utils/login_procedures.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/localization/drivers/edit_driver.i18n.dart';

/// allows editing driver
class EditDriver extends StatefulWidget {
  EditDriver(
      {@required this.storage,
      @required this.driver,
      this.testApi,
      this.notSetIp});

  /// internal storage
  final SecureStorage storage;

  /// selected driver
  final Driver driver;

  /// api used for tests
  final Api testApi;

  /// used only when adding ip address to a new bulb causes error
  ///
  /// true if error occurred - displays message to user
  final bool notSetIp;

  /// handles state of widgets
  @override
  _EditDriverState createState() => _EditDriverState();
}

class _EditDriverState extends State<EditDriver> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  TextEditingController _nameController;
  TextEditingController _categoryController;
  TextEditingController _ipAddressController;
  String categoryValue;
  Api api = Api();
  bool _load;
  String fieldsValidationMessage;
  Driver driver;

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }

    LoginProcedures.init(widget.storage, api);

    driver = widget.driver;
    _load = false;

    /// seting current driver name
    _nameController = TextEditingController(text: widget.driver.name);

    /// setting current driver category
    _categoryController = TextEditingController(
        text: DriverCategories.values
            .firstWhere(
                (element) => element["value"] == widget.driver.category)['text']
            .i18n);
    categoryValue = widget.driver.category;

    _ipAddressController = TextEditingController(text: widget.driver.ipAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<bool> _onBackButton() async {
    Navigator.pop(context);
    return true;
  }

  /// builds driver name form field
  Widget _buildName() {
    return TextFormField(
        decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).textTheme.bodyText2.color),
                borderRadius: BorderRadius.circular(10.0)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).textTheme.bodyText2.color),
              borderRadius: BorderRadius.circular(10.0),
            ),
            labelText: "Nazwa".i18n,
            labelStyle: Theme.of(context).textTheme.headline5,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            counterStyle:
                Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 12.5)),
        key: Key('name'),
        style: Theme.of(context).textTheme.bodyText2,
        autofocus: true,
        maxLength: 30,
        controller: _nameController,
        validator: DriverNameFieldValidator.validate);
  }

  /// builds driver category field
  Widget _buildCategoryField() {
    return TextFormField(
        key: Key("categoriesButton"),
        controller: _categoryController,
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
          labelText: "Kategoria".i18n,
          labelStyle: Theme.of(context).textTheme.headline5,
          suffixIcon: Icon(Icons.arrow_drop_down,
              color: Theme.of(context).textTheme.bodyText2.color),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onTap: () async {
          final Map<String, String> selectedCategory = await showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: CategoryDialog(
                      currentCategory: categoryValue, type: "drivers"),
                );
              });
          if (selectedCategory != null) {
            _categoryController.text = selectedCategory['text'].i18n;
            categoryValue = selectedCategory['value'];
            setState(() {});
          }
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        readOnly: true,
        style: Theme.of(context).textTheme.bodyText2,
        validator: CategoryFieldValidator.validate);
  }

  /// build ip address form field
  Widget _buildIpAddress() {
    return TextFormField(
        key: Key("ipAddress"),
        controller: _ipAddressController,
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
          labelText: "Adres IP".i18n,
          labelStyle: Theme.of(context).textTheme.headline5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        style: Theme.of(context).textTheme.bodyText2);
  }

  _displayNotSetIpAddressMessage() {
    return Text(
        "Podczas dodawania żarówki nie udało się zapisać adresu IP. Spróbuj ponownie."
            .i18n,
        style: Theme.of(context).textTheme.subtitle1);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackButton,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(title: Text(widget.driver.name), actions: [
              IconButton(
                  key: Key('editDriverButton'),
                  icon: Icon(Icons.save),
                  onPressed: _verifyChanges)
            ]),
            drawer: IdomDrawer(
                storage: widget.storage,
                testApi: widget.testApi,
                parentWidgetType: "EditDriver"),

            /// builds form with driver's properties
            body: SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Column(children: <Widget>[
                    Align(
                      child: loadingIndicator(_load),
                      alignment: FractionalOffset.center,
                    ),
                    if (widget.notSetIp != null && widget.notSetIp)
                      Padding(
                          padding: EdgeInsets.only(
                              left: 62.0, top: 20.0, right: 62.0, bottom: 0.0),
                          child: _displayNotSetIpAddressMessage()),
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
                            left: 62.0, top: 10.0, right: 62.0, bottom: 0.0),
                        child: _buildName()),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 62.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildCategoryField())),
                    if (categoryValue != null && categoryValue == "bulb")
                      Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 62.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: _buildIpAddress())),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 62.0),
                      child: AnimatedCrossFade(
                        crossFadeState: fieldsValidationMessage != null
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: Duration(milliseconds: 300),
                        firstChild: fieldsValidationMessage != null
                            ? Text(fieldsValidationMessage,
                                style: Theme.of(context).textTheme.subtitle1)
                            : SizedBox(),
                        secondChild: SizedBox(),
                      ),
                    ),
                  ])),
            )));
  }

  _refreshDriverDetails(
      bool changedName, bool changedCategory, bool changedIpAddress) async {
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
          driver = refreshedDriver;
          if (changedName) {
            _nameController.text = driver.name;
          }
          if (changedCategory) {
            _categoryController = TextEditingController(
                text: DriverCategories.values
                    .firstWhere((element) =>
                        element["value"] == driver.category)['text']
                    .i18n);
            categoryValue = driver.category;
          }
          if (changedIpAddress) {
            categoryValue = driver.category;
          }
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

  /// saves changes after form fields and dropdown buttons validation
  _saveChanges(
      bool changedName, bool changedCategory, bool changedIpAddress) async {
    FocusScope.of(context).unfocus();
    var name = changedName ? _nameController.text : null;
    var category = changedCategory ? categoryValue : null;
    var ipAddress = changedIpAddress ? _ipAddressController.text : null;
    setState(() {
      _load = true;
    });
    try {
      var res;
      var resIP;
      if (changedName || changedCategory) {
        res = await api.editDriver(widget.driver.id, name, category);
      }
      if (changedIpAddress) {
        resIP = await api.addIpAddress(widget.driver.id, ipAddress);
      }
      setState(() {
        _load = false;
      });
      if ((res != null && res['statusCode'] == "200" || res == null) &&
          (resIP == 200 || resIP == 503 || resIP == null)) {
        fieldsValidationMessage = null;
        setState(() {});
        Navigator.pop(context, true);
      } else if (resIP == 400 &&
          res != null &&
          res['body'].contains("Driver with provided name already exists")) {
        _refreshDriverDetails(false, true, false);
        fieldsValidationMessage =
            "Sterownik o podanej nazwie już istnieje. Adres IP jest niepoprawny."
                .i18n;
        setState(() {});
      } else if (resIP == 400) {
        _refreshDriverDetails(true, true, false);
        fieldsValidationMessage = "Adres IP jest niepoprawny.".i18n;
        setState(() {});
      } else if (res != null &&
          res['body'].contains("Driver with provided name already exists")) {
        _refreshDriverDetails(false, true, true);
        fieldsValidationMessage =
            "Sterownik o podanej nazwie już istnieje.".i18n;
        setState(() {});
        return;
      } else if (res != null && res['statusCode'] == "401") {
        fieldsValidationMessage = null;
        setState(() {});
        var message;
        if (widget.testApi != null) {
          message = "error";
        } else {
          message = await LoginProcedures.signInWithStoredData();
        }
        if (message != null) {
          logOut();
        } else {
          if (changedName || changedCategory) {
            res = await api.editDriver(widget.driver.id, name, category);
          }
          if (changedIpAddress) {
            resIP = await api.addIpAddress(widget.driver.id, ipAddress);
          }

          if ((res != null && res['statusCode'] == "200" || res == null) &&
              (resIP == 200 || resIP == 503 || resIP == null)) {
            fieldsValidationMessage = null;
            setState(() {});
            Navigator.pop(context, true);
          } else if (resIP == 400 &&
              res != null &&
              res['body']
                  .contains("Driver with provided name already exists")) {
            _refreshDriverDetails(false, true, false);
            fieldsValidationMessage =
                "Sterownik o podanej nazwie już istnieje. Adres IP jest niepoprawny."
                    .i18n;
            setState(() {});
          } else if (resIP == 400) {
            _refreshDriverDetails(true, true, false);
            fieldsValidationMessage = "Adres IP jest niepoprawny.".i18n;
            setState(() {});
          } else if (res != null &&
              res['body']
                  .contains("Driver with provided name already exists")) {
            _refreshDriverDetails(false, true, true);
            fieldsValidationMessage =
                "Sterownik o podanej nazwie już istnieje.".i18n;
            setState(() {});
            return;
          } else if (res != null && res['statusCode'] == "401") {
            fieldsValidationMessage = null;
            setState(() {});
            logOut();
          } else {
            fieldsValidationMessage = null;
            setState(() {});
            final snackBar = new SnackBar(
                content: new Text(
                    "Edycja sterownika nie powiodła się. Spróbuj ponownie."
                        .i18n));
            _scaffoldKey.currentState.showSnackBar((snackBar));
          }
        }
      } else {
        fieldsValidationMessage = null;
        setState(() {});
        final snackBar = new SnackBar(
            content: new Text(
                "Edycja sterownika nie powiodła się. Spróbuj ponownie.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _load = false;
        fieldsValidationMessage = null;
      });
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd edytowania sterownika. Sprawdź połączenie z serwerem i spróbuj ponownie."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd edytowania sterownika. Adres serwera nieprawidłowy."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }

  Future<void> logOut() async {
    displayProgressDialog(
        context: _scaffoldKey.currentContext,
        key: _keyLoader,
        text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
    await new Future.delayed(const Duration(seconds: 3));
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    await widget.storage.resetUserData();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// confirms saving changes
  _confirmSavingChanges(
      bool changedName, bool changedCategory, bool changedIpAddress) async {
    var decision = await confirmActionDialog(
        context, "Potwierdź".i18n, "Czy na pewno zapisać zmiany?".i18n);
    if (decision != null && decision) {
      await _saveChanges(changedName, changedCategory, changedIpAddress);
    }
  }

  /// verifies data changes
  _verifyChanges() async {
    var name = _nameController.text;
    var category = categoryValue;
    var ipAddress =
        _ipAddressController.text == "" ? null : _ipAddressController.text;
    var changedName = false;
    var changedCategory = false;
    var changedIpAddress = false;

    final formState = _formKey.currentState;
    if (formState.validate()) {
      /// sends request only if data changed
      if (name != driver.name) {
        changedName = true;
      }
      if (category != driver.category) {
        changedCategory = true;
      }
      if (categoryValue == "bulb" && ipAddress != driver.ipAddress) {
        changedIpAddress = true;
      }

      if (changedName || changedCategory || changedIpAddress) {
        await _confirmSavingChanges(
            changedName, changedCategory, changedIpAddress);
      } else {
        setState(() {
          fieldsValidationMessage = null;
        });
        final snackBar = new SnackBar(
            content: new Text("Nie wprowadzono żadnych zmian.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }
}
