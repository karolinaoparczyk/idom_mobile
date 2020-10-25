import 'package:flutter/material.dart';
import 'package:idom/utils/idom_colors.dart';

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
                  Icon(Icons.roofing_rounded,
                      size: 50.0, color: IdomColors.mainFill),
                  Text(
                    'IDOM',
                    style: TextStyle(
                        fontSize: 100.0, color: IdomColors.textDark),
                    textAlign: TextAlign.center,
                  ),
                  Icon(Icons.roofing_rounded,
                      size: 50.0, color: Colors.transparent),
                ]),
                Text(
                  'TWÓJ INTELIGENTNY DOM\nW JEDNYM MIEJSCU',
                  style: TextStyle(
                      fontSize: 21,
                      color: IdomColors.additionalColor,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text("Trwa ładowanie...",
                        style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 21.0, fontWeight: FontWeight.normal)))
              ])),
    );
  }
}
