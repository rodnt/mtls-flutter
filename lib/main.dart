import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dioPlugin;
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/io_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo For Using mTLS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Demo For mTLS'),
    );
  }
}

class SecurityConfiguration {
  static const String privateKeyBase64 = String.fromEnvironment('PRIVATE_KEY_BASE64');
  static const String certificateBase64 = String.fromEnvironment('CERTIFICATE_BASE64');

  static Uint8List get privateKeyBytes => base64.decode(privateKeyBase64);
  static Uint8List get certificateChainBytes => base64.decode(certificateBase64);

  static Future<SecurityContext> get globalContext async {
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.usePrivateKeyBytes(privateKeyBytes);
    sc.useCertificateChainBytes(certificateChainBytes);
    return sc;
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late IOClient client;
  late Dio dio = Dio();
  String responseText = '';

  void _initHttpClient() async {
    HttpClient _httpClient = HttpClient(context: await SecurityConfiguration.globalContext);
    _httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    client = IOClient(_httpClient);
  }

  void _initDioClient() async {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      SecurityContext sc = SecurityContext(withTrustedRoots: true);
      sc.useCertificateChainBytes(SecurityConfiguration.certificateChainBytes);
      sc.usePrivateKeyBytes(SecurityConfiguration.privateKeyBytes);
      HttpClient httpClient = HttpClient(context: sc);
      httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return httpClient;
    };
  }

  @override
  void initState() {
    super.initState();
    _initHttpClient();
    _initDioClient();
  }

  String endpoint = 'https://192.168.1.5:8000/';

  Future<void> _makeHttpRequest() async {
    http.Response response = await client.get(Uri.parse("$endpoint"),
        headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      setState(() {
        responseText = "HTTP: Response: ${response.body} \nStatus Code: ${response.statusCode}";
      });
    }
  }

  Future<void> _makeDioRequest() async {
    dioPlugin.Response response = await dio.get("$endpoint");
    if (response.statusCode == 200) {
      setState(() {
        responseText = "DIO: Response: ${response.data} \nStatus Code: ${response.statusCode}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(responseText),
          Row(
            children: [
              Expanded(
                  child: OutlinedButton(
                    onPressed: _makeHttpRequest,
                    child: Row(
                      children: [Text('http')],
                    ),
                  )),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                  child: OutlinedButton(
                    onPressed: _makeDioRequest,
                    child: Row(
                      children: [Text('dio')],
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
