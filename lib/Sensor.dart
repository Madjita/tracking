import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'HubService.dart';

class Sensor extends  StatefulWidget {
  @override
  State<Sensor> createState() => _SensorState();
}

class _SensorState extends State<Sensor>
{
  late double accelerometer_x = 0.0, accelerometer_y = 0.0, accelerometer_z = 0.0;
  late double gyroscope_x = 0.0, gyroscope_y = 0.0, gyroscope_z = 0.0;
  late double magnetometer_x = 0.0, magnetometer_y = 0.0, magnetometer_z = 0.0;

  @override
  void initState() {
    super.initState();

    //accelerometerEvents
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        accelerometer_x = event.x;
        accelerometer_y = event.y;
        accelerometer_z = event.z;
      });
      try
      {
        HubService.SendAccelerometer(event);
      }
      catch(e)
      {
        print("Возникло исключение $e");
      }
    }); //get the sensor data and set then to the data types

    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        gyroscope_x = event.x;
        gyroscope_y = event.y;
        gyroscope_z = event.z;
      });
      try
      {
        HubService.SendGyroscope(event);
      }
      catch(e)
      {
        print("Возникло исключение $e");
      }
    }); //get the sensor data and set then to the data types

    magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        magnetometer_x = event.x;
        magnetometer_y = event.y;
        magnetometer_z = event.z;
      });
      try
      {
        HubService.SendMagnetometer(event);
      }
      catch(e)
      {
        print("Возникло исключение $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container (
        alignment: Alignment.bottomCenter,
       // padding: EdgeInsets.all(30),
        child: Column(
            children: [
              Text("Accelerometer X: ${accelerometer_x.toStringAsFixed(5)}", style:TextStyle(fontSize: 20)),
              Text("Accelerometer Y: ${accelerometer_y.toStringAsFixed(5)}", style: TextStyle(fontSize: 20),),
              Text("Accelerometer Z: ${accelerometer_z.toStringAsFixed(5)}", style: TextStyle(fontSize: 20),),
              Text("Gyroscope X: ${gyroscope_x.toStringAsFixed(5)}", style:TextStyle(fontSize: 20)),
              Text("Gyroscope Y: ${gyroscope_y.toStringAsFixed(5)}", style: TextStyle(fontSize: 20),),
              Text("Gyroscope Z: ${gyroscope_z.toStringAsFixed(5)}", style: TextStyle(fontSize: 20),),
            ]
        )
    );
  }
}