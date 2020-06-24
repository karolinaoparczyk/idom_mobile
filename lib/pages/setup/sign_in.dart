import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/setup/enter_email.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/dialog.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/widgets/text_color.dart';

/// signs user in
class SignIn extends StatefulWidget {
  SignIn({@required this.api, this.onSignedIn, this.onSignedOut});

  final Function(String, Account, Api) onSignedIn;
  Api api;
  VoidCallback onSignedOut;

  @override
  _SignInState createState() => new _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusScopeNode _node = FocusScopeNode();
  bool _load;

  void initState() {
    super.initState();
    _load = false;
  }

  /// builds username text field for the form
  Widget _buildUsername() {
    return TextFormField(
      key: Key('email'),
      autofocus: true,
      controller: _usernameController,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: "Podaj login",
      ),
      style: TextStyle(fontSize: 17.0),
      validator: UsernameFieldValidator.validate,
      onEditingComplete: _node.nextFocus,
      textInputAction: TextInputAction.next,
    );
  }

  /// builds password text field for the form
  Widget _buildPassword() {
    return TextFormField(
      key: Key('password'),
      controller: _passwordController,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: "Podaj hasło",
      ),
      validator: PasswordFieldValidator.validate,
      style: TextStyle(fontSize: 17.0),
      obscureText: true,
      onEditingComplete: _node.nextFocus,
      textInputAction: TextInputAction.done,
    );
  }

  /// tries to sign in the user with provided credentials
  signIn() async {
    try {
      final formState = _formKey.currentState;
      if (formState.validate()) {
        setState(() {
          _load = true;
        });
        var result = await widget.api.signIn(
            _usernameController.value.text, _passwordController.value.text);
        if (result[1] == 200 && result[0].toString().contains('token')) {
          var userResult = await widget.api.getUser(
              _usernameController.value.text,
              result[0].split(':')[1].substring(1, 41));
          if (userResult[1] == 200) {
            dynamic body = jsonDecode(userResult[0]);
            Account account = Account.fromJson(body);
            setState(() {
              _load = false;
            });
            widget.onSignedIn(
                result[0].split(':')[1].substring(1, 41), account, widget.api);
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          if (userResult[1] == 401) {
            setState(() {
              _load = false;
            });
            displayDialog(
                context: context,
                title: "Błąd pobierania danych użytkownika",
                text: "Spróbuj zalogować się ponownie");
          }
        } else if (result[1] == 400) {
          setState(() {
            _load = false;
          });
          displayDialog(
              context: context,
              title: "Błąd logowania",
              text: "Błędne hasło lub konto z podanym loginem nie istnieje");
        }
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _load = false;
      });
      if (e.toString().contains("TimeoutException")) {
        displayDialog(
            context: context,
            title: "Błąd logowania",
            text: "Sprawdź połączenie z serwerem i spróbuj ponownie.");
      }
      if (e.toString().contains("No address associated with hostname")) {
        await displayDialog(
            context: context,
            title: "Błąd logowania",
            text: "Adres serwera nieprawidłowy.");
        widget.onSignedOut();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  Future<bool> _onBackButton() async {
    Navigator.of(context).popUntil((route) => route.isFirst);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackButton,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text('Zaloguj się'),
          ),
          body: Row(
            children: <Widget>[
              Expanded(flex: 1, child: SizedBox(width: 1)),
              Expanded(
                  flex: 30,
                  child: Column(children: <Widget>[
                    Expanded(
                        flex: 3,
                        child: Form(
                            key: _formKey,
                            child: FocusScope(
                                node: _node,
                                child: Column(
                                  children: <Widget>[
                                    Align(
                                      child: loadingIndicator(_load),
                                      alignment: FractionalOffset.center,
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            left: 30.0,
                                            top: 20,
                                            right: 30.0,
                                            bottom: 0.0),
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text("Login",
                                                style: TextStyle(
                                                    color: textColor,
                                                    fontSize: 13.5,
                                                    fontWeight:
                                                    FontWeight.bold)))),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            left: 30.0,
                                            top: 0.0,
                                            right: 30.0,
                                            bottom: 0.0),
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: _buildUsername())),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            left: 30.0,
                                            top: 0,
                                            right: 30.0,
                                            bottom: 0.0),
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text("Hasło",
                                                style: TextStyle(
                                                    color: textColor,
                                                    fontSize: 13.5,
                                                    fontWeight:
                                                    FontWeight.bold)))),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            left: 30.0,
                                            top: 0.0,
                                            right: 30.0,
                                            bottom: 13.5),
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: _buildPassword())),
                                  ],
                                )))),
                    Expanded(
                        flex: 1,
                        child: AnimatedContainer(
                            curve: Curves.easeInToLinear,
                            duration: Duration(
                              milliseconds: 10,
                            ),
                            alignment: Alignment.bottomCenter,
                            child: Column(children: <Widget>[
                              buttonWidget(context, "Zaloguj się", signIn),
                              FlatButton(
                                key: Key("passwordReset"),
                                child: Text('Zapomniałeś/aś hasła?'),
                                onPressed: navigateToEnterEmail,
                              ),
                            ])))
                  ])),
              Expanded(flex: 1, child: SizedBox(width: 1)),
            ],
          ),
        ));
  }

  /// navigates to sending reset password request page
  navigateToEnterEmail() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EnterEmail(api: widget.api, onSignedOut: widget.onSignedOut),
            fullscreenDialog: true));

    /// displays success message when the email is successfully sent
    if (result != null) {
      if (result['dataSaved'] == true) {
        final snackBar = new SnackBar(
            content: new Text("Email został wysłany. Sprawdź pocztę."));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      setState(() {
        widget.onSignedOut = result['onSignedOut'];
      });
    }
  }
}
