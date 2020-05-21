import 'package:flutter/material.dart';
import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/setup/front.dart';

class AccountDetail extends StatelessWidget {
  AccountDetail(
      {Key key, @required this.currentLoggedInToken, @required this.account})
      : super(key: key);
  final String currentLoggedInToken;
  final Account account;
  final Api api = Api();

  void displayDialog(BuildContext context, String title, String text) =>
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(account.username), actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              try {
                var statusCode = await api.logOut(currentLoggedInToken);
                if (statusCode == 200) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Front(), fullscreenDialog: true));
                } else {
                  displayDialog(
                      context, "Błąd", "Wylogowanie nie powiodło się. Spróbuj ponownie.");
                }
              } catch (e) {
                print(e);
              }
            },
          ),
        ]),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                    child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text("Login"),
                      subtitle: Text(account.username),
                    ),
                    ListTile(
                      title: Text("Email"),
                      subtitle: Text(account.email),
                    ),
                    ListTile(
                      title: Text("Nr telefonu"),
                      subtitle: Text(account.telephone),
                    ),
                  ],
                )))));
  }
}
