import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';


class PageManager {
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );
  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);

  // TODO: Maybe create a service to check a web page and/or local
  //       cache so we can easily alter this URL on the fly.
  static const url = 'https://patmos.cdnstream.com/proxy/artfmin1/?mp=/stream';
  
  late AudioPlayer _audioPlayer;
  
  PageManager() {
    _init();
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

    // Set callback for the position stream.
    _audioPlayer.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      if (oldState.current.inSeconds < position.inSeconds) {
        progressNotifier.value = ProgressBarState(
          current: position,
          buffered: oldState.buffered,
          total: oldState.total,
        );
      }
    });

    // Set callback for the buffer-position stream.
    /*
    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });
    */

    // Set callback for the duration stream.
    /*
    _audioPlayer.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
    */

  }

  void dispose() {
    _audioPlayer.dispose();
  }

  void play() {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }    
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  final Duration current;
  final Duration buffered;
  final Duration total;
}

enum ButtonState {
  paused, playing, loading
}