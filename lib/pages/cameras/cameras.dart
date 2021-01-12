import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idom/api.dart';
import 'package:idom/dialogs/confirm_action_dialog.dart';
import 'package:idom/dialogs/progress_indicator_dialog.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/cameras/camera_stream.dart';
import 'package:idom/pages/cameras/new_camera.dart';
import 'package:idom/utils/idom_colors.dart';
import 'package:idom/utils/login_procedures.dart';
import 'package:idom/utils/secure_storage.dart';
import 'package:idom/widgets/idom_drawer.dart';
import 'package:idom/localization/cameras/cameras.i18n.dart';

/// displays cameras list
class Cameras extends StatefulWidget {
  Cameras({@required this.storage, this.testApi});

  /// internal storage
  final SecureStorage storage;

  /// api used for tests
  final Api testApi;

  /// handles state of widgets
  @override
  _CamerasState createState() => _CamerasState();
}

class _CamerasState extends State<Cameras> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  final TextEditingController _searchController = TextEditingController();
  Api api = Api();
  List<Camera> _cameraList = List<Camera>();
  List<Camera> _duplicateCameraList = List<Camera>();
  bool zeroFetchedItems = false;
  bool _connectionEstablished;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.testApi != null) {
      api = widget.testApi;
    }

    LoginProcedures.init(widget.storage, api);

    getCameras();
    _searchController.addListener(() {
      filterSearchResults(_searchController.text);
    });
  }

  /// returns list of cameras
  Future<void> getCameras() async {
    try {
      /// gets cameras
      var res = await api.getCameras();

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
      } /// on invalid token log out
      else if (res != null && res['statusCode'] == "401") {
        final message = await LoginProcedures.signInWithStoredData();
        if (message != null) {
          logOut();
        } else {
          res = await api.getCameras();

          /// on success fetching data
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
            logOut();
          } else {
            _connectionEstablished = false;
            setState(() {});
            return null;
          }
        }
      }
      else {
        _connectionEstablished = false;
        setState(() {});
        return null;
      }
    } catch (e) {
      print(e.toString());
      if (e.toString().contains("TimeoutException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania kamer. Sprawdź połączenie z serwerem i spróbuj ponownie."
                    .i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
      if (e.toString().contains("SocketException")) {
        final snackBar = new SnackBar(
            content: new Text(
                "Błąd pobierania kamer. Adres serwera nieprawidłowy.".i18n));
        _scaffoldKey.currentState.showSnackBar((snackBar));
      }
    }
    setState(() {
      _duplicateCameraList.clear();
      _duplicateCameraList.addAll(_cameraList);
    });
  }

  Future<void> logOut() async {
    displayProgressDialog(
        context: _scaffoldKey.currentContext,
        key: _keyLoader,
        text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
    await new Future.delayed(const Duration(seconds: 3));
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    await widget.storage.resetUserData();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }


  /// deletes camera
  _deleteCamera(Camera camera) async {
    var decision = await confirmActionDialog(context, "Potwierdź".i18n,
        "Czy na pewno chcesz usunąć kamerę ".i18n + camera.name + "?");
    if (decision) {
      try {
        displayProgressDialog(
            context: _scaffoldKey.currentContext,
            key: _keyLoader,
            text: "Trwa usuwanie kamery...".i18n);

        int statusCode = await api.deleteCamera(camera.id);
        Navigator.of(_scaffoldKey.currentContext, rootNavigator: true).pop();
        if (statusCode == 200) {
          setState(() {
            /// refreshes cameras' list
            getCameras();
          });
        } else if (statusCode == 401) {
          displayProgressDialog(
              context: _scaffoldKey.currentContext,
              key: _keyLoader,
              text: "Sesja użytkownika wygasła. \nTrwa wylogowywanie...".i18n);
          await new Future.delayed(const Duration(seconds: 3));
          Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
          await widget.storage.resetUserData();
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (statusCode == null) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd usuwania kamery. Sprawdź połączenie z serwerem i spróbuj ponownie."
                      .i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        } else {
          final snackBar = new SnackBar(
              content: new Text(
                  "Usunięcie kamery nie powiodło się. Spróbuj ponownie.".i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      } catch (e) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        print(e.toString());
        if (e.toString().contains("TimeoutException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Błąd usuwania kamery. Sprawdź połączenie z serwerem i spróbuj ponownie."
                      .i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
        if (e.toString().contains("SocketException")) {
          final snackBar = new SnackBar(
              content: new Text(
                  "Usunięcie kamery nie powiodło się. Spróbuj ponownie.".i18n));
          _scaffoldKey.currentState.showSnackBar((snackBar));
        }
      }
    }
  }

  Future<bool> _onBackButton() async {
    Navigator.pop(context);
    return true;
  }

  _buildSearchField() {
    return TextField(
      key: Key('searchField'),
      controller: _searchController,
      style: TextStyle(
          color: IdomColors.whiteTextLight, fontSize: 20, letterSpacing: 2.0),
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Wyszukaj...".i18n,
        hintStyle: TextStyle(
            color: IdomColors.whiteTextLight, fontSize: 20, letterSpacing: 2.0),
        border: UnderlineInputBorder(
            borderSide: BorderSide(color: IdomColors.additionalColor)),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: IdomColors.additionalColor),
        ),
      ),
    );
  }

  void filterSearchResults(String query) {
    query = query.toLowerCase();
    List<Camera> dummySearchList = List<Camera>();
    dummySearchList.addAll(_duplicateCameraList);
    if (query.isNotEmpty) {
      List<Camera> dummyListData = List<Camera>();
      dummySearchList.forEach((item) {
        if (item.name.toLowerCase().contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        _cameraList.clear();
        _cameraList.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        _cameraList.clear();
        _cameraList.addAll(_duplicateCameraList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackButton,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: _isSearching
              ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.text = "";
                    });
                  })
              : IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    _scaffoldKey.currentState.openDrawer();
                  },
                ),
          title: _isSearching ? _buildSearchField() : Text('Kamery'.i18n),
          actions: [
            _isSearching
                ? SizedBox()
                : IconButton(
                    icon: Icon(Icons.search, size: 25.0),
                    key: Key("searchButton"),
                    onPressed: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                  ),
            _isSearching
                ? IconButton(
                    icon: Icon(Icons.close, size: 25.0),
                    key: Key("clearSearchingBox"),
                    onPressed: () {
                      setState(() {
                        _searchController.text = "";
                      });
                    },
                  )
                : SizedBox(),
            _isSearching
                ? SizedBox()
                : IconButton(
                    icon: Icon(Icons.add, size: 30.0),
                    key: Key("addCameraButton"),
                    onPressed: navigateToNewCamera,
                  )
          ],
        ),
        drawer: IdomDrawer(
            storage: widget.storage,
            parentWidgetType: "Cameras"),

        /// builds cameras' list
        body: Container(child: listCameras()),
      ),
    );
  }

  Widget listCameras() {
    if (zeroFetchedItems) {
      return RefreshIndicator(
          backgroundColor: IdomColors.mainBackgroundDark,
          onRefresh: _pullRefresh,
          child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.only(
                      left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Text("Brak kamer w systemie".i18n,
                          style: Theme.of(context).textTheme.subtitle1,
                          textAlign: TextAlign.center)))));
    }
    if (_connectionEstablished != null &&
        _connectionEstablished == false &&
        _cameraList.isEmpty) {
      return RefreshIndicator(
          backgroundColor: IdomColors.mainBackgroundDark,
          onRefresh: _pullRefresh,
          child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.only(
                      left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Text("Błąd połączenia z serwerem.".i18n,
                          style: Theme.of(context).textTheme.subtitle1,
                          textAlign: TextAlign.center)))));
    } else if (!zeroFetchedItems &&
        _duplicateCameraList.isNotEmpty &&
        _cameraList.isEmpty) {
      return Padding(
          padding:
              EdgeInsets.only(left: 30.0, top: 33.5, right: 30.0, bottom: 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Text("Brak wyników wyszukiwania.".i18n,
                  style: Theme.of(context).textTheme.bodyText2,
                  textAlign: TextAlign.center)));
    } else if (_cameraList.isNotEmpty && _cameraList.length > 0) {
      return Column(
        children: [
          Expanded(
              child: Scrollbar(
                  child: RefreshIndicator(
                      backgroundColor: IdomColors.mainBackgroundDark,
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
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(fontSize: 21.0)),
                                        onTap: () {
                                          navigateToCameraStream(
                                              _cameraList[index]);
                                        },
                                        leading: SizedBox(
                                            width: 35,
                                            child: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: SvgPicture.asset(
                                                    "assets/icons/video-camera.svg",
                                                    matchTextDirection: false,
                                                    width: 32,
                                                    height: 32,
                                                    color: IdomColors
                                                        .additionalColor,
                                                    key: Key(
                                                        "assets/icons/video-camera.svg")))),
                                        trailing:
                                            getTrailing(_cameraList[index])),
                                  ))))))),
        ],
      );
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

  getTrailing(Camera camera) {
    return SizedBox(
        width: 35,
        child: Container(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: Key("deleteButton"),
              child: SizedBox(
                  width: 35,
                  child: Container(
                      padding: EdgeInsets.only(top: 5),
                      alignment: Alignment.topRight,
                      child: SvgPicture.asset(
                        "assets/icons/dustbin.svg",
                        matchTextDirection: false,
                        width: 32,
                        height: 32,
                        color: Theme.of(context).textTheme.bodyText1.color,
                      ))),
              onPressed: () {
                setState(() {
                  _deleteCamera(camera);
                });
              },
            )));
  }

  /// navigates to adding camera page
  navigateToNewCamera() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewCamera(storage: widget.storage),
            fullscreenDialog: true));

    /// displays success message if camera added successfully
    if (result == true) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      final snackBar = new SnackBar(
        content: new Text("Dodano nową kamerę.".i18n),
        duration: Duration(seconds: 1),
      );
      _scaffoldKey.currentState.showSnackBar((snackBar));
      await getCameras();
    }
  }
}
