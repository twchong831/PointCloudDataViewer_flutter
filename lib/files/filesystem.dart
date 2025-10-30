import 'dart:convert';
import 'dart:io';

/// Minimal file I/O helper for reading and writing text files line-by-line.
class FileSystem {
  String filename = '';
  String bPath = '';

  // FileSystem({
  //   required this.filename,
  // });

  /// Sets the base directory path used for reading/writing.
  void setLocalPath(String path) {
    bPath = path;
  }

  /// Sets the filename used within the base directory.
  void setFileName(String name) {
    filename = name;
  }

  void setPathName(String pathName) {}

  /// Full file path for the configured base path and filename.
  File get filePath {
    return File('$bPath/$filename');
  }

  /// Writes [value] as a string to the configured file.
  Future<File> write(var value) async {
    final file = filePath;
    // 파일 쓰기
    return file.writeAsString('$value');
  }

  /// Reads file as a stream of lines (async).
  Future<Stream<String>> read() async {
    Stream<String> contents;
    final File file;
    if (bPath.isNotEmpty) {
      file = File('$bPath/$filename');
    } else {
      file = filePath;
    }
    if (await file.exists()) {
      try {
        contents = file
            .openRead()
            .transform(utf8.decoder)
            .transform(const LineSplitter());
        // file.deleteSync(); //delete file
        return contents; //return
      } catch (e) {
        print('Error : $e');
        return const Stream.empty();
      }
    }
    return const Stream.empty();
  }

  /// Reads file as a stream of lines (sync path, async content).
  Stream<String> readSync() {
    final File file = filePath;

    if (file.existsSync()) {
      try {
        Stream<String> contents = file
            .openRead()
            .transform(utf8.decoder)
            .transform(const LineSplitter());
        // file.deleteSync(); //delete file
        return contents;
      } catch (e) {
        print('Error : $e');
        return const Stream.empty();
      }
    } else {
      print("file not exists ${filePath.path}");
    }
    return const Stream.empty();
  }

  /// Returns the configured base path.
  Future<String> getBasePath() async {
    return bPath;
  }
}
