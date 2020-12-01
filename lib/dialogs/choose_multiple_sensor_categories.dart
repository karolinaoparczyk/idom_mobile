import 'package:flutter/material.dart';
import 'package:idom/enums/categories.dart';

class ChooseMultipleSensorCategoriesDialog extends StatefulWidget {
  ChooseMultipleSensorCategoriesDialog({this.selectedCategories});

  final List<Map<String, String>> selectedCategories;

  @override
  _ChooseMultipleSensorCategoriesDialogState createState() => _ChooseMultipleSensorCategoriesDialogState();
}

class _ChooseMultipleSensorCategoriesDialogState extends State<ChooseMultipleSensorCategoriesDialog> {
  bool searchBarVisible;
  TextEditingController _searchBarController = TextEditingController();
  List<Map<String, String>> tempSelectedCategories = List<Map<String, String>>();
  List<Map<String, String>> categories;

  @override
  void initState() {
    super.initState();
    searchBarVisible = false;
    tempSelectedCategories.addAll(widget.selectedCategories);
    categories = SensorCategories.values;
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
                        "Wybierz kategorie",
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
                      ? categories.where((category) => category['text']
                      .toLowerCase()
                      .contains(_searchBarController.text.toLowerCase()))
                      : categories)
                      .map((category) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: CheckboxListTile(
                        onChanged: (checked) {
                          setState(() {
                            checked
                                ? tempSelectedCategories.add(category)
                                :  tempSelectedCategories.remove(category);
                          });
                        },
                        value:  tempSelectedCategories.contains(category),
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(category['text'],
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(fontWeight: FontWeight.normal)),
                      )))
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
                      Navigator.pop(context,  tempSelectedCategories);
                    }),
              ],
            ),
          ],
        ));
  }
}
