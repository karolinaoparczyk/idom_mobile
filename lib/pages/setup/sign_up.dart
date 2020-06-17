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
  const SignUp({Key key, @required this.onSignedIn, @required this.api})
      : super(key: key);
  final Function(String, Account, Api) onSignedIn;
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
  bool _load;

  void initState() {
    super.initState();
    _load = false;
  }

  /// builds username form field
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

  /// builds password form field
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

  /// builds password confirmation form field
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

  /// builds email form field
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

  /// builds telephone form field
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
                        buttonWidget(context, "Zarejestruj się", signUp),
                        Align(
                          child: loadingIndicator(_load),
                          alignment: FractionalOffset.center,
                        )
                      ],
                    ))),
            Expanded(child: SizedBox(width: 1)),
          ],
        ),
      ),
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

        if (res['statusCode'] == "201") {
          setState(() {
            _load = false;
          });
          await displayDialog(context, "Sukces",
              "Konto zostało utworzone. Możesz się zalogować.");

          /// navigates to logging in page
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      SignIn(api: widget.api, onSignedIn: widget.onSignedIn)));
        } else if (res['body']
            .contains("User with given username already exists")) {
          displayDialog(
              context, "Błąd", "Konto dla podanego loginu już istnieje.");
        } else if (res['body']
            .contains("User with given email already exists")) {
          displayDialog(
              context, "Błąd", "Konto dla podanego adresu email już istnieje.");
        } else if (res['body'].contains("Enter a valid phone number")) {
          displayDialog(context, "Błąd", "Numer telefonu jest niepoprawny.");
        } else if (res['body']
            .contains("User with given telephone number already exists")) {
          displayDialog(context, "Błąd",
              "Konto dla podanego numeru telefonu już istnieje.");
        }
        setState(() {
          _load = false;
        });
      } catch (e) {
        print(e.toString());
      }
    }
  }
}
