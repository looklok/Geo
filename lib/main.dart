import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Geo Demo',
      home: MyHomePage(title: 'Example de geolocalisation'),
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
  String adress_longitude = '00.00';
  String adress_latitude = '00.00';
  String adress_altitude = '00.00';
  String adress_time = '00.00';
  String adress_speed = '00.00';


  Future getadress () async{

    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    adress_longitude = position.longitude.toString();
    adress_latitude = position.latitude.toString();
    adress_altitude = position.altitude.toString();
    adress_time = position.timestamp.second.toString();
    adress_speed = position.speed.toString();
    print('$adress_latitude $adress_longitude $adress_altitude');
    double d = await Geolocator().distanceBetween(36.7179526, 3.1530259, 36.7179609, 3.1527123);
    print( d );
   // Geolocator().getPositionStream()


  }
  void recuperer_adr() async {
    try {
      await getadress();
    } catch(e) {
      print(e);
    }

    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'votre longitude est : ',
            ),
            Text(
              '$adress_longitude',
              style: Theme.of(context).textTheme.display1,
            ),
            Text(
              'votre latitude est : ',
            ),
            Text(
              '$adress_latitude',
              style: Theme.of(context).textTheme.display1,
            ),
            Text(
              'votre altitude est : ',
            ),
            Text(
              '$adress_altitude',
              style: Theme.of(context).textTheme.display1,
            ),
            Text(
              'votre vitesse est : ',
            ),
            Text(
              '$adress_speed',
              style: Theme.of(context).textTheme.display1,
            ),
            Text(
              'La seconde est : ',
            ),
            Text(
              '$adress_time',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: recuperer_adr,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
