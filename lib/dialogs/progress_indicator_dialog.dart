import 'package:flutter/material.dart';

/// displays dialog for user with provided title and text
void displayDialog({BuildContext context, String title, String text}) =>
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(title: Text(title), content: Text(text), actions: [
        FlatButton(
          key: Key("ok button"),
          onPressed: () => Navigator.pop(context, false),
          child: Text('OK'),
        ),
      ]),
    );

void displayProgressDialog({BuildContext context, GlobalKey key, String text}) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return new WillPopScope(
            onWillPop: () async => false,
            child: SimpleDialog(key: key, children: <Widget>[
              Center(
                child: Column(children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10,
                  ),
                  Text(text,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 21.0))
                ]),
              )
            ]));
      });
}
