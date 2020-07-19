import 'package:audio_player_10/constants.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;
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
  List<dynamic> _audiosInFolderPlaying2 = [];

  ImageProvider audiosInFolderNavigationArtwork(int index) {
    if (audiosInFolderNavigation[index][2].runtimeType == int) {
      return AssetImage('assets/coverArt_${audiosInFolderNavigation[index][2]}.jpg');
    } else if (audiosInFolderNavigation[index][2].runtimeType == String) {
      return MemoryImage(rawArtworkImageFolderNavigation);
    } else {
      return MemoryImage(audiosInFolderNavigation[index][2]);
    }
  }

  ImageProvider audiosInFolderPlaying2Artwork(int index) {
    if (_audiosInFolderPlaying2[index].runtimeType == int) {
      return AssetImage('assets/coverArt_${_audiosInFolderPlaying2[index]}.jpg');
    } else if (_audiosInFolderPlaying2[index].runtimeType == String) {
      return MemoryImage(rawArtworkImageFolderPlaying);
    } else {
      return MemoryImage(_audiosInFolderPlaying2[index]);
    }
  }

  Uint8List audiosInFolderPlaying2ArtworkAsBytes(int index) {
    if (_audiosInFolderPlaying2[index].runtimeType == int) {
      return rawArtworkImage[_audiosInFolderPlaying2[index]];
    } else if (_audiosInFolderPlaying2[index].runtimeType == String) {
      return rawArtworkImageFolderPlaying;
    } else {
      return _audiosInFolderPlaying2[index];
    }
  }

  int currentNavigationFolderIndex;
  int currentPlayingFolderIndex;
  int currentAudioIndex;

  Audiotagger tagger = new Audiotagger();

  /// the default album arts
  List<Uint8List> rawArtworkImage;

  /// If any folder.jpg or cover.jpg is found in audio's folder,
  /// it will be used to replace those having no album art.
  Uint8List rawArtworkImageFolderNavigation;
  Uint8List rawArtworkImageFolderPlaying;

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
    for (int i = 0; i < artTotal; i++) {
      rawArtworkImage.add((await rootBundle.load('assets/coverArt_$i.jpg')).buffer.asUint8List());
    }
//    print('done______________' * 50);
  }

  Future<void> findAllAudios(String parentFolder) async {
    audiosInFolderNavigation.clear();
    rawArtworkImageFolderNavigation = null;
    ByteData dta;
    Random random = Random();
    int randomInteger = -1;
    int p = 0;

    List<io.FileSystemEntity> _data =
        io.Directory(parentFolder).listSync(recursive: false, followLinks: false);
    _data.forEach((element) async {
      if (element is io.File) {
        if (_isAudio(element.path)) {
          if (randomArt && artIsSelectedTotal >= 3) {
            do {
              randomInteger = random.nextInt(artTotal);
            } while (p == randomInteger || artIsSelected[randomInteger] == '0');
            p = randomInteger;
          } else {
            do {
              randomInteger++;
              if (randomInteger >= artTotal) randomInteger = 0;
            } while (artIsSelected[randomInteger] == '0');
          }

          audiosInFolderNavigation.add([
            element.path,
            element.path.substring(
              element.path.lastIndexOf('/') + 1,
              element.path.lastIndexOf('.'),
            ),
            randomInteger,
          ]);
        } else if (_isFolderAlbumArt(element.path)) {
//          dta = await rootBundle.load(element.path); //this does not work for other than app assets
          dta = element.readAsBytesSync().buffer.asByteData();
          Uint8List art = dta.buffer.asUint8List();
          rawArtworkImageFolderNavigation = art;
//          rawArtworkImageFolderNavigation =
//              image.encodeJpg(image.copyResize(image.decodeImage(art), width: 500, height: 500));
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
//        art = image.encodeJpg(image.copyResize(image.decodeImage(art), width: 500, height: 500));
      } catch (e) {}
      if (art != null) {
        audiosInFolderNavigation[i][2] = art;
      } else if (rawArtworkImageFolderNavigation != null) {
        audiosInFolderNavigation[i][2] = "";
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
    storage._audiosInFolderPlaying2.clear();
    storage.audiosInFolderNavigation.forEach((element) {
      storage.audiosInFolderPlaying0.add(element[0]);
      storage.audiosInFolderPlaying1.add(element[1]);
      storage._audiosInFolderPlaying2.add(element[2]);
    });
    rawArtworkImageFolderPlaying = rawArtworkImageFolderNavigation;
  }

  // ignore: non_constant_identifier_names
  void copy_audiosInFolderPlaying0_into_audiosInFolderNavigation() {
    storage.audiosInFolderNavigation.clear();
    for (int i = 0; i < storage.audiosInFolderPlaying0.length; i++) {
      storage.audiosInFolderNavigation.add([
        storage.audiosInFolderPlaying0[i],
        storage.audiosInFolderPlaying1[i],
        storage._audiosInFolderPlaying2[i],
      ]);
    }
    rawArtworkImageFolderNavigation = rawArtworkImageFolderPlaying;
  }
}
