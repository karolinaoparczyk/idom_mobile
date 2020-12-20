import 'package:flutter/material.dart';
import 'package:idom/enums/languages.dart';
import 'package:idom/localization/dialogs/language.i18n.dart';

class LanguageDialog extends StatefulWidget {
  final String currentLanguage;

  LanguageDialog({this.currentLanguage});

  @override
  _LanguageDialogState createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  Map<String, String> _selectedLanguage;

  @override
  void initState() {

    if (widget.currentLanguage != null) {
      _selectedLanguage = Languages.values
          .firstWhere((element) => element['value'] == widget.currentLanguage);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 15, bottom: 10),
                child: Text("Wybierz język powiadomień".i18n,
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        .copyWith(fontSize: 21.0)),
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  key: Key("languagesList"),
                  itemCount: Languages.values.length,
                  itemBuilder: (BuildContext context, int index) {
                    return RadioListTile(
                     title: Text(Languages.values[index]['text'].i18n,
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.normal, fontSize: 21.0)),
                      value: Languages.values[index],
                      groupValue: _selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value;
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
                      key: Key('yesButton'),
                      child: Text("OK",
                          style: Theme.of(context).textTheme.headline5),
                      onPressed: () {
                        Navigator.pop(context, _selectedLanguage);
                      }),
                ],
              ),
            ],
          )),
    );
  }
}
