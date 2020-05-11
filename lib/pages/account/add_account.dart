import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// adds a new account
class AddAccount extends StatefulWidget {
  @override
  _AddAccountState createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  /// adds a new account to database through API
  Future<Map<String, String>> attemptAddAccount(
      String username,
      String password1,
      String password2,
      String email,
      String telephone) async {
    var res = await http.post('http://10.0.2.2:8000/register/', body: {
      "username": username,
      "password1": password1,
      "password2": password2,
      "email": email,
      "telephone": telephone,
    });
    var resDict = {
      "body": res.body.toString(),
      "statusCode": res.statusCode.toString(),
    };
    return resDict;
  }

  Widget _buildUsername() {
    return TextFormField(
        controller: _usernameController,
        decoration: InputDecoration(
          labelText: 'Login',
          labelStyle: TextStyle(color: Colors.black, fontSize: 18),
          suffixText: '*',
          suffixStyle: TextStyle(
            color: Colors.red,
          ),
        ),
        maxLength: 30,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Login jest wymagany';
          }
          if (value.contains(' ')) {
            return 'Login nie może zawierać spacji';
          }
        });
  }

  Widget _buildPassword() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Hasło',
        labelStyle: TextStyle(color: Colors.black, fontSize: 18),
        suffixText: '*',
        suffixStyle: TextStyle(
          color: Colors.red,
        ),
      ),
      maxLength: 20,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Hasło jest wymagane';
        }
        if (value.length < 8) {
          return 'Hasło musi zawierać przynajmniej 8 znaków';
        }
      },
      obscureText: true,
    );
  }

  Widget _buildConfirmPassword() {
    return TextFormField(
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        labelText: 'Powtórz hasło',
        labelStyle: TextStyle(color: Colors.black, fontSize: 18),
        suffixText: '*',
        suffixStyle: TextStyle(
          color: Colors.red,
        ),
      ),
      maxLength: 20,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Hasło jest wymagane';
        }
        if (value != _passwordController.text) {
          return 'Hasła nie mogą się różnić';
        }
      },
      obscureText: true,
    );
  }

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
      },
    );
  }

  Widget _buildTelephone() {
    return TextFormField(
      controller: _telephoneController,
      decoration: InputDecoration(
          labelText: 'Nr telefonu komórkowego',
          labelStyle: TextStyle(color: Colors.black, fontSize: 18)),
      validator: (String value) {
        if (value.isNotEmpty &&
            !RegExp(r"^(?:[[+]|0]9)?[0-9]{9,12}$").hasMatch(value)) {
          return 'Podaj poprawny numer telefonu';
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dodaj nowe konto'),
      ),
      /// new account form
      body: SingleChildScrollView(
        child: Row(
          children: <Widget>[
            Expanded(child: SizedBox(width: 1)),
            Expanded(
                flex: 7,
                child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _buildUsername(),
                        _buildEmail(),
                        _buildTelephone(),
                        _buildPassword(),
                        _buildConfirmPassword(),
                        SizedBox(height: 20),
                        /// confirm adding new account button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 250,
                              child: RaisedButton(
                                  onPressed: addAccount,
                                  child: Text(
                                    'Dodaj nowe konto',
                                    textAlign: TextAlign.center,
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
            Expanded(child: SizedBox(width: 1))
          ],
        ),
      ),
    );
  }

  /// displays message for the user
  void displayDialog(BuildContext context, String title, String text) =>
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  /// checks http status code
  Future<void> addAccount() async {
    var username = _usernameController.text;
    var password1 = _passwordController.text;
    var password2 = _confirmPasswordController.text;
    var email = _emailController.text;
    var telephone = _telephoneController.text;

    final formState = _formKey.currentState;
    if (formState.validate()) {
      try {
        var res = await attemptAddAccount(
            username, password1, password2, email, telephone);
        if (res['statusCode'] == "201") {
          Navigator.of(context).pop(true);
        } else if (res['body']
            .contains("for key 'register_customuser.username'")) {
          displayDialog(
              context, "Błąd", "Konto dla podanego loginu już istnieje.");
        } else if (res['body']
            .contains("for key 'register_customuser.email'")) {
          displayDialog(
              context, "Błąd", "Konto dla podanego adresu email już istnieje.");
        }
      } catch (e) {
        print(e.toString());
      }
    }
  }
}
