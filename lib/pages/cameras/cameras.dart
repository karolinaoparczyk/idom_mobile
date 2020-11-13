import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/cameras/camera_stream.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';

class Cameras extends StatefulWidget {
  Cameras({@required this.storage, this.testApi});

  final SecureStorage storage;
  final Api testApi;

  @override
  _CamerasState createState() => _CamerasState();
}

class _CamerasState extends State<Cameras> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoaderInvalidToken = GlobalKey<State>();
  Api api = Api();
  List<Camera> _cameraList;
  bool zeroFetchedItems = false;
  bool _connectionEstablished;
  String _token;

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null){
      api = widget.testApi;
    }
    getCameras();
  }

  Future<void> getUserToken() async {
    _token = await widget.storage.getToken();
  }

  /// returns list of cameras
  Future<void> getCameras() async {
    await getUserToken();
    try {
      /// gets cameras
      var res = await api.getCameras(_token);

      if (res != null && res['statusCode'] == "200") {
        List<dynamic> body = jsonDecode(res['body']);
        setState(() {
          _cameraList =
              body.map((dynamic item) => Camera.fromJson(item)).toList();
        });
        if (_cameraList.length == 0)
          zeroFetchedItems = true;
        else
          zeroFetchedItems = false;
      } else if (res != null && res['statusCode'] == "401") {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoaderInvalidToken,
            text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...");
        await new Future.delayed(const Duration(seconds: 3));
        Navigator.of(_keyLoaderInvalidToken.currentContext, rootNavigator: true)
            .pop();
        await widget.storage.resetUserData();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      if (res == null) {
        _connectionEstablished = false;
        setState(() {});
        return null;
      }
    } catch (e) {
      print(e.toString());
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania czujników. Sprawdź połączenie z serwerem i spróbuj ponownie."));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania czujników. Adres serwera nieprawidłowy."));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
  }

  onLogOutFailure(String text) {
    final snackBar = new SnackBar(content: new Text(text));
    _scaffoldKey.currentState.showSnackBar((snackBar));
  }

  Future<bool> _onBackButton() async {
    Navigator.pop(context);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackButton,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Kamery'),
        ),
        drawer: IdomDrawer(
            storage: widget.storage,
            parentWidgetType: "Cameras",
            onLogOutFailure: onLogOutFailure),

        /// builds cameras' list
        body: Container(child: Column(children: <Widget>[listCameras()])),
      ),
    );
  }

  Widget listCameras() {
    if (zeroFetchedItems) {
      return Padding(
          padding:
              EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                  "Brak kamer w systemie \nlub błąd połączenia z serwerem.",
                  style: TextStyle(fontSize: 16.5),
                  textAlign: TextAlign.center)));
    }
    if (_connectionEstablished != null &&
        _connectionEstablished == false &&
        _cameraList == null) {
      return Padding(
          padding:
              EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text("Błąd połączenia z serwerem.",
                  style: TextStyle(fontSize: 16.5),
                  textAlign: TextAlign.center)));
    } else if (_cameraList != null && _cameraList.length > 0) {
      return Expanded(
          child: Scrollbar(
              child: RefreshIndicator(
                  onRefresh: _pullRefresh,
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, top: 10, right: 10.0, bottom: 0.0),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _cameraList.length,
                          itemBuilder: (context, index) => Container(
                              height: 80,
                              child: Card(
                                child: ListTile(
                                  key: Key(_cameraList[index].name),
                                  title: Text(_cameraList[index].name,
                                      style: TextStyle(fontSize: 21.0)),
                                  onTap: () {
                                    navigateToCameraStream(_cameraList[index]);
                                  },
                                  leading: SizedBox(
                                    width: 35,
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      child:Icon(
                                    Icons.videocam,
                                    color: Theme.of(context).iconTheme.color,
                                  size: 30,
                                  ))),
                                ),
                              )))))));
    }

    /// shows progress indicator while fetching data
    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, top: 10, right: 10.0, bottom: 0.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      /// refreshes cameras' list
      getCameras();
    });
  }

  navigateToCameraStream(Camera camera) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            CameraStream(storage: widget.storage, camera: camera)));
    await getCameras();
  }
}
