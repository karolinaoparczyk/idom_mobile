import 'package:flutter/material.dart';

Widget loadingIndicator(bool load) {
  return load
      ? new Container(
          width: 70.0,
          height: 70.0,
          child: new Padding(
              padding: const EdgeInsets.all(5.0),
              child: new Center(child: new CircularProgressIndicator())),
        )
      : new Container();
}
