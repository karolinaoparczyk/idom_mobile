import 'package:flutter/material.dart';
import 'package:idom/pages/setup/accounts.dart';

class NewAccount extends StatefulWidget {
  @override
  _NewAccountState createState() => _NewAccountState();
}

class _NewAccountState extends State<NewAccount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  String _login, _password, _confirmPassword, _email, _phoneNumber;
  Map<String, bool> _permissions = {
    'Dodaj nowego użytkownika': false,
    'Usuń użytkownika': false,
  };

  Widget _buildLogin() {
    return TextFormField(
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
        },
        onSaved: (String value) {
          _login = value;
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
      onSaved: (String value) {
        _password = value;
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
      onSaved: (String value) {
        _confirmPassword = value;
      },
      obscureText: true,
    );
  }

  Widget _buildEmail() {
    return TextFormField(
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
        onSaved: (String value) {
          _email = value;
        });
  }

  Widget _buildPhoneNumber() {
    return TextFormField(
        decoration: InputDecoration(
            labelText: 'Nr telefonu komórkowego',
            labelStyle: TextStyle(color: Colors.black, fontSize: 18)),
        keyboardType: TextInputType.phone,
        validator: (String value) {
          if (value.isNotEmpty &&
              !RegExp(r"^(?:[[+]|0]9)?[0-9]{9,12}$").hasMatch(value)) {
            return 'Podaj poprawny numer telefonu';
          }
          return null;
        },
        onSaved: (String value) {
          _phoneNumber = value;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dodaj nowe konto'),
      ),
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
                        _buildLogin(),
                        _buildEmail(),
                        _buildPhoneNumber(),
                        _buildPassword(),
                        _buildConfirmPassword(),
                        SizedBox(height: 20),
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

  Future<void> addAccount() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        //user = await database create user
        //user send email notification
        // display that we sent email notification to user
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Accounts()));
      } catch (e) {
        print(e.toString());
      }
      //sign in to database
    }
  }
}
