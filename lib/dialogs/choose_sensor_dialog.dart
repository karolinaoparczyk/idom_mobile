import 'package:flutter/material.dart';
import 'package:idom/models.dart';

/// pop-up dialog for selecting existing sensor
class ChooseSensorDialog extends StatefulWidget {
  ChooseSensorDialog({this.sensors, this.currentSensor});

  /// allowed sensors to select
  final List<Sensor> sensors;
  /// currently selected sensor
  final Sensor currentSensor;

  /// handles state of widgets
  @override
  _ChooseSensorDialogState createState() => _ChooseSensorDialogState();
}

class _ChooseSensorDialogState extends State<ChooseSensorDialog> {
  /// true when searching
  bool searchBarVisible;
  TextEditingController _searchBarController = TextEditingController();
  Sensor selectedSensor;

  @override
  void initState() {
    super.initState();
    searchBarVisible = false;
    selectedSensor = widget.currentSensor;

    /// builds driver list based on searched word
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
                  key: Key("searchField"),
                  controller: _searchBarController,
                  decoration: InputDecoration(
                    hintText: "Wyszukaj...",

                    /// closes searching box
                    prefixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          searchBarVisible = false;
                          _searchBarController.clear();
                        });
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),

                    /// clears searching text
                    suffixIcon: _searchBarController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () => _searchBarController.clear(),
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
                ),

                /// default tab
                secondChild: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "Wybierz czujnik",
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(fontSize: 21.0),
                      ),
                    ),

                    /// show search bar
                    GestureDetector(
                        key: Key("searchIcon"),
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
              /// if searching, search given word in sensors' names
              children: (searchBarVisible
                      ? widget.sensors.where((sensor) => sensor.name
                          .toLowerCase()
                          .contains(_searchBarController.text.toLowerCase()))
                      : widget.sensors)
                  .map(
                    /// allows selecting only one sensor
                    (sensor) => RadioListTile(
                      title: Text(sensor.name,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2),
                      value: sensor,
                      groupValue: selectedSensor,
                      onChanged: (value) {
                        setState(() {
                          selectedSensor = sensor;
                        });
                      },
                    ),
                  )
                  .toList(),
            )),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                /// cancel action
                TextButton(
                    key: Key('Cancel'),
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
                      Navigator.pop(context, selectedSensor);
                    }),
              ],
            ),
          ],
        ));
  }
}
