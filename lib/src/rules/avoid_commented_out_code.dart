import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Lints commented-out Dart code.
class AvoidCommentedOutCode extends AnalysisRule {
  static const _name = 'avoid_commented_out_code';
  static const _description =
      'Avoid keeping commented-out code. '
      'Use version control to restore when needed.';
  static const code = LintCode(_name, _description);

  AvoidCommentedOutCode() : super(name: _name, description: _description);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidCommentedOutCode _rule;

  _Visitor(this._rule);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    for (final comment in _allComments(node)) {
      if (_isCodeComment(comment.lexeme)) {
        _rule.reportAtOffset(comment.offset, comment.length);
      }
    }
  }

  Iterable<Token> _allComments(CompilationUnit unit) sync* {
    Token? t = unit.beginToken;

    while (t != null) {
      // comments "attached" to the current token
      for (Token? c = t.precedingComments; c != null; c = c.next) {
        yield c;
      }
      // exit the loop after processing EOF
      if (t.isEof) return;

      t = t.next;
    }
  }

  bool _isCodeComment(String raw) {
    final text = raw.trim().replaceAll('\n', ' ');

    return !_isDoc(text) && !_hasSkipPrefix(text) && _matches(text);
  }

  bool _isDoc(String t) => t.startsWith('///') || t.startsWith('/**');

  bool _hasSkipPrefix(String t) {
    final pattern =
        '^(?:/\\*|//)\\s*(?:${_Patterns.skipPrefixes.join('|')})\\b';

    return RegExp(pattern, caseSensitive: false).hasMatch(t);
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
    'REASON',
    'IGNORE',
    'IGNORE_FOR_FILE',
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
    r'^(?:/\*|//)\s*\w+\s*:\s+.+[,)]?\s*(?:\*/)?$',

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
