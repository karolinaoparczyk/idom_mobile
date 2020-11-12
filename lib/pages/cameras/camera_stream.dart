import 'dart:async';

import 'package:flutter/material.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CameraStream extends StatefulWidget {
  CameraStream({@required this.storage, @required this.camera});

  final SecureStorage storage;
  final camera;

  @override
  _CameraStreamState createState() => _CameraStreamState();
}

class _CameraStreamState extends State<CameraStream> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();
  bool _loading;
  String apiURL;

  @override
  void initState() {
    super.initState();
    _loading = true;
    getApiURL();
  }

  Future<void> getApiURL() async {
    apiURL = await widget.storage.getApiURL();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: IdomColors.white,
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.camera.name),
        ),
        drawer: IdomDrawer(
            storage: widget.storage,
            parentWidgetType: "Camera",
            onLogOutFailure: onLogOutFailure),
        body: Column(
          children: [
            Container(
                padding: EdgeInsets.only(top: 10),
                alignment: Alignment.center,
                height: 30,
                child: FlatButton(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Otwórz w przeglądarce",
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headline5),
                          Icon(Icons.arrow_right,
                              color: IdomColors.additionalColor)
                        ]),
                    onPressed: () async {
                      if (apiURL != null){
                      try {
                        await launch(
                            apiURL + '/cameras/stream/' + widget.camera.id.toString());
                      } catch (e) {
                        throw 'Could not launch page';
                      }}
                    })),
            if(_loading)
              SizedBox(height:30, width: 30,child: CircularProgressIndicator()),
            Expanded(
              child: Container(
                  padding: EdgeInsets.all(20.0),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: apiURL != null ?
                        WebView(
                      gestureNavigationEnabled: false,
                      onWebResourceError: (error) {
                        print("error $error");
                      },
                      initialUrl: apiURL + '/cameras/stream/' + widget.camera.id.toString(),
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated:
                          (WebViewController webViewController) {
                        _controller.complete(webViewController);
                        _loading = false;
                        setState(() {});
                      },
                    ) : SizedBox())
            )
          ],
        ),
      ),
    );
  }

  onLogOutFailure(String text) {
    final snackBar = new SnackBar(content: new Text(text));
    _scaffoldKey.currentState.showSnackBar((snackBar));
  }
}
