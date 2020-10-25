import 'package:flutter/material.dart';

Future<bool> confirmActionDialog(BuildContext context, String titleText, String content, Function onConfirm) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleText),
          content: Text(content, style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.normal)),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              key: Key("yesButton"),
              child: Text("Tak", style: Theme.of(context).textTheme.headline5),
              onPressed: onConfirm,
            ),
            FlatButton(
              key: Key("noButton"),
              child: Text("Nie", style: Theme.of(context).textTheme.headline5),
              onPressed: () async {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      });
}
