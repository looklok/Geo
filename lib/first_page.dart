import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'dart:async';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application du bus',
      home: First(),
    );
  }
}
class First extends StatefulWidget {
  First({Key key,}) : super(key: key);

  @override
  _FirstState createState() => _FirstState();
}


class _FirstState extends State<First> {
  // This widget is the root of your application.
  var password;
  Future<QuerySnapshot> getPasswords() async {

    var pass = await Firestore.instance.collection('bus').getDocuments();
    return pass;
  }

   passwordVerification (QuerySnapshot query)
  {
    bool verifie=false; var i=0;
   while  (( i<query.documents.length)&&(verifie==false))
      {
        print('heeeeeeeeeerrrrrrrrrrrre' +query.documents[i].data['password'].floor().toString() );
        if(this.password == query.documents[i].data['password'].floor().toString()) verifie=true;
        else{i++;}
      }
      print(verifie.toString());
     if (verifie == true ) Navigator.push(context, MaterialPageRoute(builder: (context)=>MyHomePage(info: query.documents[i])));

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            body: Center(
              child: FutureBuilder(
              future : getPasswords(),
              builder :(context, possibledata){
              if (possibledata.data == null)
                {
                  return CircularProgressIndicator();
                }
                else {
                  return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                    margin: EdgeInsets.symmetric(vertical: 30.0, horizontal: 6.0),
                    width: 200,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color(0xfff5f5f5),
                      border: Border.all(color: Colors.black12)
                       ),
                     child: Center(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (String value) {password= value;},
                        style: TextStyle(fontSize: 20, color: Colors.black87),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.security),
                          border: InputBorder.none,
                          hintText: "MotDePasse",
                          ),
                            ),
                          ),
                        ),

                        Container(
                        width: 150,
                        height: 48,
                        child: FlatButton(
                            onPressed: () { passwordVerification(possibledata.data);},
                            child: Text('Connect', style: TextStyle(color: Colors.white),)
                            ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            gradient: LinearGradient(
                            colors: [
                                Color.fromRGBO(254,38,77,1),
                                 Color.fromRGBO(255,221,8,1),
                            ],
                            ),
                            boxShadow: [
                            BoxShadow(
                            color: Color(0xCCf95149),
                            offset: Offset(0, 3),
                            blurRadius: 10)
                            ],
                    ),)
                  ]
                  );
                  }
                 }
        )));
    }
  }
