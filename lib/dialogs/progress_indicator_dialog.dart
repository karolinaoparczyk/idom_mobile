import 'package:flutter/material.dart';

/// pop-up dialog for displaying action in progress with given message
void displayProgressDialog({BuildContext context, GlobalKey key, String text}) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return new WillPopScope(
            onWillPop: () async => false,
            child: SimpleDialog(key: key, children: <Widget>[
              Center(
                child: Column(children: [
                  /// action in progress animated icon
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10,
                  ),

                  /// given message
                  Text(text,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText2)
                ]),
              )
            ]));
      });
}
