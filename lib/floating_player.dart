import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:flutter/painting.dart';
import 'classes/set_state_callbacks.dart';
import 'classes/player.dart';
import 'classes/storage.dart';
import 'player_screen.dart';
import 'audio_screen.dart';

/// use this widget as an argument to any floatingActionsButton:
class FloatingPlayer extends StatefulWidget {
  /// parent screen need to pass its name (FolderScreen or AudioScreen)
  final String parentName;
  final Function audioScreenScrollCallback;

  FloatingPlayer({@required this.parentName, this.audioScreenScrollCallback});

  @override
  _FloatingPlayerState createState() => _FloatingPlayerState();
}

class _FloatingPlayerState extends State<FloatingPlayer> {
  final Color bgCol = Colors.grey[700];

  void gotoPlayer() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen())).then((value) {
      if (widget.parentName == 'AudioScreen') {
        setStateCalls.audioScreen();
      } else if (widget.parentName == 'FolderScreen') {
        setStateCalls.folderScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ///kFloaterHeight = 2*playerSizePar + playerGapsPar
    final double playerSizePar = 0.465 * kFloaterHeight;
    final double playerGapsPar = 0.07 * kFloaterHeight;

    return player.audio == null
        ? Container()
        : Hero(
            // this helps prevent floating player to go with new page transitions, and stay in one place only.
            tag: 'floater',
            child: Stack(
              alignment: Alignment.bottomRight,
              children: <Widget>[
                ///this widget prevents unwanted actions, when user taps any small inter-space b/w the buttons
                Padding(
                  padding:
                      EdgeInsets.only(right: 2 * playerSizePar - 0.5 * playerGapsPar, bottom: playerSizePar),
                  child: Transform(
                    transform: Matrix4.skew(-0.463, 0),
                    child: Container(
                      width: 2 * playerSizePar + 2 * playerGapsPar,
                      height: playerSizePar + playerGapsPar,
                      color: Colors.transparent,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 2 * playerSizePar + 3 * playerGapsPar),
                  child: Transform(
                    transform: Matrix4.skew(0.463, 0),
                    child: Padding(
                      padding: EdgeInsets.only(left: playerSizePar / 2),
                      child: Material(
                        color: bgCol,
                        elevation: 2,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.red,
                          onTap: gotoPlayer,
                          child: Container(
                            height: playerSizePar,
                            color: Colors.transparent,
                            child: Padding(
                              padding: EdgeInsets.only(left: playerSizePar / 2),
                              child: Transform(
                                transform: Matrix4.skew(-0.463, 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      player.tag.title,
                                      textScaleFactor: 1,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 0.3 * playerSizePar, color: Colors.white),
                                    ),
                                    Text(
                                      player.tag.artist,
                                      textScaleFactor: 1,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 0.3 * playerSizePar, color: Colors.white60),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      right: 1.5 * playerSizePar + 4 * playerGapsPar, bottom: playerSizePar + playerGapsPar),
                  child: SkewButton(
                    height: playerSizePar,
                    col: bgCol,
                    icon: player.audioPlaying ? Icons.pause : Icons.play_arrow,
                    onTap: () async {
                      player.audioPlaying
                          ? await player.pauseBackgroundAudio()
                          : player.resumeBackgroundAudio();
                      setState(() {});
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      right: 2.5 * playerSizePar + 5 * playerGapsPar, bottom: playerSizePar + playerGapsPar),
                  child: SkewButton(
                    height: playerSizePar,
                    col: bgCol,
                    icon: Icons.format_list_bulleted,
                    onTap: () {
                      if (widget.parentName == 'AudioScreen') {
                        if (storage.currentPlayingFolderIndex != storage.currentNavigationFolderIndex) {
                          Navigator.pop(context);
                          storage.copy_audiosInFolderPlaying0_into_audiosInFolderNavigation();
                          storage.currentNavigationFolderIndex = storage.currentPlayingFolderIndex;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AudioScreen(
                                        autoScroll: true,
                                      ))).then((value) => setStateCalls.folderScreen());
                        } else {
                          widget.audioScreenScrollCallback(); //for scrolling
                        }
                      } else if (widget.parentName == 'FolderScreen') {
                        storage.copy_audiosInFolderPlaying0_into_audiosInFolderNavigation();
                        storage.currentNavigationFolderIndex = storage.currentPlayingFolderIndex;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AudioScreen(
                                      autoScroll: true,
                                    ))).then((value) => setStateCalls.folderScreen());
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: playerSizePar + playerGapsPar,
                    right: 0.5 * playerSizePar,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Transform(
                        transform: Matrix4.skew(-0.463, 0),
                        child: Material(
                          elevation: 2,
                          child: Container(
                            width: 0.5 * playerSizePar + 1.5 * playerGapsPar,
                            height: playerSizePar,
                            color: bgCol,
                          ),
                        ),
                      ),
                      Transform(
                        transform: Matrix4.skew(0.463, 0),
                        child: Material(
                          elevation: 2,
                          child: Container(
                            width: 0.5 * playerSizePar + 1.5 * playerGapsPar,
                            height: playerSizePar,
                            color: bgCol,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: playerGapsPar),
                  child: GestureDetector(
                    onTap: gotoPlayer,
                    child: CircleAvatar(
                      radius: playerSizePar + playerGapsPar / 2,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: playerSizePar + playerGapsPar / 2 - 1,
                        backgroundImage:
                            MemoryImage(storage.audiosInFolderPlaying2[storage.currentAudioIndex]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

class SkewButton extends StatelessWidget {
  final Color col;
  final double height;
  final IconData icon;
  final Function onTap;

  const SkewButton({this.col, this.height, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.skew(-0.463, 0),
      child: Material(
        color: col,
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          highlightColor: Colors.red,
          splashColor: Colors.red,
          child: Stack(
            alignment: Alignment.centerRight,
            children: <Widget>[
              ClipRect(
                child: Transform(
                  transform: Matrix4.skew(3.141 / 4, 0),
                  child: Container(
                    height: height,
                    width: height,
                    color: Colors.white10,
                  ),
                ),
              ),
              Container(
                height: height,
                width: height,
                color: Colors.transparent,
                child: Icon(
                  icon,
                  size: 0.6 * height,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
