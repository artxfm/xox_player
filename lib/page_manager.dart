import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:developer' as developer;
import 'dart:async';



class PageManager {
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
    ),
  );
  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);

  // TODO: Maybe create a service to check a web page and/or local
  //       cache so we can easily alter this URL on the fly.
  static const url = 'https://patmos.cdnstream.com/proxy/artfmin1/?mp=/stream';
  
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
    await _audioPlayer.setUrl(url);

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