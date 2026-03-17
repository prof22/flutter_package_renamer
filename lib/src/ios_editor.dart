import 'dart:io';
import 'file_utils.dart';
import 'package:path/path.dart' as p;

Future<void> updateIOS(
  String newBundleId,
  String projectPath, {
  bool undo = false,
}) async {
  final pbxPath = p.join(
    projectPath,
    'ios',
    'Runner.xcodeproj',
    'project.pbxproj',
  );
  final pbx = File(pbxPath);

  if (!pbx.existsSync()) {
    print('❌ project.pbxproj not found at ${p.dirname(pbxPath)}');
    return;
  }

  if (undo) {
    final backup = File('${pbx.path}.bak');
    if (backup.existsSync()) {
      await backup.copy(pbx.path);
      print('💾 Restored project.pbxproj from backup');
    } else {
      print('⚠️ No backup found for project.pbxproj');
    }
    return;
  }

  // Create backup
  final pbxBackup = File('${pbx.path}.bak');
  await pbx.copy(pbxBackup.path);
  print('💾 Backup created: ${pbxBackup.path}');

  String content = await pbx.readAsString();

  final oldBundleId =
      RegExp(
        r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*(.+?);',
      ).firstMatch(content)?.group(1) ??
      r'$(PRODUCT_BUNDLE_IDENTIFIER)';

  print('🔄 iOS: $oldBundleId → $newBundleId');

  // Replace in all pbx files
  final pbxFiles = await getAllFiles(
    Directory(p.join(projectPath, 'ios', 'Runner.xcodeproj')),
  );
  for (var file in pbxFiles) {
    await replaceInFile(file.path, oldBundleId, newBundleId);
  }

  // Info.plist
  final infoPlistPath = p.join(projectPath, 'ios', 'Runner', 'Info.plist');
  final infoPlist = File(infoPlistPath);
  if (infoPlist.existsSync()) {
    // Backup Info.plist
    final plistBackup = File('$infoPlistPath.bak');
    await infoPlist.copy(plistBackup.path);
    print('💾 Backup created: ${plistBackup.path}');

    String plistContent = await infoPlist.readAsString();
    plistContent = plistContent.replaceAll(oldBundleId, newBundleId);
    await infoPlist.writeAsString(plistContent);
  }
}
