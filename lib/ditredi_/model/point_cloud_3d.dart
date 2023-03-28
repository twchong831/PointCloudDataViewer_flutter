import 'package:ditredi/ditredi.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart';

/// A plane with list of points.
/// Used often to present a scale.
class PointCloud3D extends Group3D {
  final List<Point3D> list3D;

  /// Center of the plane.
  final Vector3 position;

  final Color? color;

  /// Width of points. Defaults to [DiTreDiConfig] setting.
  final double? pointWidth;

  /// Creates a new [PointCloud3D].
  PointCloud3D(
    this.list3D,
    this.position, {
    this.pointWidth,
    this.color,
  }) : super(_generateFigures(list3D, position, color, pointWidth));

  /// Copies the Pointcloud.
  PointCloud3D copyWith({
    List<Point3D>? list3D,
    Vector3? position,
    Color? color,
    double? pointWidth,
  }) {
    return PointCloud3D(
      list3D ?? this.list3D,
      position ?? this.position,
      color: color ?? this.color,
      pointWidth: pointWidth ?? this.pointWidth,
    );
  }

  @override
  PointCloud3D clone() {
    return PointCloud3D(
      list3D,
      position,
      color: color,
      pointWidth: pointWidth,
    );
  }

  @override
  int get hashCode => Object.hash(list3D, position, color, pointWidth);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PointCloud3D &&
            runtimeType == other.runtimeType &&
            list3D == other.list3D &&
            position == other.position &&
            color == other.color &&
            pointWidth == other.pointWidth;
  }
}

bool _checkColor(Color? color) {
  bool checked = false;

  if (color.toString() != "null") {
    checked = true;
  }
  return checked;
}

Vector3 inverseX(Vector3 coor) {
  return Vector3(-coor.x, coor.y, coor.z);
}

List<Model3D<Model3D<dynamic>>> _generateFigures(
    List<Point3D> list3d, Vector3 position, Color? color, double? thickness) {
  return List.generate(
    list3d.length,
    (index) {
      return Point3D(
        inverseX(list3d[index].position),
        color: _checkColor(color) ? color : list3d[index].color,
        width:
            thickness.toString().isNotEmpty ? thickness : list3d[index].width,
      );
    },
  );
}
