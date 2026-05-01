import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';

const _lintMarker = '// expect_lint:';

Future<void> assertDiagnosticsFromMarkers(
  AnalysisRuleTest test,
  String source,
) async {
  final expected = [
    for (final marker in _expectedLints(source))
      test.lint(marker.offset, marker.length),
  ];

  await test.assertDiagnostics(source, expected);
}

List<_ExpectedLint> _expectedLints(String source) {
  final lints = <_ExpectedLint>[];
  int searchStart = 0;

  while (searchStart < source.length) {
    final markerOffset = source.indexOf(_lintMarker, searchStart);

    if (markerOffset == -1) return lints;

    final targetOffset = _nextCodeOffset(
      source,
      _nextLineStart(source, markerOffset),
    );

    if (targetOffset == null) return lints;

    lints.add(
      _ExpectedLint(
        offset: targetOffset,
        length: _diagnosticLength(source, targetOffset),
      ),
    );

    searchStart = targetOffset;
  }

  return lints;
}

int? _nextCodeOffset(String source, int lineStart) {
  int currentLineStart = lineStart;

  while (currentLineStart < source.length) {
    final currentLineEnd = _lineEnd(source, currentLineStart);
    final line = source.substring(currentLineStart, currentLineEnd);
    final trimmedLine = line.trimLeft();

    if (trimmedLine.isNotEmpty) {
      return currentLineStart + line.length - trimmedLine.length;
    }

    currentLineStart = currentLineEnd + 1;
  }

  return null;
}

int _diagnosticLength(String source, int offset) {
  if (source.startsWith('//', offset)) {
    return _lineEnd(source, offset) - offset;
  }

  if (source.startsWith('/*', offset)) {
    final blockEnd = source.indexOf('*/', offset + 2);

    if (blockEnd == -1) return source.length - offset;

    return blockEnd + 2 - offset;
  }

  final tokenMatch = RegExp(
    r'''[A-Za-z_$][A-Za-z0-9_$]*|\.\.|[0-9]+|'[^']*'|"[^"]*"|[{}]''',
  ).matchAsPrefix(source.substring(offset));

  final token = tokenMatch?.group(0);

  if (token == null) return 1;

  return token.length;
}

int _nextLineStart(String source, int offset) {
  final lineEnd = _lineEnd(source, offset);

  if (lineEnd == source.length) return source.length;

  return lineEnd + 1;
}

int _lineEnd(String source, int offset) {
  final lineEnd = source.indexOf('\n', offset);

  if (lineEnd == -1) return source.length;

  return lineEnd;
}

class _ExpectedLint {
  final int offset;
  final int length;

  const _ExpectedLint({required this.offset, required this.length});
}
