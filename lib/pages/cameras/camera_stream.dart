import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/cameras/edit_camera.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/widgets/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:idom/localization/cameras/camera_stream.i18n.dart';

class CameraStream extends StatefulWidget {
  CameraStream({@required this.storage, @required this.camera, this.testApi});

  final SecureStorage storage;
  Camera camera;
  final Api testApi;

  @override
  _CameraStreamState createState() => _CameraStreamState();
}

class _CameraStreamState extends State<CameraStream> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  Api api = Api();
  bool _loading;
  String apiURL;
  bool _load;

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }
    _loading = true;
    _load = false;
    getApiURL();
  }

  Future<void> getApiURL() async {
    apiURL = "https://" + await widget.storage.getApiServerAddress();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(
            context)
            .backgroundColor,
        key: _scaffoldKey,
        appBar: AppBar(title: Text(widget.camera.name), actions: [
          IconButton(
              key: Key("editCameraButton"),
              icon: Icon(Icons.edit),
              onPressed: _navigateToEditCamera)
        ]),
        drawer: IdomDrawer(
            storage: widget.storage,
            parentWidgetType: "Camera",
            onLogOutFailure: onLogOutFailure),
        body: Column(
          children: [
            Align(
              child: loadingIndicator(_load),
              alignment: FractionalOffset.center,
            ),
            Container(
                padding: EdgeInsets.only(top: 10),
                alignment: Alignment.center,
                height: 30,
                child: FlatButton(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Otwórz w przeglądarce".i18n,
                              key: Key("goToBrowser"),
                              style: Theme.of(context).textTheme.headline5),
                          Icon(Icons.arrow_right,
                              color: IdomColors.additionalColor)
                        ]),
                    onPressed: () async {
                      if (apiURL != null) {
                        try {
                          await launch(apiURL +
                              '/cameras/stream/' +
                              widget.camera.id.toString());
                        } catch (e) {
                          throw 'Could not launch page';
                        }
                      }
                    })),
            if (_loading)
              SizedBox(
                  height: 30, width: 30, child: CircularProgressIndicator()),
            Expanded(
                child: Container(
                    padding: EdgeInsets.all(20.0),
                    width: MediaQuery.of(context).size.width,
                    child: apiURL != null
                        ? InAppWebView(
                            initialUrl: apiURL +
                                '/cameras/stream/' +
                                widget.camera.id.toString(),
                            initialOptions: InAppWebViewGroupOptions(
                              crossPlatform: InAppWebViewOptions(
                                  debuggingEnabled: true,
                                  preferredContentMode:
                                      MediaQuery.of(context).size.width <= 600
                                          ? UserPreferredContentMode.DESKTOP
                                          : UserPreferredContentMode.MOBILE),
                            ),
                            onWebViewCreated:
                                (InAppWebViewController webViewController) {
                              _loading = false;
                              setState(() {});
                            },
                          )
                        : SizedBox()))
          ],
        ),
      ),
    );
  }

  onLogOutFailure(String text) {
    final snackBar = new SnackBar(content: new Text(text));
    _scaffoldKey.currentState.showSnackBar((snackBar));
  }

  _navigateToEditCamera() async {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditCamera(
                  storage: widget.storage,
                  camera: widget.camera,
                  testApi: widget.testApi,
                ),
            fullscreenDialog: true));
    if (result == true) {
      final snackBar = new SnackBar(content: new Text("Zapisano kamere.".i18n));
      _scaffoldKey.currentState.showSnackBar((snackBar));
      await _refreshSensorDetails();
    }
  }

  _refreshSensorDetails() async {
    try {
      setState(() {
        _load = true;
      });
      var res = await api.getCameraDetails(widget.camera.id);
      setState(() {
        _load = false;
      });
      if (res['statusCode'] == "200") {
        dynamic body = jsonDecode(res['body']);
        Camera refreshedCamera = Camera.fromJson(body);
        setState(() {
          widget.camera = refreshedCamera;
        });
      } else if (res['statusCode'] == "401") {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoader,
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
        await new Future.delayed(const Duration(seconds: 3));
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        await widget.storage.resetUserData();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        final snackBar = new SnackBar(
            content: new Text("Odświeżenie danych kamery nie powiodło się.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _load = false;
      });
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych kamery. Sprawdź połączenie z serwerem i spróbuj ponownie.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania danych kamery. Adres serwera nieprawidłowy.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
    setState(() {
      _load = false;
    });
  }
}
