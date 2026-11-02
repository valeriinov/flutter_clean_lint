import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/source/line_info.dart';
// ignore: implementation_imports
import 'package:analyzer/src/ignore_comments/ignore_info.dart';
// ignore: implementation_imports
import 'package:analyzer/src/string_source.dart';

import '../plugin_name.dart';
import '../rules/order_private_methods_by_usage.dart';
import '../rules/private_method_order.dart';

/// Rewrites the order of private methods so that
/// `order_private_methods_by_usage` reports nothing.
abstract final class PrivateMethodOrderFixer {
  /// Returns [content] with the private methods of every class, mixin,
  /// extension, extension type and enum in [unit] placed in the order of their
  /// latest usage.
  ///
  /// The [unit] must be resolved. Each private method moves with the comments
  /// and annotations above it and the comment at the end of its last line. A
  /// comment on the line of the previous token, or one separated from the
  /// method by a blank line, stays in place. Other members do not move. A
  /// declaration with a violation that an `ignore` or `ignore_for_file`
  /// comment suppresses is left as is.
  static String fix(String content, CompilationUnit unit) {
    final ignoreInfo = IgnoreInfo.forDart(unit, content);
    final source = StringSource(content, null);
    final replacements = <_Replacement>[];

    for (final declaration in unit.declarations) {
      replacements.addAll(
        _replacementsFor(declaration, content, unit.lineInfo, (method) {
          return _isIgnored(ignoreInfo, source, method);
        }),
      );
    }

    replacements.sort((a, b) => b.start.compareTo(a.start));

    String fixed = content;

    for (final replacement in replacements) {
      fixed = fixed.replaceRange(
        replacement.start,
        replacement.end,
        replacement.text,
      );
    }

    return fixed;
  }

  static List<_Replacement> _replacementsFor(
    CompilationUnitMember declaration,
    String content,
    LineInfo lineInfo,
    bool Function(MisplacedPrivateMethod) isIgnored,
  ) {
    final methods = collectPrivateMethods(declaration);
    final misplaced = misplacedPrivateMethods(methods);

    if (misplaced.isEmpty || misplaced.any(isIgnored)) {
      return const [];
    }

    final ordered = orderedPrivateMethods(methods);

    return [
      for (int index = 0; index < methods.length; index++)
        _Replacement(
          start: _startOf(methods[index].node, lineInfo),
          end: _endOf(methods[index].node, lineInfo),
          text: _textOf(ordered[index].node, content, lineInfo),
        ),
    ];
  }

  static bool _isIgnored(
    IgnoreInfo ignoreInfo,
    StringSource source,
    MisplacedPrivateMethod misplaced,
  ) {
    final token = misplaced.method.node.name;
    final diagnostic = Diagnostic.tmp(
      source: source,
      offset: token.offset,
      length: token.length,
      diagnosticCode: OrderPrivateMethodsByUsage.code,
      arguments: [misplaced.method.name, ''],
    );

    return ignoreInfo.ignored(diagnostic, pluginName: pluginName);
  }

  static String _textOf(
    MethodDeclaration node,
    String content,
    LineInfo lineInfo,
  ) {
    return content.substring(_startOf(node, lineInfo), _endOf(node, lineInfo));
  }

  static int _startOf(MethodDeclaration node, LineInfo lineInfo) {
    final first =
        node.metadata.firstOrNull?.beginToken ??
        node.firstTokenAfterCommentAndMetadata;
    int start = node.offset;
    int nextLine = _lineOf(lineInfo, start);

    for (final comment in _commentsOf(first).reversed) {
      if (_lineOf(lineInfo, comment.end) < nextLine - 1) {
        break;
      }

      if (!_startsOwnLine(comment, first, lineInfo)) {
        break;
      }

      start = comment.offset < start ? comment.offset : start;
      nextLine = _lineOf(lineInfo, comment.offset);
    }

    return start;
  }

  static List<Token> _commentsOf(Token first) {
    final comments = <Token>[];

    for (
      Token? comment = first.precedingComments;
      comment != null;
      comment = comment.next
    ) {
      comments.add(comment);
    }

    return comments;
  }

  static bool _startsOwnLine(Token comment, Token first, LineInfo lineInfo) {
    final previous = first.previous;

    if (previous == null || previous == first) {
      return true;
    }

    return _lineOf(lineInfo, comment.offset) > _lineOf(lineInfo, previous.end);
  }

  static int _endOf(MethodDeclaration node, LineInfo lineInfo) {
    final trailing = node.endToken.next?.precedingComments;

    if (trailing == null ||
        _lineOf(lineInfo, trailing.offset) != _lineOf(lineInfo, node.end)) {
      return node.end;
    }

    return trailing.end;
  }

  static int _lineOf(LineInfo lineInfo, int offset) {
    return lineInfo.getLocation(offset).lineNumber;
  }
}

class _Replacement {
  final int start;
  final int end;
  final String text;

  const _Replacement({
    required this.start,
    required this.end,
    required this.text,
  });
}
