import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;

class Config {
  final String? androidPackage;
  final String? iosBundleId;

  Config({this.androidPackage, this.iosBundleId});
}

Future<Config?> loadConfig([String? projectDir]) async {
  final dir = projectDir ?? Directory.current.path;
  final pubspecFile = File(p.join(dir, 'pubspec.yaml'));
  if (!pubspecFile.existsSync()) return null;

  final content = await pubspecFile.readAsString();
  final yamlMap = loadYaml(content) as YamlMap;
  final configYaml = yamlMap['flutter_package_renamer'] as YamlMap?;

  if (configYaml == null) return null;

  return Config(
    androidPackage: configYaml['android_package']?.toString(),
    iosBundleId: configYaml['ios_bundle_id']?.toString(),
  );
}
