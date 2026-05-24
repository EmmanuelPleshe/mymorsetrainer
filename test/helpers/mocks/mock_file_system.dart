import 'dart:convert';
import 'dart:io';
import 'package:mocktail/mocktail.dart';

class MockDirectory extends Mock implements Directory {
  @override
  Future<Directory> create({bool recursive = false}) async => this;

  @override
  String get path => '/tmp/morse_test_logs';
}

class MockFile extends Mock implements File {
  String _content = '';

  @override
  Future<File> writeAsString(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) async {
    _content += contents;
    return this;
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async => _content;

  @override
  Future<bool> exists() async => true;

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) async => this;
}

class MockFileSystem {
  static MockDirectory createMockDirectory() {
    return MockDirectory();
  }

  static MockFile createMockFile([String initialContent = '']) {
    final file = MockFile();
    return file;
  }
}
