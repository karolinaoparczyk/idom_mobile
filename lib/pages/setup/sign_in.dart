import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:idom/api.dart';
import 'package:idom/pages/account/accounts.dart';
import 'package:idom/pages/setup/enter_email.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/dialog.dart';

final storage = FlutterSecureStorage();

class SignIn extends StatefulWidget {
  const SignIn({@required this.api, this.onSignedIn});
  final VoidCallback onSignedIn;
  final Api api;

  @override
  _SignInState createState() => new _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// builds username text field for the form
  Widget _buildUsername() {
    return TextFormField(
        key: Key('email'),
        controller: _usernameController,
        decoration: InputDecoration(
            labelText: 'Login',
            labelStyle: TextStyle(color: Colors.black, fontSize: 18)),
        validator: UsernameFieldValidator.validate);
  }

  /// builds password text field for the form
  Widget _buildPassword() {
    return TextFormField(
      key: Key('password'),
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Hasło',
        labelStyle: TextStyle(color: Colors.black, fontSize: 18),
      ),
      validator: PasswordFieldValidator.validate,
      obscureText: true,
    );
  }

  /// tries to sign in the user with provided credentials
  signIn() async {
    try {
      final formState = _formKey.currentState;
      if (formState.validate()) {
        var result = await widget.api.signIn(
            _usernameController.value.text, _passwordController.value.text);
        if (result[1] == 200 && result[0].toString().contains('token')) {
          widget.onSignedIn();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Accounts(
                      currentLoggedInToken:
                          result[0].split(':')[1].substring(1, 41),
                      currentLoggedInUsername: _usernameController.value.text,
                      api: widget.api)));
        } else if (result[1] == 400) {
          displayDialog(context, "Błąd logowania",
              "Błędne hasło lub konto z podanym loginem nie istnieje");
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Zaloguj się'),
      ),
      body: Row(
        children: <Widget>[
          Expanded(child: SizedBox(width: 1)),
          Expanded(
              flex: 7,
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildUsername(),
                      _buildPassword(),
                      SizedBox(height: 20),
                      FlatButton(
                        key: Key("passwordReset"),
                        child: Text('Zapomniałeś/aś hasła?'),
                        onPressed: navigateToEnterEmail,
                      ),
                      buttonWidget(context, "Zaloguj się", signIn)
                    ],
                  ))),
          Expanded(child: SizedBox(width: 1))
        ],
      ),
    );
  }

  navigateToEnterEmail() async {
    bool result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EnterEmail(api: widget.api), fullscreenDialog: true));

    /// displays success message when the email is successfuly sent
    if (result != null && result == true) {
      final snackBar = new SnackBar(
          content: new Text("Email został wysłany. Sprawdź pocztę."));

      _scaffoldKey.currentState.showSnackBar((snackBar));
    }
  }
}
