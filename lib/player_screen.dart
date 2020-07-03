import 'package:flutter/material.dart';
import 'constants.dart';
import 'classes/set_state_callbacks.dart';
import 'player_screen_widgets/player_widget.dart';
import 'background_image.dart';

final playerScaffoldKey = GlobalKey<ScaffoldState>();

class PlayerScreen extends StatefulWidget {
  @override
  PlayerScreenState createState() => PlayerScreenState();
}

class PlayerScreenState extends State<PlayerScreen> {
  @override
  void initState() {
    super.initState();
    setStateCalls.playerScreen = () {
      setState(() {});
      setStateCalls.bottomStackAnimation();
    };
  }

  @override
  void dispose() {
    super.dispose();
    setStateCalls.playerScreen = () => print('player screen already disposed -' * 20);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      child: Scaffold(
        backgroundColor: scaffoldTransparentColorForBgOverlay.withAlpha(150),
        key: playerScaffoldKey,
        body: SafeArea(
          child: PlayerWidget(
            unit: kPlayerScreenUnit,
            col1: Colors.white,
            col2: Colors.grey,
            col3: Colors.grey[800],
          ),
        ),
      ),
    );
  }
}
