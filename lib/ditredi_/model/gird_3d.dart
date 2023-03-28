import 'dart:math';

import 'package:ditredi/ditredi.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class Grid3D extends Group3D {
  final Point max;
  final Point min;
  final int interval;
  final Color? color;
  final double? lineWidth;

  Grid3D(
    this.max,
    this.min,
    this.interval, {
    this.color,
    this.lineWidth,
  }) : super(_generateFigures(max, min, interval, color, lineWidth));

  /// Copies the Pointcloud.
  Grid3D copyWith({
    Point? max,
    Point? min,
    int? interval,
    Color? color,
    double? lineWidth,
  }) {
    return Grid3D(
      max ?? this.max,
      min ?? this.min,
      interval ?? this.interval,
      color: color ?? color,
      lineWidth: lineWidth ?? this.lineWidth,
    );
  }

  @override
  Grid3D clone() {
    return Grid3D(
      max,
      min,
      interval,
      color: color,
      lineWidth: lineWidth,
    );
  }

  @override
  int get hashCode => Object.hash(max, min, interval, color, lineWidth);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Grid3D &&
            runtimeType == other.runtimeType &&
            max == other.max &&
            min == other.min &&
            interval == other.interval &&
            color == other.color &&
            lineWidth == other.lineWidth;
  }
}

List<Model3D<Model3D<dynamic>>> _generateFigures(
    Point max, Point min, int interval, Color? color, double? thickness) {
  int xSize = (max.x - min.x) ~/ interval;
  int ySize = (max.y - min.y) ~/ interval;
  int size = xSize + ySize + 2;
  int countX = 0;
  int countY = 0;
  late Vector3 st;
  late Vector3 ed;
  return List.generate(size, (index) {
    if (countY <= ySize) {
      st =
          Vector3((max.x.toDouble()), (min.y + interval * index).toDouble(), 0);
      ed =
          Vector3((min.x.toDouble()), (min.y + interval * index).toDouble(), 0);
      countY++;
    } else {
      st = Vector3((min.x + interval * countX).toDouble(), max.y.toDouble(), 0);
      ed = Vector3((min.x + interval * countX).toDouble(), min.y.toDouble(), 0);
      countX++;
    }
    return Line3D(st, ed, color: color, width: thickness);
  });
}
