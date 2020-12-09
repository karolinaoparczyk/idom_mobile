import 'package:flutter/material.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/localization/setup/front.i18n.dart';

class LogotypeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Image.asset('assets/home.png', height: 70.0, width: 70.0),
                  Text(
                    'IDOM',
                    style:
                        TextStyle(fontSize: 100.0, color: IdomColors.textDark),
                    textAlign: TextAlign.center,
                  ),
                  Icon(Icons.roofing_rounded,
                      size: 70.0, color: Colors.transparent),
                ]),
                Text(
                  'TWÓJ INTELIGENTNY DOM\nW JEDNYM MIEJSCU'.i18n,
                  style: TextStyle(
                      fontSize: 21,
                      color: IdomColors.additionalColor,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text("Trwa ładowanie...".i18n,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontSize: 21.0, fontWeight: FontWeight.normal)))
              ])),
    );
  }
}
