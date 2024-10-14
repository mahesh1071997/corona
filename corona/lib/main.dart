import 'package:flutter/cupertino.dart';
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

class ClicksPerYear {
  final String year;
  final int clicks;
  final charts.Color color;

  ClicksPerYear(this.year, this.clicks, Color color)
      : this.color = charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

class _MyHomePageState extends State<MyHomePage> {
  int _ActivCase = 0;
  int _RecCase = 0;
  int _FatalCase = 0;
  int _totalCase = 0;
  BuildContext mcontexx = null;

  Future<List<Country>> _fetchCountry() async {
    final jobsListAPIUrl = 'http://27.54.169.89:6060/API/GetRecord';
    final response = await http.get(jobsListAPIUrl);

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
    mcontexx = context;
    /*var data = [
      ClicksPerYear('Active', _ActivCase, Colors.amber),
      ClicksPerYear('Recovered', _RecCase, Colors.green),
      ClicksPerYear('Fatal', _FatalCase, Colors.black38),
    ];

    var series = [
      charts.Series(
        domainFn: (ClicksPerYear clickData, _) => clickData.year,
        measureFn: (ClicksPerYear clickData, _) => clickData.clicks,
        colorFn: (ClicksPerYear clickData, _) => clickData.color,
        id: 'Clicks',
        data: data,
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
    );*/
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: IconButton(
              icon: Icon(Icons.info,),
              onPressed: () {
                _showAboutDialog(mcontexx);
              },
            ),),
          ),
        ],
      ),
      body: Center(
        child: ListFutureBuilder()
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),*/ // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  ListFutureBuilder() {
    return FutureBuilder<List<Country>>(
      future: _fetchCountry(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Country> data = snapshot.data;
          for(Country obj in data){
            _ActivCase = _ActivCase +obj.cases;
            _FatalCase = _FatalCase + obj.death;
            _RecCase = _RecCase + obj.recovered;
            _totalCase = _ActivCase+ _FatalCase + _RecCase;
          }
          _tile(data);
          var chartdata = [
            ClicksPerYear('Active', _ActivCase, Colors.amber),
            ClicksPerYear('Recovered', _RecCase, Colors.green),
            ClicksPerYear('Fatal', _FatalCase, Colors.black38),
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

          var chartWidget= Padding(
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
                  onTap:(){_launchURL("https://en.wikipedia.org/wiki/2019%E2%80%9320_coronavirus_pandemic");},
                  title: Center(child: Text('Data From Wikipidia ')),
                ),
              ),
              _TotalView(),
              chartWidget,
              Container(
                height: 400,
                margin: EdgeInsets.symmetric(vertical: 20.0),
                child:_tile(data),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }

  _tile(List<Country> data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {return _tileCategory(data[index]);});
  }

  Card _tileCategory(Country data) => Card(
    child: ListTile(
      title: Text(data.country),
      trailing: Text((data.cases + data.death + data.recovered).toString()),
      onTap: (){_showDialog(mcontexx,data);},),
  );
  Card _TotalView() => Card(
  margin: EdgeInsets.all(8.0),
  child: Column(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('TOTAL CONFIRMED CASES', style: TextStyle(fontSize: 20,)),),
      Text('$_totalCase', style: TextStyle(fontSize: 25),),
      ListTile(
        trailing: Text('$_ActivCase'),
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
        trailing: Text('$_RecCase'),
        title: Text("Recovered cases"),
        leading: CircleAvatar(
          child: Icon(Icons.insert_emoticon, color: Colors.white),
          backgroundColor: Colors.green,
        ),
      ),
      ListTile(
        trailing: Text('$_FatalCase'),
        title: Text("Fatal cases"),
        leading: CircleAvatar(
          child: Icon(Icons.hotel, color: Colors.white),
          backgroundColor: Colors.black38,
        ),
      ),
    ],
  ),
);
  void _showDialog(BuildContext context,Country data) {
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
                borderRadius:
                BorderRadius.circular(20.0)), //this right here
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
                     child: Center(child: Text(data.country,style: TextStyle(fontSize: 30),)),
                   ),
                    chartWidget,
                    Center(child: Text("Active : "+ data.cases.toString(),textAlign: TextAlign.center,)),
                    Center(child: Text("Recovered : " + data.recovered.toString())),
                    Center(child: Text("Fatal : " + data.death.toString())),
                  ],
                ),
              ),
            ),
          );
        });
  }
  void _showAboutDialog(BuildContext context)
  {
    showDialog(
        context: context,
        builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20.0)), //this right here
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
                  child: Center(child: Text('Gatistavam Softech Pvt. Ltd.',style: TextStyle(fontSize: 20),)),
                ),
                Center(child: Text("Web : www.gatistavamsoftech.com/",textAlign: TextAlign.center,)),
                Center(child: Text("Email : gatistavam@gatistavamsoftech.com" )),
               /* SizedBox(height: 10,),
                Center(child: Text("Data : gatistavam@gatistavamsoftech.com" )),*/

                /*SizedBox(
                      width: 320.0,
                      child: RaisedButton(
                        onPressed: () {},
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: const Color(0xFF1BC0C5),
                      ),
                    )*/
              ],
            ),
          ),
        ),
      );
    });
  }

  _launchURL(String Url) async {
    if (await canLaunch(Url)) {
      await launch(Url);
    } else {
      throw 'Could not launch $Url';
    }
  }
}
