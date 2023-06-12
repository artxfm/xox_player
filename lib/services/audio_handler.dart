
import '../station.dart' as station;
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';


Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.artxfm.xox_player.audio',
      androidNotificationChannelName: 'WXOX Player Audio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      // TODO: We could set an androidNotificationIcon here too.
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  final _audioPlayer = AudioPlayer();

  MyAudioHandler() {
    _init();
    _notifyAudioHandlerAboutPlaybackEvents();
  }

  void _init() async {
    await _audioPlayer.setUrl(station.streamURL);
  }

  bool isPlaying() {
    return _audioPlayer.playing;
  }

  @override
  Future<void> play() => _audioPlayer.play();

  @override
  Future<void> pause() => _audioPlayer.pause();  

  @override
  Future<void> stop() async {
    await _audioPlayer.dispose();
    return super.stop();
  }

  // Sets things up so that state changes from our audio player are
  // broadcast to the audio handler listeners (like our page manager).
  void _notifyAudioHandlerAboutPlaybackEvents() {
    _audioPlayer.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _audioPlayer.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          if (playing) MediaControl.pause else MediaControl.play,
        ],
        androidCompactActionIndices: const [0],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_audioPlayer.processingState]!,
        playing: playing,
      ));
    });
  }  

}