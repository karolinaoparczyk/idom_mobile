import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:idom/api.dart';
import 'package:idom/utils/app_state_notifier.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/localization/widgets/hard_reset.i18n.dart';

class HardReset extends StatefulWidget {
  HardReset({@required this.storage, this.testApi});

  final SecureStorage storage;
  final Api testApi;

  @override
  State createState() {
    return _HardResetState();
  }
}

class _HardResetState extends State<HardReset> {
  String hardReset = "";

  @override
  void initState() {
    super.initState();
    _initHardReset();
  }

  Future<void> _initHardReset() async {
    bool isDarkMode = await DarkMode.getStorageThemeMode(testStorage: widget.storage);
    String hardReset;
    if (isDarkMode) {
      hardReset = await rootBundle.loadString('assets/hard-reset-dark.html');
    } else {
      hardReset = await rootBundle.loadString('assets/hard-reset.html');
    }

    setState(() {
      this.hardReset = hardReset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Usuwanie danych'.i18n)),
      drawer: IdomDrawer(
          storage: widget.storage,
          testApi: widget.testApi,
          parentWidgetType: "DataRemoval"),
      body: ListView(shrinkWrap: true, children: [
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: HtmlWidget(
            hardReset,
          ),
        ),
      ]),
    );
  }
}
