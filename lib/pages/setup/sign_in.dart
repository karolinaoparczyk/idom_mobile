import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/setup/enter_email.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/loading_indicator.dart';

/// signs user in
class SignIn extends StatefulWidget {
  SignIn({@required this.storage});

  final SecureStorage storage;

  @override
  _SignInState createState() => new _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusScopeNode _node = FocusScopeNode();
  final Api api = Api();
  bool _load;
  IconData _passwordIcon = Icons.visibility_outlined;
  bool _obscurePassword = true;

  void initState() {
    super.initState();
    _load = false;
  }

  /// builds username text field for the form
  Widget _buildUsername() {
    return TextFormField(
      key: Key('username'),
      autofocus: true,
      decoration: InputDecoration(
        labelText: "Nazwa użytkownika",
        labelStyle: Theme.of(context).textTheme.headline5,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      controller: _usernameController,
      style: TextStyle(fontSize: 21.0),
      validator: UsernameFieldValidator.validate,
      onEditingComplete: _node.nextFocus,
      textInputAction: TextInputAction.next,
    );
  }

  /// builds password text field for the form
  Widget _buildPassword() {
    return TextFormField(
      key: Key('password'),
      decoration: InputDecoration(
        labelText: "Hasło",
        labelStyle: Theme.of(context).textTheme.headline5,
        suffixIcon: IconButton(
            color: Theme.of(context).iconTheme.color,
            icon: Icon(_passwordIcon),
            onPressed: () {
              if (_passwordIcon == Icons.visibility_outlined) {
                setState(() {
                  _passwordIcon = Icons.visibility_off_outlined;
                  _obscurePassword = false;
                });
              } else {
                setState(() {
                  _passwordIcon = Icons.visibility_outlined;
                  _obscurePassword = true;
                });
              }
            }),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      controller: _passwordController,
      validator: PasswordFieldValidator.validate,
      style: TextStyle(fontSize: 21.0),
      obscureText: _obscurePassword,
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
        var result = await api.signIn(
            _usernameController.text, _passwordController.text);
        if (result[1] == 200 && result[0].toString().contains('token')) {
          var userResult = await api.getUser(_usernameController.text,
              result[0].split(':')[1].substring(1, 41));
          if (userResult[1] == 200) {
            dynamic body = jsonDecode(userResult[0]);
            Account account = Account.fromJson(body);

            widget.storage.setUserData(
                account.username,
                _passwordController.text,
                account.email,
                account.telephone,
                account.id.toString(),
                account.smsNotifications,
                account.appNotifications,
                account.isActive.toString(),
                account.isStaff.toString(),
                result[0].split(':')[1].substring(1, 41));

            var isSetLoggedIn = await widget.storage.getIsLoggedIn();
            if (isSetLoggedIn == "true") {
              setState(() {
                _load = false;
              });
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          }
          if (userResult[1] == 401) {
            setState(() {
              _load = false;
            });
            final snackBar = new SnackBar(
                content: new Text(
                    "Błąd pobierania danych użytkownika. Spróbuj zalogować się ponownie."));
            ScaffoldMessenger.of(context).showSnackBar((snackBar));
          }
        } else if (result[1] == 400) {
          setState(() {
            _load = false;
          });
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd logowania. Błędne hasło lub konto z podanym loginem nie istnieje."));
          ScaffoldMessenger.of(context).showSnackBar((snackBar));
        }
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _load = false;
      });
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd logowania. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text("Błąd logowania. Adres serwera nieprawidłowy."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
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
                        flex: 2,
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
                                            top: 20.0,
                                            right: 30.0,
                                            bottom: 0.0),
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: _buildUsername())),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            left: 30.0,
                                            top: 20.0,
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
                              buttonWidget(context, "Zaloguj", Icons.arrow_right_outlined, signIn),
                              TextButton(
                                key: Key("passwordReset"),
                                child: Text('Zapomniałeś/aś hasła?',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                            fontWeight: FontWeight.normal)),
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
            builder: (context) => EnterEmail(), fullscreenDialog: true));

    /// displays success message when the email is successfully sent
    if (result == true) {
      final snackBar = new SnackBar(
          content: new Text("Email został wysłany. Sprawdź pocztę."));
      ScaffoldMessenger.of(context).showSnackBar((snackBar));
    }
  }
}
