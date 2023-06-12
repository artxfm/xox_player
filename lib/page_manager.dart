import 'package:flutter/material.dart';
// import 'dart:developer' as developer;
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:xox_player/services/audio_handler.dart';
import 'station.dart' as station;
import 'package:audio_service/audio_service.dart';
import 'services/service_locator.dart';



class PageManager {
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
    ),
  );

  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);
  final _audioHandler = getIt<AudioHandler>(); 

  static final _site = Uri.parse(station.stationURL);
  
  // late AudioPlayer _audioPlayer;
  late Timer _timer;
  DateTime _startTime = DateTime.now();

  
  PageManager() {
    _init();
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _timer = timer;
      
      final myHandler = _audioHandler as MyAudioHandler;

      if (myHandler.isPlaying()) {
        final elapsed = DateTime.now().difference(_startTime);
        if (elapsed.inSeconds > 0) {
          final oldState = progressNotifier.value;
          if (oldState.current.inSeconds < elapsed.inSeconds) {
            progressNotifier.value = ProgressBarState(
              current: elapsed,
            );
          }
        }
      }
    });
  }


  void _init() async {

    // Set up a callback for the state of the stream (and update button view).
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        buttonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        buttonNotifier.value = ButtonState.paused;
      }  else {
        buttonNotifier.value = ButtonState.playing;
      }
    });

  }

  void dispose() {
    _timer.cancel();
    _audioHandler.stop();
  }

  void play() {
    _startTime = DateTime.now();
    progressNotifier.value = ProgressBarState(
      current: Duration.zero,
    );
    _audioHandler.play();
  }

  void pause() {
    _audioHandler.pause();
  }    

  void openURL() async {
    if (!await launchUrl(_site, mode: LaunchMode.externalApplication)) {
      throw Exception('XOX could not launch URL $_site');
    }
  }
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
  });
  final Duration current;
}

enum ButtonState {
  paused, playing, loading
}