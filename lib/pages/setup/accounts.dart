import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:idom/models.dart';
import 'package:idom/pages/account_detail.dart';
import 'package:idom/pages/new_account.dart';

class Accounts extends StatefulWidget {
  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  final String accountsUrl = "http://10.0.2.2:8000/register/";

  /// gets accounts from API
  Future<List<Account>> getAccounts() async {
    Response res = await get(accountsUrl);

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      print(body);

      List<Account> accounts =
          body.map((dynamic item) => Account.fromJson(item)).toList();
      // TODO: show only active users
      return accounts;
    } else {
      throw "Can't get accounts";
    }
  }

  /// deactivates user when pressed delete
  _onSelected(dynamic val) {
    //delete from database
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('IDOM Konta w systemie')),
        body: FutureBuilder(
          future: getAccounts(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Account>> snapshot) {
            if (snapshot.hasData) {
              List<Account> accounts = snapshot.data;
              return ListView(
                children: accounts
                .where((account) => account.isActive == true)
                    .map((Account account) => ListTile(
                          title: Text(account.username),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AccountDetail(account: account))),
                          trailing: PopupMenuButton(
                            onSelected: _onSelected,
                            icon: Icon(Icons.menu),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: account,
                                child: Text("Usuń"),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              );
            }

            return Center(child: CircularProgressIndicator());
          },
        ));
  }

  void navigateToNewAccount() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewAccount(), fullscreenDialog: true));
  }
}
