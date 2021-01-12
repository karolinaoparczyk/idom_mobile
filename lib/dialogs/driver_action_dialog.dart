import 'package:flutter/material.dart';
import 'package:idom/enums/driver_actions.dart';
import 'package:idom/localization/dialogs/driver_action.i18n.dart';

/// pop-up dialog for selecting notifications language
class DriverActionDialog extends StatefulWidget {
  /// currently selected action
  final String currentAction;
  final String driverCategory;

  DriverActionDialog({this.currentAction, this.driverCategory});

  /// handles state of widgets
  @override
  _DriverActionDialogState createState() => _DriverActionDialogState();
}

class _DriverActionDialogState extends State<DriverActionDialog> {
  Map<String, String> _selectedAction;
  List<Map<String, String>> actions;

  @override
  void initState() {
    actions = DriverActions.getValues(widget.driverCategory);
    if (widget.currentAction != null) {
      /// loads allowed actions
      _selectedAction = actions
          .firstWhere((element) => element['value'] == widget.currentAction);
    }
    super.initState();
  }

  /// builds pop-up dialog
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;

    return SingleChildScrollView(
      child: SizedBox(
          height: 450,
          width: size.width * 2 / 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 15, bottom: 10),
                child: Text("Wybierz akcję".i18n,
                    style: Theme
                        .of(context)
                        .textTheme
                        .headline5
                        .copyWith(fontSize: 21.0)),
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  key: Key("actionList"),
                  itemCount: actions.length,
                  itemBuilder: (BuildContext context, int index) {
                    /// allows selecting only one action
                    return RadioListTile(
                      title: Text(actions[index]['text'].i18n,
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyText2),
                      value: actions[index],
                      groupValue: _selectedAction,
                      onChanged: (value) {
                        setState(() {
                          _selectedAction = value;
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
                      child: Text("Anuluj",
                          style: Theme
                              .of(context)
                              .textTheme
                              .headline5),
                      onPressed: () {
                        Navigator.pop(context);
                      }),

                  /// confirm action
                  TextButton(
                      key: Key('yesButton'),
                      child: Text("OK",
                          style: Theme
                              .of(context)
                              .textTheme
                              .headline5),
                      onPressed: () {
                        Navigator.pop(context, _selectedAction);
                      }),
                ],
              ),
            ],
          )),
    );
  }
}
