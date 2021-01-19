import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/dialogs/category_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/drivers/edit_driver.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/login_procedures.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/localization/drivers/new_driver.i18n.dart';

/// allows adding new driver
class NewDriver extends StatefulWidget {
  NewDriver({@required this.storage, this.testApi});

  /// internal storage
  final SecureStorage storage;

  /// api used for tests
  final Api testApi;

  /// handles state of widgets
  @override
  _NewDriverState createState() => _NewDriverState();
}

class _NewDriverState extends State<NewDriver> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoaderInvalidToken = new GlobalKey<State>();
  TextEditingController _nameController;
  TextEditingController _categoryController;
  TextEditingController _ipAddressController;
  String categoryValue;
  Api api = Api();
  bool _load;
  String fieldsValidationMessage;

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }

    LoginProcedures.init(widget.storage, api);

    _load = false;
    _nameController = TextEditingController();
    _categoryController = TextEditingController();
    _ipAddressController = TextEditingController();
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
            labelText: "Nazwa".i18n,
            labelStyle: Theme.of(context).textTheme.headline5,
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).textTheme.bodyText2.color),
                borderRadius: BorderRadius.circular(10.0)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).textTheme.bodyText2.color),
              borderRadius: BorderRadius.circular(10.0),
            ),
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
          suffixIcon:
              Icon(Icons.arrow_drop_down, color: IdomColors.additionalColor),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackButton,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(title: Text("Dodaj sterownik".i18n), actions: [
              IconButton(
                  key: Key('saveDriverButton'),
                  icon: Icon(Icons.save),
                  onPressed: _saveChanges)
            ]),
            drawer: IdomDrawer(
                storage: widget.storage, parentWidgetType: "NewDriver"),

            /// builds form with driver's properties
            body: SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Column(children: <Widget>[
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

  /// saves changes after form fields validation
  _saveChanges() async {
    FocusScope.of(context).unfocus();
    final formState = _formKey.currentState;
    if (formState.validate()) {
      setState(() {
        _load = true;
      });
      try {
        var res = await api.addDriver(_nameController.text, categoryValue);
        setState(() {
          _load = false;
        });
        if (res['statusCode'] == "201") {
          if (categoryValue == "bulb" && _ipAddressController.text.isNotEmpty) {
            var driver = Driver.fromJson(jsonDecode(res['body']));
            var resBulb =
                await api.addIpAddress(driver.id, _ipAddressController.text);
            if (resBulb != 200 && resBulb != 503) {
              _navigateToEditDriver(driver);
            } else {
              fieldsValidationMessage = null;
              setState(() {});
              Navigator.pop(context, true);
            }
          } else {
            fieldsValidationMessage = null;
            setState(() {});
            Navigator.pop(context, true);
          }
        } else if (res['statusCode'] == "401") {
          final message = await LoginProcedures.signInWithStoredData();
          if (message != null) {
            logOut();
          } else {
            setState(() {
              _load = true;
            });
            var res = await api.addDriver(_nameController.text, categoryValue);
            setState(() {
              _load = false;
            });

            /// on success fetching data
            if (res['statusCode'] == "201") {
              if (categoryValue == "bulb" &&
                  _ipAddressController.text.isNotEmpty) {
                var driver = Driver.fromJson(jsonDecode(res['body']));
                var resBulb = await api.addIpAddress(
                    driver.id, _ipAddressController.text);
                if (resBulb != 200 && resBulb != 503) {
                  _navigateToEditDriver(driver);
                } else {
                  fieldsValidationMessage = null;
                  setState(() {});
                  Navigator.pop(context, true);
                }
              } else {
                fieldsValidationMessage = null;
                setState(() {});
                Navigator.pop(context, true);
              }
            } else if (res != null && res['statusCode'] == "401") {
              logOut();
            } else if (res['body']
                .contains("Driver with provided name already exists")) {
              fieldsValidationMessage =
                  "Sterownik o podanej nazwie już istnieje.".i18n;
              setState(() {});
              return;
            } else if (res['body']
                .contains("Enter a valid IPv4 or IPv6 address")) {
              fieldsValidationMessage = "Adres IP jest nieprawidłowy".i18n;
              setState(() {});
              return;
            } else {
              fieldsValidationMessage = null;
              setState(() {});
              final snackBar = new SnackBar(
                  content: new Text(
                      "Dodawanie sterownika nie powiodło się. Spróbuj ponownie."
                          .i18n));
              _scaffoldKey.currentState.showSnackBar((snackBar));
            }
          }
        } else if (res['body']
            .contains("Driver with provided name already exists")) {
          fieldsValidationMessage =
              "Sterownik o podanej nazwie już istnieje.".i18n;
          setState(() {});
          return;
        } else if (res['body'].contains("Enter a valid IPv4 or IPv6 address")) {
          fieldsValidationMessage = "Adres IP jest nieprawidłowy".i18n;
          setState(() {});
          return;
        } else {
          fieldsValidationMessage = null;
          setState(() {});
          final snackBar = new SnackBar(
              content: new Text(
                  "Dodawanie sterownika nie powiodło się. Spróbuj ponownie."
                      .i18n));
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
                  "Błąd dodawania sterownika. Sprawdź połączenie z serwerem i spróbuj ponownie."
                      .i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
        if (e.toString().contains("SocketException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd dodawania sterownika. Adres serwera nieprawidłowy."
                      .i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        } else {
          final snackBar = new SnackBar(
              content: new Text(
                  "Dodawanie sterownika nie powiodło się. Spróbuj ponownie."
                      .i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      }
    }
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

  _navigateToEditDriver(Driver driver) async {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditDriver(
                storage: widget.storage,
                driver: driver,
                testApi: widget.testApi,
                notSetIp: true),
            fullscreenDialog: true));
    if (result == true) {
      Navigator.pop(context, true);
    } else {
      Navigator.pop(context);
    }
  }
}
