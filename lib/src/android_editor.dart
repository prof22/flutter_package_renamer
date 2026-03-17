import 'dart:io';
import 'package:path/path.dart' as p;

/// Updates Android package namespace and applicationId
/// [newPackage] - the package name to change to
/// [projectPath] - the path to the Flutter project
/// [createBackup] - whether to backup original files before changing
Future<void> updateAndroid(
  String newPackage,
  String projectPath, {
  bool createBackup = true,
}) async {
  final gradlePaths = [
    p.join(projectPath, 'android', 'app', 'build.gradle'),
    p.join(projectPath, 'android', 'app', 'build.gradle.kts'),
  ];

  File? buildGradle;
  for (final candidate in gradlePaths) {
    final file = File(candidate);
    if (file.existsSync()) {
      buildGradle = file;
      break;
    }
  }

  if (buildGradle == null) {
    print(
      '❌ build.gradle not found at ${p.join(projectPath, 'android', 'app')}',
    );
    return;
  }

  // Backup gradle before changing
  if (createBackup) await _backupFile(buildGradle);

  var gradleContent = await buildGradle.readAsString();

  // Match namespace and applicationId with optional quotes
  final namespaceRegex = RegExp(r'''(namespace\s*=\s*)(['"])([^'"]+)(['"])''');
  final appIdRegex = RegExp(r'''(applicationId\s*=\s*)(['"])([^'"]+)(['"])''');

  final namespaceMatch = namespaceRegex.firstMatch(gradleContent);
  final appIdMatch = appIdRegex.firstMatch(gradleContent);

  final oldPackage =
      namespaceMatch?.group(3) ?? appIdMatch?.group(3) ?? 'com.example.app';

  if (oldPackage == newPackage) {
    print('✅ Package name is already $newPackage. Skipping.');
    return;
  }

  print('🔄 Android: $oldPackage → $newPackage');

  // Replace namespace and applicationId
  if (namespaceMatch != null) {
    gradleContent = gradleContent.replaceFirst(
      namespaceRegex,
      '${namespaceMatch.group(1)}${namespaceMatch.group(2)}$newPackage${namespaceMatch.group(4)}',
    );
  }
  if (appIdMatch != null) {
    gradleContent = gradleContent.replaceFirst(
      appIdRegex,
      '${appIdMatch.group(1)}${appIdMatch.group(2)}$newPackage${appIdMatch.group(4)}',
    );
  }
  await buildGradle.writeAsString(gradleContent);

  // Update AndroidManifest.xml
  final manifestPath = p.join(
    projectPath,
    'android',
    'app',
    'src',
    'main',
    'AndroidManifest.xml',
  );
  final manifest = File(manifestPath);
  if (manifest.existsSync()) {
    if (createBackup) await _backupFile(manifest);

    var manifestContent = await manifest.readAsString();
    manifestContent = manifestContent.replaceAll(oldPackage, newPackage);
    await manifest.writeAsString(manifestContent);
  }

  // Move Kotlin/Java folders safely
  await _movePackageFolder(oldPackage, newPackage, projectPath);
}

/// Moves Kotlin/Java package folders safely, skipping on permissions errors
Future<void> _movePackageFolder(
  String oldPackage,
  String newPackage,
  String projectPath,
) async {
  final folders = ['kotlin', 'java'];

  for (final folder in folders) {
    final baseDir = Directory(
      p.join(projectPath, 'android', 'app', 'src', 'main', folder),
    );
    if (!baseDir.existsSync()) continue;

    final oldRelativePath = oldPackage.replaceAll('.', Platform.pathSeparator);
    final newRelativePath = newPackage.replaceAll('.', Platform.pathSeparator);

    final oldPackageDir = Directory(p.join(baseDir.path, oldRelativePath));
    if (!oldPackageDir.existsSync()) continue;

    final newPackageDir = Directory(p.join(baseDir.path, newRelativePath));

    // Safe folder creation
    try {
      await newPackageDir.create(recursive: true);
    } catch (e) {
      print('⚠️ Could not create folder $newPackageDir: $e');
      print('Skipping folder move for $folder.');
      continue;
    }

    // Copy files and update package declarations
    await for (final entity in oldPackageDir.list(recursive: true)) {
      if (entity is File) {
        final relativeFilePath = p.relative(
          entity.path,
          from: oldPackageDir.path,
        );
        final newFilePath = p.join(newPackageDir.path, relativeFilePath);

        try {
          await File(p.dirname(newFilePath)).create(recursive: true);
        } catch (_) {}

        try {
          if (entity.path.endsWith('.kt') || entity.path.endsWith('.java')) {
            var content = await entity.readAsString();
            content = content.replaceFirst(
              RegExp('package $oldPackage'),
              'package $newPackage',
            );
            await File(newFilePath).writeAsString(content);
          } else {
            await entity.copy(newFilePath);
          }
        } catch (e) {
          print('⚠️ Could not copy file ${entity.path}: $e');
        }
      }
    }

    // Attempt to delete old directories safely
    try {
      await oldPackageDir.delete(recursive: true);
      var parent = oldPackageDir.parent;
      while (p.isWithin(baseDir.path, parent.path) &&
          parent.path != baseDir.path) {
        if (parent.listSync().isEmpty) {
          await parent.delete();
          parent = parent.parent;
        } else {
          break;
        }
      }
    } catch (e) {
      print('⚠️ Could not delete old package folders: $e');
      print('You may need to manually remove $oldPackageDir');
    }
  }
}

/// Backup a file before modifying
Future<File> _backupFile(File file) async {
  final backupPath = '${file.path}.bak';
  await file.copy(backupPath);
  print('💾 Backup created: $backupPath');
  return File(backupPath);
}

/// Restore all Android backups
Future<void> undoBackup(String projectPath) async {
  final filesToRestore = [
    p.join(projectPath, 'android', 'app', 'build.gradle'),
    p.join(projectPath, 'android', 'app', 'build.gradle.kts'),
    p.join(projectPath, 'android', 'app', 'src', 'main', 'AndroidManifest.xml'),
  ];

  for (final path in filesToRestore) {
    final backup = File('$path.bak');
    final original = File(path);
    if (backup.existsSync()) {
      await backup.copy(original.path);
      print('♻️ Restored backup for $path');
    }
  }

  print(
    '⚠️ Undo only restores files; old Kotlin/Java package folders may require manual cleanup.',
  );
}
