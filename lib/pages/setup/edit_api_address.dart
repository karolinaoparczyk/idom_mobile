import 'package:flutter/material.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';

import 'package:idom/dialogs/protocol_dialog.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';

/// allows to enter email and send reset password request
class EditApiAddress extends StatefulWidget {
  EditApiAddress({@required this.storage});

  final SecureStorage storage;

  @override
  _EditApiAddressState createState() => _EditApiAddressState();
}

class _EditApiAddressState extends State<EditApiAddress> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _apiAddressController = TextEditingController();
  TextEditingController _apiAddressProtocolController = TextEditingController();
  TextEditingController _apiAddressPortController = TextEditingController();
  String currentAddress;
  String currentAddressProtocol;
  String currentAddressPort;
  FocusNode _apiAddressFocusNode = FocusNode();
  bool _load;
  String _isUserLoggedIn;

  void initState() {
    super.initState();
    _load = true;
    getApiAddress();
    checkIfUserIsSignedIn();
  }

  Future<void> getApiAddress() async {
    currentAddressProtocol = await widget.storage.getApiServerAddressProtocol();
    currentAddress = await widget.storage.getApiServerAddress();
    currentAddressPort = await widget.storage.getApiServerAddressPort();
    _apiAddressProtocolController =
        TextEditingController(text: currentAddressProtocol ?? "");
    _apiAddressController = TextEditingController(text: currentAddress ?? "");
    _apiAddressPortController =
        TextEditingController(text: currentAddressPort ?? "");
    _load = false;
    setState(() {});
  }

  Future<void> checkIfUserIsSignedIn() async {
    _isUserLoggedIn = await widget.storage.getIsLoggedIn();
    setState(() {});
  }

  /// build api address protocol field
  Widget _buildApiAddressProtocol() {
    return TextFormField(
        key: Key("apiAddressProtocol"),
        controller: _apiAddressProtocolController,
        decoration: InputDecoration(
          labelText: "Protokół",
          labelStyle: Theme.of(context).textTheme.headline5,
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
          labelStyle: Theme.of(context).textTheme.headline5,
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
          labelStyle: Theme.of(context).textTheme.headline5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        style: TextStyle(fontSize: 21.0),
        validator: PortFieldValidator.validate);
  }

  Future<bool> _onBackButton() async {
    Navigator.pop(context, false);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackButton,
        child: Scaffold(
            appBar: AppBar(title: Text('Adres serwera'), actions: [
              IconButton(icon: Icon(Icons.save), onPressed: _verifyChanges)
            ]),
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
                          ]),
                  )),
              Expanded(flex: 1, child: SizedBox(width: 1)),
            ])));
  }

  /// verifies data changes
  _verifyChanges() async {
    var protocol = _apiAddressProtocolController.text;
    var address = _apiAddressController.text;
    var port = _apiAddressPortController.text;
    var changedProtocol = false;
    var changedAddress = false;
    var changedPort = false;

    final formState = _formKey.currentState;
    if (formState.validate()) {
      /// sends request only if data has changed
      if (protocol != currentAddressProtocol) {
        changedProtocol = true;
      }
      if (address != currentAddress) {
        changedAddress = true;
      }
      if (port != currentAddressPort) {
        changedPort = true;
      }
      if (changedProtocol || changedAddress || changedPort) {
        await _confirmSavingChanges(
            changedProtocol, changedAddress, changedPort);
      } else {
        final snackBar =
            new SnackBar(content: new Text("Nie wprowadzono żadnych zmian."));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
    }
  }

  /// confirms saving api address changes
  _confirmSavingChanges(
      bool changedProtocol, bool changedAddress, bool changedPort) async {
    await confirmActionDialog(
      context,
      "Potwierdź",
      "Czy na pewno zapisać zmiany?",
      () async {
        await _saveChanges(changedProtocol, changedAddress, changedPort);
      },
    );
  }

  /// sets api address
  _saveChanges(
      bool changedProtocol, bool changedAddress, bool changedPort) async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      if (changedProtocol)
        widget.storage
            .setApiServerAddressProtocol(_apiAddressProtocolController.text);
      if (changedAddress)
        widget.storage.setApiServerAddress(_apiAddressController.text);
      if (changedPort)
        widget.storage.setApiServerAddressPort(_apiAddressPortController.text);
      if (_isUserLoggedIn == "true") {
        final snackBar = new SnackBar(
            content: new Text("Adres serwera został zapisany."),
            duration: Duration(seconds: 2));
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
      }
      Navigator.pop(context, true);
    }
  }
}
