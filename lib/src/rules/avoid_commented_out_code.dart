import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lints commented-out Dart code.
class AvoidCommentedOutCode extends DartLintRule {
  const AvoidCommentedOutCode()
      : super(
          code: const LintCode(
            name: 'avoid_commented_out_code',
            problemMessage: 'Avoid keeping commented-out code. '
                'Use version control to restore when needed.',
          ),
        );

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) async {
    final unit = (await resolver.getResolvedUnitResult()).unit;

    for (final comment in _allComments(unit)) {
      if (_isCodeComment(comment.lexeme)) {
        // ignore: deprecated_member_use
        reporter.reportErrorForOffset(
          code,
          comment.offset,
          comment.length,
        );
      }
    }
  }

  Iterable<Token> _allComments(CompilationUnit unit) sync* {
    for (Token t = unit.beginToken;; t = t.next!) {
      // comments "attached" to the current token
      for (Token? c = t.precedingComments; c != null; c = c.next) {
        yield c;
      }
      // exit the loop after processing EOF
      if (t.isEof) break;
    }
  }

  bool _isCodeComment(String raw) {
    final text = raw.trim().replaceAll('\n', ' ');

    return !_isDoc(text) && !_hasSkipPrefix(text) && _matches(text);
  }

  bool _isDoc(String t) => t.startsWith('///') || t.startsWith('/**');

  bool _hasSkipPrefix(String t) {
    const prefixes = _Patterns.skipPrefixes;

    return prefixes.any(
      (s) =>
          t.toUpperCase().startsWith('// $s:') ||
          t.toUpperCase().startsWith('/* $s:'),
    );
  }

  bool _matches(String t) {
    const patterns = _Patterns.codePatterns;

    for (final pattern in patterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(t)) return true;
    }

    return false;
  }
}

abstract final class _Patterns {
  static const List<String> skipPrefixes = [
    'NOTE',
    'TODO',
    'TRY THIS',
    'EXAMPLE',
    'EXPLANATION',
    'INFO',
    'WARNING',
    'DEBUG',
    'SEE',
    'REF',
    'USAGE',
    'IMPORTANT',
    'FIXME',
    'HACK',
    // Testing helpers
    'EXPECT_LINT',
    'NO_LINT',
  ];

  static const List<String> codePatterns = [
    // Function definition: void foo() {
    r'\bvoid\s+\w+\s*\([^)]*\)\s*\{',
    // Class definition: class MyClass { or class MyClass extends Base {
    r'\bclass\b[^\{]*\{',
    // Import statement: import 'package:foo/foo.dart'
    r'''\bimport\s+['\"]''',
    // Export statement: export 'foo.dart'
    r'''\bexport\s+['\"]''',
    // Part directive: part 'foo.g.dart'
    r'''\bpart\s+['\"]''',

    // Named/positional parameter: // label: value,
    r'^(?:/\*|//)\s*\w+\s*:\s*.+[,)]?\s*(?:\*/)?$',

    // Stand-alone function/method/constructor call: // foo(...);
    // Allows an optional "const" prefix and multi-line invocations.
    r'^(?:/\*|//)\s*(?:const\s+)?(?!if\b)(?!for\b)(?!while\b)\w+(?:\.\w+)*\s*\([^)]*\)?.*',

    // if / for / while blocks: // if (...) {  , // for (...) {
    r'^(?:/\*|//)\s*if\s*\([^)]*\)\s*\{\s*(?:\*/)?$',
    r'^(?:/\*|//)\s*for\s*\([^)]*\)\s*\{\s*(?:\*/)?$',
    r'^(?:/\*|//)\s*while\s*\([^)]*\)\s*\{\s*(?:\*/)?$',

    // Simple assignment: // x = 5;
    r'^(?:/\*|//)\s*\w+\s*=\s*[^;]+;\s*(?:\*/)?$',

    // Return statement: // return value; or // return;
    r'^(?:/\*|//)\s*return(?:\s+[^;]+)?;\s*(?:\*/)?$',

    // Annotation: // @override
    r'^(?:/\*|//)\s*@\w+',

    // Variable declaration without init: // int counter;
    r'^(?:/\*|//)\s*(?:int|double|num|bool|String|var|final|dynamic|[A-Z]\w*)\s+\w+\s*;\s*(?:\*/)?$',
    // Variable declaration with init: // final x = 2;
    r'^(?:/\*|//)\s*(?:int|double|num|bool|String|var|final|dynamic|[A-Z]\w*)\s+\w+\s*=.*;\s*(?:\*/)?$',
  ];
}
