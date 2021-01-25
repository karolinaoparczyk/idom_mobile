import 'package:flutter/material.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/utils/login_procedures.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/localization/cameras/edit_camera.i18n.dart';

/// allows editing camera
class EditCamera extends StatefulWidget {
  EditCamera({@required this.storage, @required this.camera, this.testApi});

  /// internal storage
  final SecureStorage storage;

  /// selected camera
  final Camera camera;

  /// api used for tests
  final Api testApi;

  /// handles state of widgets
  @override
  _EditCameraState createState() => _EditCameraState();
}

class _EditCameraState extends State<EditCamera> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  TextEditingController _nameController;
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

    /// seting current camera name
    _nameController = TextEditingController(text: widget.camera.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<bool> _onBackButton() async {
    Navigator.pop(context);
    return true;
  }

  /// builds camera name form field
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackButton,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(title: Text(widget.camera.name), actions: [
              IconButton(
                  key: Key('editCameraButton'),
                  icon: Icon(Icons.save),
                  onPressed: _verifyChanges)
            ]),
            drawer: IdomDrawer(
                storage: widget.storage,
                testApi: widget.testApi,
                parentWidgetType: "EditCamera"),

            /// builds form with camera's properties
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
  _saveChanges(bool changedName) async {
    FocusScope.of(context).unfocus();
    var name = changedName ? _nameController.text : null;
    setState(() {
      _load = true;
    });
    try {
      var res = await api.editCamera(widget.camera.id, name);
      setState(() {
        _load = false;
      });
      if (res['statusCode'] == "200") {
        fieldsValidationMessage = null;
        setState(() {});
        Navigator.pop(context, true);
      }

      /// on invalid token log out
      else if (res['statusCode'] == "401") {
        final message = await LoginProcedures.signInWithStoredData();
        if (message != null) {
          logOut();
        } else {
          setState(() {
            _load = true;
          });
          var res = await api.editCamera(widget.camera.id, name);
          setState(() {
            _load = false;
          });

          /// on success fetching data
          if (res['statusCode'] == "200") {
            fieldsValidationMessage = null;
            setState(() {});
            Navigator.pop(context, true);
          } else if (res != null && res['statusCode'] == "401") {
            logOut();
          } else if (res['body']
              .contains("Camera with provided name already exists")) {
            fieldsValidationMessage =
                "Kamera o podanej nazwie już istnieje.".i18n;
            setState(() {});
            return;
          } else {
            fieldsValidationMessage = null;
            setState(() {});
            final snackBar = new SnackBar(
                content: new Text(
                    "Edycja kamery nie powiodła się. Spróbuj ponownie.".i18n));
            _scaffoldKey.currentState.showSnackBar((snackBar));
          }
        }
      } else if (res['body']
          .contains("Camera with provided name already exists")) {
        fieldsValidationMessage = "Kamera o podanej nazwie już istnieje.".i18n;
        setState(() {});
        return;
      } else {
        fieldsValidationMessage = null;
        setState(() {});
        final snackBar = new SnackBar(
            content: new Text(
                "Edycja kamery nie powiodła się. Spróbuj ponownie.".i18n));
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
                "Błąd edytowania kamery. Sprawdź połączenie z serwerem i spróbuj ponownie."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd edytowania kamery. Adres serwera nieprawidłowy.".i18n));
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
  _confirmSavingChanges(bool changedName) async {
    var decision = await confirmActionDialog(
        context, "Potwierdź".i18n, "Czy na pewno zapisać zmiany?".i18n);
    if (decision) {
      await _saveChanges(changedName);
    }
  }

  /// verifies data changes
  _verifyChanges() async {
    var name = _nameController.text;
    var changedName = false;

    final formState = _formKey.currentState;
    if (formState.validate()) {
      /// sends request only if data changed
      if (name != widget.camera.name) {
        changedName = true;
      }

      if (changedName) {
        await _confirmSavingChanges(changedName);
      } else {
        final snackBar = new SnackBar(
            content: new Text("Nie wprowadzono żadnych zmian.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }
}
