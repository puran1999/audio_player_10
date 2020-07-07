import 'set_state_callbacks.dart';
import 'storage.dart';
import 'audio_focus.dart';
import '../constants.dart';
import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:audiofileplayer/audio_system.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'dart:math';
import 'package:flutter/services.dart';

Player player = Player();

class Player {
  Audio audio;
  bool audioPlaying = false;
  double _audioDurationSeconds = 0;
  double _audioPositionSeconds = 0;

  /// Identifiers for the two custom Android notification buttons.
  static const String crossButtonId = 'crossButtonId';

  get audioDuration => _audioDurationSeconds;

  get audioPosition => _audioPositionSeconds;

  Audiotagger tagger = new Audiotagger();

  Tag tag = Tag(
    title: '',
    artist: '',
    album: '',
    year: '',
  );

  Player() {
    AudioSystem.instance.addMediaEventListener(mediaEventListener);
  }

  Future<void> _readTag(String path) async {
    try {
      tag = await tagger.readTags(path: path);
    } catch (e) {
      tag = Tag(
        title: '',
        artist: '',
        album: '',
        year: '',
      );
//      print(e);
    }
    if (tag.title == '' || tag.title == null) {
      tag.title = storage.audiosInFolderPlaying1[storage.currentAudioIndex];
    }
    if (tag.artist == '') {
      tag.artist = 'Unknown';
    }
  }

  void exitApp() {
    if (audio != null) {
      AudioSystem.instance.stopBackgroundDisplay();
      AudioSystem.instance.removeMediaEventListener(mediaEventListener);
      AudioSystem.instance.setPlaybackState(false, _audioPositionSeconds);
      audio.pause();
      audio.dispose();
    }
    SystemNavigator.pop();
  }

  bool waiting = false;

  Future<void> playNew() async {
    if (!waiting) {
      waiting = true;
      if (audio != null) {
        await audio.pause();
        await audio.dispose();
      }
      try {
        await _readTag(storage.audiosInFolderPlaying0[storage.currentAudioIndex]);
        audio = Audio.loadFromAbsolutePath(
          storage.audiosInFolderPlaying0[storage.currentAudioIndex],
          playInBackground: true,
          onDuration: _localDurationCallback,
          onPosition: _localPositionCallback,
          onComplete: _localOnCompleteCallback,
        );
      } catch (e) {
        print(e);
      }
      await resumeBackgroundAudio();
//      setStateCalls.playerScreen();
      waiting = false;
    }
  }

  void _localDurationCallback(double val) {
    _audioDurationSeconds = val;
    setStateCalls.playerScreenSliderDuration(val);
  }

  void _localPositionCallback(double val) {
    _audioPositionSeconds = val;
    setStateCalls.playerScreenSliderPosition(val);
  }

  Future<void> _localOnCompleteCallback() async {
    {
      if (loopSingle) {
        playNew();
      } else {
        await playNext();
      }
      setStateCalls.folderScreen();
      setStateCalls.audioScreen();
      setStateCalls.playerScreen();
    }
  }

  Future<void> mediaEventListener(MediaEvent mediaEvent) async {
    final MediaActionType type = mediaEvent.type;
    if (type == MediaActionType.play) {
      await resumeBackgroundAudio();
      setStateCalls.folderScreen(); //!! do not alter the order of callbacks
      setStateCalls.audioScreen();
      setStateCalls.playerScreen();
    } else if (type == MediaActionType.pause) {
      await pauseBackgroundAudio();
      setStateCalls.folderScreen(); //!! do not alter the order of callbacks
      setStateCalls.audioScreen();
      setStateCalls.playerScreen();
    } else if (type == MediaActionType.playPause) {
      /// lock screen play/pause button
      audioPlaying ? await pauseBackgroundAudio() : resumeBackgroundAudio();
      setStateCalls.folderScreen(); //!! do not alter the order of callbacks
      setStateCalls.audioScreen();
      setStateCalls.playerScreen();
    } else if (type == MediaActionType.next) {
      await playNext();
      setStateCalls.folderScreen(); //!! do not alter the order of callbacks
      setStateCalls.audioScreen();
      setStateCalls.playerScreen();
    } else if (type == MediaActionType.previous) {
      await playPrev();
      setStateCalls.folderScreen(); // do not alter the order of callbacks
      setStateCalls.audioScreen();
      setStateCalls.playerScreen();
    } else if (type == MediaActionType.custom && mediaEvent.customEventId == crossButtonId) {
      exitApp();
    }
  }

  Future<void> resumeBackgroundAudio() async {
    if (await handleAudioFocus()) {
      try {
        audio.resume();
        audioPlaying = true;
        AudioSystem.instance.setPlaybackState(true, _audioPositionSeconds);
        _updateSystemControls(AndroidMediaButtonType.pause);
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> pauseBackgroundAudio() async {
    try {
      await audio.pause();
      audioPlaying = false;
      AudioSystem.instance.setPlaybackState(false, _audioPositionSeconds);
      _updateSystemControls(AndroidMediaButtonType.play);
    } catch (e) {
      print(e);
    }
  }

  Future<void> playNext() async {
    if (shuffle) {
      final int index = storage.currentAudioIndex;
      do {
        storage.currentAudioIndex = Random().nextInt(storage.audiosInFolderPlaying0.length);
      } while (index == storage.currentAudioIndex);
    } else {
      storage.currentAudioIndex++;
      if (storage.currentAudioIndex >= storage.audiosInFolderPlaying0.length) {
        storage.currentAudioIndex = 0;
      }
    }
    await playNew();
  }

  Future<void> playPrev() async {
    if (shuffle) {
      final int index = storage.currentAudioIndex;
      do {
        storage.currentAudioIndex = Random().nextInt(storage.audiosInFolderPlaying0.length);
      } while (index == storage.currentAudioIndex);
    } else {
      storage.currentAudioIndex--;
      if (storage.currentAudioIndex <= -1) {
        storage.currentAudioIndex = storage.audiosInFolderPlaying0.length - 1;
      }
    }
    await playNew();
  }

  void _updateSystemControls(AndroidMediaButtonType playOrPause) {
    AudioSystem.instance.setMetadata(AudioMetadata(
      title: tag.title,
      artist: tag.artist,
//      album: tag.album,
//      genre: tag.genre,
//      durationSeconds: _audioDurationSeconds,
      artBytes: storage.audiosInFolderPlaying2[storage.currentAudioIndex],
    ));

    AudioSystem.instance.setAndroidNotificationButtons(<dynamic>[
      AndroidMediaButtonType.previous,
      playOrPause,
      AndroidMediaButtonType.next,
//      AndroidMediaButtonType.stop,
      const AndroidCustomMediaButton('close', crossButtonId, 'cross'),
    ], androidCompactIndices: <int>[
      1,
      3
    ]);

    AudioSystem.instance.setSupportedMediaActions(<MediaActionType>{
      MediaActionType.play,
      MediaActionType.pause,
      MediaActionType.next,
      MediaActionType.previous,
    });
  }

  bool havingAudioFocus = false;

  Future<bool> handleAudioFocus() async {
    if (!havingAudioFocus) {
      /// TODO: This works flawlessly, but the audio is not resumed automatically after
      /// focus gained from transient focus lost if we again request focus, because each time we request,
      /// a new object is created and previous one is discarded.
      /// In simple, when audio is automatically paused during a call,
      /// it will not resume automatically if user presses play button during this time.
      AudioFocus audioFocus = AudioFocus();
      audioFocus.audioFocusEvents.listen((focusEvent) async {
//      print('-----' * 100);
//      print(focusEvent);
        if (focusEvent == AudioState.AUDIOFOCUS_GAIN) {
//        print('AUDIOFOCUS_GAIN----' * 50);
          havingAudioFocus = true;
          await resumeBackgroundAudio();
          setStateCalls.folderScreen(); //!! do not alter the order of callbacks
          setStateCalls.audioScreen();
          setStateCalls.playerScreen();
        } else {
          //        print('ELSE----' * 50);
          havingAudioFocus = false;
          await pauseBackgroundAudio();
          setStateCalls.folderScreen(); //!! do not alter the order of callbacks
          setStateCalls.audioScreen();
          setStateCalls.playerScreen();
        }
      });
      havingAudioFocus = await audioFocus.getAudioFocus();
    }
    return havingAudioFocus;
  }

  String secondsToString(double seconds) {
    if (_audioDurationSeconds >= 60 * 60) {
      return stringForSecondsWithHours(seconds);
    } else {
      return stringForSeconds(seconds);
    }
  }

  String stringForSeconds(double seconds) {
    if (seconds == null) return null;
    return '${(seconds ~/ 60)}:${(seconds.truncate() % 60).toString().padLeft(2, '0')}';
  }

  String stringForSecondsWithHours(double seconds) {
    if (seconds == null) return null;
    String h = '${(seconds ~/ 3600)}';
    String m = '${((seconds ~/ 60).truncate() % 60).toString().padLeft(2, '0')}';
    String s = '${(seconds.truncate() % 60).toString().padLeft(2, '0')}';
    return '$h:$m:$s';
  }
}
