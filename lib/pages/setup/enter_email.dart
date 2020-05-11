import 'package:flutter/material.dart';

class EnterEmail extends StatefulWidget {
  @override
  _EnterEmailState createState() => _EnterEmailState();
}

class _EnterEmailState extends State<EnterEmail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  Widget _buildEmail() {
    return TextFormField(
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
        validator: (String value) {
          if (value.isEmpty) {
            return 'Email jest wymagany';
          }
          if (!RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(value)) {
            return 'Podaj poprawny adres email';
          }
          return null;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset hasła'),
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
                      Text("Wprowadź email połączony z Twoim kontem"),
                      _buildEmail(),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 190,
                            child: RaisedButton(
                                key: Key('sendResetPasswordRequest'),
                                onPressed: sendResetPasswordRequest,
                                child: Text(
                                  'Resetuj hasło',
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

  /// sends request to API to reset password if form is validated
  sendResetPasswordRequest() {
    try {
      final formState = _formKey.currentState;
      if (formState.validate()) {
        print('reset password');
        // TODO: send API request to reset password
        // TODO: error if wrong email
        // TODO: navigate to login page if success
        // TODO: show success message after sending email to the user
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
