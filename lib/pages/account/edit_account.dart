import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/localization/account/edit_account.i18n.dart';

/// allows editing account
class EditAccount extends StatefulWidget {
  EditAccount({@required this.storage, @required this.account, this.testApi});

  final SecureStorage storage;
  final Account account;
  final Api testApi;

  @override
  _EditAccountState createState() => new _EditAccountState();
}

class _EditAccountState extends State<EditAccount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoaderInvalidToken = new GlobalKey<State>();
  Api api = Api();
  bool _load;
  String fieldsValidationMessage;
  String currentUsername;

  TextEditingController _emailController;
  TextEditingController _telephoneController;

  /// builds email form field
  Widget _buildEmail() {
    return TextFormField(
        key: Key('email'),
        controller: _emailController,
        autofocus: true,
        decoration: InputDecoration(
          labelText: "Adres e-mail*".i18n,
          labelStyle: Theme.of(context).textTheme.headline5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(fontSize: 21.0),
        validator: EmailFieldValidator.validate);
  }

  /// builds telephone form field
  Widget _buildTelephone() {
    return TextFormField(
        key: Key('telephone'),
        style: TextStyle(fontSize: 21.0),
        controller: _telephoneController,
        decoration: InputDecoration(
          labelText: "Nr telefonu komórkowego".i18n,
          labelStyle: Theme.of(context).textTheme.headline5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        keyboardType: TextInputType.phone,
        validator: TelephoneFieldValidator.validate);
  }

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }
    _getCurrentUser();
    _load = false;
    _emailController = TextEditingController(text: widget.account.email);
    _telephoneController =
        TextEditingController(text: widget.account.telephone);
  }

  _getCurrentUser() async {
    currentUsername = await widget.storage.getUsername();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _telephoneController.dispose();
    super.dispose();
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
            appBar: AppBar(title: Text(widget.account.username), actions: [
              IconButton(
                  key: Key("saveAccountButton"),
                  icon: Icon(Icons.save),
                  onPressed: _verifyChanges)
            ]),
            drawer: IdomDrawer(
                storage: widget.storage,
                parentWidgetType: "EditAccount",
                onLogOutFailure: onLogOutFailure),
            body: Container(
                child: Column(children: <Widget>[
              SingleChildScrollView(
                  child: Form(
                      key: _formKey,
                      child: Column(children: <Widget>[
                        Align(
                          child: loadingIndicator(_load),
                          alignment: FractionalOffset.center,
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 30.0,
                                top: 20.0,
                                right: 30.0,
                                bottom: 0.0),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded,
                                        size: 17.5),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Text("Ogólne".i18n,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(
                                                  fontWeight:
                                                      FontWeight.normal)),
                                    ),
                                  ],
                                ))),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 30.0,
                                top: 13.5,
                                right: 30.0,
                                bottom: 0.0),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildEmail())),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 30.0,
                                top: 10.0,
                                right: 30.0,
                                bottom: 0.0),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildTelephone())),
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
                                        .copyWith(
                                            fontWeight: FontWeight.normal))
                                : SizedBox(),
                            secondChild: SizedBox(),
                          ),
                        ),
                      ]))),
            ]))));
  }

  /// saves changes or displays error dialogs
  _saveChanges(bool changedEmail, bool changedTelephone) async {
    var email = changedEmail ? _emailController.text : null;
    var telephone = changedTelephone ? _telephoneController.text : null;
    setState(() {
      _load = true;
    });
    try {
      var res = await api.editAccount(widget.account.id, email, telephone);
      var emailExists = false;
      var emailInvalid = false;
      var telephoneExists = false;
      var telephoneInvalid = false;

      if (res['statusCode'] == "200") {
        setState(() {
          _load = false;
          fieldsValidationMessage = null;
        });
        if (widget.account.username == currentUsername) {
          widget.storage.setEmail(_emailController.text);
          widget.storage.setTelephone(_telephoneController.text);
        }
        Navigator.pop(context, true);
      } else if (res['statusCode'] == "401") {
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
      if (res['body'].contains("Email address already exists")) {
        emailExists = true;
      }
      if (res['body'].contains("Enter a valid email address")) {
        emailInvalid = true;
      }
      if (res['body'].contains("Enter a valid phone number")) {
        telephoneInvalid = true;
      }
      if (res['body'].contains("Telephone number already exists")) {
        telephoneExists = true;
      }
      String errorText = "";
      if (emailExists && telephoneExists)
        errorText =
            "Konto dla podanego adresu e-mail i numeru telefonu już istnieje.".i18n;
      else if (emailExists)
        errorText = "Konto dla podanego adresu e-mail już istnieje.".i18n;
      else if (telephoneExists)
        errorText = "Konto dla podanego numeru telefonu już istnieje.".i18n;

      if (telephoneInvalid && emailInvalid)
        errorText += "Adres e-mail oraz numer telefonu są nieprawidłowe.".i18n;
      else if (telephoneInvalid)
        errorText += "Numer telefonu jest nieprawidłowy.".i18n;
      else if (emailInvalid) errorText += "Adres e-mail jest nieprawidłowy.".i18n;

      if (errorText != "") fieldsValidationMessage = errorText;

      setState(() {
        _load = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        _load = false;
      });
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd edycji użytkownika. Sprawdź połączenie z serwerem i spróbuj ponownie.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd edycji użytkownika. Adres serwera nieprawidłowy.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }

  /// confirms saving account changes
  _confirmSavingChanges(bool changedEmail, bool changedTelephone) async {
    var decision = await confirmActionDialog(
        context, "Potwierdź".i18n, "Czy na pewno zapisać zmiany?".i18n);
    if (decision) {
      await _saveChanges(changedEmail, changedTelephone);
    }
  }

  /// verifies data changes
  _verifyChanges() async {
    var email = _emailController.text;
    var telephone = _telephoneController.text;
    var changedEmail = false;
    var changedTelephone = false;

    final formState = _formKey.currentState;
    if (formState.validate()) {
      /// sends request only if data has changed
      if (email != widget.account.email) {
        changedEmail = true;
      }
      if (telephone != widget.account.telephone) {
        changedTelephone = true;
      }
      if (changedEmail || changedTelephone) {
        await _confirmSavingChanges(changedEmail, changedTelephone);
      } else {
        final snackBar =
            new SnackBar(content: new Text("Nie wprowadzono żadnych zmian.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }
}
