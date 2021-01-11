import 'package:flutter/material.dart';
import 'package:idom/models.dart';

/// pop-up dialog for selecting existing multiple sensors
class ChooseMultipleSensorsDialog extends StatefulWidget {
  ChooseMultipleSensorsDialog({this.sensors, this.selectedSensors});

  /// allowed sensors to select
  final List<Sensor> sensors;

  /// currently selected sensors
  final List<Sensor> selectedSensors;

  /// handles state of widgets
  @override
  _ChooseMultipleSensorsDialogState createState() =>
      _ChooseMultipleSensorsDialogState();
}

class _ChooseMultipleSensorsDialogState
    extends State<ChooseMultipleSensorsDialog> {
  /// true when searching
  bool searchBarVisible;
  TextEditingController _searchBarController = TextEditingController();

  /// sensors selected in pop-up
  List<Sensor> tempSelectedSensors = List<Sensor>();

  @override
  void initState() {
    super.initState();
    searchBarVisible = false;
    tempSelectedSensors.addAll(widget.selectedSensors);

    /// builds sensor list based on searched word
    _searchBarController.addListener(() {
      setState(() {});
    });
  }

  /// disposing objects after using them
  @override
  void dispose() {
    _searchBarController.dispose();
    super.dispose();
  }

  /// builds pop-up dialog
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SizedBox(
        height: 400,
        width: size.width * 2 / 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 15, top: 15, bottom: 10, right: 15),

              /// search bar
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: searchBarVisible
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,

                /// on search icon tab
                firstChild: TextField(
                  style: Theme.of(context).textTheme.bodyText2,
                  controller: _searchBarController,
                  decoration: InputDecoration(
                    hintText: "Wyszukaj...",
                    hintStyle: Theme.of(context).textTheme.bodyText2,

                    /// closes searching box
                    prefixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          searchBarVisible = false;
                          _searchBarController.clear();
                        });
                      },
                      icon: Icon(Icons.arrow_back,
                          color: Theme.of(context).textTheme.bodyText2.color),
                    ),

                    /// clears searching text
                    suffixIcon: _searchBarController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () => _searchBarController.clear(),
                            icon: Icon(Icons.clear,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .color),
                          )
                        : null,
                  ),
                ),

                /// default tab
                secondChild: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "Wybierz czujniki",
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(fontSize: 21.0),
                      ),
                    ),

                    /// show search bar
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            searchBarVisible = true;
                          });
                        },
                        child: const Icon(Icons.search))
                  ],
                ),
              ),
            ),
            Divider(),
            Expanded(
                child: ListView(
              /// if searching, search given word in categories
              children: (searchBarVisible
                      ? widget.sensors.where((sensor) => sensor.name
                          .toLowerCase()
                          .contains(_searchBarController.text.toLowerCase()))
                      : widget.sensors)
                  .map((sensor) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},

                      /// allows selecting multiple sensors
                      child: CheckboxListTile(
                        onChanged: (checked) {
                          setState(() {
                            checked
                                ? tempSelectedSensors.add(sensor)
                                : tempSelectedSensors.remove(sensor);
                          });
                        },
                        value: tempSelectedSensors.contains(sensor),
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(sensor.name,
                            style: Theme.of(context).textTheme.bodyText2),
                      )))
                  .toList(),
            )),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                /// cancel action
                TextButton(
                    child: Text("Anuluj",
                        style: Theme.of(context).textTheme.headline5),
                    onPressed: () {
                      Navigator.pop(context, null);
                    }),

                /// confirm action
                TextButton(
                    key: Key('yesButton'),
                    child: Text("OK",
                        style: Theme.of(context).textTheme.headline5),
                    onPressed: () {
                      Navigator.pop(context, tempSelectedSensors);
                    }),
              ],
            ),
          ],
        ));
  }
}
