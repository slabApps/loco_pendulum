import 'dart:ui';

import 'methods.dart';

double gDefault = 9.81; // m/s2
double m1Default = 10; // kg  arm 1 mass
double m2Default = 10; // kg  arm 2 mass
double l1Default = 1.0; // m  arm 1 length
double l2Default = 1.0; // m  arm 2 length
double arm1AccDefault = 0.0; // m/s2
double arm1VelDefault = 0.4; // m/s
double arm2AccDefault = 0.0; // m/s2
double arm2VelDefault = -1.7; // m/s
double arm1AngleDefault = deg2Rad(120); //
double arm2AngleDefault = deg2Rad(90); // degrees
double timeCount = 0;

double g = gDefault; // m/s2
double m1 = m1Default; // kg  arm 1 mass
double m2 = m2Default; // kg  arm 2 mass
double l1 = l1Default; // m  arm 1 length
double l2 = l2Default; // m  arm 2 length
double arm1Acc = arm1AccDefault; // m/s2
double arm1Vel = arm1VelDefault; // m/s
double arm2Acc = arm2AccDefault; // m/s2
double arm2Vel = arm2VelDefault; // m/s
double arm1Angle = arm1AngleDefault; //
double arm2Angle = arm2AngleDefault; // degrees

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

// double compassRoseTouchOuterDia = hsiOuterDiameter * 1.2;
// double compassRoseTouchInnerDia = hsiOuterDiameter * 0.5;
// double compassRoseTouchInnerRadius = compassRoseTouchInnerDia / 2;
// double compassRoseTouchOuterRadius = compassRoseTouchOuterDia / 2;
// Offset compassRoseTouchInnerOffset = Offset(
//     0, 0); //Offset(compassRoseTouchInnerRadius,compassRoseTouchInnerRadius);
// Offset compassRoseTouchOuterOffset =
//    Offset(compassRoseTouchOuterRadius, compassRoseTouchOuterRadius);
Offset rosePanStartRadialPos = Offset(0, 0);
double rosePanStartRadialAngle = 0;
double headingPanStart = 0;

double armLengthSliderMin = 0.3;
double armLengthSliderMax = 2.5;