import 'package:flutter/material.dart';

import 'package:idom/pages/setup/front.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

        /// default app theme and colors
        theme: ThemeData(
          primaryColor: Colors.black,
          accentColor: Colors.grey,
        ),
        home: Front());
  }
}
