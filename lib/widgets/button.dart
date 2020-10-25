import 'package:flutter/material.dart';
import 'package:idom/utils/idom_colors.dart';

/// default app button
Widget buttonWidget(BuildContext context, String text, Function onPressed) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      SizedBox(
        width: 160,
        child: RaisedButton(
          elevation: 15,
            key: Key(text),
            onPressed: onPressed,
            child: Text(
              text,
              style: TextStyle(
                  color: IdomColors.textLight,
                  fontSize: 21,
                  fontWeight: FontWeight.normal),
              textAlign: TextAlign.center
            ),
            color: IdomColors.buttonBackground,
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0))),
      ),
    ],
  );
}
