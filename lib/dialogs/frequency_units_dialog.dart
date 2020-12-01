import 'package:flutter/material.dart';
import 'package:idom/enums/frequency_units.dart';

class FrequencyUnitsDialog extends StatefulWidget {
  final String currentFrequencyUnits;

  FrequencyUnitsDialog({this.currentFrequencyUnits});

  @override
  _FrequencyUnitsDialogState createState() => _FrequencyUnitsDialogState();
}

class _FrequencyUnitsDialogState extends State<FrequencyUnitsDialog> {
  List<Map<String, String>> frequencyUnitsList = FrequencyUnits.values;
  Map<String, String> _selectedFrequencyUnits;

  @override
  void initState() {
    if (widget.currentFrequencyUnits != null) {
      _selectedFrequencyUnits = frequencyUnitsList.firstWhere(
          (element) => element['value'] == widget.currentFrequencyUnits);
    }
    super.initState();
  }

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
                child: Text("Wybierz jednostki",
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
                    return RadioListTile(
                      title: Text(frequencyUnitsList[index]['text'],
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.normal, fontSize: 21.0)),
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
                  TextButton(
                      child: Text("Anuluj",
                          style: Theme.of(context).textTheme.headline5),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  TextButton(
                      key: Key('yesButton'),
                      child: Text("OK",
                          style: Theme.of(context).textTheme.headline5),
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
