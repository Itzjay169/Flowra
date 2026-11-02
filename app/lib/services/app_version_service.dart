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
        version: '1.2.0',
        buildNumber: '3',
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
  /// Shows clean version name only (e.g. "Version 1.2.0"), never with build numbers in parentheses.
  static String get currentVersionString {
    final info = _cachedInfo;
    if (info == null) return 'Version 1.2.0';
    return 'Version ${info.version}';
  }

  /// Returns formatted "Version x.y.z"
  static Future<String> getFullVersionString() async {
    final info = await packageInfo;
    return 'Version ${info.version}';
  }

  /// Returns "v{version}"
  static Future<String> getShortVersionString() async {
    final info = await packageInfo;
    return 'v${info.version}';
  }

  /// Internal build number for release tracking/diagnostics only
  static Future<String> getInternalBuildNumber() async {
    final info = await packageInfo;
    return info.buildNumber;
  }
}
