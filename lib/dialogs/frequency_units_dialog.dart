import 'package:flutter/material.dart';
import 'package:idom/enums/frequency_units.dart';
import 'package:idom/localization/dialogs/frequency_units.i18n.dart';

/// pop-up dialog for selecting existing frequency units
class FrequencyUnitsDialog extends StatefulWidget {
  /// currently selected frequency units
  final String currentFrequencyUnits;

  FrequencyUnitsDialog({this.currentFrequencyUnits});

  /// handles state of widgets
  @override
  _FrequencyUnitsDialogState createState() => _FrequencyUnitsDialogState();
}

class _FrequencyUnitsDialogState extends State<FrequencyUnitsDialog> {
  List<Map<String, String>> frequencyUnitsList = FrequencyUnits.values;
  Map<String, String> _selectedFrequencyUnits;

  @override
  void initState() {
    if (widget.currentFrequencyUnits != null) {
      /// loads allowed frequency units
      _selectedFrequencyUnits = frequencyUnitsList.firstWhere(
          (element) => element['value'] == widget.currentFrequencyUnits);
    }
    super.initState();
  }

  /// builds pop-up dialog
  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: SizedBox(
          height: 450,
          width: size.width * 2 / 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 15, bottom: 10),
                child: Text("Wybierz jednostki".i18n,
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        .copyWith(fontSize: 21.0)),
              ),
              Divider(),
              SizedBox(
                height: 320.0,
                width: size.width * 2 / 3,
                child: ListView.builder(
                  itemCount: frequencyUnitsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    /// allows selecting only one unit
                    return RadioListTile(
                      title: Text(frequencyUnitsList[index]['text'].i18n,
                          style: Theme.of(context).textTheme.bodyText2),
                      value: frequencyUnitsList[index],
                      groupValue: _selectedFrequencyUnits,
                      onChanged: (value) {
                        setState(() {
                          _selectedFrequencyUnits = value;
                        });
                      },
                    );
                  },
                ),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  /// cancel action
                  TextButton(
                      key: Key('Cancel'),
                      child: Text("Anuluj".i18n,
                          style: Theme.of(context).textTheme.headline5),
                      style: ButtonStyle(
                          overlayColor: MaterialStateColor.resolveWith(
                              (states) => Theme.of(context).splashColor)),
                      onPressed: () {
                        Navigator.pop(context);
                      }),

                  /// confirm action
                  TextButton(
                      key: Key('yesButton'),
                      child: Text("OK",
                          style: Theme.of(context).textTheme.headline5),
                      style: ButtonStyle(
                          overlayColor: MaterialStateColor.resolveWith(
                              (states) => Theme.of(context).splashColor)),
                      onPressed: () {
                        Navigator.pop(context, _selectedFrequencyUnits);
                      }),
                ],
              ),
            ],
          )),
    );
  }
}
