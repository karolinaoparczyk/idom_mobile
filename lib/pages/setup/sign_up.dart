import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/pages/setup/sign_in.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/dialog.dart';
import 'package:idom/widgets/loading_indicator.dart';

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
  }

  /// builds username form field
  Widget _buildUsername() {
    return TextFormField(
      key: Key('username'),
      autofocus: true,
      decoration: InputDecoration(
        labelText: "Nazwa użytkownika*",
        labelStyle: Theme.of(context).textTheme.headline5,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      controller: _usernameController,
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
      decoration: InputDecoration(
        labelText: "Hasło*",
        labelStyle: Theme.of(context).textTheme.headline5,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      controller: _passwordController,
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
      decoration: InputDecoration(
        labelText: "Powtórz hasło",
        labelStyle: Theme.of(context).textTheme.headline5,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      controller: _confirmPasswordController,
      style: TextStyle(fontSize: 17.0),
      validator: (String value) {
        if (value != _passwordController.text) {
          return 'Hasła nie mogą się różnić';
        }
        return null;
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
      decoration: InputDecoration(
        labelText: "Adres e-mail*",
        labelStyle: Theme.of(context).textTheme.headline5,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      controller: _emailController,
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
      decoration: InputDecoration(
        labelText: "Nr telefonu komórkowego",
        labelStyle: Theme.of(context).textTheme.headline5,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      controller: _telephoneController,
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
                                    child: _buildUsername())),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 10.0,
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
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 10.0,
                                    right: 30.0,
                                    bottom: 0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _buildPassword())),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 10.0,
                                    right: 30.0,
                                    bottom: 10),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _buildConfirmPassword())),
                            buttonWidget(context, "Zarejestruj się", signUp),

                          ],
                        ))))),
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
          final snackBar = new SnackBar(
              content:
                  new Text("Konto zostało utworzone. Możesz się zalogować."));
          ScaffoldMessenger.of(context).showSnackBar((snackBar));

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
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd rejestracji. Sprawdź połączenie z serwerem i spróbuj ponownie."));
          ScaffoldMessenger.of(context).showSnackBar((snackBar));
        }
        if (e.toString().contains("SocketException")) {
          final snackBar = new SnackBar(
              content:
                  new Text("Błąd rejestracji. Adres serwera nieprawidłowy."));
          ScaffoldMessenger.of(context).showSnackBar((snackBar));
        }
      }
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}
