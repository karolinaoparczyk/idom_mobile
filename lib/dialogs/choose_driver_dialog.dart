import 'package:flutter/material.dart';
import 'package:idom/models.dart';

class ChooseDriverDialog extends StatefulWidget {
  ChooseDriverDialog({this.drivers, this.currentDriver});

  final List<Driver> drivers;
  final Driver currentDriver;

  @override
  _ChooseDriverDialogState createState() => _ChooseDriverDialogState();
}

class _ChooseDriverDialogState extends State<ChooseDriverDialog> {
  bool searchBarVisible;
  TextEditingController _searchBarController = TextEditingController();
  Driver selectedDriver;

  @override
  void initState() {
    super.initState();
    searchBarVisible = false;
    selectedDriver = widget.currentDriver;
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
                        "Wybierz sterownik",
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
                      ? widget.drivers.where((driver) => driver.name
                      .toLowerCase()
                      .contains(_searchBarController.text.toLowerCase()))
                      : widget.drivers)
                      .map(
                        (driver) => RadioListTile(
                      title: Text(driver.name,
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.normal, fontSize: 21.0)),
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
                      Navigator.pop(context, selectedDriver);
                    }),
              ],
            ),
          ],
        ));
  }
}
