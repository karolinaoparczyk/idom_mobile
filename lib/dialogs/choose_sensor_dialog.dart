import 'package:flutter/material.dart';
import 'package:idom/models.dart';

class ChooseSensorDialog extends StatefulWidget {
  ChooseSensorDialog({this.sensors, this.currentSensor});

  final List<Sensor> sensors;
  final Sensor currentSensor;

  @override
  _ChooseSensorDialogState createState() => _ChooseSensorDialogState();
}

class _ChooseSensorDialogState extends State<ChooseSensorDialog> {
  bool searchBarVisible;
  TextEditingController _searchBarController = TextEditingController();
  Sensor selectedSensor;

  @override
  void initState() {
    super.initState();
    searchBarVisible = false;
    selectedSensor = widget.currentSensor;
    _searchBarController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchBarController.dispose();
    super.dispose();
  }

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
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: searchBarVisible
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: TextField(
                  controller: _searchBarController,
                  decoration: InputDecoration(
                    hintText: "Wyszukaj...",
                    prefixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          searchBarVisible = false;
                          _searchBarController.clear();
                        });
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    suffixIcon: _searchBarController.text.isNotEmpty
                        ? IconButton(
                      onPressed: () => _searchBarController.clear(),
                      icon: const Icon(Icons.clear),
                    )
                        : null,
                  ),
                ),
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
                  children: (searchBarVisible
                      ? widget.sensors.where((sensor) => sensor.name
                      .toLowerCase()
                      .contains(_searchBarController.text.toLowerCase()))
                      : widget.sensors)
                      .map(
                        (sensor) => RadioListTile(
                      title: Text(sensor.name,
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.normal, fontSize: 21.0)),
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
                TextButton(
                    child: Text("Anuluj",
                        style: Theme.of(context).textTheme.headline5),
                    onPressed: () {
                      Navigator.pop(context, null);
                    }),
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
