import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';


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
  double busID = 1;
  double ligne = 1;
  bool first = true;


  Future getadress () async{

    var busref = Firestore.instance.collection('bus').document('bus '+busID.toString());
    List<DocumentSnapshot> l;
    /*var ref = Firestore.instance.collection('bus');
    var query = ref.getDocuments();
    query.then((QuerySnapshot q) {
      q.documents.forEach((DocumentSnapshot v) {
        int.parse(v.documentID);
      });
    });*/
    if (connected == true) {
      /* writing to database */
      Map<String ,dynamic> data = Map();
      data['ligne']=ligne;
      data['busID'] = busID;
      data['actif'] = true;
      var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 10);
      positionStream =Geolocator().getPositionStream(locationOptions).listen((Position position1) async
          {
                  print(position1 == null ? 'Unknown' : position1.latitude.toString() + ', ' + position1.speed.toString());
                  adress_longitude = position1.longitude.toString();
                  adress_latitude = position1.latitude.toString();
                  adress_speed=(position1.speed*3.6).toString();
                  adress_time_seconde = position1.timestamp.second.toString();
                  adress_time_minute = position1.timestamp.minute.toString();
                  adress_time_heure = position1.timestamp.hour.toString();
                  data['latitude'] = position1.latitude;
                  data['longitude'] = position1.longitude;
                  data['vitesse'] = (position1.speed*3.6);
                  if (first == true) {data['prochain']=2; first= false;}
                  else {
                    /// récuperer l'arret prochain de ce bus
                    var query = await Firestore.instance.collection('bus').where('busID',isEqualTo: busID).getDocuments();
                     int prochain = query.documents[0].data['prochain'];
                     print('prochain  : '+prochain.toString());
                     var Ligne = await Firestore.instance.collection('lignes').where('ligneID' , isEqualTo: ligne).getDocuments();
                     ///récuperer le nombre d'arrets de bus de ce bus
                     var nb = Ligne.documents[0].data['nb_arrets'];
                     var query1 = await Ligne.documents[0].reference.collection('arrets de bus').where('arretID', isEqualTo: prochain).getDocuments();
                     ///récuperer latitude et longitude du bus
                     var lat = query1.documents[0].data['latitude'];
                     var lon = query1.documents[0].data['longitude'];
                     /// calculer la distance entre le bus et l'arret prochain
                     var dis = await Geolocator().distanceBetween(lat.toDouble(), lon.toDouble(), position1.latitude, position1.longitude);
                      print('la distance est : '+dis.toString());
                      if (dis < 25){if (prochain == nb ){ data['prochain'] = 2;} else {data['prochain']= prochain+1;}}
                      else {data['prochain']=prochain;}

                  }
                  busref.setData(data);
                  Geolocator().distanceBetween(36.745664, 3.069634, position1.latitude, position1.longitude).then((double d){
                    distance=d;
                  });
                  setState(() {});
          });
    }
    else {
      print('heeeeeeeere');
      busref.updateData({'actif' : false});
      positionStream.cancel();
      setState(() {});
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
    if (connected==false) {
        connected = true;
        siconnecte = 'ETAT :connecte';
        recuperer_adr();
        setState(() {});
          }
    else {
      connected = false;
      siconnecte = 'ETAT : pas connecte';
      print('stream cancelled');
      recuperer_adr();
      setState(() {});
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
    );
  }
}
