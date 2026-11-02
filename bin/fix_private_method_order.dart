import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:flutter_clean_lint/src/fix/private_method_order_fixer.dart';

/// Orders the private methods by their latest usage in the Dart files under
/// the given paths and prints every file it changed.
Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) {
    stderr.writeln(
      'Usage: dart run flutter_clean_lint:fix_private_method_order <path>...',
    );
    exitCode = 64;

    return;
  }

  final missingPaths = arguments.where(_isMissing).toList();

  if (missingPaths.isNotEmpty) {
    for (final path in missingPaths) {
      stderr.writeln('Path not found: $path');
    }
    exitCode = 64;

    return;
  }

  final pathContext = PhysicalResourceProvider.INSTANCE.pathContext;
  final includedPaths = [
    for (final path in arguments)
      pathContext.normalize(pathContext.absolute(path)),
  ];
  final collection = AnalysisContextCollection(includedPaths: includedPaths);

  for (final context in collection.contexts) {
    for (final path in context.contextRoot.analyzedFiles()) {
      if (!path.endsWith('.dart')) {
        continue;
      }

      final result = await context.currentSession.getResolvedUnit(path);

      if (result is! ResolvedUnitResult) {
        continue;
      }

      final fixed = PrivateMethodOrderFixer.fix(result.content, result.unit);

      if (fixed == result.content) {
        continue;
      }

      File(path).writeAsStringSync(fixed);
      stdout.writeln(path);
    }
  }
}

bool _isMissing(String path) {
  return FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound;
}
