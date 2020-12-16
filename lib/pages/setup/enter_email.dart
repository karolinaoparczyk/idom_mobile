import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/localization/setup/enter_email.i18n.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/loading_indicator.dart';

/// allows to enter email and send reset password request
class EnterEmail extends StatefulWidget {
  EnterEmail({this.testApi});

  final Api testApi;
  @override
  _EnterEmailState createState() => _EnterEmailState();
}

class _EnterEmailState extends State<EnterEmail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = TextEditingController();
  Api api = Api();
  bool _load;

  void initState() {
    super.initState();
    if (widget.testApi != null){
      api = widget.testApi;
    }
    _load = false;
  }

  /// build email form field
  Widget _buildEmail() {
    return TextFormField(
        key: Key("email"),
        controller: _emailController,
        decoration: InputDecoration(
          labelText: "Adres e-mail".i18n,
          labelStyle: Theme.of(context).textTheme.headline5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        style: Theme.of(context)
            .textTheme
            .bodyText1
            .copyWith(fontSize: 21.0),
        validator: EmailFieldValidator.validate);
  }

  Future<bool> _onBackButton() async {
    Navigator.pop(context, false);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackButton,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('Reset hasła'.i18n),
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
                                        "Podaj adres e-mail połączony z Twoim kontem".i18n,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1)),
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
                              buttonWidget(context, "Resetuj hasło".i18n, Icons.arrow_right_outlined,
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
        var res = await api.resetPassword(_emailController.value.text);
        setState(() {
          _load = false;
        });
        if (res == 200) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Link do resetu hasła został wysłany na podany adres e-mail.".i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        } else if (res == 400) {
          final snackBar = new SnackBar(
              content:
                  new Text("Konto dla podanego adresu e-mail nie istnieje.".i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
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
                "Błąd resetu hasła. Sprawdź połączenie z serwerem i spróbuj ponownie.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content:
                new Text("Błąd resetu hasła. Adres serwera nieprawidłowy.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      } else {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd resetu hasła. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }
}
