import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:idom/api.dart';
import 'package:idom/pages/setup/enter_email.dart';
import 'package:idom/pages/setup/sign_in.dart';
import 'package:idom/pages/setup/sign_up.dart';
import 'package:idom/widgets/button.dart';

enum AuthStatus {
  notDetermined,
  notSignedIn,
  signedIn,
}

class Front extends StatefulWidget {
  Front({this.api});

  Api api;

  @override
  _FrontState createState() => _FrontState();
}

class _FrontState extends State<Front> {
  AuthStatus authStatus = AuthStatus.notDetermined;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _signedIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(leading: Container(), title: Text('IDOM')),
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
                  style: TextStyle(fontSize: 15, color: Colors.black),
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

  navigateToEnterEmail() async {
    if (widget.api == null) widget.api = Api();
    bool result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EnterEmail(api: widget.api),
            fullscreenDialog: true));

    /// displays success message when the email is successfuly sent
    if (result != null && result == true) {
      final snackBar = new SnackBar(
          content: new Text("Email został wysłany. Sprawdź pocztę."));

      _scaffoldKey.currentState.showSnackBar((snackBar));
    }
  }

  void navigateToSignIn() {
    if (widget.api == null) widget.api = Api();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SignIn(
                  api: widget.api,
                  onSignedIn: _signedIn,
                ),
            fullscreenDialog: true));
  }

  void navigateToSignUp() {
    if (widget.api == null) widget.api = Api();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SignUp(api: widget.api),
            fullscreenDialog: true));
  }
}
