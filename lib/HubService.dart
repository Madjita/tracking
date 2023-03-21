import 'dart:convert';
import 'dart:ffi';

import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:signalr_client/signalr_client.dart';

class HubService {
  static String? _url = "";
  static HubConnection? connection;
  static bool flagConnection = false;
  // ignore: non_constant_identifier_names
  static dynamic Connection(String url) async {
    _url = url;
    connection = HubConnectionBuilder()
        .withUrl(_url)
        .build();

    try
    {
      await connection!.start();
    }
    catch(e)
    {
      //print("Возникло исключение  при подключении к хабу $e");
      flagConnection = false;
      return flagConnection;
    }
    connection!.onclose((error) {
      print("Connection Closed");
      flagConnection = false;
    });

    flagConnection = true;
    return flagConnection;
  }

  /// Converts the [Position] instance into a [Map] instance that can be
  /// serialized to JSON.
  static Map<String, dynamic> accelerometerToJson(UserAccelerometerEvent accelerometer) => {
    'x': accelerometer.x,
    'y': accelerometer.y,
    'z': accelerometer.z,
  };
  /// Converts the [Position] instance into a [Map] instance that can be
  /// serialized to JSON.
  static Map<String, dynamic> gyroscopeToJson(GyroscopeEvent gyroscope) => {
    'x': gyroscope.x,
    'y': gyroscope.y,
    'z': gyroscope.z,
  };
  /// Converts the [Position] instance into a [Map] instance that can be
  /// serialized to JSON.
  static Map<String, dynamic> magnetometerToJson(MagnetometerEvent magnetometer) => {
    'x': magnetometer.x,
    'y': magnetometer.y,
    'z': magnetometer.z,
  };


  // Define a method to receive GPS coordinates
  static void SendGpsCoordinates(Position position) async
  {
    // Process GPS coordinates here
    if(flagConnection) {
      await connection?.invoke('GetGpsCoordinates', args: [json.encode(position.toJson())]);
    }
  }

  static void SendAccelerometer(UserAccelerometerEvent accelerometer) async
  {
    // Process GPS coordinates here
    if(flagConnection) {
      await connection?.invoke('GetAccelerometer', args: [json.encode(accelerometerToJson(accelerometer))]);
    }
  }

  static void SendGyroscope(GyroscopeEvent gyroscope) async
  {
    // Process GPS coordinates here
    if(flagConnection) {
      await connection?.invoke('GetGyroscopePhone', args: [json.encode(gyroscopeToJson(gyroscope))]);
    }
  }

  static void SendMagnetometer(MagnetometerEvent magnetometer) async
  {
    // Process GPS coordinates here
    if(flagConnection) {
      await connection?.invoke('GetMagnetometerPhone', args: [json.encode(magnetometerToJson(magnetometer))]);
    }
  }

}
