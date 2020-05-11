import 'package:flutter/material.dart';
import 'package:idom/models.dart';

class AccountDetail extends StatelessWidget {
  const AccountDetail({@required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(account.username)),
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
