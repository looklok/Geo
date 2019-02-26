import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

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
  String adress_longitude = '00.00' ;
  String adress_latitude = '00.00';
  String adress_time_seconde = '00.00';
  String adress_time_heure = '00.00';
  String adress_time_minute = '00.00';

  String adress_speed = '00.00';
  String localite='';
  bool connected = false;
  String siconnecte = 'ETAT : pas connecte';
  String wilaya='';
  StreamSubscription<Position> positionStream ;
  double distance=0;

  Future getadress () async{
    int i =0;
    /*Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    adress_longitude = position.longitude.toString();
    adress_latitude = position.latitude.toString();
    adress_time = position.timestamp.second.toString();
    adress_speed = position.speed.toString();
    print('$adress_latitude $adress_longitude $adress_altitude');
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    localite = placemark[0].locality;
    wilaya = placemark[0].administrativeArea;*/
    if (connected == true) {
      var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 10);

      positionStream = Geolocator().getPositionStream(locationOptions).listen((Position position1)
          {

                  print(i);
                  i++;
                  print(position1 == null ? 'Unknown' : position1.latitude.toString() + ', ' + position1.longitude.toString());
                  adress_longitude = position1.longitude.toString();
                  adress_latitude = position1.latitude.toString();
                  adress_speed=(position1.speed*1.85).toString();
                  adress_time_seconde = position1.timestamp.second.toString();
                  adress_time_minute = position1.timestamp.minute.toString();
                  adress_time_heure = position1.timestamp.hour.toString();
                  print(position1.speedAccuracy);
                  Geolocator().distanceBetween(36.745664, 3.069634, position1.latitude, position1.longitude).then((double d){
                    distance=d;
                  });

                  setState(() {});

          });
    }else {
      print('heeeeeeeere');
      positionStream.cancel();
      setState(() {

      });

    }
  }

  void recuperer_adr() async {
    try {
      await getadress();
    } catch(e) {
      print(e);
    }
  }
  void connect ()
  {
    if (connected==false){connected = true;
    siconnecte = 'ETAT :connecte';
    recuperer_adr();
    setState(() {

    });}
    else {
      connected = false;
      siconnecte = 'ETAT : pas connecte';
      print('stream cancelled');
      positionStream.cancel();
      setState(() {});
          }
    }

  @override
  Widget build(BuildContext context) {

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
              wilaya + '  '+localite
            ),
            Text(
              '             '
            ),
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
              'votre vitesse est : ',
            ),
            Text(
              '$adress_speed',
              style: Theme.of(context).textTheme.display1,
            ),
            Text(
              'L\'instant est : ',
            ),
            Text(
              '$adress_time_heure : $adress_time_minute : $adress_time_seconde',
              style: Theme.of(context).textTheme.display1,
            ),
            Text(
              'La distance de la a Maqem a chahid est : ',
            ),
            Text(
              '$distance',
              style: Theme.of(context).textTheme.display1,
            ),
            RaisedButton(child: Text(' connectée/ deconnecte '),
             textColor: Colors.deepOrange,
              onPressed: connect ,
            ),
            Text(siconnecte)
          ],
        ),
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
