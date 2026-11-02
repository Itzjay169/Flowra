// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, unnecessary_brace_in_string_interps
/// Flowra Release Automation Script
///
/// Usage:
///   dart run tools/release.dart [--bump patch|minor|major] [--notes "Added x; Fixed y"] [--skip-build]
library;

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

void main(List<String> args) async {
  print('====================================================');
  print('🚀 Flowra Release Pipeline');
  print('====================================================');

  // Parse CLI flags
  String bumpType = 'patch';
  String? rawNotes;
  bool skipBuild = false;

  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--bump' && i + 1 < args.length) {
      bumpType = args[++i].toLowerCase();
    } else if (arg == '--notes' && i + 1 < args.length) {
      rawNotes = args[++i];
    } else if (arg == '--skip-build') {
      skipBuild = true;
    } else if (arg == '--help' || arg == '-h') {
      print('Usage: dart run tools/release.dart [options]');
      print('Options:');
      print('  --bump <patch|minor|major>  Bump type (default: patch)');
      print('  --notes "<notes>"           Semicolon-separated release notes');
      print('  --skip-build                Skip flutter build (dry run)');
      exit(0);
    }
  }

  final rootDir = Directory.current;
  // Support running from repo root (Flowra/) — pubspec is in app/
  var pubspecFile = File('${rootDir.path}/app/pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    // Fallback: check if running from within app/ directory
    pubspecFile = File('${rootDir.path}/pubspec.yaml');
  }
  if (!pubspecFile.existsSync()) {
    print('❌ Error: pubspec.yaml not found in ${rootDir.path}/app/ or ${rootDir.path}');
    exit(1);
  }
  // Derive appDir for build commands
  final appDir = pubspecFile.parent;

  // 1. Read & Bump pubspec.yaml
  final pubspecContent = pubspecFile.readAsStringSync();
  final versionRegex = RegExp(r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)', multiLine: true);
  final match = versionRegex.firstMatch(pubspecContent);

  if (match == null) {
    print('❌ Error: Could not find version line formatted as x.y.z+build in pubspec.yaml');
    exit(1);
  }

  int major = int.parse(match.group(1)!);
  int minor = int.parse(match.group(2)!);
  int patch = int.parse(match.group(3)!);
  int build = int.parse(match.group(4)!);

  final oldVersion = '$major.$minor.$patch';
  final oldBuild = build;

  switch (bumpType) {
    case 'major':
      major++;
      minor = 0;
      patch = 0;
      break;
    case 'minor':
      minor++;
      patch = 0;
      break;
    case 'patch':
    default:
      patch++;
      break;
  }
  build++;

  final newVersion = '$major.$minor.$patch';
  final newVersionFull = '$newVersion+$build';
  final releaseDate = DateTime.now().toIso8601String().substring(0, 10);

  print('📦 Current Version : $oldVersion (build $oldBuild)');
  print('⬆️  New Version     : $newVersion (build $build) [Bump: $bumpType]');

  // 2. Resolve Release Notes
  List<String> noteItems = [];
  if (rawNotes != null && rawNotes.trim().isNotEmpty) {
    noteItems = rawNotes
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  } else {
    // Generate notes from git commits since last tag
    print('\n🔍 Generating release notes from git commits since last tag...');
    final lastTagResult = Process.runSync('git', ['describe', '--tags', '--abbrev=0']);
    final lastTag = lastTagResult.exitCode == 0 ? lastTagResult.stdout.toString().trim() : null;

    final gitArgs = ['log', '--no-merges', '--oneline'];
    if (lastTag != null && lastTag.isNotEmpty) {
      gitArgs.add('$lastTag..HEAD');
      print('   Found latest tag: $lastTag');
    } else {
      gitArgs.addAll(['-n', '10']);
    }

    final gitLogResult = Process.runSync('git', gitArgs);
    final logLines = gitLogResult.exitCode == 0
        ? gitLogResult.stdout.toString().split('\n').where((l) => l.trim().isNotEmpty).toList()
        : <String>[];

    if (logLines.isNotEmpty) {
      print('\nRecent commits:');
      for (final line in logLines) {
        // Strip short sha
        final commitMessage = line.replaceFirst(RegExp(r'^[a-f0-9]+\s+'), '').trim();
        print('  • $commitMessage');
        noteItems.add(commitMessage);
      }
    } else {
      noteItems.add('Performance improvements and bug fixes');
    }

    // Prompt user confirmation if interactive
    if (stdin.hasTerminal) {
      stdout.write('\nUse these release notes? (Y/n/custom): ');
      final input = stdin.readLineSync()?.trim().toLowerCase();
      if (input == 'n') {
        print('Aborted by user.');
        exit(0);
      } else if (input != null && input != 'y' && input.isNotEmpty) {
        noteItems = input.split(';').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
    }
  }

  // Group notes into Added / Changed / Fixed / Removed
  final grouped = <String, List<String>>{
    'Added': [],
    'Changed': [],
    'Fixed': [],
    'Removed': [],
  };

  for (final note in noteItems) {
    final lower = note.toLowerCase();
    if (lower.startsWith('add') || lower.startsWith('feat') || lower.startsWith('new')) {
      grouped['Added']!.add(note);
    } else if (lower.startsWith('fix') || lower.startsWith('bug')) {
      grouped['Fixed']!.add(note);
    } else if (lower.startsWith('remove') || lower.startsWith('deprecat')) {
      grouped['Removed']!.add(note);
    } else {
      grouped['Changed']!.add(note);
    }
  }

  // Ensure at least one entry
  if (grouped.values.every((list) => list.isEmpty)) {
    grouped['Changed']!.add('General improvements and stability updates');
  }

  // 3. Write bumped version to pubspec.yaml
  final updatedPubspec = pubspecContent.replaceFirst(
    versionRegex,
    'version: $newVersionFull',
  );
  pubspecFile.writeAsStringSync(updatedPubspec);
  print('✅ Updated pubspec.yaml to version: $newVersionFull');

  // 4. Build Release APK
  final apkOutputName = 'Flowra-v$newVersion.apk';
  final releasesDir = Directory('${rootDir.path}/releases');
  if (!releasesDir.existsSync()) {
    releasesDir.createSync(recursive: true);
  }
  final targetApkFile = File('${releasesDir.path}/$apkOutputName');

  double fileSizeMb = 18.5;
  String sha256Hex = '';

  if (!skipBuild) {
    print('\n🔨 Building Release APK with Flutter (this may take 1-2 minutes)...');
    final buildProcess = await Process.start(
      'flutter',
      ['build', 'apk', '--release', '--android-skip-build-dependency-validation'],
      workingDirectory: appDir.path,
      runInShell: true,
      mode: ProcessStartMode.inheritStdio,
    );

    final exitCode = await buildProcess.exitCode;
    if (exitCode != 0) {
      print('❌ Error: flutter build apk failed with code $exitCode');
      // Revert pubspec.yaml
      pubspecFile.writeAsStringSync(pubspecContent);
      print('↩️ Reverted pubspec.yaml');
      exit(exitCode);
    }

    final builtApk = File('${appDir.path}/build/app/outputs/flutter-apk/app-release.apk');
    if (!builtApk.existsSync()) {
      print('❌ Error: Built APK not found at ${builtApk.path}');
      exit(1);
    }

    builtApk.copySync(targetApkFile.path);
    print('✅ Copied APK to ${targetApkFile.path}');

    final bytes = targetApkFile.readAsBytesSync();
    fileSizeMb = double.parse((bytes.length / (1024 * 1024)).toStringAsFixed(2));
    sha256Hex = sha256.convert(bytes).toString();
  } else {
    print('⚠️  Skipping build (--skip-build requested). Using placeholder checksum & size.');
    sha256Hex = sha256.convert(utf8.encode(newVersionFull)).toString();
  }

  print('📊 APK File Size : $fileSizeMb MB');
  print('🔒 SHA-256 Hash  : $sha256Hex');

  // 5. Update CHANGELOG.md
  final changelogFile = File('${rootDir.path}/CHANGELOG.md');
  final changelogBuffer = StringBuffer();
  changelogBuffer.writeln('## [$newVersion] - $releaseDate\n');
  for (final entry in grouped.entries) {
    if (entry.value.isNotEmpty) {
      changelogBuffer.writeln('### ${entry.key}');
      for (final item in entry.value) {
        changelogBuffer.writeln('- $item');
      }
      changelogBuffer.writeln();
    }
  }

  if (changelogFile.existsSync()) {
    final existingChangelog = changelogFile.readAsStringSync();
    // Insert after standard header
    final headerIndex = existingChangelog.indexOf('---');
    if (headerIndex != -1) {
      final insertPos = headerIndex + 3;
      final newChangelog = existingChangelog.substring(0, insertPos) +
          '\n\n' +
          changelogBuffer.toString().trim() +
          '\n' +
          existingChangelog.substring(insertPos);
      changelogFile.writeAsStringSync(newChangelog);
    } else {
      changelogFile.writeAsStringSync(changelogBuffer.toString() + '\n' + existingChangelog);
    }
  } else {
    changelogFile.writeAsStringSync('# Changelog\n\n' + changelogBuffer.toString());
  }
  print('✅ Prepended $newVersion to CHANGELOG.md');

  // 6. Update releases/releases.json
  final releasesJsonFile = File('${releasesDir.path}/releases.json');
  List<dynamic> releasesList = [];
  if (releasesJsonFile.existsSync()) {
    try {
      releasesList = json.decode(releasesJsonFile.readAsStringSync()) as List<dynamic>;
    } catch (_) {
      releasesList = [];
    }
  }

  final newReleaseEntry = {
    'version': newVersion,
    'buildNumber': build,
    'releaseDate': releaseDate,
    'title': 'Flowra v$newVersion',
    'apkFileName': apkOutputName,
    'fileSizeMb': fileSizeMb,
    'sha256': sha256Hex,
    'downloadUrl':
        'https://github.com/Itzjay169/Flowra/releases/download/v$newVersion/$apkOutputName',
    'githubReleaseUrl': 'https://github.com/Itzjay169/Flowra/releases/tag/v$newVersion',
    'changes': grouped,
  };

  // Prepend new release entry
  releasesList.insert(0, newReleaseEntry);
  final prettyReleasesJson = const JsonEncoder.withIndent('  ').convert(releasesList);
  releasesJsonFile.writeAsStringSync(prettyReleasesJson);
  print('✅ Updated releases/releases.json');

  // Also copy releases.json to website/ directory
  final websiteDir = Directory('${rootDir.path}/website');
  if (!websiteDir.existsSync()) websiteDir.createSync(recursive: true);
  final websiteReleasesFile = File('${websiteDir.path}/releases.json');
  websiteReleasesFile.writeAsStringSync(prettyReleasesJson);
  print('✅ Synced releases.json to website/releases.json');

  // 7. Update README.md (Version History & Latest Version section)
  final readmeFile = File('${rootDir.path}/README.md');
  if (readmeFile.existsSync()) {
    var readmeContent = readmeFile.readAsStringSync();
    final versionSectionBuffer = StringBuffer();
    versionSectionBuffer.writeln('<!-- VERSION_SECTION_START -->');
    versionSectionBuffer.writeln('## 📦 Latest Version & Releases\n');
    versionSectionBuffer.writeln(
        '> **Latest Release**: `v$newVersion` (Build $build) • **Date**: $releaseDate  \n'
        '> 📥 **Direct Download**: [Flowra-v$newVersion.apk](https://github.com/Itzjay169/Flowra/releases/download/v$newVersion/$apkOutputName)  \n'
        '> 🔒 **SHA-256**: `$sha256Hex`\n');
    versionSectionBuffer.writeln('### Version History\n');
    versionSectionBuffer.writeln('| Version | Build | Date | Size | Checksum (SHA-256) | Download |');
    versionSectionBuffer.writeln('|---|---|---|---|---|---|');

    for (final rel in releasesList.take(5)) {
      final v = rel['version'];
      final b = rel['buildNumber'];
      final d = rel['releaseDate'];
      final s = rel['fileSizeMb'];
      final hash = (rel['sha256'] as String).substring(0, 12) + '...';
      final dl = rel['downloadUrl'];
      final file = rel['apkFileName'];
      versionSectionBuffer.writeln('| `v$v` | $b | $d | ${s} MB | `$hash` | [$file]($dl) |');
    }
    versionSectionBuffer.writeln('\n*See [CHANGELOG.md](CHANGELOG.md) and [releases.json](releases/releases.json) for full history.*');
    versionSectionBuffer.writeln('<!-- VERSION_SECTION_END -->');

    final sectionRegex = RegExp(r'<!-- VERSION_SECTION_START -->[\s\S]*?<!-- VERSION_SECTION_END -->');
    if (sectionRegex.hasMatch(readmeContent)) {
      readmeContent = readmeContent.replaceFirst(sectionRegex, versionSectionBuffer.toString().trim());
    } else {
      // Insert after the main blockquote
      final insertTarget = '> All study schedules, tasks, expenses, and budget data remain entirely on your device. The app operates reliably across airplane mode, low-power mode, force-close, and phone restarts.\n';
      if (readmeContent.contains(insertTarget)) {
        readmeContent = readmeContent.replaceFirst(
          insertTarget,
          '$insertTarget\n---\n\n${versionSectionBuffer.toString().trim()}\n',
        );
      } else {
        readmeContent = '${versionSectionBuffer.toString().trim()}\n\n---\n\n$readmeContent';
      }
    }
    readmeFile.writeAsStringSync(readmeContent);
    print('✅ Updated Latest Version section in README.md');
  }

  // 8. Create Git Commit and Tag
  print('\n📝 Creating git commit and tag...');
  Process.runSync('git', [
    'add',
    'app/pubspec.yaml',
    'app/pubspec.lock',
    'CHANGELOG.md',
    'README.md',
    'releases/releases.json',
    'website/releases.json',
  ]);

  final commitMsg = 'chore(release): Flowra v$newVersion (build $build)';
  final commitRes = Process.runSync('git', ['commit', '-m', commitMsg]);
  if (commitRes.exitCode == 0) {
    print('✅ Git commit created: "$commitMsg"');
  } else {
    print('ℹ️  Git commit notice: ${commitRes.stdout.toString().trim()} ${commitRes.stderr.toString().trim()}');
  }

  final tagRes = Process.runSync('git', ['tag', '-a', 'v$newVersion', '-m', 'Flowra release v$newVersion']);
  if (tagRes.exitCode == 0) {
    print('✅ Git tag created: v$newVersion');
  } else {
    print('⚠️  Git tag warning: ${tagRes.stderr.toString().trim()}');
  }

  print('\n🎉 Release v$newVersion completed successfully!');
  print('To publish this release to GitHub, run:');
  print('   git push origin main --tags');
  print('====================================================\n');
}
