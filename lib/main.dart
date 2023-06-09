import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/list_view_page.dart';
import 'package:location/location.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_application_1/search_page.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:io' show Directory, Platform;

import 'data_model/popular_data_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(),
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UserLocation userLocation = UserLocation();
  List<Results> resultData = [];
  late Database database;
  double lat = 0;
  double long = 0;

  @override
  void initState() {
    super.initState();
    userLocation.requestService().then(
          (value) => userLocation.requestPermission(),
        );
    userLocation.location.changeSettings(
      accuracy: LocationAccuracy.high,
    );
    userLocation.location.onLocationChanged.listen((event) {
      setState(() {
        lat = event.latitude!;
        long = event.longitude!;
      });
    });
    initDb();
  }

  initDb() async {
    database = await openDatabase(
      join(
          Platform.isIOS
              ? (await getApplicationDocumentsDirectory()).path
              : await getDatabasesPath(),
          'popular.db'),
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE Popular (publishedDate TEXT, title TEXT)''',
        );
      },
      version: 1,
    );
  }

  void insertPopularDb(Results result) {
    database.insert(
      'Popular',
      result.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Results>> getPopularDb() async {
    final List<Map<String, dynamic>> maps = await database.query('Popular');

    return List.generate(maps.length, (i) {
      return Results(
        publishedDate: maps[i]['publishedDate'],
        title: maps[i]['title'],
      );
    });
  }

  Future popularApiCall({String? api}) async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      resultData.addAll(await getPopularDb());
      EasyLoading.dismiss();
    } else {
      http.Response response = await http.get(
        Uri.parse('$api?api-key=snT4uLnLAsf7vw5NbILG13pQjLL26wEv'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> convertedData = jsonDecode(response.body);

        final data = PopularDataModel.fromJson(convertedData);

        resultData.addAll(data.results!);

        EasyLoading.dismiss();

        for (Results data in resultData) {
          insertPopularDb(data);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NYT"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Column(
            children: <Widget>[
              Row(
                children: const [
                  Text(
                    'Search',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(
                thickness: 2,
                color: Colors.black,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchPage(),
                    ),
                  );
                },
                child: Row(
                  children: const [
                    Expanded(child: Text('Search Articles')),
                    Icon(Icons.arrow_forward_ios_rounded),
                  ],
                ),
              ),
              const Divider(
                thickness: 2,
                color: Colors.black,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Row(
                  children: const [
                    Text(
                      'Popular',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Divider(
                thickness: 2,
                color: Colors.black,
              ),
              GestureDetector(
                onTap: () {
                  EasyLoading.show(status: 'loading...');
                  popularApiCall(
                          api:
                              'https://api.nytimes.com/svc/mostpopular/v2/viewed/1.json')
                      .then(
                    (value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListViewPage(
                          resultData: resultData,
                        ),
                      ),
                    ),
                  );
                },
                child: Row(
                  children: const [
                    Expanded(child: Text('Most Viewed')),
                    Icon(Icons.arrow_forward_ios_rounded),
                  ],
                ),
              ),
              const Divider(
                thickness: 2,
                color: Colors.black,
              ),
              GestureDetector(
                onTap: () {
                  EasyLoading.show(status: 'loading...');
                  popularApiCall(
                          api:
                              'https://api.nytimes.com/svc/mostpopular/v2/shared/1/facebook.json')
                      .then(
                    (value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ListViewPage(resultData: resultData),
                      ),
                    ),
                  );
                },
                child: Row(
                  children: const [
                    Expanded(child: Text('Most Shared')),
                    Icon(Icons.arrow_forward_ios_rounded),
                  ],
                ),
              ),
              const Divider(
                thickness: 2,
                color: Colors.black,
              ),
              GestureDetector(
                onTap: () {
                  EasyLoading.show(status: 'loading...');
                  popularApiCall(
                          api:
                              'https://api.nytimes.com/svc/mostpopular/v2/emailed/1.json')
                      .then(
                    (value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ListViewPage(resultData: resultData),
                      ),
                    ),
                  );
                },
                child: Row(
                  children: const [
                    Expanded(child: Text('Most Emailed')),
                    Icon(Icons.arrow_forward_ios_rounded),
                  ],
                ),
              ),
              const Divider(
                thickness: 2,
                color: Colors.black,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text('Location'),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text('Latitude'),
                          Text(lat.toString()),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text('Longitude'),
                        Text(long.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserLocation {
  final Location location = Location();

  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;

  Future requestService() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
  }

  Future requestPermission() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }
}
