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
      title: 'Application du bus',
      home: MyHomePage(title: 'BusTrucker'),
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
  String adress_speed = '00.00';
  String localite='';
  bool connected = false;
  String siconnecte = 'Pas Connecté';
  String wilaya='';
  StreamSubscription<Position> positionStream ;
  double distance=0;
  double busID = 1;
  double ligne = 1;
  bool first = true;
  var _color = Color.fromRGBO(229,144,129, 1);
  var buttoncolor = Color.fromRGBO(127,0,0, 1);


  Future getadress () async{ /// recuperer la position,vitesse faire des mise à jour pour le bus prochain en temps reel

    var busref = Firestore.instance.collection('bus').document('bus '+busID.toString());
    if (connected == true) {
      /* writing to database */
      Map<String ,dynamic> data = Map();
      data['ligne']=ligne;
      data['busID'] = busID;
      data['actif'] = true;
      var locationOptions = LocationOptions(accuracy: LocationAccuracy.best, distanceFilter: 10);
      positionStream =Geolocator().getPositionStream(locationOptions).listen((Position position1) async
          {
                  print(position1 == null ? 'Unknown' : position1.latitude.toString() + ', ' + position1.speed.toString());
                  adress_longitude = position1.longitude.toString();
                  adress_latitude = position1.latitude.toString();
                  adress_speed=(position1.speed*3.6).toString();
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

  void recuperer_adr() async { /// on essaye de recuperer nos données (positoin , vitesse ...)
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
        _color =Color.fromRGBO(152,238,153, 1);
        siconnecte = 'Connecté';
        buttoncolor = Color.fromRGBO(0,80,5, 1);
        recuperer_adr();
        setState(() {});
          }
    else {
      connected = false;
      _color = Color.fromRGBO(255,138,128, 1);
      buttoncolor = Color.fromRGBO(127,0,0, 1);
      siconnecte = 'Pas Connecté';
      print('stream cancelled');
      recuperer_adr();
      setState(() {});
          }
    }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(widget.title , style: TextStyle( fontWeight: FontWeight.bold ,fontSize: 22.0 , color: Color.fromRGBO(254,38,77,1)),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(255,221,8,1),
        brightness: Brightness.dark,
        leading: Icon(Icons.directions_bus , size: 27.5,color: Color.fromRGBO(254,38,77,1)),
      ),
      
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
               Container(
                    height: 150,
                    width: 150,
                    margin: EdgeInsets.only(bottom: 60),
                    child: Image.asset('assets/images/logo.png', fit: BoxFit.contain, width: 25, height: 35,)
          ),
              Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                              'votre longitude est : ',
                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold ,color: Color.fromRGBO(254,38,77, 1)),
                              ),
                              Text(
                                '${adress_longitude}',
                                style: TextStyle(color:/* Color.fromRGBO(208,92,227, 1)*/ Colors.black87, fontSize: 25),
                              ),]),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                              'votre latitude est : ',
                                style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Color.fromRGBO(254,38,77, 1) ),
                              ),
                              Text(
                                '$adress_latitude',
                                style: TextStyle(color:/* Color.fromRGBO(208,92,227, 1)*/ Colors.black87 , fontSize: 25),
                              ),
                            ]
            ),
                      ]
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 14, 0, 0),
                child :Text(
                'votre vitesse est : ',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold,color:Color.fromRGBO(254,38,77, 1)),

                ),
            ),
            Text(
              '$adress_speed',
              style: TextStyle(color: Colors.black87 , fontSize: 25),
            ),
            Container(
              width: 300,
              height: 80,
              margin: EdgeInsets.fromLTRB(0,60,0,15),
              child : RaisedButton.icon(
                         icon: Icon(Icons.settings_input_antenna,size: 50.5,color: buttoncolor),
                         label: Text(siconnecte , style: TextStyle( fontSize: 25.0,color: buttoncolor ),
                         ),
                        textColor: Colors.white ,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(75)),
                        elevation: 10,
                        onPressed: connect , ///les changements sur l'ecran se déclenche d'ici
                          color: _color,
                          highlightElevation: 10,
                      ),
            ),
            Text('ETAT : '+siconnecte, style: TextStyle(fontSize: 16.0),
            )
          ],
        ),
      ),
    );
  }
}
