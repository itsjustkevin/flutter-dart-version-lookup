import 'dart:io';
import 'dart:convert';
import 'package:chalkdart/chalkstrings.dart';

final FLUTTER_REPO = '${Platform.environment['HOME']}/programming/flutter';
final DART_SDK_REPO = '${Platform.environment['HOME']}/programming/sdk';

Future<String> runGit(String repoPath, String refAndFile) async {
  var result = await Process.run(
    'git',
    ['-C', repoPath, 'show', refAndFile],
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );

  if (result.exitCode != 0) {
    throw Exception("Git error: ${result.stderr}");
  }
  return result.stdout as String;
}

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln("Error: No Flutter tag provided.");
    stderr.writeln("Usage: dart run bin/find_version.dart <flutter-tag>");
    exit(1);
  }

  var flutterTag = args[0];

  try {
    var depsContent = await runGit(FLUTTER_REPO, '$flutterTag:DEPS');

    // Bashing my head because I can't figure out why I can't parse
    // out the Dart revision, so we just remove all white space
    // and try without it.
    // The DEPS file uses non-breaking spaces (U+00A0).
    // This line replaces all of them with regular spaces.
    var normalizedContent = depsContent.replaceAll('\u00A0', ' ');

    var regex = RegExp(r"'dart_revision'\s*:\s*'([^']*)'");
    var match = regex.firstMatch(normalizedContent);

    if (match == null) {
      throw Exception(
          "Could not parse 'dart_revision' from DEPS.");
    }

    var dartRevision = match.group(1)!;

    var versionFileContent =
        await runGit(DART_SDK_REPO, '$dartRevision:tools/VERSION');

    var versionParts = Map.fromEntries(
      versionFileContent
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty && line.contains(' '))
          .map((line) {
        var parts = line.split(' ');
        return MapEntry(parts[0], parts[1]);
      }),
    );

    var channel = versionParts['CHANNEL'];
    var fullVersion;

    if (channel == 'stable') {
      fullVersion =
          "${versionParts['MAJOR']}.${versionParts['MINOR']}.${versionParts['PATCH']}";
    } else {
      fullVersion =
          "${versionParts['MAJOR']}.${versionParts['MINOR']}.${versionParts['PATCH']}-"
          "${versionParts['PRERELEASE']}.${versionParts['PRERELEASE_PATCH']}.${channel}";
    }

    print("\tFlutter Tag:  $flutterTag".green);
    print("\tDart Version: $fullVersion".green);
    print("\tDart Commit:  $dartRevision".green);
  } catch (e) {
    stderr.writeln("Error: $e".red);
    exit(1);
  }
}
