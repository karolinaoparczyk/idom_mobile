import 'package:flutter/material.dart';

Future<bool> confirmActionDialog(BuildContext context, String titleText,
    String content) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleText,
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  .copyWith(fontSize: 21.0)),
          content: Text(content,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(fontWeight: FontWeight.normal, fontSize: 21.0)),
          actions: <Widget>[
            TextButton(
              key: Key("yesButton"),
              child: Text("Tak", style: Theme.of(context).textTheme.headline5),
              onPressed: () async {
                Navigator.of(context).pop(true);
              },),
            TextButton(
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
