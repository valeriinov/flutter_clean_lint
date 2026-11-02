import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import 'private_method_order.dart';

/// Lints private methods that are not ordered by their latest usage.
class OrderPrivateMethodsByUsage extends AnalysisRule {
  static const _name = 'order_private_methods_by_usage';
  static const _description =
      'Order private methods by their latest usage in the declaration: '
      'call sites come first, implementations below them.';
  static const code = LintCode(
    _name,
    "Move '{0}' {1}; private methods follow the order of their latest usage.",
  );

  OrderPrivateMethodsByUsage() : super(name: _name, description: _description);

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
  final OrderPrivateMethodsByUsage _rule;

  _CompilationUnitVisitor(this._rule);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    for (final declaration in node.declarations) {
      _checkMembers(declaration);
    }
  }

  void _checkMembers(CompilationUnitMember declaration) {
    final methods = collectPrivateMethods(declaration);

    if (methods.length < 2) {
      return;
    }

    for (final misplaced in misplacedPrivateMethods(methods)) {
      _report(misplaced);
    }
  }

  void _report(MisplacedPrivateMethod misplaced) {
    final predecessor = misplaced.expectedPredecessor;
    final placement = predecessor == null
        ? 'before the other private methods'
        : "after '${predecessor.name}'";

    _rule.reportAtToken(
      misplaced.method.node.name,
      arguments: [misplaced.method.name, placement],
    );
  }
}
