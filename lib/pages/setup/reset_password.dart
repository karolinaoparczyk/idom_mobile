import 'package:flutter/material.dart';

/// only opened when redirected form sent email with valid token
class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Widget _buildPassword() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Nowe hasło',
        labelStyle: TextStyle(color: Colors.black, fontSize: 18),
        suffixText: '*',
        suffixStyle: TextStyle(
          color: Colors.red,
        ),
      ),
      maxLength: 20,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Hasło jest wymagane';
        }
        if (value.length < 8) {
          return 'Hasło musi zawierać przynajmniej 8 znaków';
        }
      },
      obscureText: true,
    );
  }

  Widget _buildConfirmPassword() {
    return TextFormField(
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
        if (value.isEmpty) {
          return 'Hasło jest wymagane';
        }
        if (value != _passwordController.text) {
          return 'Hasła nie mogą się różnić';
        }
      },
      obscureText: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nowe hasło'),
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
                      _buildPassword(),
                      _buildConfirmPassword(),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 190,
                            child: RaisedButton(
                                key: Key('updatePassword'),
                                onPressed: updatePassword,
                                child: Text(
                                  'Zapisz hasło',
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
          Expanded(child: SizedBox(width: 1)),
        ],
      ),
    );
  }

  /// updates password through API if form is validated
  updatePassword(){
    try {
      final formState = _formKey.currentState;
      if (formState.validate()) {
        print('update password');
        // TODO: update password through API
        // TODO: error message if no success
        // TODO: success message if success
        // TODO: navigation to login page
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
