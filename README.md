# Flutter/Dart Beta Version Lookup

A local Dart script to find the correct Dart beta version bundled with a specific Flutter beta tag.

## The Problem

The official `docs.flutter.dev` SDK archive page incorrectly lists the **stable** Dart version (e.g., `3.10.0`) for Flutter beta releases.

**Example: `flutter.dev` Beta Table (Incorrect)**

| Flutter version | Ref | Dart version (Incorrect) |
| :--- | :--- | :--- |
| `3.38.0-0.1.pre` | `7e592fe` | `3.10.0` |
| `3.37.0-0.1.pre` | `465e421` | `3.10.0` |

This makes it difficult to determine the true Dart SDK dependency for a given Flutter beta. This script serves as a local "map" to find the ground truth (e.g., that `3.38.0-0.1.pre` actually uses Dart `3.10.0-290.2.beta`) until the official documentation is fixed.

## Configuration

This is the most important step. Open `bin/find_version.dart` and edit the two constants at the top to point to your local `flutter` and `dart-sdk` repos.

```dart
final FLUTTER_REPO = '${Platform.environment['HOME']}/flutter';
final DART_SDK_REPO = '${Platform.environment['HOME']}/sdk';
```

## Usage
Run the script from the root of this project, passing the Flutter tag you wish to query as an argument.

```bash
dart run bin/find_version.dart <flutter-tag>
```

### Example
```bash
dart run bin/find_version.dart 3.38.0-0.1.pre
```