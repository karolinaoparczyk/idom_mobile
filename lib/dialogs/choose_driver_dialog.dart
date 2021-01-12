import 'package:flutter/material.dart';
import 'package:idom/models.dart';

/// pop-up dialog for selecting existing driver
class ChooseDriverDialog extends StatefulWidget {
  ChooseDriverDialog({this.drivers, this.currentDriver});

  /// allowed drivers to select
  final List<Driver> drivers;
  /// currently selected driver
  final Driver currentDriver;

  /// handles state of widgets
  @override
  _ChooseDriverDialogState createState() => _ChooseDriverDialogState();
}

class _ChooseDriverDialogState extends State<ChooseDriverDialog> {
  /// true when searching
  bool searchBarVisible;
  TextEditingController _searchBarController = TextEditingController();
  Driver selectedDriver;

  @override
  void initState() {
    super.initState();
    searchBarVisible = false;
    selectedDriver = widget.currentDriver;
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
                        "Wybierz sterownik",
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
              /// if searching, search given word in drivers' names
              children: (searchBarVisible
                      ? widget.drivers.where((driver) => driver.name
                          .toLowerCase()
                          .contains(_searchBarController.text.toLowerCase()))
                      : widget.drivers)
                  .map(
                    /// allows selecting only one driver
                    (driver) => RadioListTile(
                      title: Text(driver.name,
                          style: Theme.of(context).textTheme.bodyText2),
                      value: driver,
                      groupValue: selectedDriver,
                      onChanged: (value) {
                        setState(() {
                          selectedDriver = driver;
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
                      Navigator.pop(context, selectedDriver);
                    }),
              ],
            ),
          ],
        ));
  }
}
