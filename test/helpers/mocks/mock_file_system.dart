import 'dart:io';
import 'package:mocktail/mocktail.dart';

class MockDirectory extends Mock implements Directory {
  @override
  Future<void> create({bool recursive = false}) async {}

  @override
  String get path => '/tmp/morse_test_logs';
}

class MockFile extends Mock implements File {
  String _content = '';

  @override
  Future<File> writeAsString(String contents, {FileMode mode = FileMode.append}) async {
    _content += contents;
    return this;
  }

  @override
  Future<String> readAsString() async => _content;

  @override
  Future<bool> exists() async => true;

  @override
  Future<File> delete() async => this;
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