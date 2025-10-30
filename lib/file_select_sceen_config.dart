import 'package:flutter/material.dart';

/// Holds file selection state for the app.
///
/// - Exposes a list of selectable files and the currently selected file.
/// - Notifies listeners on changes so dependent widgets rebuild.
class FileSelectConfig extends ChangeNotifier {
  /// List of selectable file paths (or names).
  List<String>? _fileList;

  /// Currently selected file path (or name).
  String? _selectedFile;

  /// Creates a new file selection state.
  ///
  /// If not provided, initializes with an empty list and empty selection.
  FileSelectConfig({
    List<String>? fileList,
    String? selectedFile,
  })  : _fileList = fileList ?? [],
        _selectedFile = selectedFile ?? '';

  /// Replaces the available file list and notifies listeners.
  void setFileLists(List<String> list) {
    _fileList = list;
    notifyListeners();
  }

  /// Updates the currently selected file and notifies listeners.
  void setSelectFile(String file) {
    _selectedFile = file;
    notifyListeners();
  }

  /// Returns the current file list.
  ///
  /// Uses a non-null assertion since the constructor sets a default.
  List<String> get getFileList => _fileList!;

  /// Returns the currently selected file.
  ///
  /// Uses a non-null assertion since the constructor sets a default.
  String get getSelectedFile => _selectedFile!;
}
