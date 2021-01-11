import 'package:flutter/material.dart';
import 'package:idom/enums/languages.dart';
import 'package:idom/localization/dialogs/language.i18n.dart';

/// pop-up dialog for selecting notifications language
class LanguageDialog extends StatefulWidget {
  /// currently selected language
  final String currentLanguage;

  LanguageDialog({this.currentLanguage});

  /// handles state of widgets
  @override
  _LanguageDialogState createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  Map<String, String> _selectedLanguage;

  @override
  void initState() {
    if (widget.currentLanguage != null) {
      /// loads allowed languages
      _selectedLanguage = Languages.values
          .firstWhere((element) => element['value'] == widget.currentLanguage);
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
                    /// allows selecting only one language
                    return RadioListTile(
                      title: Text(Languages.values[index]['text'].i18n,
                          style: Theme.of(context).textTheme.bodyText2),
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
                  /// cancel action
                  TextButton(
                      child: Text("Anuluj",
                          style: Theme.of(context).textTheme.headline5),
                      onPressed: () {
                        Navigator.pop(context);
                      }),

                  /// confirm action
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
