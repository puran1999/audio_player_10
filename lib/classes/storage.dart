import 'set_state_callbacks.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:audiotagger/audiotagger.dart';

Storage storage = Storage(); //created a global single instance

class Storage {
  List<StorageInfo> storageInfo;
  List<List<String>> foldersWithAudio = []; //[ [fullPath, onlyName, modifiedPathNameForDisplay ], ...]
  List<List<dynamic>> audiosInFolderNavigation = []; // [ [fullPath, onlyName, artwork], ...]
  List<String> audiosInFolderPlaying0 = [];
  List<String> audiosInFolderPlaying1 = [];
  List<Uint8List> audiosInFolderPlaying2 = [];
  int currentNavigationFolderIndex;
  int currentPlayingFolderIndex;
  int currentAudioIndex;

  Audiotagger tagger = new Audiotagger();

  /// the default album arts
  List<Uint8List> rawArtworkImage;

  /// If any folder.jpg or cover.jpg is found in audio's folder,
  /// it will be used to replace those having no album art.
  Uint8List rawArtworkImageFolder;

//  String benchmarkTime;                                           //to check time taken

  Future<void> loadFolders() async {
//    DateTime now = DateTime.now();                                //to check time taken
    final status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      try {
        storageInfo = await PathProviderEx.getStorageInfo();
      } catch (e) {
        print(e);
      }
      foldersWithAudio.clear();

      for (int i = 0; i < storageInfo.length; i++) {
        await _findFoldersRecursively(storageInfo[i].rootDir);
      }
      rectifyFolderList();
      foldersWithAudio.sort((a, b) => (a[1].toLowerCase()).compareTo(b[1].toLowerCase()));
//      print(storageInfo[0].rootDir);
//      foldersWithAudio.forEach((element) => print(element));
    }
//    Duration dur = DateTime.now().difference(now);                //to check time taken
//    benchmarkTime = '${dur?.inSeconds}.${dur?.inMilliseconds}';   //to check time taken
//    print('========== $benchmarkTime ==========');                //to check time taken
  }

  Future<void> loadArtworks() async {
//    print('doing_____' * 50);
    rawArtworkImage = [];
    for (int i = 1; i < 14; i++) {
      rawArtworkImage.add((await rootBundle.load('assets/coverArt_$i.jpg')).buffer.asUint8List());
    }
//    print('done______________' * 50);
  }

  Future<void> findAllAudios(String parentFolder) async {
    audiosInFolderNavigation.clear();
    rawArtworkImageFolder = null;
    ByteData dta;
    Random random = Random();
    int r = 0;
    int p = 1;

    List<io.FileSystemEntity> _data =
        io.Directory(parentFolder).listSync(recursive: false, followLinks: false);
    _data.forEach((element) async {
      if (element is io.File) {
        if (_isAudio(element.path)) {
          do r = random.nextInt(13); while (p == r);
          p = r;
          audiosInFolderNavigation.add([
            element.path,
            element.path.substring(
              element.path.lastIndexOf('/') + 1,
              element.path.lastIndexOf('.'),
            ),
            rawArtworkImage[r],
          ]);
        } else if (_isFolderAlbumArt(element.path)) {
//          dta = await rootBundle.load(element.path); //this does not work for other than app assets
          dta = element.readAsBytesSync().buffer.asByteData();
          rawArtworkImageFolder = dta.buffer.asUint8List();
        }
      }
    });
    audiosInFolderNavigation.sort((a, b) => (a[1].toLowerCase()).compareTo(b[1].toLowerCase()));
    _readArtworks();
  }

  Future<void> _readArtworks() async {
    Uint8List art;
    for (int i = 0; i < audiosInFolderNavigation.length; i++) {
      try {
        art = await tagger.readArtwork(path: audiosInFolderNavigation[i][0]);
      } catch (e) {}
      if (art != null) {
        audiosInFolderNavigation[i][2] = art;
      } else if (rawArtworkImageFolder != null) {
        audiosInFolderNavigation[i][2] = rawArtworkImageFolder;
      }
    }
    setStateCalls.audioScreen();
  }

  Future<void> _findFoldersRecursively(String path) async {
    try {
      List<io.FileSystemEntity> _data = io.Directory(path).listSync(recursive: false, followLinks: false);
      _data.forEach((element) {
        if (element is io.File) {
          if (_isAudio(element.path)) {
            if (!_contains(foldersWithAudio, path)) {
              ///this variable holds arrays of 3 strings. But holding one just for now only!
              foldersWithAudio.add([path]);
            }
          }
        } else if (element is io.Directory &&
            !element.path.endsWith('/Android') &&
            !element.path.endsWith('/.android_secure')) {
          _findFoldersRecursively(element.path);
        }
      });
//      print(_data);
    } catch (e) {
      print(e);
    }
  }

  void rectifyFolderList() {
    String path;
    for (int i = 0; i < foldersWithAudio.length; i++) {
      path = foldersWithAudio[i][0];

      /// [fullPath, onlyName, modifiedPathNameForDisplay ]
      if (storageInfo.length == 1) {
        if (path == storageInfo[0].rootDir) {
          foldersWithAudio[i] = [
            path,
            'Internal Storage',
            'Internal Storage',
          ];
        } else {
          foldersWithAudio[i] = [
            path,
            path.substring(path.lastIndexOf('/') + 1, path.length),
            path.replaceAll(storageInfo[0].rootDir, 'Internal Storage'),
          ];
        }
      } else if (storageInfo.length == 2) {
        if (path == storageInfo[0].rootDir) {
          foldersWithAudio[i] = [
            path,
            'Internal Storage',
            'Internal Storage',
          ];
        } else if (path == storageInfo[1].rootDir) {
          foldersWithAudio[i] = [
            path,
            'SD Card',
            'SD Card',
          ];
        } else {
          foldersWithAudio[i] = [
            path,
            path.substring(path.lastIndexOf('/') + 1, path.length),
            path
                .replaceAll(storageInfo[0].rootDir, 'Internal Storage')
                .replaceAll(storageInfo[1].rootDir, 'SD Card'),
          ];
        }
      } else if (storageInfo.length >= 3) {
        ///when usb is connected via otg, it appears to take index 1 and memory card is shifts to index 2 of storageInfo
        if (path == storageInfo[0].rootDir) {
          foldersWithAudio[i] = [
            path,
            'Internal Storage',
            'Internal Storage',
          ];
        } else if (path == storageInfo[1].rootDir) {
          foldersWithAudio[i] = [
            path,
            'USB Storage',
            'USB Storage',
          ];
        } else if (path == storageInfo[2].rootDir) {
          foldersWithAudio[i] = [
            path,
            'SD Card',
            'SD Card',
          ];
        } else {
          foldersWithAudio[i] = [
            path,
            path.substring(path.lastIndexOf('/') + 1, path.length),
            path
                .replaceAll(storageInfo[0].rootDir, 'Internal Storage')
                .replaceAll(storageInfo[1].rootDir, 'USB Storage')
                .replaceAll(storageInfo[2].rootDir, 'SD Card'),
          ];
        }
      }
    }
  }

  bool _contains(List<List<String>> myList, String s) {
    for (List<String> myString in myList) {
      if (myString[0] == s) return true;
    }
    return false;
  }

  bool _isAudio(String file) {
    if (file != null) {
      String ext = file.substring(file.lastIndexOf('.') + 1, file.length).toLowerCase();
      for (String format in _supportedAudioFormats) {
        if (ext == format) {
          return true;
        }
      }
    }
    return false;
  }

//  bool _isVideo(String file) {
//    if (file != null) {
//      String ext = file.substring(file.lastIndexOf('.') + 1, file.length).toLowerCase();
//      for (String format in _supportedVideoFormats) {
//        if (ext == format) {
//          return true;
//        }
//      }
//    }
//    return false;
//  }

  bool _isFolderAlbumArt(String file) {
    String name = file.substring(file.lastIndexOf('/') + 1, file.length).toLowerCase();
    if (name == 'folder.jpg' || name == 'cover.jpg') {
      return true;
    }
    return false;
  }

  final List<String> _supportedAudioFormats = [
    'mp3',
    'ogg',
    'm4a',
    'wav',
    'aac',
    'flac',
  ];

  String get listSupportedAudioFormats {
    return _supportedAudioFormats.toString();
  }

//  final List<String> _supportedVideoFormats = [
//    'mp4',
//    '3gp',
//    'ts',
//    'mkv',
//  ];

  // ignore: non_constant_identifier_names
  void copy_audiosInFolderNavigation_into_audiosInFolderPlaying() {
    storage.audiosInFolderPlaying0.clear();
    storage.audiosInFolderPlaying1.clear();
    storage.audiosInFolderPlaying2.clear();
    storage.audiosInFolderNavigation.forEach((element) {
      storage.audiosInFolderPlaying0.add(element[0]);
      storage.audiosInFolderPlaying1.add(element[1]);
      storage.audiosInFolderPlaying2.add(element[2]);
    });
  }

  // ignore: non_constant_identifier_names
  void copy_audiosInFolderPlaying0_into_audiosInFolderNavigation() {
    storage.audiosInFolderNavigation.clear();
    for (int i = 0; i < storage.audiosInFolderPlaying0.length; i++) {
      storage.audiosInFolderNavigation.add([
        storage.audiosInFolderPlaying0[i],
        storage.audiosInFolderPlaying1[i],
        storage.audiosInFolderPlaying2[i],
      ]);
    }
  }
}
