import 'package:flutter/material.dart';

void displayDialog(BuildContext context, String title, String text) =>
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