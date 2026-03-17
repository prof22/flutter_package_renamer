import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter_package_renamer/src/config_reader.dart';
import 'package:flutter_package_renamer/src/android_editor.dart';
import 'package:flutter_package_renamer/src/ios_editor.dart';
import 'package:args/args.dart';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('project', abbr: 'p', help: 'Path to the Flutter project')
    ..addOption('android', abbr: 'a', help: 'New Android package name')
    ..addOption('ios', abbr: 'i', help: 'New iOS bundle ID')
    ..addFlag('undo', abbr: 'u', help: 'Undo last rename', negatable: false);

  ArgResults results;
  try {
    results = parser.parse(args);
  } catch (e) {
    print('❌ Invalid arguments: $e');
    printUsage(parser);
    return;
  }

  // Determine project directory:
  // 1. --project option
  // 2. First positional argument
  // 3. Current directory
  String projectDir = results['project'] ??
      (results.rest.isNotEmpty ? results.rest.first : Directory.current.path);

  // Normalize path
  projectDir = p.canonicalize(projectDir);

  print('🚀 Flutter Package Renamer');
  print('📂 Project: $projectDir');

  if (!Directory(projectDir).existsSync()) {
    print('❌ Error: Project directory "$projectDir" does not exist.');
    return;
  }

  // Basic Flutter project validation
  if (!File(p.join(projectDir, 'pubspec.yaml')).existsSync()) {
    print('⚠️ Warning: No pubspec.yaml found in "$projectDir".');
    print('Are you sure this is a Flutter project?');
  }

  // Load YAML config if present
  Config? config;
  try {
    config = await loadConfig(projectDir);
  } catch (_) {
    // Ignore if no config found or error loading, we'll use CLI args
  }

  final androidPackage = results['android'] ?? config?.androidPackage;
  final iosBundleId = results['ios'] ?? config?.iosBundleId;
  final undo = results['undo'] as bool;

  if (undo) {
    print('♻️  Attempting to undo last rename...');
    await undoRename(projectDir);
    print('✅ Undo completed!');
    return;
  }

  if (androidPackage == null && iosBundleId == null) {
    print('❌ Error: No package name provided.');
    print('Provide --android and/or --ios, or configure pubspec.yaml.');
    printUsage(parser);
    return;
  }

  try {
    if (androidPackage != null) {
      await updateAndroid(androidPackage, projectDir);
    }
    if (iosBundleId != null) {
      await updateIOS(iosBundleId, projectDir);
    }
    print('\n✨ Rename completed successfully!');
  } catch (e) {
    print('\n❌ Error during rename: $e');
  }
}

void printUsage(ArgParser parser) {
  print('\nUsage: flutter_package_renamer [project_path] [options]');
  print(parser.usage);
}

Future<void> undoRename(String projectDir) async {
  // Use the new centralized undo logic in editors if available
  // For now, keep the simpler restoration logic here
  
  bool restoredAny = false;

  final filesToRestore = [
    p.join(projectDir, 'android', 'app', 'build.gradle'),
    p.join(projectDir, 'android', 'app', 'build.gradle.kts'),
    p.join(projectDir, 'android', 'app', 'src', 'main', 'AndroidManifest.xml'),
    p.join(projectDir, 'ios', 'Runner.xcodeproj', 'project.pbxproj'),
    p.join(projectDir, 'ios', 'Runner', 'Info.plist'),
  ];

  for (final path in filesToRestore) {
    final backup = File('$path.bak');
    if (backup.existsSync()) {
      await backup.copy(path);
      print('💾 Restored: ${p.basename(path)}');
      restoredAny = true;
    }
  }

  if (!restoredAny) {
    print('⚠️ No backup files found to restore.');
  } else {
    print('💡 Note: Folder structural changes and package declarations in code files are not undone automatically.');
  }
}
