import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:idom/api.dart';
import 'package:idom/pages/setup/sign_in.dart';
import 'package:idom/utils/validators.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key key, @required this.api}) : super(key: key);
  final Api api;

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

  Widget _buildUsername() {
    return TextFormField(
        key: Key('username'),
        controller: _usernameController,
        decoration: InputDecoration(
          labelText: 'Login',
          labelStyle: TextStyle(color: Colors.black, fontSize: 18),
          suffixText: '*',
          suffixStyle: TextStyle(
            color: Colors.red,
          ),
        ),
        maxLength: 25,
        validator: UsernameFieldValidator.validate);
  }

  Widget _buildPassword() {
    return TextFormField(
      key: Key('password1'),
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Hasło',
        labelStyle: TextStyle(color: Colors.black, fontSize: 18),
        suffixText: '*',
        suffixStyle: TextStyle(
          color: Colors.red,
        ),
      ),
      maxLength: 20,
      validator: PasswordFieldValidator.validate,
      obscureText: true,
    );
  }

  Widget _buildConfirmPassword() {
    return TextFormField(
      key: Key('password2'),
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        labelText: 'Powtórz hasło',
        labelStyle: TextStyle(color: Colors.black, fontSize: 18),
        suffixText: '*',
        suffixStyle: TextStyle(
          color: Colors.red,
        ),
      ),
      maxLength: 20,
      validator: (String value) {
        if (value != _passwordController.text) {
          return 'Hasła nie mogą się różnić';
        }
      },
      obscureText: true,
    );
  }

  Widget _buildEmail() {
    return TextFormField(
        key: Key('email'),
        controller: _emailController,
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: TextStyle(color: Colors.black, fontSize: 18),
          suffixText: '*',
          suffixStyle: TextStyle(
            color: Colors.red,
          ),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: EmailFieldValidator.validate);
  }

  Widget _buildTelephone() {
    return TextFormField(
        key: Key('telephone'),
        controller: _telephoneController,
        decoration: InputDecoration(
            labelText: 'Nr telefonu komórkowego',
            labelStyle: TextStyle(color: Colors.black, fontSize: 18)),
        keyboardType: TextInputType.phone,
        validator: TelephoneFieldValidator.validate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zarejestruj się'),
      ),
      body: SingleChildScrollView(
        child: Row(
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
                        _buildEmail(),
                        _buildTelephone(),
                        _buildPassword(),
                        _buildConfirmPassword(),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 190,
                              child: RaisedButton(
                                  key: Key('signUp'),
                                  onPressed: signUp,
                                  child: Text(
                                    'Zarejestruj się',
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
      ),
    );
  }

  void displayDialog(BuildContext context, String title, String text) =>
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text), actions: [
              FlatButton(
                key: Key("ok button"),
                onPressed: () => Navigator.pop(context, false),
                child: Text('OK'),
              ),
            ],),
      );

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
        var res = await widget.api
            .signUp(username, password1, password2, email, telephone);
        if (res['statusCode'] == "201") {
          await displayDialog(context, "Sukces",
              "Konto zostało utworzone. Możesz się zalogować.");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SignIn(api: widget.api)));
        } else if (res['body']
            .contains("for key 'register_customuser.username'")) {
          displayDialog(
              context, "Błąd", "Konto dla podanego loginu już istnieje.");
        } else if (res['body']
            .contains("for key 'register_customuser.email'")) {
          displayDialog(
              context, "Błąd", "Konto dla podanego adresu email już istnieje.");
        } else if (res['body'].contains("Enter a valid phone number")) {
          displayDialog(context, "Błąd", "Numer telefonu jest niepoprawny.");
        }
      } catch (e) {
        print(e.toString());
      }
    }
  }
}
