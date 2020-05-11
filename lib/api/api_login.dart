import 'dart:async';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart' as dio;
import 'package:path_provider/path_provider.dart';

class ApiLogIn {
  final dio.Dio _dio = dio.Dio();
  PersistCookieJar persistentCookies;
  /// API URL
  final String URL = "http://10.0.2.2:8000/";

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// creates directory for cookies
  Future<Directory> get _localCoookieDirectory async {
    final path = await _localPath;
    final Directory dir = new Directory('$path/cookies');
    await dir.create();
    return dir;
  }

  /// gets CSRF token to safely and successfully login
  Future<String> getCsrftoken() async {
    try {
      String csrfTokenValue;
      final Directory dir = await _localCoookieDirectory;
      final cookiePath = dir.path;
      persistentCookies = new PersistCookieJar(dir: '$cookiePath');
      persistentCookies
          .deleteAll(); //clearing any existing cookies for a fresh start
      _dio.interceptors.add(dio.CookieManager(
          persistentCookies) //this sets up _dio to persist cookies throughout subsequent requests
      );
      _dio.options = new dio.BaseOptions(
        baseUrl: URL,
        contentType: ContentType.json,
        responseType: dio.ResponseType.plain,
        connectTimeout: 5000,
        receiveTimeout: 100000,
        headers: {
          HttpHeaders.userAgentHeader: "dio",
          "Connection": "keep-alive",
        },
      ); //BaseOptions will be persisted throughout subsequent requests made with _dio
      _dio.interceptors
          .add(dio.InterceptorsWrapper(onResponse: (dio.Response response) {
        List<Cookie> cookies = persistentCookies.loadForRequest(Uri.parse(URL));
        csrfTokenValue = cookies
            .firstWhere((c) => c.name == 'csrftoken', orElse: () => null)
            ?.value;
        if (csrfTokenValue != null) {
          _dio.options.headers['X-CSRF-TOKEN'] =
              csrfTokenValue; //setting the csrftoken from the response in the headers
        }
        return response;
      }));
      await _dio.get("login/");
      return csrfTokenValue;
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return null;
    }
  }

  /// attempts to sign in to database through API
  attemptToSignIn(String username, String password) async {
    try {
      final csrf = await getCsrftoken();
      dio.FormData formData = new dio.FormData.from({
        "username": username,
        "password": password,
        "csrfmiddlewaretoken": '$csrf'
      });
      dio.Options optionData = new dio.Options(
        followRedirects: false,
        validateStatus: (status) {
          return status < 500;
        },
        contentType: ContentType.parse("application/x-www-form-urlencoded"),
      );
      dio.Response response =
      await _dio.post("login/", data: formData, options: optionData);
      print(response.statusCode);
      if (response.statusCode == 200 &&
          response.data
              .toString()
              .contains("Please enter a correct username and password")) {
        return 'wrong credentials';
      } else if (response.statusCode == 200 || response.statusCode == 302) {
        return 'ok';
      }
    } on dio.DioError catch (e) {
      if (e.response != null) {
        print(
            e.response.statusCode.toString() + " " + e.response.statusMessage);
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        print(e.request);
        print(e.message);
      }
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return null;
    }
  }
}