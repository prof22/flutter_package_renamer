# Flutter Package Renamer 🚀

[![Pub Version](https://img.shields.io/pub/v/flutter_package_renamer?style=flat-square&logo=dart&color=blue)](https://pub.dev/packages/flutter_package_renamer)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios-lightgrey.svg?style=flat-square)](https://flutter.dev)

A modern, robust command-line tool to safely rename your Flutter application's package name (Android `applicationId`) and bundle identifier (iOS `PRODUCT_BUNDLE_IDENTIFIER`).

Unlike other tools, **Flutter Package Renamer** prioritizes safety with automatic file backups and a built-in undo system.

---

## ✨ Features

- 📱 **Full Android Support**: Updates `build.gradle`, `AndroidManifest.xml`, and refactors Kotlin/Java directory structures.
- 🍏 **Full iOS Support**: Updates `project.pbxproj` and `Info.plist`.
- 🛡️ **Safety First**: Automatic backups (`.bak`) for every modified file.
- ⎌ **Built-in Undo**: One command to revert all file changes if something goes wrong.
- ⚙️ **Configurable**: Use CLI arguments or define defaults in your `pubspec.yaml`.
- 🚀 **Smart Refactoring**: Automatically moves source files to the correct new package directory structure.

---

## 📦 Installation

Add the package to your `dev_dependencies`:

```bash
# Add as a dev dependency
flutter pub add --dev flutter_package_renamer
```

Alternatively, install it globally for use in any project:

```bash
dart pub global activate flutter_package_renamer
```

---

## 🛠 Usage

### Command Line
Run the tool from your project root:

```bash
# Rename both platforms
dart run flutter_package_renamer --android com.newcompany.myapp --ios com.newcompany.myapp

# Rename a specific platform
dart run flutter_package_renamer --android com.example.pro

# Target a specific project directory
dart run flutter_package_renamer /path/to/project --android com.app.id
```

### Configuration File
Save time by adding your desired configuration to your `pubspec.yaml`:

```yaml
flutter_package_renamer:
  android_package: com.newcompany.myapp
  ios_bundle_id: com.newcompany.myapp
```

Then simply run:
```bash
dart run flutter_package_renamer
```

### ⎌ Undoing Changes
If you need to revert the modified files to their original state:

```bash
dart run flutter_package_renamer --undo
```

---

## 📖 CLI Options

| Option | Abbr | Description |
| :--- | :--- | :--- |
| `[project_path]` | - | Optional positional argument for the project path |
| `--project` | `-p` | Path to the Flutter project (defaults to current directory) |
| `--android` | `-a` | New Android package name (`applicationId`) |
| `--ios` | `-i` | New iOS bundle ID (`PRODUCT_BUNDLE_IDENTIFIER`) |
| `--undo` | `-u` | Revert changes using the generated backup files |
| `--help` | `-h` | Show usage information |

---

## ⚠️ Important Notes

- **Version Control**: While we provide an undo system, it is *always* recommended to commit your changes or use a clean Git state before running automated refactoring tools.
- **Directory Cleanup**: Empty old package folders are removed automatically, but non-empty folders are preserved for safety.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.