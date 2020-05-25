import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/dialog.dart';

class EnterEmail extends StatefulWidget {
  const EnterEmail({@required this.api});
  final Api api;

  @override
  _EnterEmailState createState() => _EnterEmailState();
}

class _EnterEmailState extends State<EnterEmail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  Widget _buildEmail() {
    return TextFormField(
        key: Key("email"),
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
                      buttonWidget(context, "Resetuj hasło", sendResetPasswordRequest)
                    ],
                  ))),
          Expanded(child: SizedBox(width: 1)),
        ],
      ),
    );
  }

  /// sends request to API to reset password if form is validated
  sendResetPasswordRequest() async {
    try {
      final formState = _formKey.currentState;
      if (formState.validate()) {
        var res = await widget.api.resetPassword(_emailController.value.text);
        if (res == 200) {
          Navigator.of(context).pop(true);
        } else if (res == 400) {
          displayDialog(
              context, "Błąd", "Konto dla podanego adresu email nie istnieje.");
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
