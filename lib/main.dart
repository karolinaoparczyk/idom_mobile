import 'package:flutter/material.dart';
import 'package:idom/pages/home.dart';
import 'package:idom/utils/idom_colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

        /// default app theme and colors
        theme: ThemeData(
          primaryColor: IdomColors.mainFill,
          primaryColorLight: IdomColors.additionalColor,
          accentColor: IdomColors.additionalColor,
          scaffoldBackgroundColor: IdomColors.mainBackground,
          dialogBackgroundColor: IdomColors.mainBackground,
          backgroundColor: IdomColors.mainBackground,
          cardTheme: CardTheme(elevation: 15, color: IdomColors.mainBackground),
          errorColor: IdomColors.error,
          iconTheme: IconThemeData(color: IdomColors.additionalColor),
          textTheme: TextTheme(headline5: TextStyle(color: IdomColors.additionalColor, fontSize: 16, fontWeight: FontWeight.bold)),
          appBarTheme: AppBarTheme(
            textTheme: TextTheme(
                headline6:
                    TextStyle(color: IdomColors.textLight, fontSize: 20)),
            iconTheme: IconThemeData(color: IdomColors.iconLight),
            actionsIconTheme: IconThemeData(color: IdomColors.iconLight),
          ),
        ),
        home: SafeArea(child: Home()));
  }
}
