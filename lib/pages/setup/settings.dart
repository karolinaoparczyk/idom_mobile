import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';

import 'package:idom/localization/setup/settings.i18n.dart';
import 'package:idom/push_notifications.dart';
import 'package:idom/utils/app_state_notifier.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/utils/validators.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
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
  List<bool> selectedMode = List<bool>();

  void initState() {
    super.initState();
    _load = true;
    getThemeMode();
    getApiAddress();
    getFirebaseParams();
    checkIfUserIsSignedIn();
  }

  Future<void> getThemeMode() async {
    bool isDarkMode = await DarkMode.getStorageThemeMode();
    selectedMode.add(!isDarkMode ? true : false);
    selectedMode.add(isDarkMode ? true : false);
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
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).textTheme.bodyText2.color),
              borderRadius: BorderRadius.circular(10.0)),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).textTheme.bodyText2.color),
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Adres serwera".i18n,
          labelStyle: Theme.of(context).textTheme.headline5,
          prefixText: "https://",
          prefixStyle: Theme.of(context).textTheme.bodyText2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          suffixIcon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("/api", style: Theme.of(context).textTheme.bodyText2),
            ],
          ),
        ),
        style: Theme.of(context).textTheme.bodyText2,
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
          appBar: AppBar(title: Text('Ustawienia'.i18n), actions: [
            IconButton(icon: Icon(Icons.save), onPressed: _verifyChanges)
          ]),
          drawer: _isUserLoggedIn == "true"
              ? IdomDrawer(
                  storage: widget.storage,
                  parentWidgetType: "EditApiAddress",
                  onLogOutFailure: onLogOutFailure)
              : null,
          body: _load
              ? loadingIndicator(true)
              : Column(children: <Widget>[
                  Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 30.0,
                                      top: 20.0,
                                      right: 30.0,
                                      bottom: 10.0),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Icon(Icons.settings, size: 21),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Text("Konfiguracja".i18n,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1),
                                          ),
                                        ],
                                      ))),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 62.0,
                                    top: 0.0,
                                    right: 62.0,
                                    bottom: 0.0),
                                child: _buildApiAddress(),
                              ),
                              if (_isUserLoggedIn == "true")
                                SizedBox(height: 20.0),
                              if (_isUserLoggedIn == "true")
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 62.0,
                                      top: 0.0,
                                      right: 62.0,
                                      bottom: 0.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Plik google_services.json".i18n,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      ),
                                    ],
                                  ),
                                ),
                              if (_isUserLoggedIn == "true" &&
                                      currentFirebaseParams != null &&
                                      currentFirebaseParams['fileName'] !=
                                          null ||
                                  file != null)
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 62.0,
                                      top: 0.0,
                                      right: 62.0,
                                      bottom: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                            file == null
                                                ? currentFirebaseParams[
                                                    'fileName']
                                                : file.path.split("/").last,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2),
                                      ),
                                      SizedBox.fromSize(
                                          size: Size(21, 21),
                                          child: ClipOval(
                                              child: Material(
                                                  color: Theme.of(context)
                                                      .backgroundColor,
                                                  child: InkWell(
                                                    child: SvgPicture.asset(
                                                        "assets/icons/minus.svg",
                                                        matchTextDirection:
                                                            false,
                                                        width: 21,
                                                        height: 21,
                                                        color: IdomColors.error,
                                                        key: Key(
                                                            "deleteSensor")),
                                                    onTap: () {
                                                      setState(() {
                                                        file = null;
                                                        fieldsValidationMessage =
                                                            null;
                                                        currentFirebaseParams =
                                                            null;
                                                      });
                                                    },
                                                  ))))
                                    ],
                                  ),
                                ),
                              if (_isUserLoggedIn == "true" &&
                                  (currentFirebaseParams == null ||
                                      currentFirebaseParams['fileName'] ==
                                          null) &&
                                  file == null)
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 62.0,
                                      top: 0.0,
                                      right: 62.0,
                                      bottom: 0.0),
                                  child: Row(
                                    children: [
                                      SizedBox.fromSize(
                                          size: Size(36, 36),
                                          child: ClipOval(
                                            child: Material(
                                              color: Theme.of(context)
                                                  .backgroundColor,
                                              child: InkWell(
                                                child: Icon(
                                                    Icons
                                                        .add_circle_outline_rounded,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2
                                                        .color),
                                                onTap: _pickFile,
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              if (_isUserLoggedIn == "true")
                                AnimatedCrossFade(
                                  crossFadeState:
                                      fieldsValidationMessage != null
                                          ? CrossFadeState.showFirst
                                          : CrossFadeState.showSecond,
                                  duration: Duration(milliseconds: 300),
                                  firstChild: fieldsValidationMessage != null
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              left: 62.0,
                                              top: 10.0,
                                              right: 62.0,
                                              bottom: 10.0),
                                          child: Text(fieldsValidationMessage,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1),
                                        )
                                      : SizedBox(),
                                  secondChild: SizedBox(),
                                ),
                              if (_isUserLoggedIn == "true") Divider(),
                              if (_isUserLoggedIn == "true")
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 30.0,
                                        top: 10.0,
                                        right: 30.0,
                                        bottom: 10.0),
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            Icon(Icons.brightness_4_outlined,
                                                size: 21),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: Text("Motyw".i18n,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1),
                                            ),
                                          ],
                                        ))),
                              if (_isUserLoggedIn == "true")
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 30.0,
                                      top: 0.0,
                                      right: 30.0,
                                      bottom: 10.0),
                                  child: ToggleButtons(
                                    borderRadius: BorderRadius.circular(30),
                                    borderColor: IdomColors.additionalColor,
                                    splashColor: Colors.transparent,
                                    fillColor: IdomColors.lighten(
                                        IdomColors.additionalColor, 0.2),
                                    selectedColor: IdomColors.blackTextLight,
                                    children: [
                                      Container(
                                        width: 60,
                                        child: Text("jasny".i18n,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1
                                                .copyWith(
                                                    color: selectedMode[0]
                                                        ? IdomColors
                                                            .whiteTextDark
                                                        : Theme.of(context)
                                                            .textTheme
                                                            .bodyText1
                                                            .color)),
                                      ),
                                      Container(
                                        width: 60,
                                        child: Text("ciemny".i18n,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1
                                                .copyWith(
                                                    color: selectedMode[1]
                                                        ? IdomColors
                                                            .whiteTextDark
                                                        : Theme.of(context)
                                                            .textTheme
                                                            .bodyText1
                                                            .color)),
                                      )
                                    ],
                                    isSelected: selectedMode,
                                    onPressed: (int index) async {
                                      if (selectedMode[index] == false) {
                                        var theme =
                                            index == 0 ? "light" : "dark";
                                        await DarkMode.setStorageThemeMode(
                                            theme);
                                        setState(() {
                                          Provider.of<AppStateNotifier>(context,
                                                  listen: false)
                                              .updateTheme();
                                          selectedMode[0] = !selectedMode[0];
                                          selectedMode[1] = !selectedMode[1];
                                        });
                                      }
                                    },
                                  ),
                                ),
                              if (_isUserLoggedIn == "true") Divider(),
                              if (_isUserLoggedIn == "true")
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 30.0,
                                        top: 10.0,
                                        right: 30.0,
                                        bottom: 10.0),
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            Icon(Icons.data_usage, size: 21),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: Text("Dane".i18n,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1),
                                            ),
                                          ],
                                        ))),
                              if (_isUserLoggedIn == "true")
                                Container(
                                    alignment: Alignment.center,
                                    height: 30,
                                    child: FlatButton(
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text("Jak mogę usunąć dane?".i18n,
                                                  key: Key("deleteData"),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline5),
                                              Icon(Icons.arrow_right,
                                                  color: IdomColors
                                                      .additionalColor)
                                            ]),
                                        onPressed: () async {
                                          _navigateToProjectWebPage();
                                        })),
                            ],
                          ),
                        ),
                      )),
                ]),
        ));
  }

  _navigateToProjectWebPage() async {
    try {
      await launch("https://adriannajmrocki.github.io/idom-website/");
    } catch (e) {
      throw 'Could not launch page';
    }
  }

  _pickFile() async {
    File result = await FilePicker.getFile(type: FileType.custom);
    if (result != null) {
      file = File(result.path);
      try {
        final Map<String, dynamic> googleServicesJson =
            jsonDecode(file.readAsStringSync());
        firebaseUrl = googleServicesJson['project_info']['firebase_url'];
        storageBucket = googleServicesJson['project_info']['storage_bucket'];
        mobileAppId =
            googleServicesJson['client'][0]['client_info']['mobilesdk_app_id'];
        apiKey = googleServicesJson['client'][0]['api_key'][0]['current_key'];
        fieldsValidationMessage = null;
      } catch (e) {
        fieldsValidationMessage =
            "Plik jest niepoprawny. Pobierz go z serwisu Firebase i spróbuj ponownie."
                .i18n;
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
    if (formState.validate()) {
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
        final snackBar = new SnackBar(
            content: new Text("Nie wprowadzono żadnych zmian.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }

  /// confirms saving api address changes
  _confirmSavingChanges(bool changedProtocol, bool changedAddress,
      bool changedPort, bool changedGoogleServicesFile) async {
    var decision = await confirmActionDialog(
        context, "Potwierdź".i18n, "Czy na pewno zapisać zmiany?".i18n);
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
        displayProgressDialog(
            context: context,
            key: _keyLoader,
            text: "Zapisywanie ustawień...".i18n);
        var result = await _createSensorsNotificationsChannel();
        if (result) {
          var tokenSent = await sendDeviceToken();
          Navigator.pop(context);
          if (!tokenSent) {
            final snackBar = new SnackBar(
                content: new Text(
                    "Nie udało się połączyć z serwisem firebase. Sprawdź czy plik google_services.json jest aktualny oraz połączenie z internetem."
                        .i18n),
                duration: Duration(seconds: 4));
            _scaffoldKey.currentState.showSnackBar((snackBar));
            return;
          }
        } else {
          Navigator.pop(context);
          final snackBar = new SnackBar(
              content: new Text(
                  "Nie udało się wygenerować tokenu. Spróbuj ponownie.".i18n),
              duration: Duration(seconds: 2));
          _scaffoldKey.currentState.showSnackBar((snackBar));
          return;
        }
      }
      if (_isUserLoggedIn == "true") {
        final snackBar = new SnackBar(
            content: new Text("Ustawienia zostały zapisane.".i18n),
            duration: Duration(seconds: 2));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      } else {
        Navigator.pop(context, true);
      }
    }
  }

  Future<bool> _createSensorsNotificationsChannel() async {
    channelMap["firebaseUrl"] = firebaseUrl;
    channelMap["storageBucket"] = storageBucket;
    channelMap["mobileAppId"] = mobileAppId;
    channelMap["apiKey"] = apiKey;
    try {
      await _channel.invokeMethod('createNotificationChannel', channelMap);
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  Future<bool> sendDeviceToken() async {
    final pushNotificationsManager = PushNotificationsManager();
    await pushNotificationsManager.init();
    if (pushNotificationsManager.deviceToken == null) {
      return false;
    }
    var deviceResponse =
        await api.checkIfDeviceTokenSent(pushNotificationsManager.deviceToken);
    if (deviceResponse != null && deviceResponse['statusCode'] != "200") {
      var tokenResponse =
          await api.sendDeviceToken(pushNotificationsManager.deviceToken);
      if (tokenResponse != null && tokenResponse['statusCode'] == "201") {
        print("Device token sent successfully");
        return true;
      } else {
        print("Error while sending device token.");
        return false;
      }
    }
  }
}
