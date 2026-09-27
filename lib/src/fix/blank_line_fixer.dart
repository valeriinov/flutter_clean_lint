import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
// ignore: implementation_imports
import 'package:analyzer/src/ignore_comments/ignore_info.dart';
// ignore: implementation_imports
import 'package:analyzer/src/string_source.dart';

import '../plugin_name.dart';
import '../rules/insert_line_between_sections.dart';
import '../rules/section_spacing_visitor.dart';

/// Rewrites blank lines so that `insert_line_between_sections` reports
/// nothing it can be satisfied on without moving code or comments.
abstract final class BlankLineFixer {
  /// Returns [content] with every violation gap found in [unit] brought to
  /// its expected number of blank lines.
  ///
  /// Only whitespace-only lines are removed or inserted. A gap between tokens
  /// on the same line, or one expecting a blank line while holding text, is
  /// left as is, and so is a violation that an `ignore` or `ignore_for_file`
  /// comment suppresses.
  static String fix(String content, CompilationUnit unit) {
    final gaps = <(int, int), BlankLineGap>{};
    final ignoreInfo = IgnoreInfo.forDart(unit, content);
    final source = StringSource(content, null);

    unit.visitChildren(
      SectionSpacingVisitor(unit.lineInfo, (violation) {
        if (_isIgnored(ignoreInfo, source, violation)) {
          return;
        }

        for (final gap in violation.gaps) {
          gaps.putIfAbsent((gap.prevLine, gap.nextLine), () => gap);
        }
      }),
    );

    final lineEnding = content.contains('\r\n') ? '\r\n' : '\n';
    final lines = content.split(lineEnding);
    final sortedGaps = gaps.values.toList()
      ..sort((a, b) => b.prevLine.compareTo(a.prevLine));

    for (final gap in sortedGaps) {
      _applyGap(lines, gap);
    }

    return lines.join(lineEnding);
  }

  static bool _isIgnored(
    IgnoreInfo ignoreInfo,
    StringSource source,
    BlankLineViolation violation,
  ) {
    final diagnostic = Diagnostic.tmp(
      source: source,
      offset: violation.token.offset,
      length: violation.token.length,
      diagnosticCode: InsertLineBetweenSections.code,
    );

    return ignoreInfo.ignored(diagnostic, pluginName: pluginName);
  }

  static void _applyGap(List<String> lines, BlankLineGap gap) {
    if (gap.nextLine <= gap.prevLine) {
      return;
    }

    // Line numbers are 1-based, so the lines strictly between the two start
    // at index prevLine and end before index nextLine - 1.
    final start = gap.prevLine;
    final end = gap.nextLine - 1;
    final between = lines.sublist(start, end);
    final textLines = between.where(_hasText).toList();

    if (gap.expectedBlankLines == 0) {
      lines.replaceRange(start, end, textLines);

      return;
    }

    if (textLines.isNotEmpty) {
      return;
    }

    lines.replaceRange(start, end, List.filled(gap.expectedBlankLines, ''));
  }

  static bool _hasText(String line) {
    return line.trim().isNotEmpty;
  }
}
