import 'package:flutter/material.dart';
import 'dart:math';
import '../constants.dart';
import '../classes/player.dart';
import '../classes/set_state_callbacks.dart';

class MightySlider extends StatefulWidget {
  final double sliderThickness;
  final double width;
  final Color col1, col2, col3;

  MightySlider({this.width = 200, this.sliderThickness = 20, this.col1, this.col2, this.col3});

  @override
  _MightySliderState createState() => _MightySliderState();
}

class _MightySliderState extends State<MightySlider> {
  double _audioDurationSeconds = 0;
  double _audioPositionSeconds = 0;
  bool positionLock = false;

  @override
  void initState() {
    super.initState();
    _audioDurationSeconds = player.audioDuration;
    _audioPositionSeconds = player.audioPosition;
    setStateCalls.playerScreenSliderPosition = positionUpdate;
    setStateCalls.playerScreenSliderDuration = durationUpdate;
  }

  @override
  void dispose() {
    super.dispose();
    setStateCalls.playerScreenSliderPosition = () => print('slider already disposed -' * 20);
    setStateCalls.playerScreenSliderDuration = () => print('slider already disposed -' * 20);
  }

  void positionUpdate(double val) {
    if (!positionLock) {
//      try {
      setState(() => _audioPositionSeconds = val);
//      } catch (e) {
//        print(e);
//      }
    }
  }

  void durationUpdate(double val) {
//    try {
    setState(() => _audioDurationSeconds = val);
//    } catch (e) {
//      print(e);
//    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      /// to balance the padding. When the column is rotated, the slider goes to right side a little
      offset: Offset(-widget.width / 24, 2 * widget.width / 24),
      child: Transform.rotate(
        angle: -0.463, //atan(0.5)
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: widget.width / 4), //again to balance the padding.
              child: Transform(
                transform: Matrix4.skew(-0.463, 0),
                child: RichText(
                  text: TextSpan(
                    text:
                        '${player.secondsToString(_audioPositionSeconds)}   |   ${player.secondsToString(_audioDurationSeconds)}',
                    style: TextStyle(
                      color: widget.col1,
                      fontSize: widget.width / 12,
                      shadows: [
                        Shadow(color: Colors.black, blurRadius: 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: widget.width / 20),
            SizedBox(
              width: 1.1 * widget.width + 2 * widget.sliderThickness,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: widget.col1,
                  inactiveTrackColor: widget.col1,
                  trackHeight: widget.sliderThickness / 3,
                  thumbShape: CubeSliderThumbShape(
                      thumbSize: widget.sliderThickness,
                      col1: widget.col1,
                      col2: widget.col2,
                      col3: widget.col3),
                  overlayShape: SliderThumbOverlayShape(
                    radiusSize: widget.sliderThickness,
                    rotation: _audioPositionSeconds / (_audioDurationSeconds + 0.001),
                    col1: widget.col1,
                  ), //RoundSliderOverlayShape(overlayRadius: 40.0),
                ),
                child: Slider(
                  value: constrain(_audioPositionSeconds / (_audioDurationSeconds + 0.001), 0, 1),
                  max: 1 + widget.sliderThickness / widget.width,
                  min: 0 - widget.sliderThickness / widget.width,
                  onChangeStart: (double d) {
                    randomiseArcs();
                    positionLock = true;
                  },
                  onChanged: (double d) {
                    setState(() {
                      d = constrain(d, 0, 1);
                      _audioPositionSeconds = d * _audioDurationSeconds;
                    });
                    positionLock = true;
                  },
                  onChangeEnd: (double d) async {
                    d = constrain(d, 0, 1);
                    await player.audio.seek(d * _audioDurationSeconds);
                    _audioPositionSeconds = d * _audioDurationSeconds;
                    positionLock = false;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double constrain(double what, double fromLow, double toHigh) {
  if (what < fromLow)
    return fromLow;
  else if (what > toHigh)
    return toHigh;
  else
    return what;
}

class CubeSliderThumbShape extends SliderComponentShape {
  final double thumbSize;
  final Color col1, col2, col3;

  const CubeSliderThumbShape({
    this.thumbSize = 12.0,
    this.col1,
    this.col2,
    this.col3,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(0.8 * thumbSize);
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
    double a = 0.463; //atan(0.5)
    double d = thumbSize;
    double d2 = 2 * d * sin(a);
    double c1 = d * cos(2 * a);
    double s1 = d * sin(2 * a);
    double c2 = d2 * cos(pi / 2 - a);
    double s2 = d2 * sin(pi / 2 - a);

    final path1 = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx - c1, center.dy - s1)
      ..lineTo(center.dx - d, center.dy)
      ..lineTo(center.dx - c2, center.dy + s2)
      ..close();
    final path2 = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx - c1, center.dy - s1)
      ..lineTo(center.dx + d - c1, center.dy - s1)
      ..lineTo(center.dx + d, center.dy)
      ..close();
    final path3 = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx + d, center.dy)
      ..lineTo(center.dx + d - c2, center.dy + s2)
      ..lineTo(center.dx - c2, center.dy + s2)
      ..close();
    canvas.drawPath(path1, Paint()..color = col3);
    canvas.drawPath(path2, Paint()..color = col1);
    canvas.drawPath(path3, Paint()..color = col2);
    final baseLinePaint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = col1
      ..strokeWidth = d / 3;
    canvas.drawLine(
        Offset(center.dx - 0.9 * d, center.dy), Offset(center.dx - 1.1 * d / 2, center.dy), baseLinePaint);
  }
}

class SliderThumbOverlayShape extends SliderComponentShape {
  final double radiusSize;
  final double rotation;
  final Color col1;

  const SliderThumbOverlayShape({
    this.radiusSize = 12.0,
    this.rotation = 0,
    this.col1,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(radiusSize);
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
    if (sliderAnimations) {
      final Canvas canvas = context.canvas;

      final Tween<double> radiusTween = Tween<double>(
        begin: 0.0,
        end: 1.0,
      );
      double m = radiusTween.evaluate(activationAnimation);
      Rect rectBase(double size) {
        return Offset(center.dx - size / 2 * m, center.dy - size * m) & Size(size * m, 2 * size * m);
      }

      final strokePaint = Paint()
        ..color = col1
        ..style = PaintingStyle.stroke;

//      ..strokeCap = StrokeCap.round;
//      ..strokeWidth = 2;
//    canvas.drawArc(rectBase(radiusSize + 40), 0 + 50 * rotation, pi / 4, false, strokePaint);
//    canvas.drawArc(rectBase(radiusSize + 40), pi / 2 + 50 * rotation, pi / 4, false, strokePaint);
//    canvas.drawArc(rectBase(radiusSize + 40), pi + 50 * rotation, pi / 4, false, strokePaint);
//    canvas.drawArc(rectBase(radiusSize + 40), 3 * pi / 2 + 50 * rotation, pi / 4, false, strokePaint);
//    canvas.drawArc(rectBase(radiusSize + 20), 0 + 100 * rotation, pi / 3, false, strokePaint);
//    canvas.drawArc(rectBase(radiusSize + 20), 2 * pi / 3 + 100 * rotation, pi / 3, false, strokePaint);
//    canvas.drawArc(rectBase(radiusSize + 20), 4 * pi / 3 + 100 * rotation, pi / 3, false, strokePaint);

      for (int i = 0; i < radii.length; i++) {
        canvas.drawArc(rectBase(radiusSize + 20 + radii[i]), offsets[i] + speeds[i] * rotation, arcLens[i],
            false, strokePaint..strokeWidth = thicknesses[i]);
      }
    }
  }
}

List<double> radii = [];
List<double> offsets = [];
List<double> arcLens = [];
List<double> speeds = [];
List<double> thicknesses = [];

void randomiseArcs() {
  Random rnd = Random();
  radii.clear();
  offsets.clear();
  arcLens.clear();
  speeds.clear();
  thicknesses.clear();
  for (int i = 0; i < 5; i++) {
    radii.add(40 * rnd.nextDouble());
    offsets.add(6.14 * rnd.nextDouble());
    arcLens.add(6.14 * rnd.nextDouble());
    speeds.add(100 * rnd.nextDouble());
    thicknesses.add(2 * rnd.nextDouble());
  }
}
