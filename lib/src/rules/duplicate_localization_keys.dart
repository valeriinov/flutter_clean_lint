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
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final src = File(resolver.path).readAsStringSync();
    final occurrences = _keyOffsets(src);

    for (final entry in occurrences.entries) {
      if (entry.value.length < 2) continue; // no duplicates

      for (final offset in entry.value.skip(1)) {
        reporter.atOffset(
          offset: offset,
          length: entry.key.length + 2,
          errorCode: _code,
          arguments: [entry.key],
        );
      }
    }
  }

  Map<String, List<int>> _keyOffsets(String src) {
    final map = <String, List<int>>{};
    final regex = RegExp(r'"(?<key>[^"]+)"\s*:');

    for (final match in regex.allMatches(src)) {
      final key = match.namedGroup('key');

      if (key == null || !LocalizationUtils.isRealKey(key)) continue;

      map.putIfAbsent(key, () => []).add(match.start);
    }

    return map;
  }
}
