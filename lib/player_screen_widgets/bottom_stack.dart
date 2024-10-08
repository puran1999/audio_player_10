import 'package:flutter/material.dart';
import '../constants.dart';
import '../classes/set_state_callbacks.dart';
import '../classes/player.dart';
import '../classes/storage.dart';

import 'cover_clipper.dart';

class BottomStack extends StatefulWidget {
  final double unit;
  final Color col1, col2, col3;

  BottomStack({@required this.unit, this.col1, this.col2, this.col3});

  @override
  _BottomStackState createState() => _BottomStackState();
}

class _BottomStackState extends State<BottomStack> with WidgetsBindingObserver {
  Offset bottomRightClipPad;
  double destination = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStateCalls.bottomStackAnimation = setStateAnimation;
    if (initialAnimations) {
      Future.delayed(Duration(milliseconds: 1200), () {
        if (mounted) setState(() => destination = 0);
      });
    } else {
      if (playPauseAnimations) {
        player.audioPlaying ? destination = 0 : destination = 0.78;
      } else {
        destination = 0;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    setStateCalls.bottomStackAnimation = () => print('bottom stack already disposed -' * 20);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
//    print('$state---------------' * 500);
    if (state == AppLifecycleState.resumed) {
//      print('now*****' * 500);
      if (initialAnimations) {
        if (destination == 0 || destination == 0.78) {
          setState(() => destination = 3);
          Future.delayed(Duration(milliseconds: 1600), () {
            if (mounted) setState(() => destination = 0);
          });
        }
      }
    }
  }

  void setStateAnimation() {
    if (playPauseAnimations) {
      setStateCalls.centreStackAnimation();
      player.audioPlaying ? destination = 0 : destination = 0.78;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration backDecoration = BoxDecoration(
      color: widget.col3,
      border: Border.all(color: widget.col2, width: 0.2),
    );
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        TweenAnimationBuilder(
          onEnd: () {
            if (playPauseAnimations && destination != 3) {
              setState(() => player.audioPlaying ? destination = 0 : destination = 0.78);
            }
          },
          duration: Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
          tween: Tween<double>(begin: initialAnimations ? 3 : 0, end: destination),
          builder: (BuildContext context, double d, Widget child) {
            return Transform.translate(
                offset: Offset(d * widget.unit, 0.5 * (1 - d) * widget.unit), child: child);
          },
          child: Align(
            alignment: Alignment.bottomRight,
            heightFactor: 0.5,
            widthFactor: 1.32,
            child: ClipPath(
              clipper: BottomRightClip(),
              child: SquaredAlbumArtWidget(size: 4 * widget.unit),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: widget.unit, top: 0.5 * widget.unit),
          child: Material(
            elevation: 3,
            child: Container(
              width: widget.unit,
              height: widget.unit,
              decoration: backDecoration,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: widget.unit, top: 1.5 * widget.unit),
          child: Material(
            elevation: 3,
            child: Container(
              width: widget.unit,
              height: widget.unit,
              decoration: backDecoration,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 3 * widget.unit, top: 0.5 * widget.unit),
          child: Transform(
            transform: Matrix4.skew(0, -0.463),
            child: Material(
              color: widget.col2,
              elevation: 3,
              child: InkWell(
                splashColor: Colors.red,
                highlightColor: Colors.red.withAlpha(200),
                child: Container(
                  width: widget.unit,
                  height: widget.unit,
                  child: Icon(
                    Icons.skip_next,
                    color: widget.col1,
                    size: 0.7 * widget.unit,
                  ),
                ),
                onTap: () async {
                  await player.playNext();
                  setStateCalls.playerScreen();
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 3 * widget.unit, top: 2 * widget.unit),
          child: Transform(
            transform: Matrix4.skew(0, -0.463),
            child: Material(
              color: widget.col2,
              elevation: 3,
              child: InkWell(
                splashColor: Colors.red,
                highlightColor: Colors.red.withAlpha(200),
                child: Container(
                  width: widget.unit,
                  height: widget.unit,
                  child: Icon(
                    Icons.skip_previous,
                    color: widget.col1,
                    size: 0.7 * widget.unit,
                  ),
                ),
                onTap: () async {
                  await player.playPrev();
                  setStateCalls.playerScreen();
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 0.85 * widget.unit),
          child: Material(
            color: widget.col2,
            elevation: 3,
            child: InkWell(
              splashColor: Colors.red,
              highlightColor: Colors.red.withAlpha(200),
              child: Container(
                width: 1.25 * widget.unit,
                height: 1.25 * widget.unit,
                child: Icon(
                  player.audioPlaying ? Icons.pause : Icons.play_arrow,
                  color: widget.col1,
                  size: 0.8 * widget.unit,
                ),
              ),
              onTap: () async {
                if (player.audioPlaying) {
                  await player.pauseBackgroundAudio();
//                  destination = 0.78;
                } else {
                  await player.resumeBackgroundAudio();
//                  destination = 0;
                }
                setStateAnimation();
              },
            ),
          ),
        ),
      ],
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
//          image: MemoryImage(storage.audiosInFolderPlaying2[storage.currentAudioIndex]),
          image: storage.audiosInFolderPlaying2Artwork(storage.currentAudioIndex),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
