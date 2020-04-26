import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../home.dart';

class SignIn extends StatefulWidget{
  @override
  _SignInState createState() => new _SignInState();
}

class _SignInState extends State<SignIn>{

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _login, _password;

  Widget _buildLogin() {
    return TextFormField(
        decoration: InputDecoration(
          labelText: 'Login',
          labelStyle: TextStyle(color: Colors.black, fontSize: 18)
          ),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Podaj login';
          }
        },
        onSaved: (String value) {
          _login = value;
        });
  }

  Widget _buildPassword() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Hasło',
        labelStyle: TextStyle(color: Colors.black, fontSize: 18),
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Podaj hasło';
        }
      },
      onSaved: (String value) {
        _password = value;
      },
      obscureText: true,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zaloguj się'),
      ),
      body: Row(
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
                      _buildPassword(),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 190,
                            child: RaisedButton(
                                onPressed: signIn,
                                child: Text(
                                  'Zaloguj się',
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
    );
  }

  Future<void> signIn() async {
    final formState = _formKey.currentState;
    if(formState.validate()){
      formState.save();
      try{
        //user = await database login
        Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
      }
      catch(e){
        print(e.toString());
      }
      //sign in to database
    }
  }
}