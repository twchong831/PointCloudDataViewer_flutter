import 'dart:async';
import 'dart:math';

import 'package:ditredi/ditredi.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pointcloud_data_viewer/ditredi_/ditredi_model_painter_custom.dart';
import 'package:pointcloud_data_viewer/ditredi_/model/gird_3d.dart';
import 'package:pointcloud_data_viewer/ditredi_/model/guid_axis_3d.dart';
import 'package:pointcloud_data_viewer/ditredi_/model/point_cloud_3d.dart';
import 'package:pointcloud_data_viewer/ditredi_/viewer_config_controller.dart';
import 'package:pointcloud_data_viewer/files/pcd_reader.dart';
import 'package:pointcloud_data_viewer/widget/sidebar.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/material.dart' as colorcode;

/// Data source of the viewer.
///
/// - `udp`: stream from network (future use)
/// - `fileList`: play one or multiple PCD files
enum ReadMode {
  udp,
  fileList,
}

/// Main screen that renders point clouds using DiTreDi.
///
/// Accepts optional networking params or a list of PCD file paths.
/// Falls back to a default [DiTreDiController] tuned for this viewer.
class ViewScreen extends StatefulWidget {
  final String? ip;
  final int? port;
  final List<String>? pcdList;
  final DiTreDiController _ditreControl;
  final ViewerConfigController viewerControl;

  ViewScreen({
    super.key,
    this.ip,
    this.port,
    this.pcdList,
    DiTreDiController? ditreControl,
    required this.viewerControl,
  }) : _ditreControl = ditreControl ??
            DiTreDiController(
              rotationX: 0,
              rotationY: 180,
              rotationZ: 0,
              // light: vector.Vector3(-0.5, -0.5, 0.5),
              maxUserScale: 5.0,
              minUserScale: 0.05,
            );

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  /// Reader that loads and parses PCD files into [Point3D]s.
  PCDReader pcdReader = PCDReader(path: '');
  /// Currently selected PCD file path.
  String selectFile = '';

  /// Timer to play a PCD file list like a sequence (≈30 FPS).
  late Timer mTimerPlay;
  bool gCheckedTimer = false;
  int gTimerCount = 0;

  late final ReadMode? readMode;

  List<Point3D> gPcloudReadPCD = [];

  /// Custom painter (DiTreDi-based) used by [CustomPaint].
  DiTreDiModelPainterCustom? gModelPainter;

  /// Initial logical bounds used to seed camera transform.
  final Aabb3 gBounds = Aabb3.minMax(Vector3(-10, 0, 0), Vector3(10, 15, 0));

  /// Base scene objects (grid, axes) plus the point cloud.
  List<Model3D<Model3D<dynamic>>> visualObjs = [
    Grid3D(const Point(10, 15), const Point(-10, 0), 1,
        lineWidth: 1, color: colorcode.Colors.white.withOpacity(0.6)),
    GuideAxis3D(1, lineWidth: 10),
  ];

  double gPointSize = 1.0;

  /// Rebuilds the scene with the latest point cloud and triggers repaint.
  void _updatePointCloud(List<Point3D> cloud) {
    if (mounted) {
      // gPcloud = cloud;
      visualObjs.clear();
      visualObjs = [
        Grid3D(
            Point(
              -widget.viewerControl.getGridRangeXStart,
              widget.viewerControl.getGridRangeYEnd,
            ),
            Point(
              -widget.viewerControl.getGridRangeXEnd,
              widget.viewerControl.getGridRangeYStart,
            ),
            1,
            lineWidth: 1,
            color: colorcode.Colors.white.withOpacity(0.6)),
        GuideAxis3D(1, lineWidth: 10),
        PointCloud3D(cloud, Vector3(0, 0, 0),
            pointWidth: widget.viewerControl.getPointSize),
      ];

      setState(() {
        gModelPainter!.update(control: widget._ditreControl, fig: visualObjs);
      });
    }
  }

  /// Loads a single PCD file and updates the scene.
  void _loadPcdFile(String path) async {
    gPcloudReadPCD = await pcdReader.read(path);
    _updatePointCloud(gPcloudReadPCD);
  }

  /// Advances playback for a list of PCD files (called by timer).
  void _playTimer(Timer time) async {
    if (mounted) {
      if (gPcloudReadPCD.isNotEmpty) gPcloudReadPCD.clear();
      gPcloudReadPCD = await pcdReader.read(widget.pcdList![gTimerCount]);
      _updatePointCloud(gPcloudReadPCD);
      gTimerCount++;

      if (gTimerCount > widget.pcdList!.length - 1) {
        gTimerCount = 0;
      }
    }
  }

  /// Starts the playback timer (~33ms interval) once.
  void _timerActive() {
    if (!gCheckedTimer) {
      mTimerPlay = Timer.periodic(
        const Duration(milliseconds: 33),
        (timer) => _playTimer(timer),
      );
      gCheckedTimer = true;
    }
  }

  /// Cancels the playback timer if running.
  void _cancelTimer() {
    if (gCheckedTimer) {
      mTimerPlay.cancel();
      gCheckedTimer = false;
    }
  }

  /// Initializes data source mode and prepares the custom painter.
  @override
  void initState() {
    if (widget.ip != null && widget.port != null) {
      readMode = ReadMode.udp;
    } else if (widget.pcdList != null) {
      readMode = ReadMode.fileList;
      selectFile = widget.pcdList![0];
      if (widget.pcdList!.length == 1) {
        _loadPcdFile(selectFile);
      } else if (widget.pcdList!.length > 1) {
        _timerActive();
      } else {}
    } else {
      // printError('Please Resetting parameters');
    }
    // init gModelPainter
    gModelPainter = DiTreDiModelPainterCustom(
      visualObjs,
      gBounds,
      widget._ditreControl,
      const DiTreDiConfig(),
    );

    gPointSize = widget.viewerControl.getPointSize;
    super.initState();
  }

  /// Cleans up resources on exit (stop playback timer).
  @override
  void dispose() {
    if (readMode == ReadMode.fileList) {
      _cancelTimer();
    }
    super.dispose();
  }

  /// Returns an app bar title that reflects the current data source.
  String _setTitle() {
    String val = 'none';
    setState(() {
      if (mounted) {
        if (readMode == ReadMode.udp) {
          val = 'UDP [${widget.ip}/${widget.port}]';
        } else {
          if (readMode == ReadMode.fileList) {
            if (widget.pcdList?.length == 1) {
              List sp = selectFile.split('/');
              val = 'File [ ${sp[sp.length - 1]} ]';
            } else {
              val = 'File [Count : $gTimerCount/${widget.pcdList?.length}]';
              // val = 'File Playing';
            }
          } else {
            val = 'none';
          }
        }
      }
    });

    return val;
  }

  /// Increases the point size and refreshes the view.
  void increasePointSize() {
    gPointSize++;
    widget.viewerControl.updatePointSize(gPointSize);
    _updatePointCloud(gPcloudReadPCD);
  }

  /// Decreases the point size (with a minimum of 1.0) and refreshes the view.
  void decreasePointSize() {
    gPointSize--;
    if (gPointSize < 1.0) {
      gPointSize = 1.0;
    }
    widget.viewerControl.updatePointSize(gPointSize);
    _updatePointCloud(gPcloudReadPCD);
  }

  // for side bar
  final _sideBarController = SidebarXController(
    selectedIndex: 0,
    extended: false,
  );

  // for 3D visualization
  var lastX = 0.0;
  var lastY = 0.0;
  var scaleBase = 0.0;

  final _key = GlobalKey<ScaffoldState>();

  /// Builds the viewer UI: app bar, sidebar, and interactive 3D canvas.
  @override
  Widget build(BuildContext context) {
    List<SidebarXItem> gSideBarItems = [
      SidebarXItem(
        icon: Icons.add,
        label: 'increase',
        onTap: () => increasePointSize(),
      ),
      SidebarXItem(
        icon: Icons.remove,
        label: 'decrease',
        onTap: () => decreasePointSize(),
      ),
    ];

    return Scaffold(
      key: _key,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height / 24),
        child: AppBar(
          title: Text(_setTitle()),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                size: MediaQuery.of(context).size.height / 35),
            onPressed: () {
              // set navigator for backward and send DiTreDiController value
              Navigator.pop(context, widget._ditreControl);
            },
          ),
        ),
      ),
      drawer: ControlSideBar(
        controller: _sideBarController,
        items: gSideBarItems,
      ),
      body: Container(
        color: widget.viewerControl.getBackgroundColor, //set background color
        child: SafeArea(
          child: Flex(
            crossAxisAlignment: CrossAxisAlignment.start,
            direction: Axis.vertical,
            children: [
              Expanded(
                // get painter to DiTreDiDraggable and DiTreDi
                child: Listener(
                  onPointerSignal: (pointerSignal) {
                    if (pointerSignal is PointerScrollEvent) {
                      final scaledDy = pointerSignal.scrollDelta.dy /
                          widget._ditreControl.viewScale;
                      widget._ditreControl.update(
                        userScale: widget._ditreControl.userScale - scaledDy,
                      );
                      setState(() {
                        // update painter for scroll gesture
                        gModelPainter!.update(
                            control: widget._ditreControl, fig: visualObjs);
                      });
                    }
                  },
                  child: GestureDetector(
                    onScaleStart: (data) {
                      scaleBase = widget._ditreControl.userScale;
                      lastX = data.localFocalPoint.dx;
                      lastY = data.localFocalPoint.dy;
                    },
                    onScaleUpdate: (data) {
                      final dx = data.localFocalPoint.dx - lastX;
                      final dy = data.localFocalPoint.dy - lastY;

                      lastX = data.localFocalPoint.dx;
                      lastY = data.localFocalPoint.dy;

                      widget._ditreControl.update(
                        userScale: scaleBase * data.scale,
                        rotationX: (widget._ditreControl.rotationX - dy / 2),
                        rotationY:
                            ((widget._ditreControl.rotationY - dx / 2 + 360) %
                                    360)
                                .clamp(0, 360),
                      );
                      setState(() {
                        // update painter for zoom gesture
                        gModelPainter!.update(
                            control: widget._ditreControl, fig: visualObjs);
                      });
                    },
                    child: ClipRect(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: gModelPainter,
                        willChange: true,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          _key.currentState?.openDrawer();
        },
        child: const Icon(
          Icons.add,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
    );
  }
}
