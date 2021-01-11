import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:idom/localization/setup/sign_in.i18n.dart';
import 'package:idom/api.dart';
import 'package:idom/pages/setup/enter_email.dart';
import 'package:idom/utils/login_procedures.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/loading_indicator.dart';

/// signs user in
class SignIn extends StatefulWidget {
  SignIn({@required this.storage, @required this.isFromSignUp, this.testApi});

  /// internal storage
  final SecureStorage storage;

  /// whether user came from sign up page or not
  ///
  /// true if signed up and ready to sign in
  /// false if came directly from front page
  final bool isFromSignUp;

  /// api used for tests
  final Api testApi;

  /// handles state of widgets
  @override
  _SignInState createState() => new _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusScopeNode _node = FocusScopeNode();
  Api api = Api();
  bool _load;
  IconData _passwordIcon = Icons.visibility_outlined;
  bool _obscurePassword = true;

  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }
    _load = false;
  }

  _displaySignUpSuccessMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: Text("Konto zostało utworzone. Możesz się zalogować.".i18n,
          style: Theme.of(context).textTheme.bodyText1),
    );
  }

  /// builds username text field for the form
  Widget _buildUsername() {
    return TextFormField(
      key: Key('username'),
      autofocus: true,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).textTheme.bodyText2.color),
            borderRadius: BorderRadius.circular(10.0)),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).textTheme.bodyText2.color),
          borderRadius: BorderRadius.circular(10.0),
        ),
        labelText: "Nazwa użytkownika".i18n,
        labelStyle: Theme.of(context).textTheme.headline5,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      controller: _usernameController,
      style: Theme.of(context).textTheme.bodyText2,
      validator: UsernameFieldValidator.validate,
      onEditingComplete: _node.nextFocus,
      textInputAction: TextInputAction.next,
    );
  }

  /// builds password text field for the form
  Widget _buildPassword() {
    return TextFormField(
      key: Key('password'),
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).textTheme.bodyText2.color),
            borderRadius: BorderRadius.circular(10.0)),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).textTheme.bodyText2.color),
          borderRadius: BorderRadius.circular(10.0),
        ),
        labelText: "Hasło".i18n,
        labelStyle: Theme.of(context).textTheme.headline5,
        suffixIcon: IconButton(
            color: Theme.of(context).iconTheme.color,
            icon: Icon(_passwordIcon),
            onPressed: () {
              if (_passwordIcon == Icons.visibility_outlined) {
                setState(() {
                  _passwordIcon = Icons.visibility_off_outlined;
                  _obscurePassword = false;
                });
              } else {
                setState(() {
                  _passwordIcon = Icons.visibility_outlined;
                  _obscurePassword = true;
                });
              }
            }),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      controller: _passwordController,
      validator: PasswordFieldValidator.validate,
      style: Theme.of(context).textTheme.bodyText2,
      obscureText: _obscurePassword,
      onEditingComplete: _node.nextFocus,
      textInputAction: TextInputAction.done,
    );
  }

  /// tries to sign in the user with provided credentials
  signIn() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      setState(() {
        _load = true;
      });

      LoginProcedures.init(widget.storage, api);
      var message = await LoginProcedures.signIn(
          _usernameController.text, _passwordController.text);
      setState(() {
        _load = false;
      });
      if (message != null) {
        final snackBar = new SnackBar(content: new Text(message.i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      } else {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  Future<bool> _onBackButton() async {
    Navigator.of(context).popUntil((route) => route.isFirst);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackButton,
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text('Zaloguj się'.i18n),
          ),
          body: SizedBox(
            height: MediaQuery.of(context).size.height - 60,
            child: SingleChildScrollView(
              child: Column(children: <Widget>[
                Form(
                    key: _formKey,
                    child: FocusScope(
                        node: _node,
                        child: Column(
                          children: <Widget>[
                            if (widget.isFromSignUp)
                              _displaySignUpSuccessMessage(),
                            Align(
                              child: loadingIndicator(_load),
                              alignment: FractionalOffset.center,
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 20.0,
                                    right: 30.0,
                                    bottom: 0.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _buildUsername())),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0,
                                    top: 20.0,
                                    right: 30.0,
                                    bottom: 13.5),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _buildPassword())),
                          ],
                        ))),
                AnimatedContainer(
                    curve: Curves.easeInToLinear,
                    duration: Duration(
                      milliseconds: 10,
                    ),
                    alignment: Alignment.bottomCenter,
                    child: Column(children: <Widget>[
                      buttonWidget(context, "Zaloguj".i18n, signIn),
                      TextButton(
                        key: Key("passwordReset"),
                        child: Text('Zapomniałeś/aś hasła?'.i18n,
                            style: Theme.of(context).textTheme.bodyText2),
                        onPressed: navigateToEnterEmail,
                      ),
                    ]))
              ]),
            ),
          )),
    );
  }

  /// navigates to sending reset password request page
  navigateToEnterEmail() async {
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
