import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pointcloud_data_viewer/ditredi_/viewer_config_controller.dart';

class ViewerSetScreen extends StatefulWidget {
  final ViewerConfigController vConfigController;

  ViewerSetScreen({
    super.key,
    ViewerConfigController? configController,
  }) : vConfigController = configController ?? ViewerConfigController();

  @override
  State<ViewerSetScreen> createState() => _ViewerSetScreenState();
}

class _ViewerSetScreenState extends State<ViewerSetScreen> {
  Color _backgroundColor = Colors.blue;

  final textController = TextEditingController();
  // RangeValues _rangeValues = const RangeValues(0, 20);
  late ViewerConfigController? updateController;

  @override
  void initState() {
    super.initState();
    updateController = widget.vConfigController;
    _backgroundColor = updateController!.getBackgroundColor;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color invertColor(Color now) {
    Color color = Colors.white;
    if (now.blue > 200 && now.green > 200 && now.red > 200) {
      color = Colors.black;
    }

    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onPrimary,
      child: Column(
        children: [
          const Text('Grid Setting'),
          const Text('X-Axis'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 30,
                child: Text('${updateController!.getGridRangeXStart.toInt()}'),
              ),
              Expanded(
                child: RangeSlider(
                  values: updateController!.getGridRangeX,
                  max: updateController!.getMaxRangeX.end,
                  min: updateController!.getMaxRangeX.start,
                  divisions: updateController!.rangeXdivision(),
                  onChanged: (value) {
                    setState(() {
                      updateController!.updateGridRangeX(value);
                    });
                  },
                ),
              ),
              SizedBox(
                width: 30,
                child: Text('${updateController!.getGridRangeXEnd.toInt()}'),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const Text('Y-Axis'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 30,
                child: Text(
                  '${updateController!.getGridRangeYStart.toInt()}',
                  style: const TextStyle(),
                ),
              ),
              Expanded(
                child: RangeSlider(
                  values: updateController!.getGridRangeY,
                  max: updateController!.getMaxRangeY.end,
                  min: updateController!.getMaxRangeY.start,
                  divisions: updateController!.rangeYdivision(),
                  onChanged: (value) {
                    setState(() {
                      updateController!.updateGridRangeY(value);
                    });
                  },
                ),
              ),
              SizedBox(
                width: 30,
                child: Text('${updateController!.getGridRangeYEnd.toInt()}'),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          Text('Point Size : ${updateController!.getPointSize}'),
          // Text('${widget._pointSize}'),
          Row(
            children: [
              const SizedBox(
                width: 40,
              ),
              Expanded(
                child: Slider(
                  value: updateController!.getPointSize,
                  max: 5.0,
                  min: 1.0,
                  divisions: 4,
                  onChanged: (value) {
                    setState(() {
                      updateController!.updatePointSize(double.parse(
                        value.toStringAsFixed(1),
                      ));
                    });
                  },
                ),
              ),
              const SizedBox(
                width: 40,
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(
                width: 30,
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _backgroundColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 10,
                    shadowColor: Colors.black,
                    alignment: Alignment.center,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Select Background Color'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: _backgroundColor,
                              onColorChanged: (value) {
                                setState(() {
                                  _backgroundColor = value;
                                  widget.vConfigController
                                      .updateBackgroundColor(_backgroundColor);
                                });
                              },
                              colorPickerWidth: 300,
                              pickerAreaHeightPercent: 0.7,
                              pickerAreaBorderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(2),
                                topRight: Radius.circular(2),
                              ),
                            ),
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    Navigator.of(context).pop();
                                  });
                                },
                                child: const Text('OK')),
                          ],
                        );
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.color_lens_outlined,
                        color: invertColor(_backgroundColor),
                        size: 50,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Background Color',
                        style: TextStyle(
                          color: invertColor(_backgroundColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 30,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
