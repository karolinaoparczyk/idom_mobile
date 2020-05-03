import 'package:flutter/material.dart';
import 'package:idom/pages/new_account.dart';

class Accounts extends StatefulWidget {
  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  List<Map<String, String>> _users = [
    {'login': 'abcd', 'is_superuser': '1'},
    {'login': 'xyz', 'is_superuser': '0'}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('IDOM Konta w systemie')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              itemCount: _users.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_users[index]['login']),
                  subtitle: Text(isSuperUser(index)),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 250,
                  child: RaisedButton(
                      onPressed: navigateToNewAccount,
                      child: Text(
                        'Dodaj nowe konto',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.normal),
                      ),
                      color: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      elevation: 10,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0))),
                ),
              ],
            ),
          ],
        ));
  }

  void navigateToNewAccount() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewAccount(), fullscreenDialog: true));
  }

  String isSuperUser(int user_index) {
    if (_users[user_index]['is_superuser'] == '1')
      return 'SuperUser';
    else
      return '';
  }
}