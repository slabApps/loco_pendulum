import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:loco_pendulum/variables.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';

//TODO: make a ragdoll button where it's manual/accelerometer only and responds accordingly

/// Converts the double passed from degrees to radians
double deg2Rad(double degrees) {
  return degrees * (math.pi / 180);
}

/// Converts the double passed from radians to degrees
double rad2Deg(double degrees) {
  return degrees * (180 / math.pi);
}

double armLengthCalc(int armNumber) {
  if (armNumber == 1) {
    return arm1Length * armLengthFactor * screenSizeFactor;
  } else if (armNumber == 2) {
    return arm2Length * armLengthFactor * screenSizeFactor;
  } else {
    return arm2OuterGestureLimit()/2;
  }
}

double armWidthCalc(int armNumber) {
  if (armNumber == 1) {
    return arm1Width * armLengthFactor * screenSizeFactor;
  } else {
    return arm2Width * armLengthFactor * screenSizeFactor;
  }
}

double arm1AccCalc() {
  //print("acc calc");
  return (-g * (2 * arm1Mass + arm2Mass) * math.sin(arm1Angle) -
          arm2Mass * g * math.sin((arm1Angle - 2 * arm2Angle)) -
          2 *
              math.sin((arm1Angle - arm2Angle)) *
              arm2Mass *
              ((arm2Vel * arm2Vel) * arm2Length +
                  (arm1Vel * arm1Vel) * math.cos((arm1Angle - arm2Angle)))) /
      (arm1Length *
          (2 * arm1Mass +
              arm2Mass -
              arm2Mass * math.cos((2 * arm1Angle - 2 * arm2Angle))));
}

/// Calculates the acceleration of Arm 2
double arm2AccCalc() {
  return (2 *
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
}

double velocityCalc(double velocity, double accel) {
  //print("vel calc");
  double newVelocity = velocity + accel * timeCount;
  return newVelocity;
}

// void pendCalc(){
//   arm1Acc = (-g * (2 * m1 + m2) * math.sin(arm1Angle) -
//       m2 * g * math.sin((arm1Angle - 2 * arm2Angle)) -
//       2 *
//           math.sin((arm1Angle - arm2Angle)) *
//           m2 *
//           ((arm2Vel * arm2Vel) * l2 +
//               (arm1Vel * arm1Vel) *
//                   math.cos((arm1Angle - arm2Angle)))) /
//       (l1 *
//           (2 * m1 +
//               m2 -
//               m2 * math.cos((2 * arm1Angle - 2 * arm2Angle))));
//
//   arm2Acc = (2 *
//       math.sin((arm1Angle - arm2Angle)) *
//       ((arm1Vel * arm1Vel) * l1 * (m1 + m2) +
//           g * (m1 + m2) * math.cos(arm1Angle) +
//           (arm2Vel * arm2Vel) *
//               l2 *
//               m2 *
//               math.cos((arm1Angle - arm2Angle)))) /
//       (l2 *
//           (2 * m1 +
//               m2 -
//               m2 * math.cos((2 * arm1Angle - 2 * arm2Angle))));
//
//   arm1Vel = arm1Vel + arm1Acc * _t;
//   arm1Angle = arm1Angle + arm1Vel * _t;
//   arm2Vel = arm2Vel + arm2Acc * _t;
//   arm2Angle = arm2Angle + arm2Vel * _t;
//
//   //print(arm1Angle);
//
//
// }

double angleCalc(double angle, double velocity) {
  //setState(() {
  //print("angle calc");
  double newAngle = angle + velocity * timeCount;
  return newAngle;
  //});
}

void pausePlay() {
  streamRun = !streamRun;
}

void resetToRandomAndPause() {
  streamRun = false;
}

void resetToDefinedPosAndPause() {
  streamRun = false;
  arm1Mass = m1Default; // kg  arm 1 mass
  arm2Mass = m2Default; // kg  arm 2 mass
  arm1Length = l1Default; // m  arm 1 length
  arm2Length = l2Default; // m  arm 2 length
  arm1Acc = arm1AccDefault; // m/s2
  arm1Vel = arm1VelDefault; // m/s
  arm2Acc = arm2AccDefault; // m/s2
  arm2Vel = arm2VelDefault; // m/s
  arm1Angle = arm1AngleDefault; //
  arm2Angle = arm2AngleDefault; // degrees
  timeCount = 0;
}

void armPanDown(var angle) {
  streamRun = false;
  angle = angle;
}

void armPanUpdate(var angle) {}

void arm1PanStart(DragDownDetails details) {
  // if (hdgFreeze == false) {
  //   hdgFreezeToggle();
  //   allFreezeCheck();
  // }
  arm1Touch = true;
  arm1Vel = 0;
  arm1Acc = 0;
  arm2Vel = 0;
  arm2Acc = 0;

  //streamRun = false;

  arm1PanStartRadialPos = details.localPosition - arm1TouchOfset;
  arm1PanStartRadialAngle =
      pan360logic(arm1PanStartRadialPos.dx, arm1PanStartRadialPos.dy);
  arm1PanInitial = -rad2Deg(arm1Angle);
  //headingPanStart = headingSourceLogic();
}

void arm1PanUpdate(DragUpdateDetails d) {
  Offset _panRadialPos = d.localPosition - arm1TouchOfset;
  double _panAngle = pan360logic(_panRadialPos.dx, _panRadialPos.dy);
  double _panRadialAngleDelta = 0;

  // Logic for rose rotation in same direction as finger movement
  if (arm1PanStartRadialAngle > _panAngle) {
    _panRadialAngleDelta = -(360 + (_panAngle - arm1PanStartRadialAngle)).abs();
  } else {
    _panRadialAngleDelta = -(_panAngle - arm1PanStartRadialAngle).abs();
  }

  if (arm1PanInitial + _panRadialAngleDelta < 0) {
    arm1Angle = -deg2Rad((arm1PanInitial + _panRadialAngleDelta) + 360);
  } else {
    arm1Angle = -deg2Rad(arm1PanInitial + _panRadialAngleDelta);
  }

  // Code for rounding the heading value to 1 degree
// TODO: add option in settings for level of rounding. add code for rounding to nearest 5
  //manualHDG = roundMe(manualHDG, 2);
}

void arm1PanEnd(DragEndDetails) {
  arm1Touch = false;
}

/// Logic to turn quadrants and their respective angles into a continuous 0-360 degree circle
double pan360logic(double _xPos, double _yPos) {
  if (_xPos.sign > 0) {
    return degrees360Check(90, rad2Deg(atan(_yPos / _xPos)));
  } else {
    return degrees360Check(270, rad2Deg(atan(_yPos / _xPos)));
  }
}

/// This checks if the addition  of the value will go above 360
/// or below 0 and calculates the appropriate new value with respect to a
/// 360 degree circle. ******** This is an edited and simplified version from
/// the NavMath App. See those files for the full function *******
double degrees360Check(double _referenceAngle, double _addSubtractAngle) {
  if (_referenceAngle < _addSubtractAngle) {
    return 360 - (_addSubtractAngle - _referenceAngle);
  } else if ((_referenceAngle + _addSubtractAngle) >= 360) {
    return (_referenceAngle + _addSubtractAngle) - 360;
  } else {
    return _referenceAngle + _addSubtractAngle;
  }
}

double arm2OuterGestureLimit() {
  //TODO: Need to break the lengths into their respectrive x and y lengths then do math on those
  double arm1ActiveLength = (armLengthCalc(1)) ;
  double arm2ActiveLength = (armLengthCalc(2)) ;
  double armEndPointX =
      (arm1ActiveLength * sin(arm1Angle)) + (arm2ActiveLength * sin(arm2Angle));
  double armEndPointY =
      (arm1ActiveLength * cos(arm1Angle)) + (arm2ActiveLength * cos(arm2Angle));
  double arm2OuterGestureLength;
  //double _angleOfIncedence =
  //(180 - (arm1Angle - arm2Angle)).abs();

  //var v = new Vector2(1, 2);
  //var u = new Vector2(4, 5);
  //var angleInRadians = Acos(Vector2.Dot(v, u) / (v.Length() * u.Length()));
  /// Use the end point, find it's angle from the origin. Then subtract the first
  /// arm angle to find the angle between the two. This will give the close angle
  /// of the oblique triangle. Next, use the end point details to find it's hypotenuse
  /// from the origin. We then have the angle and length to the end point.
  /// Late realisation, just need to get the hypotenuse to the end point and that's it.

  double resultantLength =
      sqrt((armEndPointX * armEndPointX) + (armEndPointY * armEndPointY));

  if (resultantLength < armLengthCalc(1) ) {
    arm2OuterGestureLength = 2 * armLengthCalc(1);
  } else {
    arm2OuterGestureLength = 2 * resultantLength;
  }

  return arm2OuterGestureLength;
}

// /// Helper to round values to set decimal places
// double roundMe(double _val, double _places) {
//   double _mod = pow(10.0, _places);
//   return ((_val * _mod).round().toDouble() / _mod);
// }
