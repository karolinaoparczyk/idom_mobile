import 'package:flutter/material.dart';
import 'package:idom/enums/categories.dart';

class CategoryDialog extends StatefulWidget {
  final String currentCategory;

  CategoryDialog({this.currentCategory});

  @override
  _CategoryDialogState createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  List<Map<String, String>> categories = Categories.values;
  Map<String, String> _selectedCategory;

  @override
  void initState() {
    if (widget.currentCategory != null) {
      _selectedCategory = categories
          .firstWhere((element) => element['value'] == widget.currentCategory);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: SizedBox(
          height: 450,
          width: size.width * 2 / 3,
          child:
          Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 15, bottom: 10),
            child: Text("Kategoria",
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .copyWith(fontSize: 20.0)),
          ),
          Divider(),
          SizedBox(
            height: 320.0,
            width: size.width * 2 / 3,
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (BuildContext context, int index) {
                return RadioListTile(
                  title: Text(categories[index]['text']),
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
              TextButton(
                  child: Text("Anuluj",
                      style: Theme.of(context).textTheme.headline5),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              TextButton(
                  child: Text("OK", style: Theme.of(context).textTheme.headline5),
                  onPressed: () {
                    Navigator.pop(context, _selectedCategory);
                  }),
            ],
          ),
        ],
      )),
    );
  }
}