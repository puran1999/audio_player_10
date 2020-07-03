import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flare_flutter/flare_actor.dart';
import 'constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'player_screen_widgets/custom_icons.dart';

class AboutDialogScreen extends StatefulWidget {
  @override
  _AboutDialogScreenState createState() => _AboutDialogScreenState();
}

class _AboutDialogScreenState extends State<AboutDialogScreen> {
  double pos = 0;
  bool logoAnimationDone = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        pos = 1;
      });
    });
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        logoAnimationDone = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                AnimatedPadding(
                  padding: EdgeInsets.only(bottom: pos * 9 * kPlayerScreenUnit),
                  duration: Duration(milliseconds: 400),
                  curve: Curves.fastOutSlowIn,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      SocialButton(
                        icon: MyFlutterApp.instagram,
                        url: 'https://www.instagram.com/puran.singh.namdhari/',
                      ),
                      SizedBox(width: 0.2 * kPlayerScreenUnit),
                      Avatar(),
                      SizedBox(width: 0.2 * kPlayerScreenUnit),
                      SocialButton(
                        icon: MyFlutterApp.facebook,
                        url: 'https://www.facebook.com/puransingh.channa.1',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 5.5 * kPlayerScreenUnit + pos * 0.5 * kPlayerScreenUnit),
                  child: ClipText(
                    'PURAN SINGH',
                    direction: 1,
                    style: TextStyle(
                      fontFamily: 'BankGothic',
                      fontSize: 0.51 * kPlayerScreenUnit,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: pos * 5.5 * kPlayerScreenUnit),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 1200),
                    curve: Interval(0.66, 1, curve: Curves.fastOutSlowIn),
                    width: pos * 4 * kPlayerScreenUnit,
                    child: Divider(color: Colors.white, height: 1),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 5.15 * kPlayerScreenUnit),
                  child: ClipText(
                    'puransinghcn15@gmail.com',
                    direction: -1,
                    style: TextStyle(fontSize: 0.25 * kPlayerScreenUnit),
                  ),
                ),
                AnimatedPadding(
                  padding: EdgeInsets.only(top: pos * 9 * kPlayerScreenUnit),
                  duration: Duration(milliseconds: 400),
                  curve: Curves.fastOutSlowIn,
                  child: GestureDetector(
                    onTap: () {
                      Future.delayed(Duration(seconds: 3), () => setState(() => logoAnimationDone = true));
                      setState(() => logoAnimationDone = false);
                    },
                    child: Container(
                      width: 2.2 * kPlayerScreenUnit,
                      height: 2.2 * kPlayerScreenUnit,
                      padding: EdgeInsets.all(0.1 * kPlayerScreenUnit),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        shape: BoxShape.circle,
                      ),
                      child: logoAnimationDone
                          ? Image.asset('assets/app_icon.png')
                          : FlareActor(
                              'assets/logo3.flr',
                              alignment: Alignment.center,
                              fit: BoxFit.fitHeight,
                              animation: 'once',
                              shouldClip: false,
                            ),
                    ),
                  ),
                ),
                Container(
                  width: 4 * kPlayerScreenUnit,
                  height: 4 * kPlayerScreenUnit,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  SocialButton({this.icon, this.url});

  final IconData icon;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          iconSize: 0.5 * kPlayerScreenUnit,
          icon: Icon(icon),
          onPressed: () async {
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              print('invalid url----' * 10);
            }
          },
        ),
      ),
    );
  }
}

class Avatar extends StatefulWidget {
  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  double face = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2.2 * kPlayerScreenUnit,
      height: 2.2 * kPlayerScreenUnit,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: 1500),
        curve: Curves.easeInOut,
        tween: Tween<double>(begin: 0, end: face),
        onEnd: () => setState(() => face == 1 ? face = 0 : face = 1),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(
                -0.35 * kPlayerScreenUnit, 0.37 * kPlayerScreenUnit - value * 0.02 * kPlayerScreenUnit),
            child: Transform.rotate(angle: -value * 0.05, child: child),
          );
        },
        child: Transform.scale(
          scale: 1.2,
          child: Image.asset(
            'assets/avatar_face.png',
          ),
        ),
      ),
    );
  }
}

class ClipText extends StatelessWidget {
  ClipText(this.text, {@required this.style, this.direction = 1});

  final String text;

  /// fontSize is must
  final TextStyle style;

  ///-1 for top to bottom and +1 for bottom to top
  final double direction;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BoundaryClip(),
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: 1600),
        curve: Interval(0.75, 1, curve: Curves.fastOutSlowIn),
        tween: Tween<double>(begin: direction * 1.2 * style.fontSize, end: 0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, value),
            child: child,
          );
        },
        child: Container(
//          color: Colors.red.withAlpha(100),
          child: Text(text, textScaleFactor: 1, style: style),
        ),
      ),
    );
  }
}

class BoundaryClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(BoundaryClip oldClipper) => false;
}
