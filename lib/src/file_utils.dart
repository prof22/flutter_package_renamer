import 'dart:io';

Future<List<File>> getAllFiles(Directory dir) async {
  List<File> files = [];
  await for (var entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is File) files.add(entity);
  }
  return files;
}

Future<void> replaceInFile(String path, String from, String to) async {
  final file = File(path);
  if (!file.existsSync()) return;
  String content = await file.readAsString();
  content = content.replaceAll(from, to);
  await file.writeAsString(content);
}
