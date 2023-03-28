import 'dart:async';
import 'dart:math';

import 'package:ditredi/ditredi.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pointcloud_data_viewer/ditredi_/karnavi_canvas_model_painter.dart';
import 'package:pointcloud_data_viewer/ditredi_/model/gird_3d.dart';
import 'package:pointcloud_data_viewer/ditredi_/model/guid_axis_3d.dart';
import 'package:pointcloud_data_viewer/ditredi_/model/point_cloud_3d.dart';
import 'package:pointcloud_data_viewer/ditredi_/viewer_config_controller.dart';
import 'package:pointcloud_data_viewer/files/pcd_reader.dart';
import 'package:pointcloud_data_viewer/widget/sidebar.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/material.dart' as colorcode;

enum ReadMode {
  udp,
  fileList,
}

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
  // point cloud view config
  PCDReader pcdReader = PCDReader(path: '');
  // selected PCD file name
  String selectFile = '';

  // timer for pcd files play
  late Timer mTimerPlay;
  bool gCheckedTimer = false;
  int gTimerCount = 0;

  late final ReadMode? readMode;

  List<Point3D> gPcloudReadPCD = [];

  // painter for 3D visualization using ditredi
  KModelPainter? gModelPainter;

  // set viewPoint Start
  final Aabb3 gBounds = Aabb3.minMax(Vector3(-10, 0, 0), Vector3(10, 15, 0));

  // visualize target using ditredi
  List<Model3D<Model3D<dynamic>>> visualObjs = [
    Grid3D(const Point(10, 15), const Point(-10, 0), 1,
        lineWidth: 1, color: colorcode.Colors.white.withOpacity(0.6)),
    GuideAxis3D(1, lineWidth: 10),
  ];

  double gPointSize = 1.0;

  // update point cloud
  void _updatePointCloud(List<Point3D> cloud) {
    if (mounted) {
      // gPcloud = cloud;
      visualObjs.clear();
      visualObjs = [
        Grid3D(
            Point(
              widget.viewerControl.getGridRangeXEnd,
              widget.viewerControl.getGridRangeYEnd,
            ),
            Point(
              widget.viewerControl.getGridRangeXStart,
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

  // load PCD files
  void _loadPcdFile(String path) async {
    gPcloudReadPCD = await pcdReader.read(path);
    _updatePointCloud(gPcloudReadPCD);
  }

  // private : play timer
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

  // private : play timer and active this func.
  void _timerActive() {
    if (!gCheckedTimer) {
      mTimerPlay = Timer.periodic(
        const Duration(milliseconds: 33),
        (timer) => _playTimer(timer),
      );
      gCheckedTimer = true;
    }
  }

  // private : cancel timer
  void _cancelTimer() {
    if (gCheckedTimer) {
      mTimerPlay.cancel();
      gCheckedTimer = false;
    }
  }

  // page init state FUNC.
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
    gModelPainter = KModelPainter(
      visualObjs,
      gBounds,
      widget._ditreControl,
      const DiTreDiConfig(),
    );

    gPointSize = widget.viewerControl.getPointSize;
    super.initState();
  }

  // page dispose state FUNC[end].
  @override
  void dispose() {
    if (readMode == ReadMode.fileList) {
      _cancelTimer();
    }
    super.dispose();
  }

  // set this page title
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

  void increasePointSize() {
    gPointSize++;
    widget.viewerControl.updatePointSize(gPointSize);
    _updatePointCloud(gPcloudReadPCD);
  }

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
            icon: const Icon(Icons.arrow_back_ios),
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
