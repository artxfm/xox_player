import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
// import 'dart:developer' as developer;
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

import 'station.dart' as station;



class PageManager {
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
    ),
  );
  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);

  static final _site = Uri.parse(station.stationURL);
  
  late AudioPlayer _audioPlayer;
  late Timer _timer;
  DateTime _startTime = DateTime.now();

  
  PageManager() {
    _init();
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _timer = timer;
      if (_audioPlayer.playing) {
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
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setUrl(station.streamURL);

    // Set up a callback for the state of the stream (and update button view).
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        buttonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        buttonNotifier.value = ButtonState.paused;
      } else {
        buttonNotifier.value = ButtonState.playing;
      }
    });

    // TODO: I was monitoring the _audioPlayer.positionStream but on iOS
    //       this was not trigger callbacks frequently enough to update the
    //       timer.  

  }

  void dispose() {
    _timer.cancel();
    _audioPlayer.dispose();
  }

  void play() {
    _startTime = DateTime.now();
    progressNotifier.value = ProgressBarState(
      current: Duration.zero,
    );
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
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