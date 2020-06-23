import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/pages/setup/sign_in.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/dialog.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/widgets/text_color.dart';

import '../../models.dart';

/// signs user up
class SignUp extends StatefulWidget {
  SignUp(
      {Key key,
      @required this.onSignedIn,
      @required this.api,
      @required this.onSignedOut})
      : super(key: key);
  final Function(String, Account, Api) onSignedIn;
  Api api;
  VoidCallback onSignedOut;

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final FocusScopeNode _node = FocusScopeNode();
  final _scrollController = ScrollController();
  bool _load;

  void initState() {
    super.initState();
    _load = false;
    if (widget.api == null) {
      widget.api = Api();
    }
  }

  /// builds username form field
  Widget _buildUsername() {
    return TextFormField(
      key: Key('username'),
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

  /// builds password form field
  Widget _buildPassword() {
    return TextFormField(
      key: Key('password1'),
      controller: _passwordController,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: "Podaj hasło",
      ),
      style: TextStyle(fontSize: 17.0),
      validator: PasswordFieldValidator.validate,
      obscureText: true,
      onEditingComplete: _node.nextFocus,
      textInputAction: TextInputAction.next,
    );
  }

  /// builds password confirmation form field
  Widget _buildConfirmPassword() {
    return TextFormField(
      key: Key('password2'),
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: "Powtórz hasło",
      ),
      style: TextStyle(fontSize: 17.0),
      validator: (String value) {
        if (value != _passwordController.text) {
          return 'Hasła nie mogą się różnić';
        }
      },
      obscureText: true,
      onEditingComplete: _node.nextFocus,
      textInputAction: TextInputAction.done,
    );
  }

  /// builds email form field
  Widget _buildEmail() {
    return TextFormField(
      key: Key('email'),
      controller: _emailController,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: "Podaj adres e-mail",
      ),
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(fontSize: 17.0),
      validator: EmailFieldValidator.validate,
      onEditingComplete: _node.nextFocus,
      textInputAction: TextInputAction.next,
    );
  }

  /// builds telephone form field
  Widget _buildTelephone() {
    return TextFormField(
      key: Key('telephone'),
      controller: _telephoneController,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: "Podaj nr telefonu komórkowego",
      ),
      keyboardType: TextInputType.phone,
      style: TextStyle(fontSize: 17.0),
      validator: TelephoneFieldValidator.validate,
      onEditingComplete: _node.nextFocus,
      textInputAction: TextInputAction.next,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zarejestruj się'),
      ),
      body: Container(
          child: Column(children: <Widget>[
        Expanded(
            flex: 5,
            child: SingleChildScrollView(
                controller: _scrollController,
                child: Form(
                    key: _formKey,
                    child: FocusScope(
                        node: _node,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Align(
                              child: loadingIndicator(_load),
                              alignment: FractionalOffset.center,
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 13.5,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Login*",
                                        style: TextStyle(
                                            color: textColor,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold)))),
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
                                    child: Text("Adres e-mail*",
                                        style: TextStyle(
                                            color: textColor,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold)))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 0.0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _buildEmail())),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Nr telefonu komórkowego",
                                        style: TextStyle(
                                            color: textColor,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold)))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 0.0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _buildTelephone())),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Hasło*",
                                        style: TextStyle(
                                            color: textColor,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold)))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 0.0,
                                    right: 30.0,
                                    bottom: 0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _buildPassword())),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Powtórz hasło*",
                                        style: TextStyle(
                                            color: textColor,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold)))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 0.0,
                                    right: 30.0,
                                    bottom: 0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _buildConfirmPassword())),
                          ],
                        ))))),
        Expanded(
            flex: 1,
            child: AnimatedContainer(
                curve: Curves.easeInToLinear,
                duration: Duration(
                  milliseconds: 10,
                ),
                alignment: Alignment.bottomCenter,
                child: Column(children: <Widget>[
                  buttonWidget(context, "Zarejestruj się", signUp),
                ])))
      ])),
    );
  }

  /// signs user up after form validation
  Future<void> signUp() async {
    var username = _usernameController.text;
    var password1 = _passwordController.text;
    var password2 = _confirmPasswordController.text;
    var email = _emailController.text;
    var telephone = _telephoneController.text;

    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        setState(() {
          _load = true;
        });
        var res = await widget.api
            .signUp(username, password1, password2, email, telephone);
        var loginExists = false;
        var emailExists = false;
        var telephoneExists = false;
        var telephoneInvalid = false;

        if (res['statusCode'] == "201") {
          setState(() {
            _load = false;
          });
          await displayDialog(
              context: context,
              title: "Sukces",
              text: "Konto zostało utworzone. Możesz się zalogować.");

          /// navigates to logging in page
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SignIn(
                      api: widget.api,
                      onSignedIn: widget.onSignedIn,
                      onSignedOut: widget.onSignedOut)));
        }
        if (res['body'].contains("Username already exists")) {
          loginExists = true;
        }
        if (res['body'].contains("Email address already exists")) {
          emailExists = true;
        }
        if (res['body'].contains("Enter a valid phone number")) {
          telephoneInvalid = true;
        }
        if (res['body'].contains("Telephone number already exists")) {
          telephoneExists = true;
        }

        String errorText;
        if (loginExists && emailExists && telephoneExists)
          errorText =
              "Konto dla podanego loginu, adresu e-mail i nr telefonu już istnieje.";
        else if (loginExists && emailExists)
          errorText = "Konto dla podanego loginu i adresu e-mail już istnieje.";
        else if (loginExists && telephoneExists)
          errorText = "Konto dla podanego loginu i nr telefonu już istnieje.";
        else if (emailExists && telephoneExists)
          errorText =
              "Konto dla podanego adresu e-mail i nr telefonu już istnieje.";
        else if (emailExists)
          errorText = "Konto dla podanego adresu e-mail już istnieje.";
        else if (loginExists)
          errorText = "Konto dla podanego loginu już istnieje.";
        else if (telephoneExists)
          errorText = "Konto dla podanego nr telefonu już istnieje.";

        if (telephoneInvalid) errorText += " Podaj poprawny nr telefonu.";

        if (errorText != null)
          displayDialog(context: context, title: "Błąd", text: errorText);

        setState(() {
          _load = false;
        });
      } catch (e) {
        print(e.toString());
        setState(() {
          _load = false;
        });
        if (e.toString().contains("TimeoutException")) {
          displayDialog(
              context: context,
              title: "Błąd rejestracji",
              text: "Sprawdź połączenie z serwerem i spróbuj ponownie.");
        }
      }
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}
