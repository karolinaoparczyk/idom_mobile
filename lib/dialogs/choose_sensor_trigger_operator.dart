import 'package:flutter/material.dart';
import 'package:idom/enums/operators.dart';
import 'package:idom/localization/dialogs/sensor_trigger_operator.i18n.dart';

/// pop-up dialog for selecting operator for sensor's trigger value
class SensorTriggerOperatorDialog extends StatefulWidget {
  /// currently selected operator
  final String currentOperator;

  SensorTriggerOperatorDialog({this.currentOperator});

  /// handles state of widgets
  @override
  _SensorTriggerOperatorDialogState createState() =>
      _SensorTriggerOperatorDialogState();
}

class _SensorTriggerOperatorDialogState
    extends State<SensorTriggerOperatorDialog> {
  String _selectedOperator;

  @override
  void initState() {
    if (widget.currentOperator != null) {
      /// loads allowed operators
      _selectedOperator = Operators.values
          .firstWhere((element) => element == widget.currentOperator);
    }
    super.initState();
  }

  /// builds pop-up dialog
  @override
  Widget build(BuildContext context) {
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
                child: Text("Wybierz operator porównania".i18n,
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
                  key: Key("operatorList"),
                  itemCount: Operators.values.length,
                  itemBuilder: (BuildContext context, int index) {
                    /// allows selecting only one operator
                    return RadioListTile(
                      title: Text(Operators.values[index],
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.normal, fontSize: 21.0)),
                      value: Operators.values[index],
                      groupValue: _selectedOperator,
                      onChanged: (value) {
                        setState(() {
                          _selectedOperator = value;
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
                      child: Text("Anuluj".i18n,
                          style: Theme.of(context).textTheme.headline5),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  /// confirm action
                  TextButton(
                      key: Key('yesButton'),
                      child: Text("OK",
                          style: Theme.of(context).textTheme.headline5),
                      onPressed: () {
                        Navigator.pop(context, _selectedOperator);
                      }),
                ],
              ),
            ],
          )),
    );
  }
}
