import 'dart:async';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class MyFaceDetectorClass {
  static bool closedEye = false;

  static Future<Eyes> analyze(File f) async { //funktion der tager en fil f
    Eyes e = Eyes.DontKnow; //variablen der beskriver den tilstand øjene kan have
    InputImage ii = InputImage.fromFile(f); //fra File til gyldig variable
    var fdo = FaceDetectorOptions(enableClassification: true); // her er nogle indstillinger

    FaceDetector detector = GoogleMlKit.vision.faceDetector(fdo); //Jeg putter AI i variabel

    final faces = await detector.processImage(ii); //scanner billedet og putter data i variabel
    if (faces.isNotEmpty) { //Ændrer tilstanden baseret på ansigtet
      if (faces[0].rightEyeOpenProbability! > 0.55) {
        e = Eyes.Open;
      } else
        e = Eyes.Closed;
    } else {
      e = Eyes.Gone;
    }
    return e; //returner tilstanden
  }
}

enum Eyes { DontKnow, Gone, Closed, Open }

