import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:idom/pages/setup/accounts.dart';
import 'package:idom/utils/validators.dart';

final storage = FlutterSecureStorage();

class SignIn extends StatefulWidget {
  const SignIn({Key key, @required this.apiLogIn, this.onSignedIn}) : super(key: key);
  final VoidCallback onSignedIn;
  final apiLogIn;

  @override
  _SignInState createState() => new _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Widget _buildLogin() {
    return TextFormField(
        key: Key('email'),
        controller: _usernameController,
        decoration: InputDecoration(
            labelText: 'Login',
            labelStyle: TextStyle(color: Colors.black, fontSize: 18)),
        validator: EmailFieldValidator.validate);
  }

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

  signIn() async {
    try {
      final formState = _formKey.currentState;
      if (formState.validate()) {
        formState.save();
        var result = await widget.apiLogIn.attemptToSignIn(
            _usernameController.value.text, _passwordController.value.text);
        print('result: $result');
        if (result == 'ok') {
          widget.onSignedIn();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Accounts()));
        } else if (result == 'wrong credentials') {
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
                      _buildLogin(),
                      _buildPassword(),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 190,
                            child: RaisedButton(
                                key: Key('signIn'),
                                onPressed: signIn,
                                child: Text(
                                  'Zaloguj się',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.normal),
                                ),
                                color: Colors.black,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                elevation: 10,
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0))),
                          ),
                        ],
                      ),
                    ],
                  ))),
          Expanded(child: SizedBox(width: 1))
        ],
      ),
    );
  }

  void displayDialog(BuildContext context, String title, String text) =>
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );
}
