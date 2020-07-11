import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'background_image.dart';
import 'classes/storage.dart';
import 'constants.dart';
import 'my_expansion_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'floating_player.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

final GlobalKey<MyExpansionTileState> expansionTile1 = new GlobalKey();
final GlobalKey<MyExpansionTileState> expansionTile2 = new GlobalKey();
final GlobalKey<MyExpansionTileState> expansionTile3 = new GlobalKey();
final GlobalKey<MyExpansionTileState> expansionTile4 = new GlobalKey();
final GlobalKey<MyExpansionTileState> expansionTile5 = new GlobalKey();

class _SettingsScreenState extends State<SettingsScreen> {
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    loadPref();
  }

  Future<void> loadPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    final double txtHeadingSize = 0.25;
    final double txtBodySize = 0.2;
    final Color txtBodyCol = Color.fromARGB(255, 150, 150, 150);

    return BackgroundImage(
      child: Scaffold(
        backgroundColor: scaffoldTransparentColorForBgOverlay,
        appBar: AppBar(
          backgroundColor: Colors.black.withAlpha(80),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              MyAnimatedSizeText('Settings', size: 0.25 * kListTileHeight),
              FlatButton(
                child: MyAnimatedSizeText(
                  'Reset to default',
                  size: 0.2 * kListTileHeight,
                  col: Colors.tealAccent,
                ),
                color: Colors.tealAccent.withAlpha(20),
                onPressed: () async {
                  resetToDefault();
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        body: ListView(
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            Container(
              color: Colors.black45,
              margin: const EdgeInsets.only(right: 10, top: 10, left: 10),
              child: MyExpansionTile(
                key: expansionTile1,
                onExpansionChanged: (bool b) {
                  if (b) {
                    expansionTile2.currentState.collapse();
                    expansionTile3.currentState.collapse();
                    expansionTile4.currentState.collapse();
                    expansionTile5.currentState.collapse();
                  }
                  setState(() {});
                },
                leading: Icon(Icons.text_fields),
                title: MyAnimatedSizeText('Text Size', size: txtHeadingSize * kListTileHeight),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(height: 1, color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                        trackShape: RoundedRectSliderTrackShape(),
                        trackHeight: 0.01 * kScreenSize.width,
                        thumbShape: RoundRectThumbShapeWithTxt(
                          txt: kListTileHeightFactor.toString(),
                          thumbSize: 0.06 * kScreenSize.width,
                          thumbRadius: 0.02 * kScreenSize.width,
                          bgCol: Colors.tealAccent,
                          txtCol: Colors.black,
                        ),
                        thumbColor: Colors.tealAccent,
                        overlayColor: Colors.tealAccent.withAlpha(100),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 20.0),
//                tickMarkShape: RoundSliderTickMarkShape(),
                        activeTickMarkColor: Colors.tealAccent,
                        inactiveTickMarkColor: Colors.white,
                      ),
                      child: Slider(
                        value: kListTileHeightFactor.toDouble(),
                        min: kListTileHeightFactorMin.toDouble(),
                        max: kListTileHeightFactorMax.toDouble(),
                        divisions: kListTileHeightFactorMax - kListTileHeightFactorMin,
                        onChanged: (double d) {
                          setState(() {
                            kListTileHeightFactor = d.toInt();
                            kListTileHeight = kListTileHeightFactor * kScreenSize.width / 100.0;
                          });
                        },
                        onChangeEnd: (double d) async {
                          kListTileHeightFactor = d.toInt();
                          saveToDevice(name: 'kListTileHeightFactor', value: kListTileHeightFactor);
                        },
                      ),
                    ),
                  ),
                  Divider(height: 1),

                  ///folder sample
                  AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.fastOutSlowIn,
                    height: kListTileHeight - 1,
                    child: ListTile(
                      onTap: () {},
                      leading: Icon(Icons.folder, color: Colors.orangeAccent),
                      trailing: Icon(Icons.sd_card, color: Colors.white38),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MyAnimatedSizeText(
                            'Folder text sample',
                            size: 0.25 * kListTileHeight,
                          ),
                          MyAnimatedSizeText(
                            'Mysterious/Folder/Path',
                            size: 0.15 * kListTileHeight,
                            col: Color.fromARGB(255, 150, 150, 150),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1),

                  ///Audio sample
                  AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.fastOutSlowIn,
                    height: kListTileHeight - 1,
                    child: ListTile(
                      onTap: () {},
                      title: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: kListTileHeight - 1,
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                backgroundImage: MemoryImage(storage.rawArtworkImageDefault),
                                radius: 0.35 * kListTileHeight,
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 15),
                                alignment: Alignment.centerLeft,
                                child: MyAnimatedSizeText('Music text sample', size: 0.25 * kListTileHeight),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.black45,
              margin: const EdgeInsets.only(right: 10, top: 10, left: 10),
              child: MyExpansionTile(
                key: expansionTile2,
                onExpansionChanged: (bool b) {
                  if (b) {
                    expansionTile1.currentState.collapse();
                    expansionTile3.currentState.collapse();
                    expansionTile4.currentState.collapse();
                    expansionTile5.currentState.collapse();
                  }
                  setState(() {});
                },
                leading: Icon(Icons.av_timer),
                title: MyAnimatedSizeText('Animations', size: txtHeadingSize * kListTileHeight),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(height: 1, color: Colors.white),
                  ),
                  ListTile(
                    title: Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.2 * kListTileHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MyAnimatedSizeText(
                            'Initial Animations',
                            size: txtHeadingSize * kListTileHeight,
                          ),
                          MyAnimatedSizeText(
                            'These animations appear when the Player Screen is just opened.',
                            size: txtBodySize * kListTileHeight,
                            col: txtBodyCol,
                          ),
                        ],
                      ),
                    ),
                    trailing: Switch(
                      value: initialAnimations,
                      onChanged: (bool b) {
                        setState(() {
                          initialAnimations = b;
                        });
                        saveToDevice(name: 'initialAnimations', value: initialAnimations);
                      },
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    title: Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.2 * kListTileHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MyAnimatedSizeText(
                            'Play/Pause Animations',
                            size: txtHeadingSize * kListTileHeight,
                          ),
                          MyAnimatedSizeText(
                            'These animations appear on the play and pause events of an audio playback.',
                            size: txtBodySize * kListTileHeight,
                            col: txtBodyCol,
                          ),
                        ],
                      ),
                    ),
                    trailing: Switch(
                      value: playPauseAnimations,
                      onChanged: (bool b) {
                        setState(() {
                          playPauseAnimations = b;
                        });
                        saveToDevice(name: 'playPauseAnimations', value: playPauseAnimations);
                      },
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    title: Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.2 * kListTileHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MyAnimatedSizeText(
                            'Slider Animations',
                            size: txtHeadingSize * kListTileHeight,
                          ),
                          MyAnimatedSizeText(
                            'These animations appear around the playback seek slider when the thumb is dragged',
                            size: txtBodySize * kListTileHeight,
                            col: txtBodyCol,
                          ),
                        ],
                      ),
                    ),
                    trailing: Switch(
                      value: sliderAnimations,
                      onChanged: (bool b) {
                        setState(() {
                          sliderAnimations = b;
                        });
                        saveToDevice(name: 'sliderAnimations', value: sliderAnimations);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.black45,
              margin: const EdgeInsets.only(right: 10, top: 10, left: 10),
              child: MyExpansionTile(
                key: expansionTile3,
                onExpansionChanged: (bool b) {
                  if (b) {
                    expansionTile1.currentState.collapse();
                    expansionTile2.currentState.collapse();
                    expansionTile4.currentState.collapse();
                    expansionTile5.currentState.collapse();
                  }
                  setState(() {});
                },
                leading: Icon(Icons.folder_open),
                title: MyAnimatedSizeText('Folder Style', size: txtHeadingSize * kListTileHeight),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(height: 1, color: Colors.white),
                  ),
                  ListTile(
                    title: Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.2 * kListTileHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MyAnimatedSizeText(
                            'Show Folder Path',
                            size: txtHeadingSize * kListTileHeight,
                          ),
                          MyAnimatedSizeText(
                            'The absolute path of every folder is shown below the folder name.',
                            size: txtBodySize * kListTileHeight,
                            col: txtBodyCol,
                          ),
                        ],
                      ),
                    ),
                    trailing: Switch(
                      value: showFolderPath,
                      onChanged: (bool b) {
                        setState(() {
                          showFolderPath = b;
                        });
                        saveToDevice(name: 'showFolderPath', value: showFolderPath);
                      },
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    title: Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.2 * kListTileHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MyAnimatedSizeText(
                            'Storage Icons',
                            size: txtHeadingSize * kListTileHeight,
                          ),
                          MyAnimatedSizeText(
                            'The icon indicating the root of folder that is phone storage, SD Card, or external USB',
                            size: txtBodySize * kListTileHeight,
                            col: txtBodyCol,
                          ),
                        ],
                      ),
                    ),
                    trailing: Switch(
                      value: showStorageIcons,
                      onChanged: (bool b) {
                        setState(() {
                          showStorageIcons = b;
                        });
                        saveToDevice(name: 'showStorageIcons', value: showStorageIcons);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.black45,
              margin: const EdgeInsets.only(right: 10, top: 10, left: 10),
              child: MyExpansionTile(
                key: expansionTile4,
                onExpansionChanged: (bool b) {
                  if (b) {
                    expansionTile1.currentState.collapse();
                    expansionTile2.currentState.collapse();
                    expansionTile3.currentState.collapse();
                    expansionTile5.currentState.collapse();
                  }
                  setState(() {});
                },
                leading: Icon(Icons.play_circle_outline),
                title: MyAnimatedSizeText('Floating Player Size', size: 0.25 * kListTileHeight),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(height: 1, color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                        trackShape: RoundedRectSliderTrackShape(),
                        trackHeight: 0.01 * kScreenSize.width,
                        thumbShape: RoundRectThumbShapeWithTxt(
                          txt: kFloaterHeightFactor.toString(),
                          thumbSize: 0.06 * kScreenSize.width,
                          thumbRadius: 0.02 * kScreenSize.width,
                          bgCol: Colors.tealAccent,
                          txtCol: Colors.black,
                        ),
                        thumbColor: Colors.tealAccent,
                        overlayColor: Colors.tealAccent.withAlpha(100),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 20.0),
//                tickMarkShape: RoundSliderTickMarkShape(),
                        activeTickMarkColor: Colors.tealAccent,
                        inactiveTickMarkColor: Colors.white,
                      ),
                      child: Slider(
                        value: kFloaterHeightFactor.toDouble(),
                        min: kFloaterHeightFactorMin.toDouble(),
                        max: kFloaterHeightFactorMax.toDouble(),
                        divisions: kFloaterHeightFactorMax - kFloaterHeightFactorMin,
                        onChanged: (double d) {
                          setState(() {
                            kFloaterHeightFactor = d.toInt();
                            kFloaterHeight = kFloaterHeightFactor * kScreenSize.width / 100.0;
                          });
                        },
                        onChangeEnd: (double d) async {
                          kFloaterHeightFactor = d.toInt();
                          saveToDevice(name: 'kFloaterHeightFactor', value: kFloaterHeightFactor);
                        },
                      ),
                    ),
                  ),
                  Divider(height: 1),
                  TweenAnimationBuilder(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.fastOutSlowIn,
                    tween: Tween<double>(begin: 10, end: kFloaterHeight),
                    builder: (context, double d, __) {
                      return Container(
                        height: d + 40,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(right: 10),
                        child: FloatingPlayerDemo(d),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 10, left: 10),
              child: Divider(height: 1, color: Colors.tealAccent.withAlpha(200)),
            ),
            Container(
              color: Colors.black45,
              margin: const EdgeInsets.only(right: 10, top: 10, left: 10),
              child: MyExpansionTile(
                key: expansionTile5,
                onExpansionChanged: (bool b) {
                  if (b) {
                    expansionTile1.currentState.collapse();
                    expansionTile2.currentState.collapse();
                    expansionTile3.currentState.collapse();
                    expansionTile4.currentState.collapse();
                  }
                  setState(() {});
                },
                leading: Icon(Icons.help_outline),
                title: MyAnimatedSizeText('Frequently Asked Questions', size: 0.25 * kListTileHeight),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(height: 1, color: Colors.white),
                  ),
                  ListTile(
                    title: Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.2 * kListTileHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MyAnimatedSizeText(
                            'What are the supported audio formats?',
                            size: txtHeadingSize * kListTileHeight,
                          ),
                          MyAnimatedSizeText(
                            storage.listSupportedAudioFormats,
                            size: txtBodySize * kListTileHeight,
                            col: txtBodyCol,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    title: Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.2 * kListTileHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MyAnimatedSizeText(
                            'What is the meaning of icons shown next to the folder names?',
                            size: txtHeadingSize * kListTileHeight,
                          ),
                          MyAnimatedSizeText(
                            'The icon visually reveals the root location of a particular folder.',
                            size: txtBodySize * kListTileHeight,
                            col: txtBodyCol,
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.phone_android,
                                color: txtBodyCol,
                                size: txtBodySize * kListTileHeight,
                              ),
                              MyAnimatedSizeText(
                                ' for Phone Internal Storage',
                                size: txtBodySize * kListTileHeight,
                                col: txtBodyCol,
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.sd_storage,
                                color: txtBodyCol,
                                size: txtBodySize * kListTileHeight,
                              ),
                              MyAnimatedSizeText(
                                ' for SD Card External Storage',
                                size: txtBodySize * kListTileHeight,
                                col: txtBodyCol,
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.usb,
                                color: txtBodyCol,
                                size: txtBodySize * kListTileHeight,
                              ),
                              MyAnimatedSizeText(
                                ' for USB External Storage',
                                size: txtBodySize * kListTileHeight,
                                col: txtBodyCol,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    title: Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.2 * kListTileHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MyAnimatedSizeText(
                            'How to change the Album Art?',
                            size: txtHeadingSize * kListTileHeight,
                          ),
                          MyAnimatedSizeText(
                            '1. The metadata of an audio file is stored with the help of ID3 tags. To change the Title, Artist Name, Album Art or anything else, you can use any online tool or download AutomaTag from google play store.',
                            size: txtBodySize * kListTileHeight,
                            col: txtBodyCol,
                          ),
                          MyAnimatedSizeText(
                            '2. Another way is to add a Folder.jpg or Cover.jpg (case insensitive) image file in the audio\'s folder. This image will be used as the album art only for those audio files, which do not have any. This method also works on a windows machine.',
                            size: txtBodySize * kListTileHeight,
                            col: txtBodyCol,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    title: Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.2 * kListTileHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MyAnimatedSizeText(
                            'Why the song name sometimes does not match with the audio name displayed?',
                            size: txtHeadingSize * kListTileHeight,
                          ),
                          MyAnimatedSizeText(
                            'The name showed in audio list view is the Filename, whereas the one shown on the player screen is the \'Title\' embedded in the ID3 tag. Refer to the above question to change that.',
                            size: txtBodySize * kListTileHeight,
                            col: txtBodyCol,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class MyAnimatedSizeText extends StatelessWidget {
  MyAnimatedSizeText(this.txt, {this.col, @required this.size});

  final String txt;
  final double size;
  final Color col;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400),
      tween: Tween<double>(begin: 1, end: size),
      curve: Curves.fastOutSlowIn,
      builder: (context, value, __) {
        return Text(
          txt,
          textScaleFactor: 1,
          style: TextStyle(
            fontSize: value,
            color: col,
          ),
        );
      },
    );
  }
}

class RoundRectThumbShapeWithTxt extends SliderComponentShape {
  final double thumbSize, thumbRadius;
  final Color bgCol, txtCol;
  final String txt;

  const RoundRectThumbShapeWithTxt({
    this.thumbSize = 12.0,
    this.thumbRadius,
    this.bgCol,
    this.txtCol,
    this.txt,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbSize);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
  }) {
    final Canvas canvas = context.canvas;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 1.3 * thumbSize, height: thumbSize),
        Radius.circular(thumbRadius),
      ),
      Paint()..color = bgCol,
    );

    TextSpan txtSpan = new TextSpan(
      style: TextStyle(
        fontSize: 0.8 * thumbSize,
        fontWeight: FontWeight.w700,
        color: txtCol,
      ),
      text: txt,
    );

    TextPainter txtPainter =
        TextPainter(text: txtSpan, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    txtPainter.layout();
    Offset textCenter = Offset(center.dx - (txtPainter.width / 2), center.dy - (txtPainter.height / 2));
    txtPainter.paint(canvas, textCenter);
  }
}

class FloatingPlayerDemo extends StatelessWidget {
  FloatingPlayerDemo(this.height);

  final double height;
  final Color bgCol = Colors.grey[700];

  @override
  Widget build(BuildContext context) {
    final double playerSizePar = 0.465 * height;
    final double playerGapsPar = 0.07 * height;

    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        ///this widget prevents unwanted actions, when user taps any small inter-space b/w the buttons
        Padding(
          padding: EdgeInsets.only(right: 2 * playerSizePar - 0.5 * playerGapsPar, bottom: playerSizePar),
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
                  splashColor: Colors.red,
                  highlightColor: Colors.red,
                  onTap: () {},
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
                              'The music title name as set in ID3 tag',
                              textScaleFactor: 1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 0.3 * playerSizePar, color: Colors.white),
                            ),
                            Text(
                              'The Artist',
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
            icon: Icons.pause,
            onTap: () {},
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              right: 2.5 * playerSizePar + 5 * playerGapsPar, bottom: playerSizePar + playerGapsPar),
          child: SkewButton(
            height: playerSizePar,
            col: bgCol,
            icon: Icons.format_list_bulleted,
            onTap: () {},
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
          child: Container(
            height: 2 * playerSizePar + playerGapsPar,
            width: 2 * playerSizePar + playerGapsPar,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(playerSizePar + 0.5 * playerGapsPar),
              border: Border.all(width: 1, color: Colors.white, style: BorderStyle.solid),
              image: DecorationImage(
                image: AssetImage('assets/albumArtDefault1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
