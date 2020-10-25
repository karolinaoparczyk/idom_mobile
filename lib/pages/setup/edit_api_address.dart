import 'dart:io';

import 'package:flutter/material.dart';

import 'package:idom/dialogs/protocol_dialog.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/button.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:idom/widgets/text_color.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  TextEditingController _apiAddressProtocolController = TextEditingController();
  TextEditingController _apiAddressPortController = TextEditingController();
  FocusNode _apiAddressFocusNode = FocusNode();
  bool _load;

  void initState() {
    super.initState();
    _load = true;
    getApiAddress();
  }

  Future<void> getApiAddress() async {
    var _apiAddressProtocol =
        await widget.storage.getApiServerAddressProtocol();
    var _apiAddress = await widget.storage.getApiServerAddress();
    var _apiAddressPort = await widget.storage.getApiServerAddressPort();
    _apiAddressProtocolController =
        TextEditingController(text: _apiAddressProtocol ?? "");
    _apiAddressController = TextEditingController(text: _apiAddress ?? "");
    _apiAddressPortController =
        TextEditingController(text: _apiAddressPort ?? "");
    _load = false;
    setState(() {});
  }

  /// build api address protocol field
  Widget _buildApiAddressProtocol() {
    return TextFormField(
        key: Key("apiAddressProtocol"),
        controller: _apiAddressProtocolController,
        decoration: InputDecoration(
          labelText: "Protokół",
          labelStyle: Theme
              .of(context)
              .textTheme
              .headline5,
          suffixIcon: Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onTap: () async {
          final String selectedProtocol = await showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: ProtocolDialog(_apiAddressProtocolController.text),
                );
              });
          if (selectedProtocol != null) {
            _apiAddressProtocolController.text = selectedProtocol;
          }
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        readOnly: true,
        style: TextStyle(fontSize: 21.0),
        validator: UrlFieldValidator.validate);
  }

  /// build api address form field
  Widget _buildApiAddress() {
    return TextFormField(
        key: Key("apiAddress"),
        controller: _apiAddressController,
        focusNode: _apiAddressFocusNode,
        decoration: InputDecoration(
          labelText: "Adres serwera",
          labelStyle: Theme
              .of(context)
              .textTheme
              .headline5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        style: TextStyle(fontSize: 21.0),
        validator: UrlFieldValidator.validate);
  }

  /// build api address port form field
  Widget _buildApiAddressPort() {
    return TextFormField(
        key: Key("apiAddressPort"),
        controller: _apiAddressPortController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: "Port",
          labelStyle: Theme
              .of(context)
              .textTheme
              .headline5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        style: TextStyle(fontSize: 21.0),
        validator: PortFieldValidator.validate);
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
            drawer: _isUserLoggedIn == "true"
                ? IdomDrawer(
                storage: widget.storage, parentWidgetType: "EditApiAddress")
                : null,
            body: Row(children: <Widget>[
              Expanded(flex: 1, child: SizedBox(width: 1)),
              Expanded(
                  flex: 30,
                  child: Padding(
                    padding:
                    const EdgeInsets.only(left: 13.5, top: 30, right: 13.5),
                    child: _load
                        ? loadingIndicator(true)
                        : Column(children: <Widget>[
                      Expanded(
                          flex: 3,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildApiAddressProtocol(),
                                SizedBox(height: 20.0),
                                _buildApiAddress(),
                                SizedBox(height: 20.0),
                                _buildApiAddressPort(),
                              ],
                            ),
                          )),
                      Expanded(
                          flex: 1,
                          child: AnimatedContainer(
                              curve: Curves.easeInToLinear,
                              duration: Duration(
                                milliseconds: 10,
                              ),
                              alignment: Alignment.bottomCenter,
                              child: Column(children: <Widget>[
                                buttonWidget(context, "Zapisz adres",
                                    setApiAddress)
                              ])))
                    ]),
                  )),
              Expanded(flex: 1, child: SizedBox(width: 1)),
            ])));
  }

  /// sets api address
  setApiAddress() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      widget.storage
          .setApiServerAddressProtocol(_apiAddressProtocolController.text);
      widget.storage.setApiServerAddress(_apiAddressController.text);
      widget.storage.setApiServerAddressPort(_apiAddressPortController.text);
      Navigator.pop(context, true);
    }
  }
}
