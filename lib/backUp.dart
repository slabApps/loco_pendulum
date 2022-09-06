/*





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
  double g = 9.81; // m/s2
  double m1 = 10; // kg  arm 1 mass
  double m2 = 10; // kg  arm 2 mass
  double l1 = 1; // m  arm 1 length
  double l2 = 1; // m  arm 2 length
  double arm1Acc = 0.0; // m/s2
  double arm1Vel = 0.4; // m/s
  double arm2Acc = 0.0; // m/s2
  double arm2Vel = -1.7; // m/s
  double arm1Angle = deg2Rad(170); //
  double arm2Angle = deg2Rad(120); // degrees
  final double timeScale =
  0.00000000002; // scale factor for time to modify magnitude of the effect of the time step
  DateTime timeOld = DateTime.now();
  double _t = 0;
  final double timerLimit = 20000;
  bool streamRun = false;
  double screenSizeFactor = 1;

  /// TODO: might need to move this one and others out into a variables file for better design
  double armLengthFactor = 200;
  double arm1Width = 0.2;
  double arm2Width = 0.2;

  double armLengthCalc(int armNumber) {
    if (armNumber == 1) {
      return l1 * armLengthFactor * screenSizeFactor;
    } else {
      return l2 * armLengthFactor * screenSizeFactor;
    }
  }

  double armWidthCalc(int armNumber) {
    if (armNumber == 1) {
      return arm1Width * armLengthFactor * screenSizeFactor;
    } else {
      return arm2Width * armLengthFactor * screenSizeFactor;
    }
  }

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

    /*
      while (_t > timerLimit) {
        //arm1Angle = arm1Angle + deg2Rad(1);
        arm1Angle =
            angle1Calc(arm1Angle, velocity1Calc(arm1Vel, arm1AccCalc()));
        arm2Angle =
            angle2Calc(arm2Angle, velocity2Calc(arm1Vel, arm2AccCalc()));
        print(arm1Angle);
        _t++;
      }*/

    while (_t < (1 * 0.00000056)) {
      //while (streamRun == true) {
      //for (int _i = 0; _i < 100; _i++) {
      setState(() {
        arm1Acc = (-g * (2 * m1 + m2) * math.sin(arm1Angle) -
            m2 * g * math.sin((arm1Angle - 2 * arm2Angle)) -
            2 *
                math.sin((arm1Angle - arm2Angle)) *
                m2 *
                ((arm2Vel * arm2Vel) * l2 +
                    (arm1Vel * arm1Vel) *
                        math.cos((arm1Angle - arm2Angle)))) /
            (l1 *
                (2 * m1 + m2 - m2 * math.cos((2 * arm1Angle - 2 * arm2Angle))));

        arm2Acc = (2 *
            math.sin((arm1Angle - arm2Angle)) *
            ((arm1Vel * arm1Vel) * l1 * (m1 + m2) +
                g * (m1 + m2) * math.cos(arm1Angle) +
                (arm2Vel * arm2Vel) *
                    l2 *
                    m2 *
                    math.cos((arm1Angle - arm2Angle)))) /
            (l2 *
                (2 * m1 + m2 - m2 * math.cos((2 * arm1Angle - 2 * arm2Angle))));

        arm1Vel = arm1Vel + arm1Acc * _t;
        arm1Angle = arm1Angle + arm1Vel * _t;
        arm2Vel = arm2Vel + arm2Acc * _t;
        arm2Angle = arm2Angle + arm2Vel * _t;

        //print(arm1Angle);

        _t = _t + (1 * timeScale);
        //print("Time  $_t");
      });
    }
  }

  double arm1AccCalc() {
    //print("acc calc");
    return (-g * (2 * m1 + m2) * math.sin(arm1Angle) -
        m2 * g * math.sin((arm1Angle - 2 * arm2Angle)) -
        2 *
            math.sin((arm1Angle - arm2Angle)) *
            m2 *
            ((arm2Vel * arm2Vel) * l2 +
                (arm1Vel * arm1Vel) * math.cos((arm1Angle - arm2Angle)))) /
        (l1 * (2 * m1 + m2 - m2 * math.cos((2 * arm1Angle - 2 * arm2Angle))));
  }

  /// Calculates the acceleration of Arm 2
  double arm2AccCalc() {
    return (2 *
        math.sin((arm1Angle - arm2Angle)) *
        ((arm1Vel * arm1Vel) * l1 * (m1 + m2) +
            g * (m1 + m2) * math.cos(arm1Angle) +
            (arm2Vel * arm2Vel) *
                l2 *
                m2 *
                math.cos((arm1Angle - arm2Angle)))) /
        (l2 * (2 * m1 + m2 - m2 * math.cos((2 * arm1Angle - 2 * arm2Angle))));
  }

  double velocityCalc(double velocity, double accel) {
    //print("vel calc");
    double newVelocity = velocity + accel * _t;
    return newVelocity;
  }

  double angleCalc(double angle, double velocity) {
    //setState(() {
    //print("angle calc");
    double newAngle = angle + velocity * _t;
    return newAngle;
    //});
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

  /// TODO: make ability to view the system from the viewpoint of the end of the pendulum

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
        child: Transform.rotate(
          angle: arm1Angle,
          origin: Offset(0, 2 * -armWidthCalc(1)),//-80),
          child: Container(
            height: armLengthCalc(1),
            width: armWidthCalc(1),
            //color: Colors.deepOrange,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.deepOrange,
                ),
                borderRadius: BorderRadius.all(Radius.circular(armWidthCalc(1)/2))),
            child: Transform.translate(
              offset: Offset(0, armLengthCalc(1) - armWidthCalc(1)),
              child: Transform.rotate(
                angle: arm2Angle - arm1Angle,
                origin:  Offset(0, 2 * -armWidthCalc(1)),
                child: Container(
                  //height: 580,
                  width: armWidthCalc(2),
                  //color: Colors.deepPurpleAccent,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.deepPurpleAccent,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(armWidthCalc(2)/2))),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            streamRun = !streamRun;
            print(streamRun);
            runPendulumStream().listen((value) {});
          });
        }, //_incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}












 floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            runPendulumStream().listen((value) {});
            //pausePlay();
            //if(streamRun == true) {
            //  runPendulumStream().listen((value) {});
           // }
          });
        }, //_incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),





 */
