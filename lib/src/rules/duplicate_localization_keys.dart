import 'dart:io';

import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils/localization_utils.dart';

/// Alerts when keys are duplicated in the same ARB file.
class DuplicateLocalizationKeys extends LintRule {
  const DuplicateLocalizationKeys() : super(code: _code);

  static const _code = LintCode(
    name: 'duplicate_localization_keys',
    problemMessage: 'The key "{0}" is duplicated.',
  );

  @override
  List<String> get filesToAnalyze => LocalizationUtils.filesToAnalyze;

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    final src = File(resolver.path).readAsStringSync();
    final occurrences = _topLevelKeyOffsets(src);

    for (final entry in occurrences.entries) {
      if (entry.value.length < 2) continue; // no duplicates

      // Highlight every occurrence after the first one
      for (final offset in entry.value.skip(1)) {
        reporter.atOffset(
          offset: offset,
          length: entry.key.length + 2, // +2 for the quotes
          diagnosticCode: _code,
          arguments: [entry.key],
        );
      }
    }
  }

  /// Returns offsets for **top-level** keys, ignoring nested objects
  /// (e.g. placeholder metadata that starts with `@` or inner maps).
  Map<String, List<int>> _topLevelKeyOffsets(String src) {
    final map = <String, List<int>>{};
    final regex = RegExp(r'"(?<key>[^"]+)"\s*:');

    int? baseIndent; // indent of the first real key

    for (final match in regex.allMatches(src)) {
      final key = match.namedGroup('key');

      if (key == null || !LocalizationUtils.isRealKey(key)) continue;

      final lineStart = src.lastIndexOf('\n', match.start) + 1;
      final indent = match.start - lineStart;

      baseIndent ??= indent; // remember indent of the first key

      if (indent != baseIndent) continue; // skip nested keys

      map.putIfAbsent(key, () => []).add(match.start);
    }

    return map;
  }
}
