import 'package:flutter/material.dart';
import 'package:idom/enums/protocols.dart';

class ProtocolDialog extends StatefulWidget {
  final String currentProtocol;

  ProtocolDialog(this.currentProtocol);

  @override
  _ProtocolDialogState createState() => _ProtocolDialogState();
}

class _ProtocolDialogState extends State<ProtocolDialog> {
  List<String> protocols = Protocols.values;
  String _selectedProtocol;

  @override
  void initState() {
    if (widget.currentProtocol != "")
      _selectedProtocol = widget.currentProtocol;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: SizedBox(
          height: 250,
          width: size.width * 2 / 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 15, bottom: 10),
                child: Text("Protokół",
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        .copyWith(fontSize: 21.0)),
              ),
              Divider(),
              SizedBox(
                height: 120.0,
                width: size.width * 2 / 3,
                child: ListView.builder(
                  itemCount: protocols.length,
                  itemBuilder: (BuildContext context, int index) {
                    return RadioListTile(
                      title: Text(protocols[index],
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.normal, fontSize: 21.0)),
                      value: protocols[index],
                      groupValue: _selectedProtocol,
                      onChanged: (value) {
                        setState(() {
                          _selectedProtocol = value;
                        });
                      },
                    );
                  },
                ),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      child: Text("Anuluj",
                          style: Theme.of(context).textTheme.headline5),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  TextButton(
                      child: Text("OK",
                          style: Theme.of(context).textTheme.headline5),
                      onPressed: () {
                        Navigator.pop(context, _selectedProtocol);
                      }),
                ],
              ),
            ],
          )),
    );
  }
}
