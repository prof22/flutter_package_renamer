# Flutter Package Renamer 🚀

A command-line tool to rename Android package names and iOS bundle IDs for Flutter projects with **automatic backup and undo support**.

---

## Features

- Rename Android `applicationId` and iOS `bundle identifier`.
- Undo last rename with `--undo`.
- Automatic backups for all modified files.
- Reads defaults from `pubspec.yaml`.
- Supports both Kotlin, Java, Swift, and Objective-C files.
- CLI-friendly: can run from anywhere.

---

## Installation

```bash
# Clone the repo
git clone https://github.com/prof22/flutter_package_renamer.git

# Use as local dependency
flutter pub add ../flutter_package_renamer


Usage
# Rename Android and iOS IDs
dart run bin/flutter_package_renamer.dart --android com.newname.app --ios com.newname.app

# Undo last rename
dart run bin/flutter_package_renamer.dart --undo


You can also set defaults in pubspec.yaml:

flutter_package_renamer:
    android_package: com.newname.app
    ios_bundle_id: com.newname.app

Then simply run:

dart run bin/flutter_package_renamer.dart


Pro Features (coming soon)

Interactive mode for renaming multiple flavors.

Version bumping automatically.

Multi-step undo history.

Logging of all changes for CI/CD pipelines.



---

## **3️⃣ Pro Features to beat existing tools**

| Feature | Description | Why it beats others |
|---------|------------|------------------|
| Undo/Backup system | Automatic backup of `build.gradle`, `AndroidManifest`, `Info.plist`, `project.pbxproj`. | Existing tools rarely support safe undo. |
| Read defaults from `pubspec.yaml` | CLI-less renaming if defaults exist. | Saves time, no typing long paths. |
| Interactive mode | Step-by-step renaming prompt for users. | Makes tool beginner-friendly. |
| Multi-flavor support | Automatically rename multiple flavors (`dev`, `prod`). | Faster CI/CD automation. |
| CI/CD Friendly | Logs changes in JSON for scripts. | Essential for automation pipelines. |

---

## **4️⃣ How to publish to pub.dev**

1. **Check package readiness**
```bash
dart pub publish --dry-run