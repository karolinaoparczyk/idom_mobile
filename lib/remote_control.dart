import 'package:http/http.dart';
import 'package:idom/models.dart';

/// handles remote control with app interaction
class RemoteControl {
  /// sends command to remote control
  static Future<int> sendCommand(Driver driver, String command,
      {int channel}) async {
    Client httpClient = Client();

    if (channel != null) {
      command = "0x" + channel.toString();
    }

    var res = await httpClient
        .post('http://${driver.ipAddress}:8000/receive?name=${driver.name}&data=$command}')
        .timeout(Duration(seconds: 5));

    return res.statusCode;
  }
}
