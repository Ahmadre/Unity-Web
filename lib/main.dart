import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_unity/flutter_unity.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UnityViewPage(),
    );
  }
}

class UnityViewPage extends StatefulWidget {
  const UnityViewPage({Key? key}) : super(key: key);

  @override
  _UnityViewPageState createState() => _UnityViewPageState();
}

class _UnityViewPageState extends State<UnityViewPage> {
  UnityViewController? unityViewController;
  Color backgroundColor = Colors.white;
  Color contrastColor = Colors.black54;

  double speed = 0;
  double rotation = 0;
  bool showBack = false;
  bool openBlinds = false;
  bool openTrunk = false;

  bool openDFD = false;
  bool openDRD = false;
  bool openPFD = false;
  bool openPRD = false;

  String actualModel = 'Model S';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    late String baseUri;

    if (kReleaseMode) {
      baseUri = 'https://unity-web.web.app';
    } else {
      baseUri = 'http://localhost:${Uri.base.port}';
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          actualModel,
          style: TextStyle(color: contrastColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 120,
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_4, color: contrastColor),
            onPressed: () {
              if (backgroundColor == Colors.white) {
                backgroundColor = Colors.black;
                contrastColor = Colors.white;
              } else {
                backgroundColor = Colors.white;
                contrastColor = Colors.black54;
              }
              String colorString =
                  '${backgroundColor.red},${backgroundColor.blue},${backgroundColor.green}';
              unityViewController?.send(
                  'MainCamera', 'SetBackgroundColor', colorString);
              Future.delayed(const Duration(milliseconds: 50), () {
                setState(() {});
              });
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_horiz,
              color: contrastColor,
            ),
            onSelected: (String result) {
              setState(() {
                actualModel = result;
              });
              unityViewController?.send(
                'Init',
                'loadModel',
                result.replaceAll(' ', '').toLowerCase(),
              );
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Model S',
                child: Text('Model S'),
              ),
              const PopupMenuItem<String>(
                value: 'Cybertruck',
                child: Text('Cybertruck'),
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height / 2,
              ),
              child: AspectRatio(
                aspectRatio: 1280 / 768,
                child: UnityView(
                  onCreated: (controller) => onUnityViewCreated(controller!),
                  onReattached: onUnityViewReattached,
                  onMessage: (controller, message) =>
                      onUnityViewMessage(controller!, message!),
                  webUrl: '$baseUri/unity/index.html',
                ),
              ),
            ),
            if (actualModel == 'Model S')
              Card(
                color: backgroundColor,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(25),
                      child: Text('Rotation'),
                    ),
                    Slider.adaptive(
                      min: 0,
                      max: 100,
                      value: rotation,
                      onChanged: (val) {
                        setState(() {
                          rotation = val;
                        });
                        unityViewController?.send(
                          actualModel.replaceAll(' ', ''),
                          'SetRotationSpeed',
                          '${val.toInt()}',
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.all(25),
                      child: Divider(),
                    ),
                    const Text('Speed'),
                    Slider.adaptive(
                      min: 0,
                      max: 400,
                      value: speed,
                      onChanged: (val) {
                        setState(() {
                          speed = val;
                        });
                        unityViewController?.send(
                          actualModel.replaceAll(' ', ''),
                          'SetCarSpeed',
                          '${val.toInt()}',
                        );
                      },
                    ),
                  ],
                ),
              ),
            if (actualModel == 'Cybertruck')
              Wrap(
                children: [
                  ElevatedButton(
                    child: Text(showBack ? 'Show Front' : 'Show Back'),
                    onPressed: () {
                      setState(() {
                        showBack = !showBack;
                      });
                      unityViewController?.send(
                        'MainCamera',
                        'showBack',
                        '$showBack',
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text(openBlinds ? 'Close Blinds' : 'Open Blinds'),
                    onPressed: () {
                      setState(() {
                        openBlinds = !openBlinds;
                      });
                      unityViewController?.send(
                        'Cybertruck',
                        'toggle',
                        'blinds,$openBlinds',
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text(openTrunk ? 'Close Trunk' : 'Open Trunk'),
                    onPressed: () {
                      setState(() {
                        openTrunk = !openTrunk;
                      });
                      unityViewController?.send(
                        'Cybertruck',
                        'toggle',
                        'trunkdoor,$openTrunk',
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text(openDFD ? 'Close DFD' : 'Open DFD'),
                    onPressed: () {
                      setState(() {
                        openDFD = !openDFD;
                      });
                      unityViewController?.send(
                        'Cybertruck',
                        'toggle',
                        'driverfrontdoor,$openDFD',
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text(openDRD ? 'Close DFD' : 'Open DFD'),
                    onPressed: () {
                      setState(() {
                        openDRD = !openDRD;
                      });
                      unityViewController?.send(
                        'Cybertruck',
                        'toggle',
                        'driverreardoor,$openDRD',
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text(openPFD ? 'Close PFD' : 'Open PFD'),
                    onPressed: () {
                      setState(() {
                        openPFD = !openPFD;
                      });
                      unityViewController?.send(
                        'Cybertruck',
                        'toggle',
                        'passengerfrontdoor,$openPFD',
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text(openPRD ? 'Close PRD' : 'Open PRD'),
                    onPressed: () {
                      setState(() {
                        openPRD = !openPRD;
                      });
                      unityViewController?.send(
                        'Cybertruck',
                        'toggle',
                        'passengerreardoor,$openPRD',
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void onUnityViewCreated(UnityViewController controller) {
    debugPrint('onUnityViewCreated');

    setState(() {
      unityViewController = controller;
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      controller.send(
        'Init',
        'loadModel',
        actualModel.replaceAll(' ', '').toLowerCase(),
      );
    });
  }

  void onUnityViewReattached(UnityViewController controller) {
    debugPrint('onUnityViewReattached');

    setState(() {
      unityViewController = controller;
    });
  }

  void onUnityViewMessage(UnityViewController controller, String message) {
    debugPrint('onUnityViewMessage');

    debugPrint(message);
  }
}
