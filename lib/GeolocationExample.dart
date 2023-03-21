import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'HubService.dart';
import 'dart:isolate';

class GeolocationExample extends  StatefulWidget {
  @override
  State<GeolocationExample> createState() => _GeolocationExampleState();
}

class _GeolocationExampleState extends State<GeolocationExample>
{
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Hook();
      /*Scaffold(
        appBar: AppBar(
            title: Text("Get GPS Location"),
            backgroundColor: Colors.blueAccent
        ),
        body: Hook()
    );*/
  }
}

class Hook extends HookWidget {
  Hook({Key? key}): super(key: key)
  {
    //_appHub = HubService();
    checkGps();
  }

  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  Position? position;
  String long = "", lat = "", altitude = "";
  late StreamSubscription<Position> positionStream;
  //late HubService _appHub;

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if(servicestatus)
    {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied)
      {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied)
        {
          print('Location permissions are denied');
        }
        else if(permission == LocationPermission.deniedForever)
        {
          print("'Location permissions are permanently denied");
        }
        else
        {
          haspermission = true;
        }
      }
      else
      {
        haspermission = true;
      }

      if(haspermission)
      {
        await HubService.Connection('http://95.188.89.10:5000/appHub');
        await getLocation();
      }
    }else{
      print("GPS Service is not enabled, turn on GPS location");
    }
  }

  getLocation() async
  {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation, //accuracy of the location data
      distanceFilter: 0, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings).listen((Position position) {

      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457
      print(position.altitude);

      long = position.longitude.toString();
      lat = position.latitude.toString();
      altitude = position.altitude.toString();

      if(this.position != null) {

          if(!(this.position == position)){
            this.position = position;
            try
            {
              HubService.SendGpsCoordinates(position);
            }
            catch(e)
            {
              print("Возникло исключение $e");
            }
          }
      }
      else {
        this.position = position;

        try
        {
          HubService.SendGpsCoordinates(position);
        }
        catch(e)
        {
          print("Возникло исключение $e");
        }
      }

    });
  }

  /*dynamic setHookGPS(ValueNotifier<String> longitude, ValueNotifier<String> latitude,ValueNotifier<String> altitude) async
  {
    if(!_appHub.flagConnection)
    {
      _appHub.Connection('http://95.188.89.10:5000/appHub');
    }
    longitude.value = this.long;
    latitude.value = this.lat;
    altitude.value = this.altitude;
  }*/

  dynamic setHookGPS(ValueNotifier<Position?> position) async
  {
    if(!HubService.flagConnection)
    {
      HubService.Connection('http://95.188.89.10:5000/TelemetryHub');
    }
    if(this.position != null)
    {
      position!.value = this!.position;//await this.position.clone();
    }
  }
  dynamic setSpeedGPS(ValueNotifier<double> speedGPS) async
  {
    if(this.position != null)
    {
      speedGPS!.value = this!.position!.speed * 3.6;
    }
  }

  int getDegreesGPS(double degrees)
  {
    return degrees.toInt();
  }
  dynamic getMinutesGPS(double degrees)
  {
    return ((degrees - getDegreesGPS(degrees)) * 60 );
  }
  dynamic getSecondsGPS(double degrees)
  {
    return (( ((degrees - getDegreesGPS(degrees)) * 60) - getMinutesGPS(degrees).toInt() )*60 ).round();
  }
  dynamic directionLatGPS(double degrees)
  {
    return  (degrees >= 0 ? "N" : "S");
  }
  dynamic directionLongGPS(double degrees)
  {
    return  (degrees >= 0 ? "E" : "W");
  }

  dynamic getLatGPSMinutesAndSeconds(double degrees)
  {
    var direction = directionLatGPS(degrees);
    var minuts = getMinutesGPS(degrees).toInt();
    var result = "${getDegreesGPS(degrees).toString()}°${minuts < 10 ? "0${minuts.toString()}" : minuts.toString() }'${getSecondsGPS(degrees).toInt().toString()}\"${direction}";
    return result;
  }

  dynamic getLongGPSMinutesAndSeconds(double degrees)
  {
    var direction = directionLongGPS(degrees);
    var minuts = getMinutesGPS(degrees).toInt();
    var result = "${getDegreesGPS(degrees).toString()}°${minuts < 10 ? "0${minuts.toString()}" : minuts.toString() }'${getSecondsGPS(degrees).toInt().toString()}\"${direction}";
    return result;
  }





  @override
  Widget build(BuildContext buildContext)
  {
    final _count = useState(0);
    final position = useState<Position>(new Position(longitude: 0, latitude: 0, timestamp: null, accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0));
    final speedGPS = useState(0.0);


    useEffect((){
      final timer = Timer.periodic(Duration(seconds: 1), (timer) async {
        _count.value = timer.tick;
        setSpeedGPS(speedGPS);
        await setHookGPS(position);
        //await setHookGPS(longitude,latitude,altitude);
      });
      //return timer.cancel;
    },[]);

    return Container (
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: Column(
            children: [
              Text("Timer tick: ${_count.value}"),
              Text(servicestatus? "GPS is Enabled": "GPS is disabled."),
              Text(haspermission? "GPS is Enabled": "GPS is disabled."),

              //Text("Longitude: ${position.value!.longitude.toStringAsFixed(5)}", style:TextStyle(fontSize: 20)),
              //Text("Latitude: ${position.value!.latitude.toStringAsFixed(5)}", style: TextStyle(fontSize: 20),),
              Text("Latitude: ${getLatGPSMinutesAndSeconds(position.value!.latitude)}", style: TextStyle(fontSize: 20),),
              Text("Longitude: ${getLongGPSMinutesAndSeconds(position.value!.longitude)}", style:TextStyle(fontSize: 20)),

              Text("Altitude: ${position.value!.altitude.toStringAsFixed(5)}", style: TextStyle(fontSize: 20),),

              Text("Heading: ${position.value!.heading.toStringAsFixed(5)}", style: TextStyle(fontSize: 20),),
              Text("Accuracy: ${position.value!.accuracy.toStringAsFixed(5)}", style: TextStyle(fontSize: 20),),
              Text("SpeedGPS: ${speedGPS.value.toStringAsFixed(5)} km/h", style: TextStyle(fontSize: 20),),
              Text("Speed: ${position.value!.speed.toStringAsFixed(5)}", style: TextStyle(fontSize: 20),),
              Text("SpeedAccuracy: ${position.value!.speedAccuracy.toStringAsFixed(5)}", style: TextStyle(fontSize: 20),),
              Text("isMocked: ${position.value!.isMocked.toString()}", style: TextStyle(fontSize: 17),)
            ]
        )
    );
  }
}


extension Clone<T> on T {
  Future<T> clone() {
    final receive = ReceivePort();
    receive.sendPort.send(this);

    return receive.first.then((e) => e as T).whenComplete(receive.close);
  }
}