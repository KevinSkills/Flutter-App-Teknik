import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'camera_box.dart';
import 'dart:io';
import 'dart:async';
import 'ai.dart';
import 'package:image/image.dart' as img;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'audio.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //så vi kan skrive kode inden vi kører runApp()

  cameras = await availableCameras(); //venter indtil den har fået adgang til kamera
  await CameraBox.initController(); //Starter controlleren
  runApp(MyApp());
}

class MyApp extends StatelessWidget { //appens begyndelse
  const MyApp({Key? key}) : super(key: key);
  static final mainPage = MainPage();

  @override
  Widget build(BuildContext context) { // det der bliver vist på skærmen
    return MaterialApp(
      title: "Dont sleep in Cars",
      home: mainPage, //den skærm, der vises
      theme: ThemeData( //Design-data f.eks. skrifttyper og farver
          primarySwatch: Colors.red,
          primaryTextTheme: TextTheme(
            headline6: TextStyle(
              color: Colors.black,
            ),
          ),
          fontFamily: GoogleFonts.montserrat().fontFamily),
      routes: {}, //Hvis vi senere skal have flere skærme, så tilføjer man dem her
    );
  }
}

class MainPage extends StatefulWidget {
  static late bool closedEyes;

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  static late MainPageState instance;
  static int closedEyesTime = 0;
  Color borderC = Colors.grey;
  Timer? timer;
  final player = AudioPlayer();
  File? pictureTaken;
  Eyes? eyesState;
  int fixedDeltaTime = 50;
  double maxAlarmTime = 2;

  @override
  void initState() {
    //Start
    Scan();
    instance = this;
    timer = Timer.periodic(Duration(milliseconds: fixedDeltaTime), (timer) {
      //Update
      setState(() => addToClosedEyesTimer(fixedDeltaTime));
      if(CameraBox.paused) closedEyesTime = 0;
      if (closedEyesTime > 1000 * maxAlarmTime)
        player.play();
      else
        player.stop();
    });
    super.initState();
    player.init();
  }

  static void addToClosedEyesTimer(int t) {
    closedEyesTime += t;
  }

  Future Scan() async {
    pictureTaken = await CameraBox.takePic();
    print(pictureTaken);
    eyesState = await MyFaceDetectorClass.analyze(pictureTaken!);
    if (eyesState == Eyes.Open || eyesState == Eyes.Gone) closedEyesTime = 0;
    switch (eyesState!) {
      case Eyes.Open:
        borderC = Colors.green;
        closedEyesTime = 0;
        break;

      case Eyes.Closed:
        borderC = Colors.yellow;
        break;

      case Eyes.Gone:
        borderC = Colors.red;
        break;
      default:
        borderC = Colors.grey;
    }
    if (!CameraBox.paused) Scan();
  }

  void setColor(Color c) {
    setState(() {
      print("called this methd");
      borderC = c;
    });
  }

  @override
  Widget build(BuildContext context) { //MainPage build.
    CameraBox cb = CameraBox();
    double width = 300;
    double height = width * CameraBox.controller!.value.aspectRatio - 3;
    return Scaffold( //Scaffold er den første widget når man laver en ny skærm.
      appBar: AppBar( //Den øveste bar
        leading: null,
        title: new Text("Do not sleep in Car while driving"),
      ),
      drawer: Drawer(), //Side bar
      drawerEnableOpenDragGesture: true,
      body: Container( //Den faktiske skærm, der hvor ting sker.
        alignment: Alignment.topCenter,
        child: Column( // Vi har 1 kolonne hvor alle elemener bare er nede eller over hinanden.
          children: [
            Spacer(flex: 2), //Spacer fylder bare tomplads ud.
            Text('$closedEyesTime'),
            Container( //Container til kameraret. Firkanten
              height: height,
              width: width,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 3,
                  color: borderC,
                ),
              ),
              child: Stack( // ting oven på hinanden
                children: [
                  cb,
                  (CameraBox.paused) //hvis kameraet er sat på pause, så er der en tekst på, der siger "Paused"
                      ? Center(
                          child: Text(
                          "Paused",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                      : Container(),
                ],
              ),
            ),
            Spacer(flex: 2),
            ElevatedButton( //pause-knap
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.yellow),
                ),
                child: Container(
                  width: 200,
                  height: 70,
                  child: Center(
                    child: Text(
                      (CameraBox.paused) ? "Start" : "Pause",
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                onPressed: () => setState(() {
                      if (CameraBox.paused) {
                        CameraBox.controller!.resumePreview();
                        Scan();
                      } else
                        CameraBox.controller!.pausePreview();
                      CameraBox.paused = !CameraBox.paused;
                    })),
            Spacer(flex: 1)
          ],
        ),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  String t;
  void Function() callback;

  MyButton(this.t, this.callback);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        callback();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          color: Colors.yellow[700],
        ),
        width: 200.0,
        height: 50.0,
        child: Center(child: Text("$t", style: TextStyle(fontSize: 30))),
      ),
    );
  }
}
