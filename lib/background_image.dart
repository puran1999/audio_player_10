import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'classes/storage.dart';
import 'classes/player.dart';

///This widget gives a fullscreen background image of the album art.
///Designed to be used as a parent for a scaffold with a transparent or translucent background.
///eg: using the scaffold property- backgroundColor: Color.fromARGB(200, 100, 100, 100),
Color scaffoldTransparentColorForBgOverlay = Color.fromARGB(200, 50, 50, 50);

class BackgroundImage extends StatelessWidget {
  BackgroundImage({this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: player.audio != null
              ? MemoryImage(storage.audiosInFolderPlaying2[storage.currentAudioIndex])
              : AssetImage('assets/coverArt_1.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: child,
      ),
    );
  }
}
