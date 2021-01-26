import 'package:flutter/material.dart';
import 'package:idom/enums/categories.dart';
import 'package:idom/localization/dialogs/category.i18n.dart';

/// pop-up dialog for selecting existing multiple sensor categories
class ChooseMultipleSensorCategoriesDialog extends StatefulWidget {
  ChooseMultipleSensorCategoriesDialog({this.selectedCategories});

  /// currently selected categories
  final List<Map<String, String>> selectedCategories;

  /// handles state of widgets
  @override
  _ChooseMultipleSensorCategoriesDialogState createState() =>
      _ChooseMultipleSensorCategoriesDialogState();
}

class _ChooseMultipleSensorCategoriesDialogState
    extends State<ChooseMultipleSensorCategoriesDialog> {
  /// true when searching
  bool searchBarVisible;
  TextEditingController _searchBarController = TextEditingController();

  /// categories selected in pop-up
  List<Map<String, String>> tempSelectedCategories =
      List<Map<String, String>>();
  List<Map<String, String>> categories;

  @override
  void initState() {
    super.initState();
    searchBarVisible = false;
    tempSelectedCategories.addAll(widget.selectedCategories);
    /// loads allowed sensor categories
    categories = SensorCategories.values;

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
                  style: Theme.of(context).textTheme.bodyText2,
                  controller: _searchBarController,
                  decoration: InputDecoration(
                    hintText: "Wyszukaj...".i18n,
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
                        "Wybierz kategorie".i18n,
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
              /// if searching, search given word in categories
              children: (searchBarVisible
                      ? categories.where((category) => category['text']
                          .toLowerCase()
                          .contains(_searchBarController.text.toLowerCase()))
                      : categories)
                  .map((category) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},

                      /// allows selecting multiple categories
                      child: CheckboxListTile(
                        onChanged: (checked) {
                          setState(() {
                            checked
                                ? tempSelectedCategories.add(category)
                                : tempSelectedCategories.remove(category);
                          });
                        },
                        value: tempSelectedCategories.contains(category),
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(category['text'].i18n,
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
                    key: Key('Cancel'),
                    child: Text("Anuluj".i18n,
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
                      Navigator.pop(context, tempSelectedCategories);
                    }),
              ],
            ),
          ],
        ));
  }
}
