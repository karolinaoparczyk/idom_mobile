import 'dart:io';

import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/material.dart';

import 'package:idom/api.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/dialog.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/widgets/text_color.dart';

/// allows to enter email and send reset password request
class EditApiAddress extends StatefulWidget {
  EditApiAddress(
      {@required this.api, @required this.onSignedOut, this.apiAddress});

  Api api;
  VoidCallback onSignedOut;
  String apiAddress;

  @override
  _EditApiAddressState createState() => _EditApiAddressState();
}

class _EditApiAddressState extends State<EditApiAddress> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _apiAddressController = TextEditingController();
  bool _load;

  void initState() {
    super.initState();
//    if (widget.api == null) {
//      widget.api = Api();
//    }
    _load = false;
    if (widget.apiAddress != null) {
      _apiAddressController = TextEditingController(text: widget.api.url);
    } else
      _apiAddressController = TextEditingController(text: "http://");
  }

  /// build api address form field
  Widget _buildApiAddress() {
    return TextFormField(
        key: Key("apiAddress"),
        controller: _apiAddressController,
        autofocus: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Podaj adres serwera",
        ),
        style: TextStyle(fontSize: 17.0),
        validator: UrlFieldValidator.validate);
  }

  Future<bool> _onBackButton() async {
    Map<String, dynamic> result = {
      'onSignedOut': widget.onSignedOut,
      'dataSaved': false
    };
    Navigator.of(context).pop(result);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackButton,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Adres serwera'),
            ),
            body: Row(children: <Widget>[
              Expanded(flex: 1, child: SizedBox(width: 1)),
              Expanded(
                  flex: 30,
                  child: Column(children: <Widget>[
                    Expanded(
                        flex: 3,
                        child: Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                Align(
                                  child: loadingIndicator(_load),
                                  alignment: FractionalOffset.center,
                                ),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 30.0,
                                        top: 33.5,
                                        right: 30.0,
                                        bottom: 0.0),
                                    child: Text("Wprowadź adres serwera",
                                        style: TextStyle(fontSize: 13.5))),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 30.0,
                                        top: 33.5,
                                        right: 30.0,
                                        bottom: 0.0),
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("Adres serwera*",
                                            style: TextStyle(
                                                color: textColor,
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.bold)))),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 30.0,
                                        top: 0.0,
                                        right: 30.0,
                                        bottom: 0.0),
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: _buildApiAddress())),
                              ],
                            ))),
                    Expanded(
                        flex: 1,
                        child: AnimatedContainer(
                            curve: Curves.easeInToLinear,
                            duration: Duration(
                              milliseconds: 10,
                            ),
                            alignment: Alignment.bottomCenter,
                            child: Column(children: <Widget>[
                              buttonWidget(
                                  context, "Zapisz adres", setApiAddress)
                            ])))
                  ])),
              Expanded(flex: 1, child: SizedBox(width: 1)),
            ])));
  }

  /// sets api address
  setApiAddress() async {
    try {
      final formState = _formKey.currentState;
      if (formState.validate()) {
        setState(() {
          _load = true;
        });

        final directory = await DownloadsPathProvider.downloadsDirectory;
        final path = '${directory.path}/serverAddress.txt';
        final file = File(path);
        await file.writeAsString(_apiAddressController.text);

        setState(() {
          _load = false;
        });
        Map<String, dynamic> result = {
          'onSignedOut': widget.onSignedOut,
          'dataSaved': true
        };
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _load = false;
      });
      if (e.toString().contains("TimeoutException")) {
        displayDialog(
            context: context,
            title: "Błąd zapisu adresu serwera",
            text: "Spróbuj ponownie.");
      }
    }
  }
}
