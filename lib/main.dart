import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:loco_pendulum/variables.dart';

import 'methods.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

/// *****************
/// *****************
/// Current task - stop it from using so much memory

/// Converts the double passed from degrees to radians
double deg2Rad(double degrees) {
  return degrees * (math.pi / 180);
}

/// Converts the double passed from radians to degrees
double rad2Deg(double degrees) {
  return degrees * (180 / math.pi);
}

/// Calculates the delta time from the last iteration and multiplies by timeScale
//Duration deltaTimeCalc() {
//  DateTime timeNow = DateTime.now();
//  Duration deltaTime = timeNow.difference(timeOld);
//  timeOld = timeNow;
//  return deltaTime;
//}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  // double g = 9.81; // m/s2
  // double m1 = 10; // kg  arm 1 mass
  // double m2 = 10; // kg  arm 2 mass
  // double l1 = 1.1; // m  arm 1 length
  // double l2 = 1.1; // m  arm 2 length
  // double arm1Acc = 0.0; // m/s2
  // double arm1Vel = 0.4; // m/s
  // double arm2Acc = 0.0; // m/s2
  // double arm2Vel = -1.7; // m/s
  // double arm1Angle = deg2Rad(120); //
  // double arm2Angle = deg2Rad(90); // degrees
  // final double timeScale =
  //     0.00000000002; // scale factor for time to modify magnitude of the effect of the time step
  // DateTime timeOld = DateTime.now();

  // final double timerLimit = 20000;
  // //bool streamRun = true;
  // double screenSizeFactor = 1;
  //
  // /// TODO: might need to move this one and others out into a variables file for better design
  // double armLengthFactor = 200;
  // double arm1Width = 0.2;
  // double arm2Width = 0.2;

  double _t = 0;

  Stream<double> runPendulumStream() async* {
    //var random = Random(2);
    while (true) {
      await Future.delayed(Duration(milliseconds: 1));
      _pendulumCalc();
      yield arm1Angle;
    }
  }

  void _pendulumCalc() {
    _t = 0;

    if (arm1Touch == true) {
      setState(() {
        arm1PanUpdate;
      });
    } else {
      while (_t < (1 * 0.00000056) && streamRun == true) {
        //while (streamRun == true) {
        //for (int _i = 0; _i < 100; _i++) {
        setState(() {
          arm1Acc = (-g * (2 * arm1Mass + arm2Mass) * math.sin(arm1Angle) -
                  arm2Mass * g * math.sin((arm1Angle - 2 * arm2Angle)) -
                  2 *
                      math.sin((arm1Angle - arm2Angle)) *
                      arm2Mass *
                      ((arm2Vel * arm2Vel) * arm2Length +
                          (arm1Vel * arm1Vel) *
                              math.cos((arm1Angle - arm2Angle)))) /
              (arm1Length *
                  (2 * arm1Mass +
                      arm2Mass -
                      arm2Mass * math.cos((2 * arm1Angle - 2 * arm2Angle))));

          arm2Acc = (2 *
                  math.sin((arm1Angle - arm2Angle)) *
                  ((arm1Vel * arm1Vel) * arm1Length * (arm1Mass + arm2Mass) +
                      g * (arm1Mass + arm2Mass) * math.cos(arm1Angle) +
                      (arm2Vel * arm2Vel) *
                          arm2Length *
                          arm2Mass *
                          math.cos((arm1Angle - arm2Angle)))) /
              (arm2Length *
                  (2 * arm1Mass +
                      arm2Mass -
                      arm2Mass * math.cos((2 * arm1Angle - 2 * arm2Angle))));

          arm1Vel = arm1Vel + arm1Acc * _t;
          arm1Angle = arm1Angle + arm1Vel * _t;
          arm2Vel = arm2Vel + arm2Acc * _t;
          arm2Angle = arm2Angle + arm2Vel * _t;

          // print('arm1Angle');
          // print(rad2Deg(arm1Angle));
          // print("arm2Angle");
          // print(rad2Deg(arm2Angle));

          _t = _t + (1 * timeScale);

          //print("Time  $_t");
        });
      }
    }
  }

/*
  Stream<int> timedCounter(Duration interval, [int? maxCount]) async* {
    int i = 0;
    while (true) {
      await Future.delayed(interval);
      yield i++;
      if (i == maxCount) break;
    }
  }



  Stream<double> getRandomValues() async* {
    var random = Random(2);
    while (streamRun == true) {
      //await Future.delayed(Duration(seconds: 1));
      yield random.nextDouble();
    }
  }

 */

  @override
  void initState() {
    runPendulumStream().listen((value) {});
    super.initState();
  }

  /// TODO: make ability to view the system from the viewpoint of the end of the pendulum
  /// TODO: also for the above  - have ability to change the picot points such (and have multiple trailing pattern points) so that the pivot can be outside of the arm for interesting effects
  /// TODO: Need to make is run off delta time just incase some devices run faster than others. Alternative is to account for this in speed scale function controllable by the user.

  @override
  Widget build(BuildContext context) {
    double pivotOffsetInArm = armWidthCalc(1);

    /// TODO: change the pivot point math so that it does not always reference the arm width as part of its offset but rather use a dedicated offset variable that can be changed depending on the arm graphic used

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
      body: Stack(
        clipBehavior: Clip.none,
        //alignment: Alignment.center,
        children: <Widget>[
          Center(
            child: SizedBox(
              height: armLengthCalc(3) * 2,
              width: armLengthCalc(3) * 2,
              child: Center(
                child: Stack(
                    alignment: Alignment.center,

                    children: <Widget>[
                  Center(
                    child: Transform.translate(
                      offset: Offset(0, armLengthCalc(1) / 2),
                      child: Transform.rotate(
                        angle: arm1Angle,
                        origin: Offset(0, -armLengthCalc(1) / 2),
                        //-80),
                        child: Container(
                          height: armLengthCalc(1),
                          width: armWidthCalc(1),
                          color: Colors.deepOrange,
                          // decoration: BoxDecoration(
                          //     border: Border.all(
                          //       color: Colors.red,
                          //     ),
                          //     borderRadius: BorderRadius.all(
                          //         Radius.circular(armWidthCalc(1) / 2))),
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(
                        -(armLengthCalc(1)) * sin(arm1Angle),
                        (armLengthCalc(1)) * cos(arm1Angle)+armLengthCalc(2)/2),
                  // -(armLengthCalc(1)) * sin(arm1Angle) + armLengthCalc(3) - armWidthCalc(2)/2,
                        // (armLengthCalc(1)) * cos(arm1Angle) + armLengthCalc(3)),
                    child: Transform.rotate(
                      angle: arm2Angle,
                      origin:
                          Offset(0, -armLengthCalc(2)/2),
                      child: Container(
                        height: armLengthCalc(2),
                        width: armWidthCalc(2),
                        color: Colors.deepPurpleAccent,
                        // decoration: BoxDecoration(
                        //     border: Border.all(
                        //       color: Colors.deepPurpleAccent,
                        //     ),
                        //     borderRadius: BorderRadius.all(
                        //         Radius.circular(armWidthCalc(2) / 2))),
                      ),
                    ),
                  ),

                  ///Gesture detector stuff under here
                  // /// GestureDetector for Arm 1
                  // Center(
                  //   child: GestureDetector(
                  //     //TODO: working here. need to get angle to update upon first tap on screen
                  //     onPanDown: arm1PanStart,
                  //     onPanUpdate: arm1PanUpdate,
                  //     onPanEnd: arm1PanEnd,
                  //     child: Opacity(
                  //       opacity: 0.5,
                  //       child: Container(
                  //         width: (armLengthCalc(1) * 2) ,
                  //         //height: 300,
                  //         decoration: new BoxDecoration(
                  //             shape: BoxShape.circle,
                  //             color: Colors.greenAccent),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // Center(
                  //   child: Transform.rotate(
                  //     angle: arm1Angle,
                  //     child: Transform.translate(
                  //       offset:
                  //           Offset((armLengthCalc(1) + armWidthCalc(1)) / 2, 0),
                  //       child: Container(
                  //         width: armLengthCalc(1),
                  //         height: armLengthCalc(1) * 2,
                  //         color: Colors.transparent,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // Center(
                  //   child: Transform.rotate(
                  //     angle: arm1Angle,
                  //     child: Transform.translate(
                  //       offset: Offset(
                  //           -(armLengthCalc(1) + armWidthCalc(1)) / 2, 0),
                  //       child: Container(
                  //         width: armLengthCalc(1),
                  //         height: armLengthCalc(1) * 2,
                  //         color: Colors.transparent,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // Center(
                  //   child: Transform.rotate(
                  //     angle: arm1Angle,
                  //     child: Transform.translate(
                  //       offset: Offset(
                  //           0, -(armLengthCalc(1)) / 2),
                  //       child: Container(
                  //         width: armWidthCalc(1) * 2,
                  //         height: armLengthCalc(1),
                  //         color: Colors.transparent,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  //
                  // /// GestureDetector for Arm 2
                  // Center(
                  //   child: GestureDetector(
                  //     onPanDown: arm1PanStart,
                  //     onPanUpdate: arm1PanUpdate,
                  //     onPanEnd: arm1PanEnd,
                  //     child: Opacity(
                  //       opacity: 0.5,
                  //       child: Container(
                  //         width: arm2OuterGestureLimit()
                  //         //((armLengthCalc(1) * 2) - armWidthCalc(1)) +
                  //         //   ((armLengthCalc(2) -armWidthCalc(2))* 2),
                  //         ,
                  //         //height: 300,
                  //            decoration: new BoxDecoration(
                  //             shape: BoxShape.circle,
                  //             color: Colors.lightBlueAccent),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  //     Center(
                  //       child: Transform.translate(
                  //         offset: Offset(0, armLengthCalc(1) / 2),
                  //         child: Transform.rotate(
                  //           angle: arm1Angle,
                  //           origin: Offset(0, -armLengthCalc(1) / 2),
                  //           //-80),
                  //           child: Container(
                  //             //height: armLengthCalc(1),
                  //             //width: armWidthCalc(1),
                  //             //color: Colors.purpleAccent,
                  //             // decoration: BoxDecoration(
                  //             //     border: Border.all(
                  //             //       color: Colors.red,
                  //             //     ),
                  //             //     borderRadius: BorderRadius.all(
                  //             //         Radius.circular(armWidthCalc(1) / 2))),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     Transform.translate(
                  //       offset: Offset(
                  //           -(armLengthCalc(1)) * sin(arm1Angle) ,
                  //           (armLengthCalc(1)) * cos(arm1Angle)+armLengthCalc(2)/2),
                  //       // -(armLengthCalc(1)) * sin(arm1Angle) + armLengthCalc(3) - armWidthCalc(2)/2,
                  //       // (armLengthCalc(1)) * cos(arm1Angle) + armLengthCalc(3)),
                  //       child: Transform.rotate(
                  //         angle: arm2Angle,
                  //         origin:
                  //         Offset(0, -armLengthCalc(2)/2),
                  //         child: Transform.translate(
                  //           offset: Offset(armWidthCalc(2),0),
                  //           child: Container(
                  //             height: armLengthCalc(2),
                  //             width: armWidthCalc(2),
                  //             color: Colors.yellow,
                  //             // decoration: BoxDecoration(
                  //             //     border: Border.all(
                  //             //       color: Colors.deepPurpleAccent,
                  //             //     ),
                  //             //     borderRadius: BorderRadius.all(
                  //             //         Radius.circular(armWidthCalc(2) / 2))),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            child: Slider(
              min: armLengthSliderMin,
              max: armLengthSliderMax,
              value: arm1Length,
              onChanged: (double value) {
                setState(() {
                  arm1Length = value;
                  // print('arm1Angle');
                  // print(rad2Deg(arm1Angle));
                  // print("arm2Angle");
                  // print(rad2Deg(arm2Angle));
                  // print('resultant length');
                  // print(arm2OuterGestureLimit());
                  // print('inner circle radius');
                  // print(armLengthCalc(1));
                });
              },
            ),
          ),
          Positioned(
            bottom: 40,
            child: Slider(
              min: armLengthSliderMin,
              max: armLengthSliderMax,
              value: arm2Length,
              onChanged: (double value) {
                setState(() {
                  arm2Length = value;
                });
              },
            ),
          ),
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    pausePlay();
                  },
                  child: Container(
                    color: Colors.lightBlue,
                    width: 100,
                    height: 60,
                    child: const Text(
                      "Pause/Play",
                      style: TextStyle(fontSize: 17, color: Colors.black),
                    ),
                  )),
              TextButton(
                  onPressed: () {
                    resetToDefinedPosAndPause();
                  },
                  child: Container(
                    color: Colors.lightBlue,
                    width: 100,
                    height: 60,
                    child: const Text(
                      "Reset",
                      style: TextStyle(fontSize: 17, color: Colors.black),
                    ),
                  )),
              TextButton(
                  onPressed: () {
                    pausePlay();
                  },
                  child: Container(
                    color: Colors.lightBlue,
                    width: 100,
                    height: 60,
                    child: const Text(
                      "Play",
                      style: TextStyle(fontSize: 17, color: Colors.black),
                    ),
                  )),
            ],
          ),
        ],
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //       setState(() {
      //         //streamRun = !streamRun;
      //         print(streamRun);
      //         //runPendulumStream().listen((value) {});
      //       });
      //
      //   }, //_incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
