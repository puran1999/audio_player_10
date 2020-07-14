import 'package:flutter/material.dart';
import 'classes/player.dart';
import 'classes/set_state_callbacks.dart';
import 'classes/storage.dart';
import 'player_screen.dart';
import 'floating_player.dart';
import 'background_image.dart';
import 'constants.dart';
import 'settings_screen.dart';
import 'about_dialog_screen.dart';

class AudioScreen extends StatefulWidget {
  AudioScreen({this.autoScroll = false});

  final bool autoScroll;

  @override
  AudioScreenState createState() => AudioScreenState();
}

class AudioScreenState extends State<AudioScreen> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    setStateCalls.audioScreen = simpleSetState;
    if (widget.autoScroll) {
      Future.delayed(Duration(microseconds: 500), () {
        if (mounted) {
          scrollToCurrentPlaying();
        }
      });
    }
  }

  ///when user taps on playlist button, audio screen disposes (player screen may or may not)
  ///and quickly rebuilds the audio screen again. both these task happen to occur simultaneously.
  ///Therefore, since it takes some time after disposed is called, so it happens like that:
  /// !! dispose of prev is called after initState of new, thus removing the callback !!
  /// So, callback is not removed in dispose as done in other widgets.
  /// instead, callback checks mounted property and then calls setState.
  /// mounted is true only if a widget is present in a tree.
  void simpleSetState() {
    if (mounted) {
      setState(() {
//        if (storage.currentNavigationFolderIndex == storage.currentPlayingFolderIndex) {
//          scrollToCurrentPlaying();
//        }
      });
    }
  }

  void scrollToCurrentPlaying() {
    _controller.animateTo((kListTileHeight) * (storage.currentAudioIndex + 1) - kScreenSize.height / 2,
        duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      child: Scaffold(
        backgroundColor: scaffoldTransparentColorForBgOverlay,
        appBar: AppBar(
          backgroundColor: Colors.black.withAlpha(50),
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.folder, color: Colors.orangeAccent),
          ),
          title: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              storage.foldersWithAudio[storage.currentNavigationFolderIndex][1],
              textScaleFactor: 1,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 0.25 * kListTileHeight),
            ),
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
        body: ListView.separated(
          controller: _controller,
          itemCount: storage.audiosInFolderNavigation.length + 1,
          separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
          itemBuilder: (context, index) {
            return index >= storage.audiosInFolderNavigation.length
                ? Container(height: kFloaterHeight)
                : Container(
                    height: kListTileHeight - 1,
                    alignment: Alignment.center,
                    child: ListTile(
                      title: Container(
                        height: kListTileHeight,
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                backgroundImage: MemoryImage(storage.audiosInFolderNavigation[index][2]),
                                radius: 0.35 * kListTileHeight,
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints.tight(
                                    Size(kScreenSize.width - kListTileHeight - 30, kListTileHeight)),
                                child: Container(
                                  padding: EdgeInsets.only(left: 15),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    storage.audiosInFolderNavigation[index][1],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                      fontSize: 0.25 * kListTileHeight,
                                      color: index == storage.currentAudioIndex &&
                                              storage.currentNavigationFolderIndex ==
                                                  storage.currentPlayingFolderIndex
                                          ? Colors.tealAccent
                                          : null,
                                      shadows: [
                                        Shadow(color: Colors.black, blurRadius: 2),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () async {
                        storage.currentAudioIndex = index;
                        storage.currentPlayingFolderIndex = storage.currentNavigationFolderIndex;
                        storage.copy_audiosInFolderNavigation_into_audiosInFolderPlaying();
                        await player.playNew();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen()))
                            .then((value) {
                          simpleSetState();
                        });
                        setState(() {});
                      },
                      onLongPress: () {},
                    ),
                  );
          },
        ),
        floatingActionButton: FloatingPlayer(
          parentName: 'AudioScreen',
          audioScreenScrollCallback: scrollToCurrentPlaying,
        ),
      ),
    );
  }
}
