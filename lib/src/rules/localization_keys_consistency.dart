import 'dart:io';

import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:path/path.dart' as p;

import '../utils/localization_utils.dart';

/// Ensures that every key is present in all ARB files.
class LocalizationKeysConsistency extends LintRule {
  const LocalizationKeysConsistency() : super(code: _code);

  static const _code = LintCode(
    name: 'localization_keys_consistency',
    problemMessage: 'Key "{0}" is missing in the following files: {1}.',
  );

  @override
  List<String> get filesToAnalyze => LocalizationUtils.filesToAnalyze;

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    final dir = Directory(p.dirname(resolver.path));
    final arbFiles = dir.listSync().where(LocalizationUtils.isArbFile);

    final fileToKeys = {
      for (final file in arbFiles)
        file.path: LocalizationUtils.readKeys(file.path)
    };

    final currentPath = resolver.path;
    final currentKeys = fileToKeys[currentPath]!;

    for (final key in currentKeys.where(LocalizationUtils.isRealKey)) {
      final missing = fileToKeys.entries
          .where((e) => !e.value.contains(key))
          .map((e) => p.basename(e.key))
          .toList();

      if (missing.isEmpty) continue;

      final offset = File(currentPath).readAsStringSync().indexOf('"$key"');

      reporter.atOffset(
        offset: offset == -1 ? 0 : offset,
        length: key.length + 2, // +2 for the quotes
        diagnosticCode: _code,
        arguments: [key, missing.join(', ')],
      );
    }
  }
}
