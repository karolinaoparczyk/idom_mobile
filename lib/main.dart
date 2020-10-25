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
          fontFamily: "BarlowCondensed",
          primaryColor: IdomColors.mainFill,
          primaryColorLight: IdomColors.additionalColor,
          accentColor: IdomColors.additionalColor,
          scaffoldBackgroundColor: IdomColors.mainBackground,
          dialogBackgroundColor: IdomColors.mainBackground,
          backgroundColor: IdomColors.mainBackground,
          cardTheme: CardTheme(elevation: 15, color: IdomColors.mainBackground),
          errorColor: IdomColors.error,
          iconTheme: IconThemeData(color: IdomColors.additionalColor),
          dividerTheme: DividerThemeData(color: IdomColors.lightBlack),
          dialogTheme: DialogTheme(
              elevation: 20,
              backgroundColor: IdomColors.mainBackground,
              titleTextStyle: TextStyle(
                  color: IdomColors.additionalColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          textTheme: TextTheme(
              headline5: TextStyle(
                  color: IdomColors.additionalColor,
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold),
              bodyText1: TextStyle(
                  color: IdomColors.textDark,
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold)),
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: IdomColors.additionalColor,
              selectionHandleColor: IdomColors.additionalColor,
              selectionColor: IdomColors.additionalColor),
          appBarTheme: AppBarTheme(
            textTheme: TextTheme(
                headline6:
                    TextStyle(color: IdomColors.textLight, fontSize: 20,letterSpacing: 2.0)),
            iconTheme: IconThemeData(color: IdomColors.iconLight),
            actionsIconTheme: IconThemeData(color: IdomColors.iconLight),
          ),
        ),
        home: SafeArea(child: Home()));
  }
}
