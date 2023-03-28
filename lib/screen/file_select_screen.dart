import 'dart:io';

// import 'package:ditredi/ditredi.dart';
import 'package:ditredi/ditredi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pointcloud_data_viewer/ditredi_/viewer_config_controller.dart';
import 'package:pointcloud_data_viewer/file_select_sceen_config.dart';
import 'package:pointcloud_data_viewer/files/pcd_reader.dart';
import 'package:pointcloud_data_viewer/screen/viewer_screen.dart';

// class HomeController extends GetxController {}

class FileSelectScreen extends StatefulWidget {
  final ViewerConfigController vConfigController;
  final FileSelectConfig? fileCofig;

  FileSelectScreen({
    super.key,
    ViewerConfigController? controller,
    this.fileCofig,
  }) : vConfigController = controller ?? ViewerConfigController();

  @override
  State<FileSelectScreen> createState() => _FileSelectScreenState();
}

class _FileSelectScreenState extends State<FileSelectScreen> {
  // FileSystem pcdFiles = FileSystem();
  PCDReader pcdReader = PCDReader(path: '');
  List<DropdownMenuItem<String>> pcdFileList = [];
  String selPcdFile = 'NONE';
  List<Point3D> pointCloud = [];

  String strNone = "NONE";
  List<String> listPcdFiles = [];

  bool checkedListUpdated = false;

  DiTreDiController? _beforeViewController;

  List<DropdownMenuItem<String>> dropDownList = [
    const DropdownMenuItem(
      value: 'NONE',
      child: Text('NONE'),
    )
  ];

  // generate dropdownMenuItem
  List<DropdownMenuItem<String>> generateFileListMenu(List<String> list) {
    print('load generate menu Item');
    bool checked = false;
    late List<DropdownMenuItem<String>> l = [];

    if (list.isEmpty) {
      l.add(DropdownMenuItem(
        value: strNone,
        child: Text(strNone),
      ));
    } else {
      for (var i = 0; i < list.length; i++) {
        List nameList = list[i].split('/');
        l.add(DropdownMenuItem(
          value: list[i],
          child: Text(nameList[nameList.length - 1]),
        ));

        if (selPcdFile.isNotEmpty && (selPcdFile == list[i])) {
          checked = true;
        }
      }
    }

    setState(() {
      if (list.isEmpty) {
        selPcdFile = strNone;
      } else {
        if (!checked) {
          selPcdFile = list[0];
        }
      }
    });

    return l;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.fileCofig!.getFileList.isNotEmpty) {
        listPcdFiles = widget.fileCofig!.getFileList;
        dropDownList = generateFileListMenu(listPcdFiles);
        checkedListUpdated = true;
        selPcdFile = listPcdFiles[0];
      }
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onPrimary,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
                top: 8,
                right: 15,
                left: 15,
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (listPcdFiles.isNotEmpty) listPcdFiles.clear();
                  String? selectedDirectory =
                      await FilePicker.platform.getDirectoryPath();
                  if (selectedDirectory == null) {
                    // User canceled the picker
                  } else {
                    Directory dir = Directory(selectedDirectory);
                    List listFiles = dir.listSync();
                    for (var i in listFiles) {
                      String sub =
                          i.toString().substring(7, i.toString().length - 1);
                      List sp = sub.split('.');
                      if (sp.length > 1) {
                        if (sp[sp.length - 1] == 'pcd') {
                          listPcdFiles.add(sub);
                        }
                      }
                    }

                    if (listPcdFiles.length > 1) {
                      checkedListUpdated = true;
                      listPcdFiles.sort(
                        (a, b) {
                          if (a.contains('(') && a.contains(')')) {
                            List<String> la = a.split(RegExp(r'[(-)]'));
                            List<String> lb = b.split(RegExp(r'[(-)]'));

                            if (int.parse(la[1]) > int.parse(lb[1])) {
                              return 1;
                            } else {
                              return -1;
                            }
                          }
                          return -1;
                        },
                      );
                    } else {
                      checkedListUpdated = false;
                      listPcdFiles.add(strNone);
                    }
                    selPcdFile = listPcdFiles[0];
                    setState(
                      () {
                        widget.fileCofig!.setFileLists(listPcdFiles);
                        dropDownList = generateFileListMenu(listPcdFiles);
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4399F8),
                  foregroundColor: Colors.white,
                  elevation: 10,
                  shadowColor: Colors.black,
                ),
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8,
                      top: 8,
                      right: 15,
                      left: 15,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.folder_open_rounded,
                          size: 30,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "PCD files Directory select",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            // backgroundColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
                top: 8,
                right: 15,
                left: 15,
              ),
              child: DropdownButton(
                isExpanded: true,
                items: dropDownList,
                // icon: Ic,
                onChanged: (dynamic value) {
                  setState(
                    () {
                      selPcdFile = value;
                      widget.fileCofig!.setSelectFile(selPcdFile);
                      if (selPcdFile != strNone) {
                        checkedListUpdated = true;
                      } else {
                        checkedListUpdated = false;
                      }
                      // print(listPcdFiles);
                    },
                  );
                },
                value: selPcdFile,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
                top: 8,
                right: 15,
                left: 15,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4399F8),
                        foregroundColor: Colors.white,
                        elevation: 10,
                        shadowColor: Colors.black,
                      ),
                      onPressed: checkedListUpdated
                          ? () async {
                              _beforeViewController = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewScreen(
                                    pcdList: [selPcdFile],
                                    ditreControl: _beforeViewController,
                                    viewerControl: widget.vConfigController,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: FittedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.file_open_outlined),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Load',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                // backgroundColor: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.fill,
                    child: SizedBox(
                      width: 70,
                      child: IconButton(
                        padding: const EdgeInsets.only(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 25,
                        ),
                        onPressed: checkedListUpdated
                            ? () async {
                                _beforeViewController = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewScreen(
                                      pcdList: listPcdFiles,
                                      ditreControl: _beforeViewController,
                                      viewerControl: widget.vConfigController,
                                    ),
                                    maintainState: false,
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(
                          Icons.play_circle_outline_outlined,
                          size: 50,
                          shadows: [],
                        ),
                        color: Colors.green,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
