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
    _validateStatements(node.statements, node.leftBracket, node.rightBracket);
    super.visitBlock(node);
  }

  @override
  void visitSwitchCase(SwitchCase node) {
    _handleSwitchMember(node, () => super.visitSwitchCase(node));
  }

  @override
  void visitSwitchDefault(SwitchDefault node) {
    _handleSwitchMember(node, () => super.visitSwitchDefault(node));
  }

  // Dart 3 pattern-matching `switch`
  @override
  void visitSwitchPatternCase(SwitchPatternCase node) {
    _handleSwitchMember(node, () => super.visitSwitchPatternCase(node));
  }

  @override
  void visitIfStatement(IfStatement node) {
    super.visitIfStatement(node);
    _validateIfStatement(node);
  }

  @override
  void visitCascadeExpression(CascadeExpression node) {
    if (node.cascadeSections.isNotEmpty) {
      _validateNodes(node.cascadeSections, node.target.endToken);
    }
    super.visitCascadeExpression(node);
  }

  @override
  void visitListLiteral(ListLiteral node) {
    _validateNodes(node.elements, node.leftBracket);
    super.visitListLiteral(node);
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    _validateNodes(node.elements, node.leftBracket);
    super.visitSetOrMapLiteral(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    _validateBinaryExpression(node);
    super.visitBinaryExpression(node);
  }

  void _handleSwitchMember(
    /* SwitchCase | SwitchDefault | SwitchPatternCase */
    dynamic node,
    void Function() superCall,
  ) {
    _validateStatements(node.statements, node.colon, null);
    superCall();
  }

  void _validateStatements(
    NodeList<Statement> statements,
    Token? start,
    Token? end,
  ) {
    int? prevLine = start != null ? _lineAfter(start) : null;
    Statement? prevStatement;

    for (final current in statements) {
      final info = _statementInfo(current, prevLine);

      if (_shouldReport(prevStatement, info)) {
        _reporter.atToken(current.beginToken, _code);
      }

      prevLine = _lineAfter(current.endToken);
      prevStatement = current;
    }

    if (_hasTrailingBlank(prevLine, end)) {
      _reporter.atToken(end!, _code);
    }
  }

  bool _hasTrailingBlank(int? prevLine, Token? end) {
    return end != null &&
        prevLine != null &&
        _lineOf(end.offset) - prevLine - 1 > 0;
  }

  int _lineAfter(Token token) {
    return _lineOf(token.end);
  }

  _StatementInfo _statementInfo(Statement node, int? prevLine) {
    final token = node.beginToken;
    final (firstLine, lastLine, hasComment) = _commentInfo(token);
    final currentLine = _lineOf(token.offset);

    final blankBefore = firstLine - (prevLine ?? firstLine) - 1;
    final blankAfter = hasComment ? currentLine - lastLine - 1 : 0;

    return _StatementInfo(
      current: node,
      blankBefore: blankBefore,
      blankAfter: blankAfter,
      hasComment: hasComment,
    );
  }

  bool _shouldReport(Statement? prev, _StatementInfo info) {
    if (prev == null) {
      return info.blankBefore > 0 || (info.hasComment && info.blankAfter != 1);
    }

    if (_isSameGroup(prev, info.current, info.blankBefore, info.hasComment)) {
      return false;
    }

    return info.blankBefore != 1 || (info.hasComment && info.blankAfter != 1);
  }

  bool _isSameGroup(
    Statement prev,
    Statement curr,
    int blanks,
    bool hasComment,
  ) {
    if (blanks != 0 || hasComment) {
      return false;
    }

    return _sameDeclaration(prev, curr) ||
        _sameAssert(prev, curr) ||
        _sameYield(prev, curr) ||
        _isCurrBreak(curr) ||
        _isCurrContinue(curr) ||
        _sameInvocation(prev, curr) ||
        _sameAwait(prev, curr);
  }

  bool _sameDeclaration(Statement prev, Statement curr) {
    return prev is VariableDeclarationStatement &&
        curr is VariableDeclarationStatement;
  }

  bool _sameAssert(Statement prev, Statement curr) {
    return prev is AssertStatement && curr is AssertStatement;
  }

  bool _sameYield(Statement prev, Statement curr) {
    return prev is YieldStatement && curr is YieldStatement;
  }

  bool _isCurrBreak(Statement curr) {
    return curr is BreakStatement;
  }

  bool _isCurrContinue(Statement curr) {
    return curr is ContinueStatement;
  }

  bool _sameInvocation(Statement prev, Statement curr) {
    return prev is ExpressionStatement &&
        curr is ExpressionStatement &&
        prev.expression is InvocationExpression &&
        curr.expression is InvocationExpression;
  }

  bool _sameAwait(Statement prev, Statement curr) {
    return prev is ExpressionStatement &&
        curr is ExpressionStatement &&
        prev.expression is AwaitExpression &&
        curr.expression is AwaitExpression;
  }

  void _validateIfStatement(IfStatement statement) {
    final elseKeyword = statement.elseKeyword;
    if (elseKeyword == null) {
      return;
    }

    final thenEndLine = _lineOf(statement.thenStatement.endToken.end);
    final firstElseLine = _firstElseLine(elseKeyword);

    if (_hasExtraBlankLines(thenEndLine, firstElseLine)) {
      _reporter.atToken(elseKeyword, _code);
    }
  }

  int _firstElseLine(Token elseKeyword) {
    int firstElseLine = _lineOf(elseKeyword.offset);

    for (Token? comment = elseKeyword.precedingComments;
        comment != null;
        comment = comment.next) {
      final commentLine = _lineOf(comment.offset);
      if (commentLine < firstElseLine) {
        firstElseLine = commentLine;
      }
    }

    return firstElseLine;
  }

  bool _hasExtraBlankLines(int prevLine, int nextLine) {
    return nextLine - prevLine - 1 > 0;
  }

  void _validateNodes(NodeList<AstNode> nodes, Token start) {
    int prevLine = _lineOf(start.end);

    for (final node in nodes) {
      final token = node.beginToken;
      final (firstLine, lastLine, hasComment) = _commentInfo(token);

      final blanksBefore = firstLine - prevLine - 1;
      final blanksAfter = hasComment ? _lineOf(token.offset) - lastLine - 1 : 0;

      if (_hasBlank(blanksBefore, blanksAfter)) {
        _reporter.atToken(token, _code);
      }

      prevLine = _lineOf(node.endToken.end);
    }
  }

  bool _hasBlank(int before, int after) {
    return before > 0 || after > 0;
  }

  void _validateBinaryExpression(BinaryExpression node) {
    final token = node.rightOperand.beginToken;
    final prevLine = _lineOf(node.leftOperand.endToken.end);
    final info = _binaryInfo(token, prevLine);

    if (_hasBinaryViolation(info)) {
      _reporter.atToken(token, _code);
    }
  }

  _BinaryInfo _binaryInfo(Token token, int prevLine) {
    final (firstLine, lastLine, hasComment) = _commentInfo(token);
    final currentLine = _lineOf(token.offset);

    return _BinaryInfo(
      blankBefore: firstLine - prevLine - 1,
      blankAfter: hasComment ? currentLine - lastLine - 1 : 0,
      hasComment: hasComment,
    );
  }

  bool _hasBinaryViolation(_BinaryInfo info) {
    return info.blankBefore > 0 || (info.hasComment && info.blankAfter > 0);
  }

  (int firstLine, int lastLine, bool hasComment) _commentInfo(Token token) {
    int firstLine = _lineOf(token.offset);
    int lastLine = firstLine;

    for (Token? comment = token.precedingComments;
        comment != null;
        comment = comment.next) {
      final startLine = _lineOf(comment.offset);
      firstLine = startLine < firstLine ? startLine : firstLine;
      lastLine = _lineOf(comment.end);
    }

    return (firstLine, lastLine, token.precedingComments != null);
  }

  int _lineOf(int offset) {
    return _lines.getLocation(offset).lineNumber;
  }
}

class _StatementInfo {
  const _StatementInfo({
    required this.current,
    required this.blankBefore,
    required this.blankAfter,
    required this.hasComment,
  });

  final Statement current;
  final int blankBefore;
  final int blankAfter;
  final bool hasComment;
}

class _BinaryInfo {
  const _BinaryInfo({
    required this.blankBefore,
    required this.blankAfter,
    required this.hasComment,
  });

  final int blankBefore;
  final int blankAfter;
  final bool hasComment;
}
