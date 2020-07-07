import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'classes/set_state_callbacks.dart';
import 'classes/storage.dart';
import 'audio_screen.dart';
import 'floating_player.dart';
import 'background_image.dart';
import 'constants.dart';
import 'settings_screen.dart';
import 'package:move_to_background/move_to_background.dart';
import 'about_dialog_screen.dart';

class FolderScreen extends StatefulWidget {
  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  @override
  void initState() {
    super.initState();
    setStateCalls.folderScreen = () => setState(() {});
    settingsLoad();
  }

  bool loaded = false;

  Future<void> settingsLoad() async {
//    Future.delayed(Duration(seconds: 2), () async {
    await loadSettings();
    await storage.loadFolders();
    setState(() {
      loaded = true;
    });
//    });
  }

  @override
  void dispose() {
    super.dispose();
    setStateCalls.folderScreen = () => print('folder screen already disposed -' * 20);
  }

  @override
  Widget build(BuildContext context) {
    setAllConstants(context);
    return !loaded
        ? Container(
            color: Colors.white,
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                child: Image.asset('assets/app_icon.png'),
              ),
            ),
          )
        : BackgroundImage(
            child: Scaffold(
              backgroundColor: scaffoldTransparentColorForBgOverlay,
              appBar: AppBar(
                backgroundColor: Colors.black.withAlpha(50),
                title: Text(
                  'Found ${storage.foldersWithAudio.length} Audio folders',
                  textScaleFactor: 1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 0.25 * kListTileHeight),
                ),
                actions: <Widget>[
                  IconButton(
                    iconSize: kToolbarHeight / 2,
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()))
                          .then((value) => setState(() {}));
                    },
                  ),
                  IconButton(
                    iconSize: kToolbarHeight / 2,
                    icon: Icon(Icons.info),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AboutDialogScreen();
                        },
                      );
                    },
                  ),
                ],
              ),
              body: WillPopScope(
                onWillPop: () async {
                  MoveToBackground.moveTaskToBack();
                  return false;
                },
                child: ListView.separated(
                  itemCount: storage.foldersWithAudio.length + 1,
                  separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    return index >= storage.foldersWithAudio.length
                        ? Container(height: kFloaterHeight)
                        : Container(
                            height: kListTileHeight - 1,
                            alignment: Alignment.center,
                            child: ListTile(
                              trailing: !showStorageIcons
                                  ? null
                                  : Icon(
                                      storage.foldersWithAudio[index][2].startsWith('Int')
                                          ? Icons.phone_android
                                          : storage.foldersWithAudio[index][2].startsWith('SD')
                                              ? Icons.sd_storage
                                              : Icons.usb,
                                      color: Colors.white38,
                                    ),
                              leading: Icon(
                                index == storage.currentPlayingFolderIndex ? Icons.folder_open : Icons.folder,
                                color: Colors.orangeAccent,
                              ),
                              title: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    storage.foldersWithAudio[index][1],
                                    textScaleFactor: 1,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 0.25 * kListTileHeight,
                                      color: index == storage.currentPlayingFolderIndex
                                          ? Colors.tealAccent
                                          : Colors.white,
                                      shadows: [
                                        Shadow(color: Colors.black, blurRadius: 2),
                                      ],
                                    ),
                                  ),
                                  !showFolderPath
                                      ? Container()
                                      : Text(
                                          storage.foldersWithAudio[index][2],
                                          textScaleFactor: 1,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 0.15 * kListTileHeight,
                                            color: Color.fromARGB(255, 150, 150, 150),
                                          ),
                                        ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  storage.findAllAudios(storage.foldersWithAudio[index][0]);
                                  storage.currentNavigationFolderIndex = index;
                                  Navigator.push(
                                          context, MaterialPageRoute(builder: (context) => AudioScreen()))
                                      .then((value) => setState(() {}));
                                });
                              },
                            ),
                          );
                  },
                ),
              ),
              floatingActionButton: FloatingPlayer(parentName: 'FolderScreen'),
            ),
          );
  }
}
