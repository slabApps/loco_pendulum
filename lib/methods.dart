import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:loco_pendulum/variables.dart';
import 'dart:math' as math;

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
    return l1 * armLengthFactor * screenSizeFactor;
  } else if (armNumber == 2) {
    return l2 * armLengthFactor * screenSizeFactor;
  } else {
    return armLengthSliderMax * armLengthFactor * screenSizeFactor;
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
  double newVelocity = velocity + accel * timeCount;
  return newVelocity;
}

//double angleCalc(double angle, double velocity) {
//  //setState(() {
//  //print("angle calc");
//  double newAngle = angle + velocity * timeCount;
//  return newAngle;
//  //});
//}

void pausePlay() {
  streamRun = !streamRun;
}

void resetToRandomAndPause() {
  streamRun = false;
}

void resetToDefinedPosAndPause() {
  streamRun = false;
  m1 = m1Default; // kg  arm 1 mass
  m2 = m2Default; // kg  arm 2 mass
  l1 = l1Default; // m  arm 1 length
  l2 = l2Default; // m  arm 2 length
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

void compassRosePanStart(DragDownDetails details) {
  // if (hdgFreeze == false) {
  //   hdgFreezeToggle();
  //   allFreezeCheck();
  // }

  //streamRun = false;

  rosePanStartRadialPos =
      details.localPosition; // - compassRoseTouchOuterOffset;
  rosePanStartRadialAngle =
      pan360logic(rosePanStartRadialPos.dx, rosePanStartRadialPos.dy);
  //headingPanStart = headingSourceLogic();
}

void compassRosePan(DragUpdateDetails d) {
  Offset _panRadialPos = d.localPosition; // - compassRoseTouchOuterOffset;
  double _panAngle = pan360logic(_panRadialPos.dx, _panRadialPos.dy);
  double _panRadialAngleDelta = 0;

  // Logic for rose rotation in same direction as finger movement
  if (rosePanStartRadialAngle > _panAngle) {
    _panRadialAngleDelta = -(360 + (_panAngle - rosePanStartRadialAngle)).abs();
  } else {
    _panRadialAngleDelta = -(_panAngle - rosePanStartRadialAngle).abs();
  }

  if (headingPanStart + _panRadialAngleDelta < 0) {
    arm1Angle = -deg2Rad((headingPanStart + _panRadialAngleDelta) + 360);
  } else {
    arm1Angle = -deg2Rad(headingPanStart + _panRadialAngleDelta);
  }

  // Code for rounding the heading value to 1 degree
// TODO: add option in settings for level of rounding. add code for rounding to nearest 5
  //manualHDG = roundMe(manualHDG, 2);
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

// /// Helper to round values to set decimal places
// double roundMe(double _val, double _places) {
//   double _mod = pow(10.0, _places);
//   return ((_val * _mod).round().toDouble() / _mod);
// }
