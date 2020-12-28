import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:idom/pages/home.dart';
import 'package:idom/utils/app_state_notifier.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DarkMode.init();

  runApp(
    ChangeNotifierProvider<AppStateNotifier>(
      create: (context) => AppStateNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateNotifier>(builder: (context, appState, child) {
      return MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en', "UK"),
          Locale('pl', "PL"),
        ],

        /// default app theme and colors
        theme: ThemeData(
          fontFamily: "BarlowCondensed",
          primaryColor: IdomColors.mainFill,
          primaryColorLight: IdomColors.additionalColor,
          accentColor: IdomColors.additionalColor,
          scaffoldBackgroundColor: IdomColors.mainBackgroundLight,
          dialogBackgroundColor: IdomColors.mainBackgroundLight,
          backgroundColor: IdomColors.mainBackgroundLight,
          cardTheme: CardTheme(elevation: 15, color: IdomColors.cardLight),
          errorColor: IdomColors.error,
          iconTheme: IconThemeData(color: IdomColors.additionalColor),
          dividerTheme: DividerThemeData(color: IdomColors.lightBlack),
          indicatorColor: IdomColors.mainBackgroundLight,
          splashColor: IdomColors.buttonSplashColorLight,
          dialogTheme: DialogTheme(
              elevation: 20,
              backgroundColor: IdomColors.mainBackgroundLight,
              titleTextStyle: TextStyle(
                  color: IdomColors.additionalColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          textTheme: TextTheme(
              headline5: TextStyle(
                  color: IdomColors.additionalColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.normal),
              bodyText1: TextStyle(
                  color: IdomColors.blackTextLight,
                  fontSize: 21,
                  fontWeight: FontWeight.normal),
              bodyText2: TextStyle(
                  color: IdomColors.brighterBlackTextLight,
                  fontSize: 18.5,
                  fontWeight: FontWeight.normal),
              subtitle1: TextStyle(
                  color: IdomColors.brighterBlackTextLight,
                  fontSize: 15,
                  fontWeight: FontWeight.normal)),
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: IdomColors.additionalColor,
              selectionHandleColor: IdomColors.additionalColor,
              selectionColor: IdomColors.additionalColor),
          appBarTheme: AppBarTheme(
            textTheme: TextTheme(
                headline6: TextStyle(
                    color: IdomColors.whiteTextLight,
                    fontSize: 20,
                    letterSpacing: 2.0)),
            iconTheme: IconThemeData(color: IdomColors.iconLight),
            actionsIconTheme: IconThemeData(color: IdomColors.iconLight),
          ),
        ),

        /// dark app theme and colors
        darkTheme: ThemeData(
          fontFamily: "BarlowCondensed",
          primaryColor: IdomColors.mainFill,
          primaryColorLight: IdomColors.additionalColor,
          accentColor: IdomColors.additionalColor,
          scaffoldBackgroundColor: IdomColors.mainBackgroundDark,
          dialogBackgroundColor: IdomColors.mainBackgroundDark,
          backgroundColor: IdomColors.mainBackgroundDark,
          cardTheme: CardTheme(elevation: 15, color: IdomColors.cardDark),
          errorColor: IdomColors.error,
          iconTheme: IconThemeData(color: IdomColors.additionalColor),
          dividerTheme: DividerThemeData(color: IdomColors.lightBlack),
          indicatorColor: IdomColors.mainBackgroundDark,
          splashColor: IdomColors.buttonSplashColorDark,
          dialogTheme: DialogTheme(
              elevation: 20,
              backgroundColor: IdomColors.mainBackgroundDark,
              titleTextStyle: TextStyle(
                  color: IdomColors.additionalColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          textTheme: TextTheme(
              headline5: TextStyle(
                  color: IdomColors.additionalColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.normal),
              bodyText1: TextStyle(
                  color: IdomColors.blackTextDark,
                  fontSize: 21,
                  fontWeight: FontWeight.normal),
              bodyText2: TextStyle(
                  color: IdomColors.brighterBlackTextDark,
                  fontSize: 18.5,
                  fontWeight: FontWeight.normal),
              subtitle1: TextStyle(
                  color: IdomColors.brighterBlackTextDark,
                  fontSize: 15,
                  fontWeight: FontWeight.normal)),
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: IdomColors.additionalColor,
              selectionHandleColor: IdomColors.additionalColor,
              selectionColor: IdomColors.additionalColor),
          appBarTheme: AppBarTheme(
            textTheme: TextTheme(
                headline6: TextStyle(
                    color: IdomColors.whiteTextLight,
                    fontSize: 20,
                    letterSpacing: 2.0)),
            iconTheme: IconThemeData(color: IdomColors.iconLight),
            actionsIconTheme: IconThemeData(color: IdomColors.iconLight),
          ),
        ),
        home: SafeArea(child: I18n(child: Home())),
        themeMode: DarkMode.getTheme() ? ThemeMode.dark : ThemeMode.light,
      );
    });
  }
}
