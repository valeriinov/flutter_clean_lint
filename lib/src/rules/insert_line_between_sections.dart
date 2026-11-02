import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import 'section_spacing_visitor.dart';

/// Ensures there is exactly one blank line between code sections inside function bodies.
class InsertLineBetweenSections extends AnalysisRule {
  static const _name = 'insert_line_between_sections';
  static const _description =
      'Separate statements of different kinds with exactly one blank line and '
      'keep statements of the same kind together. Same kind: declarations '
      '(all with await or all without), await expressions, assignments '
      'without await, invocations, asserts, yields; break and continue join '
      'the statement above; any other statement stands apart. No blank lines '
      'at block edges, at the start of a switch case, before else, '
      'between a comment and its statement, or '
      'inside collection literals, cascades and binary expressions. '
      'Fix: dart run flutter_clean_lint:fix_blank_lines <paths>.';
  static const code = LintCode(_name, _description);

  InsertLineBetweenSections() : super(name: _name, description: _description);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(this, _CompilationUnitVisitor(this));
  }
}

class _CompilationUnitVisitor extends SimpleAstVisitor<void> {
  final InsertLineBetweenSections _rule;

  _CompilationUnitVisitor(this._rule);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    node.visitChildren(
      SectionSpacingVisitor(
        node.lineInfo,
        (violation) => _rule.reportAtToken(violation.token),
      ),
    );
  }
}
