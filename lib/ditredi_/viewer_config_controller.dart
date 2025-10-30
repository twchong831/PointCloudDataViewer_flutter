import 'package:flutter/material.dart';

/// Holds viewer configuration (grid ranges, point size, background color)
/// and notifies listeners on updates.
class ViewerConfigController extends ChangeNotifier {
  RangeValues _gridRangeX;
  RangeValues _gridRangeY;
  double _pointSize;
  Color _backgroundColor;

  ViewerConfigController({
    RangeValues? gridRangeX,
    RangeValues? gridRangeY,
    double? pointSize,
    Color? backgroundColor,
  })  : _gridRangeX = gridRangeX ?? const RangeValues(-10, 10),
        _gridRangeY = gridRangeY ?? const RangeValues(0, 20),
        _pointSize = pointSize ?? 1.0,
        _backgroundColor =
            backgroundColor ?? const Color.fromARGB(255, 3, 3, 29);

  final RangeValues maxRangeX = const RangeValues(-50.0, 50.0);
  final RangeValues maxRangeY = const RangeValues(0, 100.0);

  /// Updates X-axis grid range with clamping to max bounds.
  void updateGridRangeX(RangeValues range) {
    _gridRangeX = range;

    if (_gridRangeX.start < maxRangeX.start) {
      updateGridRangeX(RangeValues(maxRangeX.start, range.end));
    }

    if (_gridRangeX.end > maxRangeX.end) {
      updateGridRangeX(RangeValues(range.start, maxRangeX.end));
    }

    notifyListeners();
  }

  /// Updates Y-axis grid range with clamping to max bounds.
  void updateGridRangeY(RangeValues range) {
    _gridRangeY = range;
    if (_gridRangeY.start < maxRangeY.start) {
      updateGridRangeX(RangeValues(maxRangeY.start, range.end));
    }

    if (_gridRangeY.end > maxRangeY.end) {
      updateGridRangeX(RangeValues(range.start, maxRangeY.end));
    }
    notifyListeners();
  }

  /// Updates point size and enforces valid range [1.0, 5.0].
  void updatePointSize(double size) {
    _pointSize = size;
    if (_pointSize <= 0) _pointSize = 1.0;
    if (_pointSize >= 6) _pointSize = 5.0;

    notifyListeners();
  }

  /// Updates background color for the viewer.
  void updateBackgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }

  RangeValues get getGridRangeX => _gridRangeX;
  double get getGridRangeXStart => _gridRangeX.start;
  double get getGridRangeXEnd => _gridRangeX.end;
  RangeValues get getGridRangeY => _gridRangeY;
  double get getGridRangeYStart => _gridRangeY.start;
  double get getGridRangeYEnd => _gridRangeY.end;
  double get getPointSize => _pointSize;

  RangeValues get getMaxRangeX => maxRangeX;
  RangeValues get getMaxRangeY => maxRangeY;

  /// Divisions used to render X-axis slider tick count.
  int rangeXdivision() {
    return (maxRangeX.end - maxRangeX.start) ~/ 5;
  }

  /// Divisions used to render Y-axis slider tick count.
  int rangeYdivision() {
    return (maxRangeY.end - maxRangeY.start) ~/ 5;
  }

  Color get getBackgroundColor => _backgroundColor;
}
