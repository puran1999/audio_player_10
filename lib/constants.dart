import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

///Actual Screen size as returned from: MediaQuery.of(context).size;
Size kScreenSize;

///the base unit for player screen.
double kPlayerScreenUnit;

///Total Height of List Tiles (including tile height and separator height) in folder screen and audio screen.
///All the text sizes also depend upon this, except those in player screen and floating player
double kListTileHeight;

///change this to change text size
int kListTileHeightFactor = 19; //0.19
const int kListTileHeightFactorMax = 26;
const int kListTileHeightFactorMin = 12;

///Total Height of the Floating audio player
double kFloaterHeight;

int kFloaterHeightFactor = 25;
const int kFloaterHeightFactorMax = 30;
const int kFloaterHeightFactorMin = 15;

/// other settings variables
bool initialAnimations = true;
bool playPauseAnimations = true;
bool sliderAnimations = true;
bool showFolderPath = true;
bool showStorageIcons = true;
bool shuffle = false;
bool loopSingle = false;

/// Random Art
bool randomArt = true;

/// Select AlbumArts
List<String> artIsSelected = ['1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1'];
const int artTotal = 13;
int artIsSelectedTotal = artTotal;

void artIsSelectedCalculateTotal() {
  artIsSelectedTotal = 0;
  artIsSelected.forEach((element) {
    if (element == '1') artIsSelectedTotal++;
  });
//  print(artIsSelectedTotal);
}

void artIsSelectedSelectAll() {
  artIsSelected = ['1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1'];
  artIsSelectedTotal = artTotal;
}

///setting the size constants require MediaQuery, hence a build context
void setAllConstants(BuildContext context) async {
  kScreenSize = MediaQuery.of(context).size;
  kPlayerScreenUnit = kScreenSize.width / 7.3;
  kFloaterHeight = kFloaterHeightFactor * kScreenSize.width / 100.0;
  kListTileHeight = kListTileHeightFactor * kScreenSize.width / 100.0;
}

Future<void> loadSettings() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  kListTileHeightFactor = prefs.getInt('kListTileHeightFactor') ?? kListTileHeightFactor;
  kFloaterHeightFactor = prefs.getInt('kFloaterHeightFactor') ?? kFloaterHeightFactor;
  initialAnimations = prefs.getBool('initialAnimations') ?? initialAnimations;
  playPauseAnimations = prefs.getBool('playPauseAnimations') ?? playPauseAnimations;
  sliderAnimations = prefs.getBool('sliderAnimations') ?? sliderAnimations;
  showFolderPath = prefs.getBool('showFolderPath') ?? showFolderPath;
  showStorageIcons = prefs.getBool('showStorageIcons') ?? showStorageIcons;
  shuffle = prefs.getBool('shuffle') ?? shuffle;
  loopSingle = prefs.getBool('loopSingle') ?? loopSingle;
  randomArt = prefs.getBool('randomArt') ?? randomArt;
  artIsSelected = prefs.getStringList('artIsSelected') ?? artIsSelected;
  artIsSelectedCalculateTotal();
}

void saveToDevice({@required String name, @required dynamic value}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (value.runtimeType == bool) {
    await prefs.setBool(name, value);
  } else if (value.runtimeType == int) {
    await prefs.setInt(name, value);
  } else if (value is List<String>) {
    artIsSelectedCalculateTotal();
    await prefs.setStringList(name, value);
  }
}

void resetToDefault() async {
  kListTileHeightFactor = 19;
  kListTileHeight = kListTileHeightFactor * kScreenSize.width / 100.0;
  kFloaterHeightFactor = 25;
  kFloaterHeight = kFloaterHeightFactor * kScreenSize.width / 100.0;
  initialAnimations = true;
  playPauseAnimations = true;
  sliderAnimations = true;
  showFolderPath = true;
  showStorageIcons = true;
  shuffle = false;
  loopSingle = false;
  randomArt = true;
  artIsSelectedSelectAll();
  artIsSelectedCalculateTotal();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('kListTileHeightFactor', kListTileHeightFactor);
  prefs.setInt('kFloaterHeightFactor', kFloaterHeightFactor);
  prefs.setBool('initialAnimations', initialAnimations);
  prefs.setBool('playPauseAnimations', playPauseAnimations);
  prefs.setBool('sliderAnimations', sliderAnimations);
  prefs.setBool('showFolderPath', showFolderPath);
  prefs.setBool('showStorageIcons', showStorageIcons);
  prefs.setBool('shuffle', shuffle);
  prefs.setBool('loopSingle', loopSingle);
  prefs.setBool('randomArt', randomArt);
  prefs.setStringList('artIsSelected', artIsSelected);
}
