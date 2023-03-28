import 'package:ditredi/ditredi.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/src/material/colors.dart' as colorcode;

class GuideAxis3D extends Group3D {
  final double length;
  final double? lineWidth;

  GuideAxis3D(
    this.length, {
    this.lineWidth,
  }) : super(_generateFigures(length, lineWidth));

  /// Copies the Pointcloud.
  GuideAxis3D copyWith({
    double? length,
    double? lineWidth,
  }) {
    return GuideAxis3D(
      length ?? this.length,
      lineWidth: lineWidth ?? this.lineWidth,
    );
  }

  @override
  GuideAxis3D clone() {
    return GuideAxis3D(
      length,
      lineWidth: lineWidth,
    );
  }

  @override
  int get hashCode => Object.hash(
        length,
        lineWidth,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is GuideAxis3D &&
            runtimeType == other.runtimeType &&
            length == other.length;
  }
}

List<Model3D<Model3D<dynamic>>> _generateFigures(
    double length, double? thickness) {
  Vector3 st = Vector3(0, 0, 0);
  Vector3 ed;
  Color color;
  return List.generate(3, (index) {
    switch (index) {
      case 0:
        ed = Vector3(-length, 0, 0);
        color = colorcode.Colors.red;
        return Line3D(st, ed, color: color, width: thickness);
      case 1:
        ed = Vector3(0, length, 0);
        color = colorcode.Colors.green;
        return Line3D(st, ed, color: color, width: thickness);
      case 2:
        ed = Vector3(0, 0, length);
        color = colorcode.Colors.blue;
        return Line3D(st, ed, color: color, width: thickness);
      default:
        ed = Vector3(length, 0, 0);
        color = colorcode.Colors.red;
        return Line3D(st, ed, color: color, width: thickness);
    }
  });
}
