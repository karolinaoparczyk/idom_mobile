import 'package:flutter/material.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/dialogs/sensor_category_dialog.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';

class NewDriver extends StatefulWidget {
  NewDriver({@required this.storage});

  final SecureStorage storage;

  @override
  _NewDriverState createState() => _NewDriverState();
}

class _NewDriverState extends State<NewDriver> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoaderInvalidToken = new GlobalKey<State>();
  TextEditingController _nameController;
  TextEditingController _categoryController;
  String categoryValue;
  Api api = Api();
  String _token;
  bool _load;

  @override
  void initState() {
    super.initState();
    getToken();
    _load = false;
    _nameController = TextEditingController();
    _categoryController = TextEditingController();
  }

  Future<void> getToken() async {
    _token = await widget.storage.getToken();
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
          labelText: "Nazwa",
          labelStyle: Theme.of(context).textTheme.headline5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        key: Key('name'),
        style: TextStyle(fontSize: 21.0),
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
          labelText: "Kategoria",
          labelStyle: Theme.of(context).textTheme.headline5,
          suffixIcon: Icon(Icons.arrow_drop_down),
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
            _categoryController.text = selectedCategory['text'];
            categoryValue = selectedCategory['value'];
          }
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        readOnly: true,
        style: TextStyle(fontSize: 21.0),
        validator: CategoryValidator.validate);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackButton,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(title: Text("Dodaj sterownik"), actions: [
              IconButton(
                  key: Key('saveDriverButton'),
                  icon: Icon(Icons.save),
                  onPressed: _saveChanges)
            ]),
            drawer: IdomDrawer(
                storage: widget.storage,
                parentWidgetType: "NewDriver",
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
                            left: 30.0, top: 10.0, right: 30.0, bottom: 0.0),
                        child: _buildName()),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 30.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildCategoryField())),
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
        // var res = await api.newDriver(
        //     widget.driver.id, name, category, _token);
        var res;
        if (res['statusCode'] == "200") {
          Navigator.pop(context, true);
        } else if (res['statusCode'] == "401") {
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
        }
      } catch (e) {
        print(e.toString());
        setState(() {
          _load = false;
        });
        if (e.toString().contains("TimeoutException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd dodawania sterownika. Sprawdź połączenie z serwerem i spróbuj ponownie."));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
        if (e.toString().contains("SocketException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd dodawania sterownika. Adres serwera nieprawidłowy."));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      }
    }
  }
}
