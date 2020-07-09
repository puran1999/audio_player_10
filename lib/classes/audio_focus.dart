import 'dart:async';
import 'package:flutter/services.dart';

class AudioFocus {
  EventChannel _audioFocusChannel = EventChannel('com.example.focus_audio/stream');
  Stream<AudioState> _audioFocusEvents;
  static const platform = const MethodChannel('com.example.focus_audio/channel');

  Stream<AudioState> get audioFocusEvents {
    if (_audioFocusEvents == null) {
      _audioFocusEvents =
          _audioFocusChannel.receiveBroadcastStream().map((dynamic event) => _parseAudioState(event));
    }
    return _audioFocusEvents;
  }

  Future<bool> getAudioFocus() async {
    bool focusGranted = false;
    try {
      final String str = await platform.invokeMethod('requestAudioFocus');
      if (str == 'GRANTED')
        focusGranted = true;
      else
        focusGranted = false;
    } on PlatformException catch (e) {
      print(e);
    }
    return focusGranted;
  }

  Future<void> abandonAudioFocus() async {
    try {
      final String str = await platform.invokeMethod('abandonAudioFocus');
    } on PlatformException catch (e) {
      print(e);
    }
  }

  AudioState _parseAudioState(String state) {
    switch (state) {
      case "android.media.AUDIO_BECOMING_NOISY":
        return AudioState.BECOME_NOISY;
      case "AUDIOFOCUS_GAIN":
        return AudioState.AUDIOFOCUS_GAIN;
      case "AUDIOFOCUS_GAIN_TRANSIENT":
        return AudioState.AUDIOFOCUS_GAIN_TRANSIENT;
      case "AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK":
        return AudioState.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK;
      case "AUDIOFOCUS_LOSS":
        return AudioState.AUDIOFOCUS_LOSS;
      case "AUDIOFOCUS_LOSS_TRANSIENT":
        return AudioState.AUDIOFOCUS_LOSS_TRANSIENT;
      case "AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK":
        return AudioState.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK;
      case "AUDIOFOCUS_REQUEST_FAILED":
        return AudioState.AUDIOFOCUS_REQUEST_FAILED;
      default:
        return AudioState.AUDIOFOCUS_REQUEST_FAILED;
    }
  }
}

enum AudioState {
  BECOME_NOISY,
  AUDIOFOCUS_GAIN,
  AUDIOFOCUS_GAIN_TRANSIENT,
  AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK,
  AUDIOFOCUS_LOSS,
  AUDIOFOCUS_LOSS_TRANSIENT,
  AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK,
  AUDIOFOCUS_REQUEST_FAILED
}
