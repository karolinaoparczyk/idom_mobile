import 'package:flutter/material.dart';

Widget buttonWidget(BuildContext context, String text, Function onPressed) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      SizedBox(
        width: 190,
        child: RaisedButton(
            key: Key(text),
            onPressed: onPressed,
            child: Text(
              text,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.normal),
            ),
            color: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 12),
            elevation: 10,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0))),
      ),
    ],
  );
}
