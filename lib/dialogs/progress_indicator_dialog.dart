import 'package:flutter/material.dart';

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
                      style: Theme.of(context).textTheme.bodyText2)
                ]),
              )
            ]));
      });
}
