import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/dialog.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/widgets/text_color.dart';

/// allows to enter email and send reset password request
class EnterEmail extends StatefulWidget {
  EnterEmail({@required this.api, @required this.onSignedOut});

  Api api;
  VoidCallback onSignedOut;

  @override
  _EnterEmailState createState() => _EnterEmailState();
}

class _EnterEmailState extends State<EnterEmail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _load;

  void initState() {
    super.initState();
    _load = false;
  }

  /// build email form field
  Widget _buildEmail() {
    return TextFormField(
        key: Key("email"),
        controller: _emailController,
        decoration: InputDecoration(
          labelText: "Adres e-mail",
          labelStyle: Theme.of(context).textTheme.headline5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(fontSize: 17.0),
        validator: EmailFieldValidator.validate);
  }

  Future<bool> _onBackButton() async {
    Map<String, dynamic> result = {
      'onSignedOut': widget.onSignedOut,
      'dataSaved': false
    };
    Navigator.of(context).pop(result);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackButton,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Reset hasła'),
            ),
            body: Row(children: <Widget>[
              Expanded(flex: 1, child: SizedBox(width: 1)),
              Expanded(
                  flex: 30,
                  child: Column(children: <Widget>[
                    Expanded(
                        flex: 3,
                        child: Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                Align(
                                  child: loadingIndicator(_load),
                                  alignment: FractionalOffset.center,
                                ),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 30.0,
                                        top: 33.5,
                                        right: 30.0,
                                        bottom: 0.0),
                                    child: Text(
                                        "Wprowadź adres e-mail połączony z Twoim kontem",
                                        style: TextStyle(fontSize: 13.5))),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 30.0,
                                        top: 10.0,
                                        right: 30.0,
                                        bottom: 0.0),
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: _buildEmail())),
                              ],
                            ))),
                    Expanded(
                        flex: 1,
                        child: AnimatedContainer(
                            curve: Curves.easeInToLinear,
                            duration: Duration(
                              milliseconds: 10,
                            ),
                            alignment: Alignment.bottomCenter,
                            child: Column(children: <Widget>[
                              buttonWidget(context, "Resetuj hasło",
                                  sendResetPasswordRequest)
                            ])))
                  ])),
              Expanded(flex: 1, child: SizedBox(width: 1)),
            ])));
  }

  /// sends request to API to reset password if form is validated
  sendResetPasswordRequest() async {
    try {
      final formState = _formKey.currentState;
      if (formState.validate()) {
        setState(() {
          _load = true;
        });
        var res = await widget.api.resetPassword(_emailController.value.text);
        setState(() {
          _load = false;
        });
        if (res == 200) {
          Map<String, dynamic> result = {
            'onSignedOut': widget.onSignedOut,
            'dataSaved': true
          };
          Navigator.of(context).pop(result);
        } else if (res == 400) {
          displayDialog(
              context: context,
              title: "Błąd",
              text: "Konto dla podanego adresu e-mail nie istnieje.");
        }
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _load = false;
      });
      if (e.toString().contains("TimeoutException")) {
        displayDialog(
            context: context,
            title: "Błąd resetu hasła",
            text: "Sprawdź połączenie z serwerem i spróbuj ponownie.");
      }
      if (e.toString().contains("SocketException")) {
        await displayDialog(
            context: context,
            title: "Błąd resetu hasła",
            text: "Adres serwera nieprawidłowy.");
        widget.onSignedOut();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }
}
