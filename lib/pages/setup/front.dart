import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/pages/setup/enter_email.dart';
import 'package:idom/pages/setup/sign_in.dart';
import 'package:idom/pages/setup/sign_up.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/text_color.dart';

import '../../models.dart';

/// allows signing in or signing up
class Front extends StatefulWidget {
  Front({this.api, this.onSignedIn, this.onSignedOut});

  Function(String, Account, Api) onSignedIn;
  VoidCallback onSignedOut;
  Api api;

  @override
  _FrontState createState() => _FrontState();
}

class _FrontState extends State<Front> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void initState() {
    super.initState();
    if (widget.api == null) {
      widget.api = Api();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            key: _scaffoldKey,
            appBar:
                AppBar(automaticallyImplyLeading: false, title: Text('IDOM')),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'IDOM',
                  style: TextStyle(fontSize: 90, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'TWÓJ INTELIGENTNY DOM W JEDNYM MIEJSCU',
                  style: TextStyle(
                      fontSize: 15,
                      color: textColor,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 54),
                buttonWidget(context, "Zaloguj się", navigateToSignIn),
                SizedBox(height: 10),
                buttonWidget(context, "Zarejestruj się", navigateToSignUp),
                FlatButton(
                  key: Key('passwordReset'),
                  child: Text('Zapomniałeś/aś hasła?'),
                  onPressed: navigateToEnterEmail,
                ),
              ],
            )));
  }

  /// navigates to sending reset password request page
  navigateToEnterEmail() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EnterEmail(api: widget.api, onSignedOut: widget.onSignedOut),
            fullscreenDialog: true));

    /// displays success message when the email is successfully sent
    if (result != null && result['dataSaved'] == true) {
      final snackBar = new SnackBar(
          content: new Text("Email został wysłany. Sprawdź pocztę."));

      _scaffoldKey.currentState.showSnackBar((snackBar));
    }
    setState(() {
      widget.onSignedOut = result['onSignedOut'];
    });
  }

  /// navigates to signing in page
  void navigateToSignIn() async {
    if (widget.api == null) widget.api = Api();
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SignIn(
                api: widget.api,
                onSignedIn: widget.onSignedIn,
                onSignedOut: widget.onSignedOut),
            fullscreenDialog: true));
    setState(() {
      widget.onSignedOut = result;
    });
  }

  /// navigates to signing up page
  void navigateToSignUp() async {
    if (widget.api == null) widget.api = Api();
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SignUp(
                api: widget.api,
                onSignedIn: widget.onSignedIn,
                onSignedOut: widget.onSignedOut),
            fullscreenDialog: true));
    setState(() {
      widget.onSignedOut = result;
    });
  }
}
