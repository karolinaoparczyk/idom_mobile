import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/pages/setup/enter_email.dart';
import 'package:idom/pages/setup/sign_in.dart';
import 'package:idom/pages/setup/sign_up.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/text_color.dart';

import '../../models.dart';
import 'edit_api_address.dart';

/// allows signing in or signing up
class Front extends StatefulWidget {
  Front(
      {this.api,
      this.onSignedIn,
      this.onSignedOut,
      this.apiAddressAdded,
      this.apiAddress,
      this.setApiAddress});

  Function(String, Account, Api) onSignedIn;
  VoidCallback onSignedOut;
  Api api;
  var apiAddressAdded;
  String apiAddress;
  Function setApiAddress;

  @override
  _FrontState createState() => _FrontState();
}

class _FrontState extends State<Front> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);

    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            key: _scaffoldKey,
            body: SingleChildScrollView(
                child: Container(
                    alignment: Alignment.center,
                    child: Center(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                            height: queryData.size.height / 15 * 8,
                            child: AnimatedContainer(
                                curve: Curves.easeInToLinear,
                                duration: Duration(
                                  milliseconds: 10,
                                ),
                                alignment: Alignment.topCenter,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'IDOM',
                                        style: TextStyle(
                                            fontSize: 100,
                                            color: IdomColors.textDark),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        'TWÓJ INTELIGENTNY DOM \nW JEDNYM MIEJSCU',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: textColor,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ]))),
                        SizedBox(
                            height: queryData.size.height / 15 * 7,
                            child: AnimatedContainer(
                                curve: Curves.easeInToLinear,
                                duration: Duration(
                                  milliseconds: 10,
                                ),
                                alignment: Alignment.topCenter,
                                child: Column(children: [
                                  apiAddressWarning(),
                                  FlatButton(
                                    key: Key('editApiServer'),
                                    child: Text('Edytuj adres serwera',
                                        style: TextStyle(fontSize: 16)),
                                    onPressed: navigateToEditApiAddress,
                                  ),
                                  buttonWidget(
                                      context, "Zaloguj się", navigateToSignIn),
                                  SizedBox(height: 10),
                                  buttonWidget(context, "Zarejestruj się",
                                      navigateToSignUp),
                                  FlatButton(
                                    key: Key('passwordReset'),
                                    child: Text('Zapomniałeś/aś hasła?'),
                                    onPressed: navigateToEnterEmail,
                                  ),
                                ]))),
                      ],
                    ))))));
  }

  apiAddressWarning() {
    if (widget.apiAddressAdded == null) {
      return SizedBox();
    } else if (!widget.apiAddressAdded) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
        Icon(Icons.warning_amber_outlined, size: 16, color: IdomColors.error),
        Text(' Adres serwera nie został ustawiony',
            style: TextStyle(fontSize: 16, color: IdomColors.error))
      ]);
    }
    return Text("");
  }

  /// navigates to sending reset password request page
  navigateToEditApiAddress() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditApiAddress(
                api: widget.api,
                onSignedOut: widget.onSignedOut,
                apiAddress: widget.apiAddress),
            fullscreenDialog: true));

    /// displays success message when the email is successfully sent
    if (result != null) {
      if (result['dataSaved'] == true) {
        var apiString = await widget.setApiAddress();

        setState(() {
          if (apiString != null) {
            widget.apiAddress = apiString;
          }
          widget.apiAddressAdded = true;
        });
        final snackBar =
            new SnackBar(content: new Text("Adres serwera został zapisany."));

        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      setState(() {
        widget.onSignedOut = result['onSignedOut'];
      });
    }
  }

  /// navigates to sending reset password request page
  navigateToEnterEmail() async {
    if (widget.apiAddressAdded) {
      var result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  EnterEmail(api: widget.api, onSignedOut: widget.onSignedOut),
              fullscreenDialog: true));

      /// displays success message when the email is successfully sent
      if (result != null) {
        if (result['dataSaved'] == true) {
          final snackBar = new SnackBar(
              content: new Text("Email został wysłany. Sprawdź pocztę."));

          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
        setState(() {
          widget.onSignedOut = result['onSignedOut'];
        });
      }
    }
  }

  /// navigates to signing in page
  void navigateToSignIn() async {
    if (widget.apiAddressAdded) {
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
  }

  /// navigates to signing up page
  void navigateToSignUp() async {
    if (widget.apiAddressAdded) {
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
}
