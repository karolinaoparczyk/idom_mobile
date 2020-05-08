import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart' as dio;
import 'package:idom/pages/setup/accounts.dart';
import 'package:path_provider/path_provider.dart';

final storage = FlutterSecureStorage();

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => new _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final dio.Dio _dio = dio.Dio();
  PersistCookieJar persistentCookies;
  final String URL = "http://10.0.2.2:8000/";

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<Directory> get _localCoookieDirectory async {
    final path = await _localPath;
    final Directory dir = new Directory('$path/cookies');
    await dir.create();
    return dir;
  }

  Future<String> getCsrftoken() async {
    try {
      String csrfTokenValue;
      final Directory dir = await _localCoookieDirectory;
      final cookiePath = dir.path;
      persistentCookies = new PersistCookieJar(dir: '$cookiePath');
      persistentCookies
          .deleteAll(); //clearing any existing cookies for a fresh start
      _dio.interceptors.add(dio.CookieManager(
              persistentCookies) //this sets up _dio to persist cookies throughout subsequent requests
          );
      _dio.options = new dio.BaseOptions(
        baseUrl: URL,
        contentType: ContentType.json,
        responseType: dio.ResponseType.plain,
        connectTimeout: 5000,
        receiveTimeout: 100000,
        headers: {
          HttpHeaders.userAgentHeader: "dio",
          "Connection": "keep-alive",
        },
      ); //BaseOptions will be persisted throughout subsequent requests made with _dio
      _dio.interceptors
          .add(dio.InterceptorsWrapper(onResponse: (dio.Response response) {
        List<Cookie> cookies = persistentCookies.loadForRequest(Uri.parse(URL));
        csrfTokenValue = cookies
            .firstWhere((c) => c.name == 'csrftoken', orElse: () => null)
            ?.value;
        if (csrfTokenValue != null) {
          _dio.options.headers['X-CSRF-TOKEN'] =
              csrfTokenValue; //setting the csrftoken from the response in the headers
        }
        return response;
      }));
      await _dio.get("login/");
      return csrfTokenValue;
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return null;
    }
  }

  attemptToSignIn() async {
    try {
      final formState = _formKey.currentState;
      if (formState.validate()) {
        formState.save();
        try {
          final csrf = await getCsrftoken();
          dio.FormData formData = new dio.FormData.from({
            "username": _usernameController.value.text,
            "password": _passwordController.value.text,
            "csrfmiddlewaretoken": '$csrf'
          });
          dio.Options optionData = new dio.Options(
            followRedirects: false,
            validateStatus: (status) {
              return status < 500;
            },
            contentType: ContentType.parse("application/x-www-form-urlencoded"),
          );
          dio.Response response =
              await _dio.post("login/", data: formData, options: optionData);
          if (response.statusCode == 200 &&
              response.data
                  .toString()
                  .contains("Please enter a correct username and password")) {
            displayDialog(context, "Błąd logowania",
                "Błędne hasło lub konto z podanym loginem nie istnieje");
          } else if (response.statusCode == 200 || response.statusCode == 302) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Accounts()));
          }
        } on dio.DioError catch (e) {
          if (e.response != null) {
            print(e.response.statusCode.toString() +
                " " +
                e.response.statusMessage);
            print(e.response.data);
            print(e.response.headers);
            print(e.response.request);
          } else {
            print(e.request);
            print(e.message);
          }
        } catch (error, stacktrace) {
          print("Exception occured: $error stackTrace: $stacktrace");
          return null;
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Widget _buildLogin() {
    return TextFormField(
        controller: _usernameController,
        decoration: InputDecoration(
            labelText: 'Login',
            labelStyle: TextStyle(color: Colors.black, fontSize: 18)),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Podaj login';
          }
        });
  }

  Widget _buildPassword() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Hasło',
        labelStyle: TextStyle(color: Colors.black, fontSize: 18),
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Podaj hasło';
        }
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
                                onPressed: attemptToSignIn,
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

  void displayDialog(BuildContext context, String title, String text) =>
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );
}
