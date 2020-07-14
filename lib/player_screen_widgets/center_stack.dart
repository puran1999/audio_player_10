import 'package:flutter/material.dart';
import '../constants.dart';
import '../classes/player.dart';
import '../classes/set_state_callbacks.dart';
import '../classes/storage.dart';
import '../player_screen.dart';
import '../audio_screen.dart';
import 'cover_clipper.dart';
import 'custom_icons.dart';

class CenterStack extends StatefulWidget {
  final double unit;
  final Color col1, col2, col3;

  CenterStack({@required this.unit, this.col1, this.col2, this.col3});

  @override
  _CenterStackState createState() => _CenterStackState();
}

class _CenterStackState extends State<CenterStack> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStateCalls.centreStackAnimation = setStateAnimation;
    if (initialAnimations) {
      //padding values for a complete image in the start
      topRightClipPad = Offset(0, 0.5 * widget.unit);
      bottomLeftClipPad = Offset(0, 0.5 * widget.unit);
      bottomRightClipPad = Offset(4 * widget.unit, 2.5 * widget.unit);
      loopButtonPad = Offset(3 * widget.unit, 3 * widget.unit);
      shuffleButtonPad = Offset(3 * widget.unit, 2 * widget.unit);
      shuffleButtonBackPad = Offset(3 * widget.unit, 2 * widget.unit);
      listButtonPad = Offset(3 * widget.unit, 2.5 * widget.unit);
      listButtonBackPad = Offset(3 * widget.unit, 1.5 * widget.unit);
      animationStep = 0;
      nextAnimation();
    } else {
      loopButtonPad = Offset(5 * widget.unit, 3.5 * widget.unit);
      shuffleButtonPad = Offset(5 * widget.unit, 1.5 * widget.unit);
      shuffleButtonBackPad = Offset(3 * widget.unit, 1 * widget.unit);
      listButtonPad = Offset(5 * widget.unit, 3 * widget.unit);
      listButtonBackPad = Offset(5.4 * widget.unit, 2.8 * widget.unit);
      animationStep = 100;
      if (playPauseAnimations) {
        if (player.audioPlaying) {
          topRightClipPad = Offset(2 * widget.unit, 0);
          bottomLeftClipPad = Offset(2 * widget.unit, 2 * widget.unit);
          bottomRightClipPad = Offset(0, 1.5 * widget.unit);
        } else {
          topRightClipPad = Offset(1 * widget.unit, 0.25 * widget.unit);
          bottomLeftClipPad = Offset(1 * widget.unit, 1.75 * widget.unit);
          bottomRightClipPad = Offset(3.5 * widget.unit, 3.25 * widget.unit);
        }
      } else {
        topRightClipPad = Offset(2 * widget.unit, 0);
        bottomLeftClipPad = Offset(2 * widget.unit, 2 * widget.unit);
        bottomRightClipPad = Offset(0, 1.5 * widget.unit);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    setStateCalls.centreStackAnimation = () => print('center stack is already removed -- ' * 100);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
//    print('$state---------------' * 500);
    if (state == AppLifecycleState.resumed) {
//      print('now*****' * 500);
      if (initialAnimations && animationStep > 3) {
        setState(() {
          //padding values for a complete image in the start
          topRightClipPad = Offset(0, 0.5 * widget.unit);
          bottomLeftClipPad = Offset(0, 0.5 * widget.unit);
          bottomRightClipPad = Offset(4 * widget.unit, 2.5 * widget.unit);
          loopButtonPad = Offset(3 * widget.unit, 3 * widget.unit);
          shuffleButtonPad = Offset(3 * widget.unit, 2 * widget.unit);
          shuffleButtonBackPad = Offset(3 * widget.unit, 2 * widget.unit);
          listButtonPad = Offset(3 * widget.unit, 2.5 * widget.unit);
          listButtonBackPad = Offset(3 * widget.unit, 1.5 * widget.unit);
          animationStep = 0;
        });
      }
    }
  }

  final Duration commonDuration = const Duration(milliseconds: 400);
  final Curve commonCurve = Curves.fastOutSlowIn;
  int animationStep;
  Offset topRightClipPad;
  Offset bottomLeftClipPad;
  Offset bottomRightClipPad;
  Offset loopButtonPad;
  Offset shuffleButtonPad;
  Offset shuffleButtonBackPad;
  Offset listButtonPad;
  Offset listButtonBackPad;

  void nextAnimation() {
    if (initialAnimations) {
      if (animationStep == 0) {
        Future.delayed(Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              bottomLeftClipPad = Offset(0, 1.5 * widget.unit);
              bottomRightClipPad = Offset(4 * widget.unit, 3.5 * widget.unit);
              loopButtonPad = Offset(3 * widget.unit, 4 * widget.unit);
              listButtonBackPad = Offset(3 * widget.unit, 2.5 * widget.unit);
            });
          }
        });
      } else if (animationStep == 1) {
        setState(() {
          topRightClipPad = Offset(2 * widget.unit, 0);
          bottomLeftClipPad = Offset(2 * widget.unit, 2 * widget.unit);
          bottomRightClipPad = Offset(0, 1.5 * widget.unit);
          loopButtonPad = Offset(5 * widget.unit, 3.5 * widget.unit);
          shuffleButtonPad = Offset(5 * widget.unit, 1.5 * widget.unit);
          shuffleButtonBackPad = Offset(5 * widget.unit, 1.5 * widget.unit);
          listButtonPad = Offset(5 * widget.unit, 3 * widget.unit);
          listButtonBackPad = Offset(5 * widget.unit, 3 * widget.unit);
        });
      } else if (animationStep == 2) {
        setState(() {
          listButtonBackPad = Offset(5.4 * widget.unit, 2.8 * widget.unit);
          shuffleButtonBackPad = Offset(3 * widget.unit, 1 * widget.unit);
        });
      } else if (animationStep == 3) {
        setStateAnimation();
      }
      animationStep++;
    }
  }

  void setStateAnimation() {
    if (playPauseAnimations) {
      setState(() {
        if (player.audioPlaying) {
          topRightClipPad = Offset(2 * widget.unit, 0);
          bottomLeftClipPad = Offset(2 * widget.unit, 2 * widget.unit);
          bottomRightClipPad = Offset(0, 1.5 * widget.unit);
        } else {
          topRightClipPad = Offset(1 * widget.unit, 0.25 * widget.unit);
          bottomLeftClipPad = Offset(1 * widget.unit, 1.75 * widget.unit);
          bottomRightClipPad = Offset(3.5 * widget.unit, 3.25 * widget.unit);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration backDecoration = BoxDecoration(
      color: widget.col3,
      border: Border.all(color: widget.col2, width: 0.5),
    );
    return Transform.translate(
      offset: Offset(0, 0.2 * widget.unit),
      child: SizedBox(
        width: 7 * widget.unit,
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            ///this one is just to constrain the minimum vertical size, to make animations stable
            Container(
              color: Colors.transparent,
              width: 50,
              height: 6 * widget.unit,
            ),
            AnimatedPadding(
              ///sequence progression
              onEnd: nextAnimation,
              duration: commonDuration,
              curve: commonCurve,
              padding: EdgeInsets.only(top: listButtonBackPad.dy, right: listButtonBackPad.dx),
              child: Transform(
                transform: Matrix4.skew(0, -0.463),
                child: Material(
                  elevation: 3,
                  child: Container(
                    width: widget.unit,
                    height: widget.unit,
                    decoration: backDecoration,
                  ),
                ),
              ),
            ),
            AnimatedPadding(
              duration: commonDuration,
              curve: commonCurve,
              padding: EdgeInsets.only(top: shuffleButtonBackPad.dy, left: shuffleButtonBackPad.dx),
              child: Transform(
                transform: Matrix4.skew(0, -0.463),
                child: Material(
                  elevation: 3,
                  child: Container(
                    width: widget.unit,
                    height: widget.unit,
                    decoration: backDecoration,
                  ),
                ),
              ),
            ),
            AnimatedPadding(
              duration: commonDuration,
              curve: commonCurve,
//            padding: EdgeInsets.only(top: 2.58 * widget.unit, left: 3.2 * widget.unit),
              padding: EdgeInsets.only(
                  top: loopButtonPad.dy - 0.92 * widget.unit, left: loopButtonPad.dx - 1.8 * widget.unit),
              child: Transform.rotate(
                angle: 3.141 / 2 - 0.463,
                child: Transform(
                  transform: Matrix4.skew(0, -0.643),
                  child: Material(
                    elevation: 3,
                    child: Container(
                      width: widget.unit,
                      height: 1.12 * widget.unit,
                      decoration: backDecoration,
                    ),
                  ),
                ),
              ),
            ),

            AnimatedPadding(
              duration: commonDuration,
              curve: commonCurve,
              padding: EdgeInsets.only(top: shuffleButtonPad.dy, left: shuffleButtonPad.dx),
              child: Button(
                size: widget.unit,
                bgCol: widget.col2,
                fgCol: widget.col1,
                ico: shuffle ? MyFlutterApp.icon_shuffle_true : MyFlutterApp.icon_shuffle_false,
                onTap: () {
                  setState(() {
                    shuffle = !shuffle;
                    saveToDevice(name: 'shuffle', value: shuffle);
                    playerScaffoldKey.currentState.showSnackBar(SnackBar(
                      content: RichText(
                        text: TextSpan(
                          text: shuffle ? 'Shuffle ON' : 'Shuffle OFF',
                          style: TextStyle(color: Colors.white, fontSize: 0.25 * kListTileHeight),
                        ),
                      ),
                      duration: Duration(milliseconds: 500),
                      backgroundColor: Colors.black45,
                    ));
                  });
                },
              ),
            ),
            AnimatedPadding(
              duration: commonDuration,
              curve: commonCurve,
              padding: EdgeInsets.only(left: loopButtonPad.dx, top: loopButtonPad.dy),
              child: Button(
                size: widget.unit,
                bgCol: widget.col2,
                fgCol: widget.col1,
                ico: loopSingle ? MyFlutterApp.icon_loop_true : MyFlutterApp.icon_loop_false,
                onTap: () {
                  setState(() {
                    loopSingle = !loopSingle;
                    saveToDevice(name: 'loopSingle', value: loopSingle);
                    playerScaffoldKey.currentState.showSnackBar(SnackBar(
                      content: RichText(
                        text: TextSpan(
                          text: loopSingle ? 'Loop single' : 'No loop',
                          style: TextStyle(color: Colors.white, fontSize: 0.25 * kListTileHeight),
                        ),
                      ),
                      duration: Duration(milliseconds: 500),
                      backgroundColor: Colors.black45,
                    ));
                  });
                },
              ),
            ),
            AnimatedPadding(
              duration: commonDuration,
              curve: commonCurve,
              padding: EdgeInsets.only(top: listButtonPad.dy, right: listButtonPad.dx),
              child: Button(
                size: widget.unit,
                bgCol: widget.col2,
                fgCol: widget.col1,
                ico: MyFlutterApp.icon_menu,
                onTap: () {
                  setState(() {
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                    storage.copy_audiosInFolderPlaying0_into_audiosInFolderNavigation();
                    storage.currentNavigationFolderIndex = storage.currentPlayingFolderIndex;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AudioScreen(
                                  autoScroll: true,
                                ))).then((value) => setStateCalls.folderScreen());
                  });
                },
              ),
            ),

            AnimatedPadding(
              duration: commonDuration,
              curve: commonCurve,
              padding: EdgeInsets.only(left: topRightClipPad.dx, top: topRightClipPad.dy),
              child: ClipPath(
                clipper: TopRightClip(),
                child: SquaredAlbumArtWidget(size: 4 * widget.unit),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: widget.unit / 2),
              child: ClipPath(
                clipper: animationStep <= 1 ? CenterClipWithBottomLeft() : CenterClipWithoutBottomLeft(),
                child: SquaredAlbumArtWidget(size: 4 * widget.unit),
              ),
            ),
            AnimatedPadding(
              duration: commonDuration,
              curve: commonCurve,
              padding: EdgeInsets.only(top: bottomLeftClipPad.dy, right: bottomLeftClipPad.dx),
              child: ClipPath(
                clipper: BottomLeftClip(),
                child: SquaredAlbumArtWidget(size: 4 * widget.unit),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Transform.translate(
                offset: Offset(2.5 * widget.unit, 0),
                child: AnimatedPadding(
                  duration: commonDuration,
                  curve: commonCurve,
                  padding: EdgeInsets.only(
                    top: bottomRightClipPad.dy,
                    right: bottomRightClipPad.dx,
                  ),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    heightFactor: 0.5,
                    child: ClipPath(
                      clipper: BottomRightClip(),
                      child: SquaredAlbumArtWidget(size: 4 * widget.unit),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Button extends StatelessWidget {
  Button({this.size, this.bgCol, this.fgCol, this.ico, this.onTap});

  final double size;
  final Color bgCol, fgCol;
  final IconData ico;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.skew(0, -0.463),
      child: Material(
        color: bgCol,
        elevation: 3,
        child: InkWell(
          splashColor: Colors.red,
          highlightColor: Colors.red.withAlpha(200),
          child: Container(
            width: size,
            height: size,
            child: Icon(ico, color: fgCol, size: 0.7 * size),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class SquaredAlbumArtWidget extends StatelessWidget {
  SquaredAlbumArtWidget({@required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: MemoryImage(storage.audiosInFolderPlaying2[storage.currentAudioIndex]),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
