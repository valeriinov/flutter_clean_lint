import 'dart:convert';
import 'dart:io';

abstract final class LocalizationUtils {
  static List<String> get filesToAnalyze => const ['lib/l10n/*.arb'];

  static bool isArbFile(FileSystemEntity e) => e.path.endsWith('.arb');

  static Set<String> readKeys(String path) {
    final raw = File(path).readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return json.keys.toSet();
  }

  static bool isRealKey(String key) => !key.startsWith('@');
}
