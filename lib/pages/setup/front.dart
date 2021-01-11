import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:idom/localization/setup/front.i18n.dart';

import 'package:idom/api.dart';
import 'package:idom/pages/setup/enter_email.dart';
import 'package:idom/pages/setup/settings.dart';
import 'package:idom/pages/setup/sign_in.dart';
import 'package:idom/pages/setup/sign_up.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/button.dart';

/// allows signing in or signing up
class Front extends StatefulWidget {
  Front({@required this.storage, this.testApi});

  /// internal storage
  final SecureStorage storage;

  /// api used for tests
  final Api testApi;

  /// handles state of widgets
  @override
  _FrontState createState() => _FrontState();
}

class _FrontState extends State<Front> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Api api = Api();
  bool apiAddressSet;

  void initState() {
    if (widget.testApi != null) {
      api = widget.testApi;
    }
    checkApiAddressSet();
    super.initState();
  }

  Future<void> checkApiAddressSet() async {
    var _apiServerAddress = await widget.storage.getApiServerAddress();
    if (_apiServerAddress != null) apiAddressSet = true;
    setState(() {});
  }

  setApiAddressEmptyMessage() {
    if (apiAddressSet != null && apiAddressSet) {
      return SizedBox();
    } else {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_outlined,
                size: 16, color: IdomColors.error),
            Text(' Adres serwera nie został ustawiony'.i18n,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: IdomColors.error))
          ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/home.png', height: 70.0, width: 70.0),
                    Text(
                      'IDOM',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(fontSize: 100.0),
                      textAlign: TextAlign.center,
                    ),
                    Icon(Icons.roofing_rounded,
                        size: 70.0, color: Colors.transparent),
                  ]),
              Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Text(
                  'TWÓJ INTELIGENTNY DOM\nW JEDNYM MIEJSCU'.i18n,
                  style: TextStyle(
                      fontSize: 21,
                      color: IdomColors.additionalColor,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              setApiAddressEmptyMessage(),
              TextButton(
                key: Key('editApiServer'),
                child: Text('Edytuj adres serwera'.i18n,
                    style: Theme.of(context).textTheme.bodyText2),
                onPressed: navigateToEditApiAddress,
              ),
              buttonWidget(context, "Zaloguj".i18n, navigateToSignIn),
              SizedBox(height: 10),
              buttonWidget(context, "Zarejestruj".i18n, navigateToSignUp),
              TextButton(
                key: Key('passwordReset'),
                child: Text('Zapomniałeś/aś hasła?'.i18n,
                    style: Theme.of(context).textTheme.bodyText2),
                onPressed: navigateToEnterEmail,
              ),
            ],
          ),
        ));
  }

  /// navigates to editing api server address
  navigateToEditApiAddress() async {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Settings(storage: widget.storage),
            fullscreenDialog: true));

    /// displays success message when server address is set
    if (result == true) {
      await checkApiAddressSet();
      final snackBar = new SnackBar(
          content: new Text("Adres serwera został zapisany.".i18n));

      _scaffoldKey.currentState.showSnackBar((snackBar));
    }
  }

  /// navigates to sending reset password request page
  navigateToEnterEmail() async {
    if (apiAddressSet != null && apiAddressSet) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      var result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EnterEmail(testApi: widget.testApi),
              fullscreenDialog: true));

      /// displays success message when the email is successfully sent
      if (result == true) {
        final snackBar = new SnackBar(
            content: new Text("E-mail został wysłany. Sprawdź pocztę.".i18n));

        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }

  /// navigates to signing in page
  void navigateToSignIn() async {
    if (apiAddressSet != null && apiAddressSet) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SignIn(storage: widget.storage, isFromSignUp: false),
              fullscreenDialog: true));
    }
  }

  /// navigates to signing up page
  void navigateToSignUp() async {
    if (apiAddressSet != null && apiAddressSet) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SignUp(storage: widget.storage),
              fullscreenDialog: true));
    }
  }
}
