import 'package:flutter/material.dart';
import 'constants.dart';
import 'classes/set_state_callbacks.dart';
//import 'classes/storage.dart';
import 'player_screen_widgets/player_widget.dart';
import 'background_image.dart';
//import 'package:palette_generator/palette_generator.dart';

bool playerScreenMounted = false;

final playerScaffoldKey = GlobalKey<ScaffoldState>();

class PlayerScreen extends StatefulWidget {
  @override
  PlayerScreenState createState() => PlayerScreenState();
}

class PlayerScreenState extends State<PlayerScreen> {
  @override
  void initState() {
    super.initState();
//    findColours();
    playerScreenMounted = true;
    setStateCalls.playerScreen = () {
      setState(() {});
      setStateCalls.bottomStackAnimation();
//      findColours();
    };
  }

  @override
  void dispose() {
    super.dispose();
    playerScreenMounted = false;
    setStateCalls.playerScreen = () => print('player screen already disposed -' * 20);
  }

//  PaletteGenerator paletteGenerator;
//  Color specialColor = Colors.red;
//
//  Future<void> findColours() async {
//    paletteGenerator = await PaletteGenerator.fromImageProvider(
//      MemoryImage(storage.audiosInFolderPlaying2[storage.currentAudioIndex]),
//      maximumColorCount: 20,
//    );
//    specialColor =
//        paletteGenerator?.darkMutedColor?.color ?? paletteGenerator?.dominantColor?.color ?? Colors.grey[700];
//    specialColor = Color.lerp(specialColor, Colors.grey[900], 0.5);
//    setState(() {});
//  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      child: Scaffold(
        backgroundColor: scaffoldTransparentColorForBgOverlay.withAlpha(150),
//        backgroundColor: Color.fromARGB(150, 40, 40, 40),
        key: playerScaffoldKey,
//        appBar: AppBar(
//          automaticallyImplyLeading: false,
//          title: Row(
//            children: <Widget>[
//              ColorTile(col: paletteGenerator?.dominantColor?.color, id: 'D'),
//              ColorTile(col: paletteGenerator?.lightVibrantColor?.color, id: 'V'),
//              ColorTile(col: paletteGenerator?.vibrantColor?.color, id: 'V'),
//              ColorTile(col: paletteGenerator?.darkVibrantColor?.color, id: 'V'),
//              ColorTile(col: paletteGenerator?.lightMutedColor?.color, id: 'M'),
//              ColorTile(col: paletteGenerator?.mutedColor?.color, id: 'M'),
//              ColorTile(col: paletteGenerator?.darkMutedColor?.color, id: 'M'),
//            ],
//          ),
//        ),
        body: SafeArea(
          child: PlayerWidget(
            unit: kPlayerScreenUnit,
            col1: Colors.white,
            col2: Colors.grey,
            col3: Colors.grey[800],
//            col3: specialColor,
//            col3: Color.fromARGB(255, 82, 82, 82), //between grey[700] and [800]
          ),
        ),
      ),
    );
  }
}

//class ColorTile extends StatelessWidget {
//  ColorTile({this.col, this.id});
//
//  final Color col;
//  final String id;
//
//  @override
//  Widget build(BuildContext context) {
//    return Expanded(
//      child: Container(
//        color: col,
//        height: kToolbarHeight,
//        alignment: Alignment.center,
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            Text(
//              id.substring(0, 1) ?? '',
//              style: TextStyle(
//                fontSize: kToolbarHeight / 3,
//                fontWeight: FontWeight.w100,
//                color:
//                    col != null ? col.computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.white,
//              ),
//            ),
//            RotatedBox(
//              quarterTurns: 1,
//              child: Text(
//                col != null
//                    ? (col.alpha.toRadixString(16) +
//                            col.red.toRadixString(16) +
//                            col.green.toRadixString(16) +
//                            col.blue.toRadixString(16))
//                        .toUpperCase()
//                    : 'null',
//                style: TextStyle(
//                  fontSize: kToolbarHeight / 6,
//                  fontWeight: FontWeight.w100,
//                  color:
//                      col != null ? col.computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.white,
//                ),
//              ),
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//}
