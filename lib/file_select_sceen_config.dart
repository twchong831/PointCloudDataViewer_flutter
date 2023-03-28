import 'package:flutter/material.dart';

class FileSelectConfig extends ChangeNotifier {
  List<String>? _fileList;
  String? _selectedFile;

  FileSelectConfig({
    List<String>? fileList,
    String? selectedFile,
  })  : _fileList = fileList ?? [],
        _selectedFile = selectedFile ?? '';

  void setFileLists(List<String> list) {
    _fileList = list;
    notifyListeners();
  }

  void setSelectFile(String file) {
    _selectedFile = file;
    notifyListeners();
  }

  List<String> get getFileList => _fileList!;
  String get getSelectedFile => _selectedFile!;
}
