import 'package:flutter/material.dart';
import 'package:idom/enums/categories.dart';
import 'package:idom/localization/dialogs/category.i18n.dart';

/// pop-up dialog for selecting category
class CategoryDialog extends StatefulWidget {
  /// currently selected category
  final String currentCategory;

  /// sensors or drivers
  final String type;

  CategoryDialog({this.currentCategory, this.type});

  /// handles state of widgets
  @override
  _CategoryDialogState createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  /// allowed categories to select
  List<Map<String, String>> categories;
  /// currently selected category
  Map<String, String> _selectedCategory;

  @override
  void initState() {
    if (widget.type == "sensors") {
      categories = SensorCategories.values;
    } else if (widget.type == "drivers") {
      categories = DriverCategories.values;
    }

    /// setting up current category value
    if (widget.currentCategory != null) {
      _selectedCategory = categories
          .firstWhere((element) => element['value'] == widget.currentCategory);
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
                child: Text("Wybierz kategorię".i18n,
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
                  key: Key("categories_list"),
                  itemCount: categories.length,
                  itemBuilder: (BuildContext context, int index) {
                    /// allowing selecting only one category
                    return RadioListTile(
                      title: Text(categories[index]['text'].i18n,
                          style: Theme.of(context).textTheme.bodyText2),
                      value: categories[index],
                      groupValue: _selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
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
                      style: ButtonStyle(
                          overlayColor: MaterialStateColor.resolveWith(
                              (states) => Theme.of(context).splashColor)),
                      onPressed: () {
                        Navigator.pop(context);
                      }),

                  /// confirm action
                  TextButton(
                      key: Key('yesButton'),
                      child: Text("OK",
                          style: Theme.of(context).textTheme.headline5),
                      style: ButtonStyle(
                          overlayColor: MaterialStateColor.resolveWith(
                              (states) => Theme.of(context).splashColor)),
                      onPressed: () {
                        /// returning chosen category to form
                        Navigator.pop(context, _selectedCategory);
                      }),
                ],
              ),
            ],
          )),
    );
  }
}
