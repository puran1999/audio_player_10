import 'package:flutter/material.dart';
import '../classes/player.dart';
import 'mighty_slider.dart';
import 'center_stack.dart';
import 'bottom_stack.dart';

class PlayerWidget extends StatelessWidget {
  final double unit;
  final Color col1, col2, col3;

  PlayerWidget(
      {@required this.unit, this.col1 = Colors.white, this.col2 = Colors.grey, this.col3 = Colors.blueGrey});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      verticalDirection: VerticalDirection.up,
      children: <Widget>[
        BottomStack(
          unit: unit,
          col1: col1,
          col2: col2,
          col3: col3,
        ),
        MightySlider(
          width: 6 * unit,
          sliderThickness: unit / 3,
          col1: col1,
          col2: col2,
          col3: col3,
        ),
        CenterStack(
          unit: unit,
          col1: col1,
          col2: col2,
          col3: col3,
        ),
        Row(
          children: <Widget>[
            Transform.translate(
              offset: Offset(0, unit / 2),
              child: Transform(
                transform: Matrix4.skew(0, -0.463),
                child: Material(
                  elevation: 3,
                  child: Container(
                    width: unit,
                    height: unit,
                    color: col3,
                  ),
                ),
              ),
            ),
            SizedBox(width: 0.1 * unit),
            ConstrainedBox(
              constraints: BoxConstraints.tight(Size(MediaQuery.of(context).size.width - 1.2 * unit, unit)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    player.tag.title,
                    textScaleFactor: 1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: col1, fontSize: unit / 2, shadows: [
                      Shadow(color: Colors.black, blurRadius: 2),
                    ]),
                  ),
                  Text(
                    player.tag.artist,
                    textScaleFactor: 1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: col1, fontSize: unit / 3, shadows: [
                      Shadow(color: Colors.black, blurRadius: 2),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
