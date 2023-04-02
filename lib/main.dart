import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'PM2.5'),
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
  int _counter = 0;
  final List<String> _cityList = [
    'shanghai',
    'macau',
    'beijing',
    'hongkong',
    'huainan'
  ];
  List<int> _pm25List = [0, 0, 0, 0, 0];

  Future<PM25Reading> fetchPM25(String city) async {
    final response = await http.get(Uri.https('api.waqi.info', '/feed/$city/',
        {'token': '893a5d75fdae03457fd58d8de502e5652d9bf226'}));
    if (response.statusCode == 200) {
      return PM25Reading.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _fetchPM25Level() async {
    for (int i = 0; i < _cityList.length;i++){
      PM25Reading reading = await fetchPM25(_cityList.elementAt(i));
      setState(() {
        _pm25List[i] = reading.pm25;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            BigCard(pair: _cityList.elementAt(0), pm25: _pm25List.elementAt(0)),
            BigCard(pair: _cityList.elementAt(1), pm25: _pm25List.elementAt(1)),
            BigCard(pair: _cityList.elementAt(2), pm25: _pm25List.elementAt(2)),
            BigCard(pair: _cityList.elementAt(3), pm25: _pm25List.elementAt(3)),
            BigCard(pair: _cityList.elementAt(4), pm25: _pm25List.elementAt(4)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchPM25Level,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
    required this.pm25,
  });

  final String pair;
  final int pm25;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(pair),
              Text(pm25.toString()),
            ],
          )),
    );
  }
}

class PM25Reading {
  final int pm25;

  PM25Reading(this.pm25);

  factory PM25Reading.fromJson(Map<String, dynamic> json) {
    return PM25Reading(json['data']['iaqi']['pm25']['v']);
  }
}