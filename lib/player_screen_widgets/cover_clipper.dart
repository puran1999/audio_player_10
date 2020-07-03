import 'package:flutter/material.dart';

class CenterClipWithBottomLeft extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 4);
    path.lineTo(size.width, 3 * size.height / 4);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CenterClipWithBottomLeft oldClipper) => false;
}

class CenterClipWithoutBottomLeft extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 4);
    path.lineTo(size.width, 3 * size.height / 4);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, 3 * size.height / 4);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CenterClipWithoutBottomLeft oldClipper) => false;
}

class TopRightClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height / 4);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TopRightClip oldClipper) => false;
}

class BottomLeftClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 3 * size.height / 4);
    path.lineTo(0, size.height / 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(BottomLeftClip oldClipper) => false;
}

class BottomRightClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 3 * size.height / 4);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(BottomRightClip oldClipper) => false;
}
