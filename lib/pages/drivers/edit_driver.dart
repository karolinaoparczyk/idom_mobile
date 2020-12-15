import 'package:flutter/material.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/dialogs/category_dialog.dart';
import 'package:idom/enums/categories.dart';
import 'package:idom/models.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/localization/drivers/edit_driver.i18n.dart';

class EditDriver extends StatefulWidget {
  EditDriver({@required this.storage, @required this.driver, this.testApi});

  final SecureStorage storage;
  final Driver driver;
  final Api testApi;

  @override
  _EditDriverState createState() => _EditDriverState();
}

class _EditDriverState extends State<EditDriver> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoaderInvalidToken = new GlobalKey<State>();
  TextEditingController _nameController;
  TextEditingController _categoryController;
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
    _load = false;

    /// seting current driver name
    _nameController = TextEditingController(text: widget.driver.name);

    /// setting current driver category
    _categoryController = TextEditingController(
        text: DriverCategories.values.firstWhere(
            (element) => element["value"] == widget.driver.category)['text'].i18n);
    categoryValue = widget.driver.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  onLogOutFailure(String text) {
    final snackBar = new SnackBar(content: new Text(text));
    _scaffoldKey.currentState.showSnackBar((snackBar));
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
            counterStyle: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(fontSize: 12.5) ),
        key: Key('name'),
        style: Theme.of(context)
            .textTheme
            .bodyText1
            .copyWith(fontSize: 21.0),
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
          labelText: "Kategoria".i18n,
          labelStyle: Theme.of(context).textTheme.headline5,
          suffixIcon: Icon(Icons.arrow_drop_down, color: Theme.of(context)
              .textTheme
              .bodyText1.color),
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
          }
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        readOnly: true,
        style: Theme.of(context)
            .textTheme
            .bodyText1
            .copyWith(fontSize: 21.0),
        validator: CategoryFieldValidator.validate);
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
                parentWidgetType: "EditDriver",
                onLogOutFailure: onLogOutFailure),

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
                                Icon(Icons.info_outline_rounded, size: 17.5),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
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
                            left: 30.0, top: 10.0, right: 30.0, bottom: 0.0),
                        child: _buildName()),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 30.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildCategoryField())),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 30.0),
                      child: AnimatedCrossFade(
                        crossFadeState: fieldsValidationMessage != null
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: Duration(milliseconds: 300),
                        firstChild: fieldsValidationMessage != null
                            ? Text(fieldsValidationMessage,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(fontWeight: FontWeight.normal))
                            : SizedBox(),
                        secondChild: SizedBox(),
                      ),
                    ),
                  ])),
            )));
  }

  /// saves changes after form fields and dropdown buttons validation
  _saveChanges(bool changedName, bool changedCategory) async {
    FocusScope.of(context).unfocus();
    var name = changedName ? _nameController.text : null;
    var category = changedCategory ? categoryValue : null;
    setState(() {
      _load = true;
    });
    try {
      var res = await api.editDriver(widget.driver.id, name, category);
      setState(() {
        _load = false;
      });
      if (res['statusCode'] == "200") {
        fieldsValidationMessage = null;
        setState(() {});  Navigator.pop(context, true);
      } else if (res['statusCode'] == "401") {
        fieldsValidationMessage = null;
        setState(() {}); displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoaderInvalidToken,
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
        await new Future.delayed(const Duration(seconds: 3));
        Navigator.of(_keyLoaderInvalidToken.currentContext, rootNavigator: true)
            .pop();
        await widget.storage.resetUserData();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (res['body']
          .contains("Driver with provided name already exists")) {
        fieldsValidationMessage = "Sterownik o podanej nazwie już istnieje.".i18n;
        setState(() {});
        return;
      } else {
        fieldsValidationMessage = null;
        setState(() {}); final snackBar = new SnackBar(
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
                "Błąd edytowania sterownika. Sprawdź połączenie z serwerem i spróbuj ponownie.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd edytowania sterownika. Adres serwera nieprawidłowy.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }

  /// confirms saving changes
  _confirmSavingChanges(bool changedName, bool changedCategory) async {
    var decision = await confirmActionDialog(
        context, "Potwierdź".i18n, "Czy na pewno zapisać zmiany?".i18n);
    if (decision) {
      await _saveChanges(changedName, changedCategory);
    }
  }

  /// verifies data changes
  _verifyChanges() async {
    var name = _nameController.text;
    var category = categoryValue;
    var changedName = false;
    var changedCategory = false;

    final formState = _formKey.currentState;
    if (formState.validate()) {
      /// sends request only if data changed
      if (name != widget.driver.name) {
        changedName = true;
      }
      if (category != widget.driver.category) {
        changedCategory = true;
      }

      if (changedName || changedCategory) {
        await _confirmSavingChanges(changedName, changedCategory);
      } else {
        final snackBar =
            new SnackBar(content: new Text("Nie wprowadzono żadnych zmian.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }
}
