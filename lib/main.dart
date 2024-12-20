import 'package:flutter/material.dart';
import 'page_manager.dart';
import 'services/service_locator.dart';
import 'station.dart' as station;


void main() async {
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final PageManager _pageManager;
  static const _playPauseIconSize = 196.0;

  @override
  void initState() {
    super.initState();
    _pageManager = PageManager(); // init PageManager
  }

  @override
  void dispose() {
    _pageManager.dispose(); // clean up
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      // theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blueGrey,
      ),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Spacer(),
              
              Image.asset(
                "assets/images/xox_logo_sky_circle_sm.jpg"
              ),

              ElevatedButton(
                onPressed: _pageManager.openURL,
                child: const Text("Visit ${station.stationNameUI}"),
              ),

              const Spacer(),

              ValueListenableBuilder<ProgressBarState>(
                valueListenable: _pageManager.progressNotifier,
                builder: (context, value, __) {
                  final current = value.current;
                  final minutes = current.inMinutes.remainder(Duration.minutesPerHour).toString();
                  final seconds = current.inSeconds.remainder(Duration.secondsPerMinute).toString().padLeft(2, '0');

                  return Text(
                    current.inHours > 0 ? '${current.inHours}:$minutes:$seconds' : '$minutes:$seconds',
                    style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0)
                  );
                },
              ),

 
              ValueListenableBuilder<ButtonState>(
                valueListenable: _pageManager.buttonNotifier,
                builder: (_, value, __) {
                  switch (value) {
                    case ButtonState.loading:
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        width: _playPauseIconSize,
                        height: _playPauseIconSize,
                        child: const CircularProgressIndicator(),
                      );
                    case ButtonState.paused:
                      return IconButton(
                        icon: const Icon(Icons.play_arrow),
                        iconSize: _playPauseIconSize,
                        onPressed: _pageManager.play,
                      );
                    case ButtonState.playing:
                      return IconButton(
                        icon: const Icon(Icons.pause),
                        iconSize: _playPauseIconSize,
                        onPressed: _pageManager.pause,
                      );
                  }
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
