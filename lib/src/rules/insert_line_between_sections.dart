import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Ensures there is exactly one blank line between statements inside function bodies.
class InsertLineBetweenSections extends DartLintRule {
  const InsertLineBetweenSections()
      : super(
          code: const LintCode(
            name: 'insert_line_between_sections',
            problemMessage: 'Insert a single blank line between code sections.',
          ),
        );

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) async {
    final result = await resolver.getResolvedUnitResult();
    final lineInfo = result.lineInfo;
    result.unit.visitChildren(_Visitor(reporter, code, lineInfo));
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final ErrorReporter _reporter;
  final LintCode _code;
  final LineInfo _lines;

  _Visitor(this._reporter, this._code, this._lines);

  @override
  void visitBlock(Block node) {
    _checkStatements(node.statements, node.leftBracket, node.rightBracket);
    super.visitBlock(node);
  }

  @override
  void visitSwitchCase(SwitchCase node) =>
      _handleSwitchMember(node, () => super.visitSwitchCase(node));

  @override
  void visitSwitchDefault(SwitchDefault node) =>
      _handleSwitchMember(node, () => super.visitSwitchDefault(node));

  // Dart 3 pattern-matching `switch`
  @override
  void visitSwitchPatternCase(SwitchPatternCase node) =>
      _handleSwitchMember(node, () => super.visitSwitchPatternCase(node));

  @override
  void visitIfStatement(IfStatement node) {
    super.visitIfStatement(node);
    final elseKeyword = node.elseKeyword;
    if (elseKeyword != null) {
      final thenEndLine =
          _lines.getLocation(node.thenStatement.endToken.end).lineNumber;
      var firstLine = _lines.getLocation(elseKeyword.offset).lineNumber;
      for (Token? comment = elseKeyword.precedingComments;
          comment != null;
          comment = comment.next) {
        final commentLine = _lines.getLocation(comment.offset).lineNumber;
        if (commentLine < firstLine) {
          firstLine = commentLine;
        }
      }

      final blankLinesBeforeElse = firstLine - thenEndLine - 1;
      if (blankLinesBeforeElse > 0) {
        _reporter.atToken(elseKeyword, _code);
      }
    }
  }

  @override
  void visitCascadeExpression(CascadeExpression node) {
    if (node.cascadeSections.isNotEmpty) {
      _checkNodes(node.cascadeSections, node.target.endToken);
    }
    super.visitCascadeExpression(node);
  }

  @override
  void visitListLiteral(ListLiteral node) {
    _checkNodes(node.elements, node.leftBracket);
    super.visitListLiteral(node);
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    _checkNodes(node.elements, node.leftBracket);
    super.visitSetOrMapLiteral(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    final prevLine =
        _lines.getLocation(node.leftOperand.endToken.end).lineNumber;
    final token = node.rightOperand.beginToken;
    var firstLine = _lines.getLocation(token.offset).lineNumber;
    final hasComment = token.precedingComments != null;
    var lastCommentLine = firstLine;
    for (Token? comment = token.precedingComments;
        comment != null;
        comment = comment.next) {
      final commentLine = _lines.getLocation(comment.offset).lineNumber;
      if (commentLine < firstLine) {
        firstLine = commentLine;
      }
      lastCommentLine = _lines.getLocation(comment.end).lineNumber;
    }

    final blankLinesBefore = firstLine - prevLine - 1;
    final blankLinesAfter = hasComment
        ? _lines.getLocation(token.offset).lineNumber - lastCommentLine - 1
        : 0;

    if (blankLinesBefore > 0 || (hasComment && blankLinesAfter > 0)) {
      _reporter.atToken(token, _code);
    }
    super.visitBinaryExpression(node);
  }

  void _handleSwitchMember(
    /* SwitchCase | SwitchDefault | SwitchPatternCase */
    dynamic node,
    void Function() superCall,
  ) {
    _checkStatements(node.statements, node.colon, null);
    superCall();
  }

  void _checkStatements(
    NodeList<Statement> statements,
    Token? start,
    Token? end,
  ) {
    var prevLine =
        start != null ? _lines.getLocation(start.end).lineNumber : null;
    Statement? previous;

    for (final current in statements) {
      final statementLine =
          _lines.getLocation(current.beginToken.offset).lineNumber;
      var firstLine = statementLine;
      final hasComment = current.beginToken.precedingComments != null;
      var lastCommentLine = statementLine;
      for (Token? comment = current.beginToken.precedingComments;
          comment != null;
          comment = comment.next) {
        final commentLine = _lines.getLocation(comment.offset).lineNumber;
        if (commentLine < firstLine) {
          firstLine = commentLine;
        }
        lastCommentLine = _lines.getLocation(comment.end).lineNumber;
      }

      final previousLine =
          prevLine ?? _lines.getLocation(current.beginToken.offset).lineNumber;
      final blankLinesBefore = firstLine - previousLine - 1;
      final blankLinesAfter =
          hasComment ? statementLine - lastCommentLine - 1 : 0;

      final sameDeclarationGroup = previous is VariableDeclarationStatement &&
          current is VariableDeclarationStatement &&
          blankLinesBefore == 0 &&
          !hasComment;
      final sameAssertGroup = previous is AssertStatement &&
          current is AssertStatement &&
          blankLinesBefore == 0 &&
          !hasComment;
      final sameYieldGroup = previous is YieldStatement &&
          current is YieldStatement &&
          blankLinesBefore == 0 &&
          !hasComment;
      final sameBreakGroup = previous is Statement &&
          current is BreakStatement &&
          blankLinesBefore == 0 &&
          !hasComment;
      final sameContinueGroup = previous is Statement &&
          current is ContinueStatement &&
          blankLinesBefore == 0 &&
          !hasComment;
      final sameInvocationGroup = previous is ExpressionStatement &&
          current is ExpressionStatement &&
          previous.expression is InvocationExpression &&
          current.expression is InvocationExpression &&
          blankLinesBefore == 0 &&
          !hasComment;
      final sameAwaitGroup = previous is ExpressionStatement &&
          current is ExpressionStatement &&
          previous.expression is AwaitExpression &&
          current.expression is AwaitExpression &&
          blankLinesBefore == 0 &&
          !hasComment;

      final isFirst = previous == null;
      if (isFirst) {
        if (blankLinesBefore > 0) {
          _reporter.atToken(current.beginToken, _code);
        } else if (hasComment && blankLinesAfter != 1) {
          _reporter.atToken(current.beginToken, _code);
        }
      } else if (!sameDeclarationGroup &&
          !sameAssertGroup &&
          !sameYieldGroup &&
          !sameBreakGroup &&
          !sameContinueGroup &&
          !sameInvocationGroup &&
          !sameAwaitGroup &&
          (blankLinesBefore != 1 || (hasComment && blankLinesAfter != 1))) {
        _reporter.atToken(current.beginToken, _code);
      }

      prevLine = _lines.getLocation(current.endToken.end).lineNumber;
      previous = current;
    }

    if (end != null && prevLine != null) {
      final closingLine = _lines.getLocation(end.offset).lineNumber;
      final blankLinesAfterLast = closingLine - prevLine! - 1;
      if (blankLinesAfterLast > 0) {
        _reporter.atToken(end, _code);
      }
    }
  }

  void _checkNodes(
    NodeList<AstNode> nodes,
    Token start,
  ) {
    var prevLine = _lines.getLocation(start.end).lineNumber;
    for (final node in nodes) {
      final token = node.beginToken;
      var firstLine = _lines.getLocation(token.offset).lineNumber;
      final hasComment = token.precedingComments != null;
      var lastCommentLine = firstLine;
      for (Token? comment = token.precedingComments;
          comment != null;
          comment = comment.next) {
        final commentLine = _lines.getLocation(comment.offset).lineNumber;
        if (commentLine < firstLine) {
          firstLine = commentLine;
        }
        lastCommentLine = _lines.getLocation(comment.end).lineNumber;
      }

      final blankLinesBefore = firstLine - prevLine - 1;
      final blankLinesAfter = hasComment
          ? _lines.getLocation(token.offset).lineNumber - lastCommentLine - 1
          : 0;

      if (blankLinesBefore > 0 || (hasComment && blankLinesAfter > 0)) {
        _reporter.atToken(token, _code);
      }

      prevLine = _lines.getLocation(node.endToken.end).lineNumber;
    }
  }
}
