import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> with SingleTickerProviderStateMixin {
  bool claimVisible = false;

  Completer<GoogleMapController> _mapController = Completer();
  GoogleMapController mapController;

  Animation<double> animation;
  AnimationController _controller;

  static final response = jsonDecode('''{"victim_latitude": ["38.897336", "38.897336", "38.897338", "38.897338", "38.897338", "38.897337", "38.896159", "38.895103", "38.894885", "38.894788", "38.894788", "38.894788", "38.894785", "38.894785", "38.894784", "38.894784", "38.894784", "38.894786", "38.894786", "38.894786", "38.894782", "38.894682", "38.887742", "38.887177", "38.885668", "38.885283", "38.884851", "38.884411", "38.883971", "38.883551", "38.883082", "38.882928", "38.882807", "38.882719", "38.882665", "38.882638"], "victim_longitude": ["-77.01129", "-77.01129", "-77.010075", "-77.010075", "-77.009701", "-77.009078", "-77.009061", "-77.00916", "-77.009469", "-77.009777", "-77.009777", "-77.009777", "-77.010752", "-77.010948", "-77.01117", "-77.01117", "-77.01117", "-77.012178", "-77.012178", "-77.012178", "-77.014078", "-77.014413", "-77.014123", "-77.013933", "-77.013119", "-77.012912", "-77.01274", "-77.012642", "-77.01264", "-77.012749", "-77.013097", "-77.013303", "-77.013543", "-77.013794", "-77.014061", "-77.014337"], "attacker": "1ZC8G8L4BXFW3YUV7", "attacker_latitude": ["38.897336", "38.897336", "38.897338", "38.897338", "38.897338", "38.89628", "38.895178", "38.895103", "38.89479", "38.894788", "38.894788", "38.894788", "38.894785", "38.894784", "38.894784", "38.894784", "38.894786", "38.894786", "38.894786", "38.894792", "38.894782", "38.894706", "38.894485", "38.887563", "38.887177", "38.887177", "38.885746", "38.885365", "38.884943", "38.88452", "38.884078", "38.883648", "38.883341", "38.883006", "38.882864", "38.882688", "38.882647", "38.882613"], "attacker_longitude": ["-77.01129", "-77.01129", "-77.010075", "-77.009701", "-77.009701", "-77.009063", "-77.009049", "-77.00916", "-77.009518", "-77.009777", "-77.009777", "-77.009777", "-77.010752", "-77.01117", "-77.01117", "-77.01117", "-77.012178", "-77.012178", "-77.012178", "-77.013804", "-77.014078", "-77.014372", "-77.014528", "-77.014064", "-77.013933", "-77.013933", "-77.013166", "-77.012953", "-77.012771", "-77.012653", "-77.012633", "-77.012702", "-77.012847", "-77.013193", "-77.013419", "-77.013928", "-77.014212", "-77.015031"]}''');

  LatLng zero1;
  LatLng zero2;

  LatLng current1;
  LatLng current2;

  BitmapDescriptor suvIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor racerIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    var lat1 = double.parse((response['victim_latitude'] as List<dynamic>)[0] as String);
    var lon1 = double.parse((response['victim_longitude'] as List<dynamic>)[0] as String);
    zero1 = LatLng(lat1, lon1);
    current1 = LatLng(lat1, lon1);

    var lat2 = double.parse((response['attacker_latitude'] as List<dynamic>)[0] as String);
    var lon2 = double.parse((response['attacker_longitude'] as List<dynamic>)[0] as String);
    zero2 = LatLng(lat2, lon2);
    current2 = LatLng(lat2, lon2);

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(256, 256)), 'assets/automobile.png')
        .then((onValue) {
      suvIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(256, 256)), 'assets/racing.png')
        .then((onValue) {
      racerIcon = onValue;
    });

    super.initState();
    _controller = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: const Duration(seconds: 20),
    );

    animation = Tween<double>(begin: 0, end: 60).animate(_controller)
        ..addListener(() {
          var index = min((response['victim_latitude'] as List<dynamic>).length - 1, animation.value.round());

          var lat1 = double.parse((response['victim_latitude'] as List<dynamic>)[index] as String);
          var lon1 = double.parse((response['victim_longitude'] as List<dynamic>)[index] as String);
          current1 = LatLng(lat1, lon1);

          var lat2 = double.parse((response['attacker_latitude'] as List<dynamic>)[index] as String);
          var lon2 = double.parse((response['attacker_longitude'] as List<dynamic>)[index] as String);
          current2 = LatLng(lat2, lon2);

          if (mapController != null) {
            mapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
              target: current1, zoom: 16
            )));
          }

          setState(() {

          });
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget map() {
    return new Container(
      padding: EdgeInsets.all(30),
      height: 300,

      child: Card(
        child: GoogleMap(
          mapType: MapType.normal,
          markers: <Marker>[
            Marker(markerId: MarkerId("1"), position: current1, icon: suvIcon),
            Marker(markerId: MarkerId("2"), position: current2, icon: racerIcon),
          ].toSet(),
          initialCameraPosition: CameraPosition(
              target: current1,
              zoom: 16
          ),
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
            _mapController.complete(controller);
          },
        ),
      ),
    );
  }

  Widget h(String txt) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      height: 50,
      child: Text(
        txt,
        textAlign: TextAlign.start,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget f(String txt) {
    return Container(
        //padding: EdgeInsets.all(10),
        height: 30,
        child: Text(
          txt,
          textAlign: TextAlign.start,
          //style: TextStyle(height: 15),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (claimVisible) {
      return new Scaffold(
          appBar: AppBar(
                title: Text('Fair Claim'),
          ),
          body:
            SingleChildScrollView(
              child: Column(
                children: [
                  h('Info from vehicle:'),
                  Column(
                    children: [
                      f('Turn signal used: Left'),
                      f('Hands On'),
                      f('Seatbelt On'),
                    ]
                  ),
                  h('How it happened:'),
                  map(),
                  MaterialButton(
                    child: Text('Submit Claim'),
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                        //side: BorderSide(color: Colors.blue)
                    ),
                    onPressed: () {
                      setState(() {
                        claimVisible = false;
                      });
                    },
                  )
              ]
            ),
          ),

      );
    } else {
      return new Scaffold(
        appBar: AppBar(
          title: Text('< Insurance Startup >'),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0, // this will be set when a new tab is tapped
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              title: new Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.mail),
              title: new Text('Messages'),
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                title: Text('Profile')
            )
          ],
        ),
        body: GestureDetector(
          onTap: () {
            setState(() {
              claimVisible = true;
              _controller.forward();
            });
          },
          child: Image.asset(
              'assets/7.png',
              //width: MediaQuery.of(context).size.width
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center
          ),
        ),
      );
    }
  }
}