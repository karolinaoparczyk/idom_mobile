import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/localization/setup/sign_up.i18n.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/pages/setup/sign_in.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/loading_indicator.dart';

/// signs user up
class SignUp extends StatefulWidget {
  SignUp({@required this.storage, this.testApi});

  final SecureStorage storage;
  final Api testApi;

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final FocusScopeNode _node = FocusScopeNode();
  final _scrollController = ScrollController();
  Api api = Api();
  bool _load;
  String fieldsValidationMessage;
  IconData _passwordIcon = Icons.visibility_outlined;
  bool _obscurePassword = true;
  IconData _passwordConfirmIcon = Icons.visibility_outlined;
  bool _obscureConfirmPassword = true;

  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }
    _load = false;
  }

  /// builds username form field
  Widget _buildUsername() {
    return TextFormField(
      key: Key('username'),
      autofocus: true,
      decoration: InputDecoration(
        labelText: "Nazwa użytkownika*".i18n,
        labelStyle: Theme.of(context).textTheme.headline5,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      controller: _usernameController,
      style: Theme.of(context)
          .textTheme
          .bodyText1
          .copyWith(fontSize: 21.0),
      validator: UsernameFieldValidator.validate,
      onEditingComplete: _node.nextFocus,
      textInputAction: TextInputAction.next,
    );
  }

  /// builds password form field
  Widget _buildPassword() {
    return TextFormField(
      key: Key('password1'),
      decoration: InputDecoration(
        labelText: "Hasło*".i18n,
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
      style: Theme.of(context)
          .textTheme
          .bodyText1
          .copyWith(fontSize: 21.0),
      validator: PasswordFieldValidator.validate,
      obscureText: _obscurePassword,
      onEditingComplete: _node.nextFocus,
      textInputAction: TextInputAction.next,
    );
  }

  /// builds password confirmation form field
  Widget _buildConfirmPassword() {
    return TextFormField(
      key: Key('password2'),
      decoration: InputDecoration(
        labelText: "Powtórz hasło*".i18n,
        labelStyle: Theme.of(context).textTheme.headline5,
        suffixIcon: IconButton(
            color: Theme.of(context).iconTheme.color,
            icon: Icon(_passwordConfirmIcon),
            onPressed: () {
              if (_passwordConfirmIcon == Icons.visibility_outlined) {
                setState(() {
                  _passwordConfirmIcon = Icons.visibility_off_outlined;
                  _obscureConfirmPassword = false;
                });
              } else {
                setState(() {
                  _passwordConfirmIcon = Icons.visibility_outlined;
                  _obscureConfirmPassword = true;
                });
              }
            }),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      controller: _confirmPasswordController,
      style:Theme.of(context)
          .textTheme
          .bodyText1
          .copyWith(fontSize: 21.0),
      validator: (String value) {
        if (value != _passwordController.text) {
          return 'Hasła nie mogą się różnić'.i18n;
        }
        return null;
      },
      obscureText: _obscureConfirmPassword,
      onEditingComplete: _node.nextFocus,
      textInputAction: TextInputAction.done,
    );
  }

  /// builds email form field
  Widget _buildEmail() {
    return TextFormField(
      key: Key('email'),
      decoration: InputDecoration(
        labelText: "Adres e-mail*".i18n,
        labelStyle: Theme.of(context).textTheme.headline5,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: Theme.of(context)
          .textTheme
          .bodyText1
          .copyWith(fontSize: 21.0),
      validator: EmailFieldValidator.validate,
      onEditingComplete: _node.nextFocus,
      textInputAction: TextInputAction.next,
    );
  }

  /// builds telephone form field
  Widget _buildTelephone() {
    return TextFormField(
      key: Key('telephone'),
      decoration: InputDecoration(
        labelText: "Nr telefonu komórkowego".i18n,
        labelStyle: Theme.of(context).textTheme.headline5,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      controller: _telephoneController,
      keyboardType: TextInputType.phone,
      style:Theme.of(context)
          .textTheme
          .bodyText1
          .copyWith(fontSize: 21.0),
      validator: TelephoneFieldValidator.validate,
      onEditingComplete: _node.nextFocus,
      textInputAction: TextInputAction.next,
    );
  }

  clearFields() {
    _formKey.currentState.reset();
    _passwordController.text = "";
    _confirmPasswordController.text = "";
    _usernameController.text = "";
    _emailController.text = "";
    _telephoneController.text = "";
    fieldsValidationMessage = "";
    _passwordIcon = Icons.visibility_outlined;
    _obscurePassword = true;
    _passwordConfirmIcon = Icons.visibility_outlined;
    _obscureConfirmPassword = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text('Zarejestruj się'.i18n), actions: [
          IconButton(
            icon: Icon(Icons.restore_page_rounded),
            onPressed: () async {
              var decision = await confirmActionDialog(
                context,
                "Potwierdź".i18n,
                "Czy na pewno wyczyścić wszystkie pola?".i18n,
              );
              if (decision) {
                clearFields();
              }
            },
          ),
          IconButton(
              key: Key("registerButton"),
              icon: Icon(Icons.check),
              onPressed: signUp),
        ]),
        body: Container(
            child: Column(
          children: <Widget>[
            Expanded(
                flex: 6,
                child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Form(
                        key: _formKey,
                        child: FocusScope(
                            node: _node,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Align(
                                    child: loadingIndicator(_load),
                                    alignment: FractionalOffset.center,
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 30.0,
                                          top: 13.5,
                                          right: 30.0,
                                          bottom: 0.0),
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: _buildUsername())),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 30.0,
                                          top: 10.0,
                                          right: 30.0,
                                          bottom: 0.0),
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: _buildEmail())),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 30.0,
                                          top: 10.0,
                                          right: 30.0,
                                          bottom: 0.0),
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: _buildTelephone())),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 30.0,
                                          top: 10.0,
                                          right: 30.0,
                                          bottom: 0),
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: _buildPassword())),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 30.0,
                                          top: 10.0,
                                          right: 30.0,
                                          bottom: 10),
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: _buildConfirmPassword())),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 30.0),
                                    child: AnimatedCrossFade(
                                      crossFadeState:
                                          fieldsValidationMessage != null
                                              ? CrossFadeState.showFirst
                                              : CrossFadeState.showSecond,
                                      duration: Duration(milliseconds: 300),
                                      firstChild: fieldsValidationMessage !=
                                              null
                                          ? Text(fieldsValidationMessage,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1)
                                          : SizedBox(),
                                      secondChild: SizedBox(),
                                    ),
                                  ),
                                ]))))),
          ],
        )));
  }

  /// signs user up after form validation
  Future<void> signUp() async {
    var username = _usernameController.text;
    var password1 = _passwordController.text;
    var password2 = _confirmPasswordController.text;
    var email = _emailController.text;
    var telephone = _telephoneController.text;

    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        setState(() {
          _load = true;
        });
        var res =
            await api.signUp(username, password1, password2, email, telephone);
        setState(() {
          _load = false;
        });
        var loginExists = false;
        var emailExists = false;
        var telephoneExists = false;
        var telephoneInvalid = false;
        var emailInvalid = false;

        if (res['statusCode'] == "201") {
          setState(() {
            fieldsValidationMessage = null;
          });

          /// navigates to logging in page
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      SignIn(storage: widget.storage, isFromSignUp: true)));
          return;
        }
        if (res['body'].contains("Username already exists")) {
          loginExists = true;
        }
        if (res['body'].contains("Email address already exists")) {
          emailExists = true;
        }
        if (res['body'].contains("Enter a valid phone number")) {
          telephoneInvalid = true;
        }
        if (res['body'].contains("Telephone number already exists")) {
          telephoneExists = true;
        }
        if (res['body'].contains("Enter a valid email address")) {
          emailInvalid = true;
        }

        String errorText = "";
        if (loginExists && emailExists && telephoneExists)
          errorText =
              "Konto dla podanej nazwy użytkownika, adresu e-mail i numeru telefonu już istnieje."
                  .i18n;
        else if (loginExists && emailExists)
          errorText =
              "Konto dla podanej nazwy użytkownika i adresu e-mail już istnieje."
                  .i18n;
        else if (loginExists && telephoneExists)
          errorText =
              "Konto dla podanej nazwy użytkownika i numeru telefonu już istnieje."
                  .i18n;
        else if (emailExists && telephoneExists)
          errorText =
              "Konto dla podanego adresu e-mail i numeru telefonu już istnieje."
                  .i18n;
        else if (emailExists)
          errorText = "Konto dla podanego adresu e-mail już istnieje.".i18n;
        else if (loginExists)
          errorText = "Konto dla podanej nazwy użytkownika już istnieje.".i18n;
        else if (telephoneExists)
          errorText = "Konto dla podanego numeru telefonu już istnieje.".i18n;

        if (telephoneInvalid && emailInvalid)
          errorText +=
              "Adres e-mail oraz numer telefonu są nieprawidłowe.".i18n;
        else if (telephoneInvalid)
          errorText += "Numer telefonu jest nieprawidłowy.".i18n;
        else if (emailInvalid)
          errorText += "Adres e-mail jest nieprawidłowy".i18n;

        if (errorText != null) {
          FocusScope.of(context).unfocus();
          setState(() {
            fieldsValidationMessage = errorText;
          });
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }

        setState(() {
          _load = false;
        });
      } catch (e) {
        print(e.toString());
        setState(() {
          _load = false;
        });
        if (e.toString().contains("TimeoutException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd rejestracji. Sprawdź połączenie z serwerem i spróbuj ponownie."
                      .i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
        if (e.toString().contains("SocketException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd rejestracji. Adres serwera nieprawidłowy.".i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        } else {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd rejestracji. Sprawdź połączenie z serwerem i spróbuj ponownie."));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      }
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}
