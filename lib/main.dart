import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'Model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'CORONA CASES'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _activCase = 0;
  int _recCase = 0;
  int _fatalCase = 0;
  int _totalCase = 0;
  List<Country> data;

  BuildContext mContex;

  Future<List<Country>> _fetchCountry() async {
    print("fetchCon api call");
    final jobsListAPIUrl = 'http://27.54.169.89:6060/API/GetRecord';
    final response = await http.get(jobsListAPIUrl,headers: {"Accept": "application/json"});
    print(response.body);
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse["Status"] as String == "Success") {
        List jsonList;
        jsonList = jsonResponse["Data"] as List;
        return jsonList.map((data) => new Country.fromJson(data)).toList();
      } else {
        return null;
      }
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("build call");
    mContex = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: IconButton(
                icon: Icon(
                  Icons.info,
                ),
                onPressed: () {
                  _showAboutDialog(mContex);
                },
              ),
            ),
          ),
        ],
      ),
      body: Center(child: listFutureBuilder()),
    );
  }

  listFutureBuilder() {
    print("list Future");
    return FutureBuilder<List<Country>>(
      future: _fetchCountry(),
      builder: (context, snapshot) {
        if (snapshot.hasData) 
        {
          this.data = snapshot.data;
          _activCase = 0; _fatalCase = 0;_recCase = 0;_totalCase = 0;
          for (Country obj in data)
          {
            _activCase = _activCase + obj.cases;
            _fatalCase = _fatalCase + obj.death;
            _recCase = _recCase + obj.recovered;
            _totalCase = _activCase + _fatalCase + _recCase;
          }
//          _tile(data);
          var chartdata = [
            ClicksPerYear('Active', _activCase, Colors.amber),
            ClicksPerYear('Recovered', _recCase, Colors.green),
            ClicksPerYear('Fatal', _fatalCase, Colors.black38),
          ];
          var series = [
            charts.Series(
              domainFn: (ClicksPerYear clickData, _) => clickData.year,
              measureFn: (ClicksPerYear clickData, _) => clickData.clicks,
              colorFn: (ClicksPerYear clickData, _) => clickData.color,
              id: 'Clicks',
              data: chartdata,
            ),
          ];
          var chart = charts.BarChart(
            series,
            animate: true,
          );

          var chartWidget = Padding(
            padding: EdgeInsets.all(32.0),
            child: SizedBox(
              height: 200.0,
              child: chart,
            ),
          );

          return ListView(
//          mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  onTap: () {
                    _launchURL(
                        "https://en.wikipedia.org/wiki/2019%E2%80%9320_coronavirus_pandemic");
                  },
                  title: Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Data From ',
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                              text: 'Wikipidia',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _totalView(),
              chartWidget,
              Container(
                height: 400,
                margin: EdgeInsets.symmetric(vertical: 20.0),
                child: _tile(data),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Center(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Icon(
                  Icons.signal_cellular_connected_no_internet_4_bar,
                  size: 100,
                ),
                Center(child: Text("NetWork Error Or Check Internet ")),
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: RaisedButton(
                      onPressed: () {
                        main();
                        print("click");
                      },
                      child: Text('Retry'),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return CircularProgressIndicator();
//          return Text("${snapshot.error}");

      },
    );
  }

  _tile(List<Country> data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _tileCategory(data[index]);
        });
  }

  Card _tileCategory(Country data) => Card(
        child: ListTile(
          title: Text(data.country),
          trailing: Text((data.cases + data.death + data.recovered).toString()),
          onTap: () {
            _showDialog(mContex, data);
          },
        ),
      );

  Card _totalView() => Card(
        margin: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('TOTAL CONFIRMED CASES',
                  style: TextStyle(
                    fontSize: 20,
                  )),
            ),
            Text(
              '$_totalCase',
              style: TextStyle(fontSize: 25),
            ),
            ListTile(
              trailing: Text('$_activCase'),
              title: Text("Active cases"),
              leading: CircleAvatar(
                child: Icon(
                  Icons.sentiment_dissatisfied,
                  color: Colors.white,
                ),
                backgroundColor: Colors.amber,
              ),
            ),
            ListTile(
              trailing: Text('$_recCase'),
              title: Text("Recovered cases"),
              leading: CircleAvatar(
                child: Icon(Icons.insert_emoticon, color: Colors.white),
                backgroundColor: Colors.green,
              ),
            ),
            ListTile(
              trailing: Text('$_fatalCase'),
              title: Text("Fatal cases"),
              leading: CircleAvatar(
                child: Icon(Icons.hotel, color: Colors.white),
                backgroundColor: Colors.black38,
              ),
            ),
          ],
        ),
      );

  void _showDialog(BuildContext context, Country data) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          var data1 = [
            ClicksPerYear('Active', data.cases, Colors.amber),
            ClicksPerYear('Recovered', data.recovered, Colors.green),
            ClicksPerYear('Fatal', data.death, Colors.black38),
          ];

          var series = [
            charts.Series(
              domainFn: (ClicksPerYear clickData, _) => clickData.year,
              measureFn: (ClicksPerYear clickData, _) => clickData.clicks,
              colorFn: (ClicksPerYear clickData, _) => clickData.color,
              id: 'Clicks',
              data: data1,
            ),
          ];
          var chart = charts.BarChart(
            series,
            animate: true,
          );
          var chartWidget = Padding(
            padding: EdgeInsets.all(20.0),
            child: SizedBox(
              height: 200.0,
              child: chart,
            ),
          );
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 400,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: Text(
                        data.country,
                        style: TextStyle(fontSize: 30),
                      )),
                    ),
                    chartWidget,
                    Center(
                        child: Text(
                      "Active : " + data.cases.toString(),
                      textAlign: TextAlign.center,
                    )),
                    Center(
                        child:
                            Text("Recovered : " + data.recovered.toString())),
                    Center(child: Text("Fatal : " + data.death.toString())),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: Text(
                        'Gatistavam Softech Pvt. Ltd.',
                        style: TextStyle(fontSize: 20),
                      )),
                    ),
                    Center(
                        child: Text(
                      "Web : www.gatistavamsoftech.com",
                      textAlign: TextAlign.center,
                    )),
                    Center(
                        child: Text(
                      "Email : gatistavam@gatistavamsoftech.com",
                      textAlign: TextAlign.center,
                    )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 320.0,
                        child: RaisedButton(
                          onPressed: () {
                            _launchURL("https://www.gatistavamsoftech.com/");
                          },
                          child: Text(
                            "Contect Us",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: const Color(0xFF1BC0C5),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class ClicksPerYear {
  final String year;
  final int clicks;
  final charts.Color color;

  ClicksPerYear(this.year, this.clicks, Color color)
      : this.color = charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}
