import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';

import 'package:idom/push_notifications.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';

/// allows to enter email and send reset password request
class Settings extends StatefulWidget {
  Settings({@required this.storage});

  final SecureStorage storage;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Api api = Api();
  TextEditingController _apiAddressController = TextEditingController();
  String currentAddress;
  FocusNode _apiAddressFocusNode = FocusNode();
  bool _load;
  String _isUserLoggedIn;
  String firebaseUrl;
  String storageBucket;
  String mobileAppId;
  String apiKey;
  File file;
  String fieldsValidationMessage;
  Map<String, String> currentFirebaseParams;
  static const MethodChannel _channel =
      MethodChannel('flutter.idom/notifications');
  Map<String, String> channelMap = {
    "id": "SENSORS_NOTIFICATIONS",
    "name": "Sensors",
    "description": "Sensors notifications",
  };

  void initState() {
    super.initState();
    _load = true;
    getApiAddress();
    getFirebaseParams();
    checkIfUserIsSignedIn();
  }

  Future<void> getApiAddress() async {
    currentAddress = await widget.storage.getApiServerAddress();
    _apiAddressController = TextEditingController(text: currentAddress ?? "");
    _load = false;
    setState(() {});
  }

  Future<void> getFirebaseParams() async {
    currentFirebaseParams = await widget.storage.getFirebaseParams();
    setState(() {});
  }

  Future<void> checkIfUserIsSignedIn() async {
    _isUserLoggedIn = await widget.storage.getIsLoggedIn();
    setState(() {});
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
          prefixText: "https://",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        style: TextStyle(fontSize: 21.0),
        validator: UrlFieldValidator.validate);
  }

  onLogOutFailure(String text) {
    final snackBar = new SnackBar(content: new Text(text));
    _scaffoldKey.currentState.showSnackBar((snackBar));
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
            key: _scaffoldKey,
            appBar: AppBar(title: Text('Ustawienia'), actions: [
              IconButton(icon: Icon(Icons.save), onPressed: _verifyChanges)
            ]),
            drawer: _isUserLoggedIn == "true"
                ? IdomDrawer(
                    storage: widget.storage,
                    parentWidgetType: "EditApiAddress",
                    onLogOutFailure: onLogOutFailure)
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
                                child: SingleChildScrollView(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        _buildApiAddress(),
                                        if (_isUserLoggedIn == "true")
                                          SizedBox(height: 20.0),
                                        if (_isUserLoggedIn == "true")
                                          Row(
                                            children: [
                                              Text(
                                                "Plik google_services.json",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline5,
                                              ),
                                            ],
                                          ),
                                        if (_isUserLoggedIn == "true" &&
                                                currentFirebaseParams != null &&
                                                currentFirebaseParams[
                                                        'fileName'] !=
                                                    null ||
                                            file != null)
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                    file == null
                                                        ? currentFirebaseParams[
                                                            'fileName']
                                                        : file.path
                                                            .split("/")
                                                            .last,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        .copyWith(
                                                            fontWeight: FontWeight
                                                                .normal)),
                                              ),
                                              SizedBox(width: 30),
                                              IconButton(
                                                icon: Icon(Icons
                                                    .remove_circle_outline),
                                                color: IdomColors.error,
                                                onPressed: () {
                                                  setState(() {
                                                    file = null;
                                                    fieldsValidationMessage =
                                                        null;
                                                    currentFirebaseParams =
                                                        null;
                                                  });
                                                },
                                              )
                                            ],
                                          ),
                                        if (_isUserLoggedIn == "true" &&
                                            (currentFirebaseParams == null ||
                                                currentFirebaseParams[
                                                        'fileName'] ==
                                                    null) &&
                                            file == null)
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                    Icons
                                                        .add_circle_outline_rounded,
                                                    color: IdomColors.textDark),
                                                onPressed: _pickFile,
                                              ),
                                            ],
                                          ),
                                        if (_isUserLoggedIn == "true")
                                          SizedBox(width: 50),
                                        if (_isUserLoggedIn == "true")
                                          AnimatedCrossFade(
                                            crossFadeState:
                                                fieldsValidationMessage != null
                                                    ? CrossFadeState.showFirst
                                                    : CrossFadeState.showSecond,
                                            duration:
                                                Duration(milliseconds: 300),
                                            firstChild:
                                                fieldsValidationMessage != null
                                                    ? Text(
                                                        fieldsValidationMessage,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal))
                                                    : SizedBox(),
                                            secondChild: SizedBox(),
                                          ),
                                      ],
                                    ),
                                  ),
                                )),
                          ]),
                  )),
              Expanded(flex: 1, child: SizedBox(width: 1)),
            ])));
  }

  _pickFile() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.custom);
    if (result != null) {
      file = File(result.files.single.path);
      try {
        final Map<String, dynamic> googleServicesJson =
            jsonDecode(file.readAsStringSync());
        firebaseUrl = googleServicesJson['project_info']['firebase_url'];
        storageBucket = googleServicesJson['project_info']['storage_bucket'];
        mobileAppId =
            googleServicesJson['client'][0]['client_info']['mobilesdk_app_id'];
        apiKey = googleServicesJson['client'][0]['api_key'][0]['current_key'];
      } catch (e) {
        fieldsValidationMessage =
            "Plik jest niepoprawny. Pobierz go z serwisu Firebase i spróbuj ponownie.";
      }
    }
    setState(() {});
  }

  /// verifies data changes
  _verifyChanges() async {
    var address = _apiAddressController.text;
    var changedProtocol = false;
    var changedAddress = false;
    var changedPort = false;
    var changedGoogleServicesFile = false;

    final formState = _formKey.currentState;
    var formValidated = formState.validate();
    if (_isUserLoggedIn == "true" &&
        file == null &&
        (currentFirebaseParams == null ||
            currentFirebaseParams['fileName'] == null)) {
      fieldsValidationMessage = "Należy dodać plik.";
      setState(() {});
      return;
    }
    if (formValidated) {
      /// sends request only if data has changed
      if (address != currentAddress) {
        changedAddress = true;
      }
      if (file != null) {
        changedGoogleServicesFile = true;
      }
      if (changedProtocol ||
          changedAddress ||
          changedPort ||
          changedGoogleServicesFile) {
        await _confirmSavingChanges(changedProtocol, changedAddress,
            changedPort, changedGoogleServicesFile);
      } else {
        final snackBar =
            new SnackBar(content: new Text("Nie wprowadzono żadnych zmian."));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }

  /// confirms saving api address changes
  _confirmSavingChanges(bool changedProtocol, bool changedAddress,
      bool changedPort, bool changedGoogleServicesFile) async {
    var decision = await confirmActionDialog(
        context, "Potwierdź", "Czy na pewno zapisać zmiany?");
    if (decision) {
      await _saveChanges(changedProtocol, changedAddress, changedPort,
          changedGoogleServicesFile);
    }
  }

  /// sets api address
  _saveChanges(bool changedProtocol, bool changedAddress, bool changedPort,
      bool changedFirebaseParams) async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      if (changedAddress)
        widget.storage.setApiServerAddress(_apiAddressController.text);
      if (changedFirebaseParams) {
        widget.storage.setFirebaseParams(firebaseUrl, storageBucket,
            mobileAppId, apiKey, file.path.split("/").last);
        await _createSensorsNotificationsChannel();
        await sendDeviceToken();
      }
      if (_isUserLoggedIn == "true") {
        final snackBar = new SnackBar(
            content: new Text("Ustawienia zostały zapisane."),
            duration: Duration(seconds: 2));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      } else {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _createSensorsNotificationsChannel() async {
    channelMap["firebaseUrl"] = firebaseUrl;
    channelMap["storageBucket"] = storageBucket;
    channelMap["mobileAppId"] = mobileAppId;
    channelMap["apiKey"] = apiKey;
    try {
      await _channel.invokeMethod('createNotificationChannel', channelMap);
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> sendDeviceToken() async {
    final pushNotificationsManager = PushNotificationsManager();
    await pushNotificationsManager.init();
    var deviceResponse =
        await api.checkIfDeviceTokenSent(pushNotificationsManager.deviceToken);
    if (deviceResponse != null && deviceResponse['statusCode'] != "200") {
      var tokenResponse =
          await api.sendDeviceToken(pushNotificationsManager.deviceToken);
      if (tokenResponse != null && tokenResponse['statusCode'] == "201")
        print("Device token sent successfully");
      else {
        print("Error while sending device token.");
      }
    }
  }
}
