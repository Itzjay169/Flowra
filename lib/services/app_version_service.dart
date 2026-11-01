/// Service providing application version and build number from PackageInfo.
library;

import 'package:package_info_plus/package_info_plus.dart';

class AppVersionService {
  AppVersionService._();

  static PackageInfo? _cachedInfo;

  /// Allows setting or mocking PackageInfo in tests or during startup.
  static void setMockInfo(PackageInfo info) {
    _cachedInfo = info;
  }

  /// Initialize early (e.g., in main.dart).
  static Future<PackageInfo> initialize() async {
    try {
      _cachedInfo = await PackageInfo.fromPlatform();
    } catch (_) {
      _cachedInfo = PackageInfo(
        appName: 'Flowra',
        packageName: 'com.flowra.flowra',
        version: '1.1.0',
        buildNumber: '2',
      );
    }
    return _cachedInfo!;
  }

  /// Returns cached or newly loaded PackageInfo.
  static Future<PackageInfo> get packageInfo async {
    if (_cachedInfo != null) return _cachedInfo!;
    return initialize();
  }

  /// Returns synchronous formatted version if cached, or fallback string.
  static String get currentVersionString {
    final info = _cachedInfo;
    if (info == null) return 'Version 1.1.0 (build 2)';
    final build = info.buildNumber.isNotEmpty ? ' (build ${info.buildNumber})' : '';
    return 'Version ${info.version}$build';
  }

  /// Returns formatted "Version x.y.z (build N)"
  static Future<String> getFullVersionString() async {
    final info = await packageInfo;
    final build = info.buildNumber.isNotEmpty ? ' (build ${info.buildNumber})' : '';
    return 'Version ${info.version}$build';
  }

  /// Returns "v{version} (build {buildNumber})"
  static Future<String> getShortVersionString() async {
    final info = await packageInfo;
    final build = info.buildNumber.isNotEmpty ? ' (build ${info.buildNumber})' : '';
    return 'v${info.version}$build';
  }
}
