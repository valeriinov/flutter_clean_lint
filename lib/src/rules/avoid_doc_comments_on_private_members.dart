import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Lints doc comments on library-private declarations.
class AvoidDocCommentsOnPrivateMembers extends AnalysisRule {
  static const _name = 'avoid_doc_comments_on_private_members';
  static const _description =
      'Avoid doc comments on private members. Keep one only for SDK or '
      'framework behaviour, an external contract, or an ordering whose breach '
      'fails silently, and suppress the lint there.';
  static const code = LintCode(_name, _description);

  AvoidDocCommentsOnPrivateMembers()
    : super(name: _name, description: _description);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addComment(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidDocCommentsOnPrivateMembers _rule;

  _Visitor(this._rule);

  @override
  void visitComment(Comment node) {
    if (!_declaresPrivateName(node.parent)) {
      return;
    }

    _rule.reportAtToken(node.tokens.first);
  }

  bool _declaresPrivateName(AstNode? node) {
    return switch (node) {
      FieldDeclaration(:final fields) => _areAllPrivate(fields),
      TopLevelVariableDeclaration(:final variables) => _areAllPrivate(
        variables,
      ),
      Declaration(:final declaredFragment?) =>
        declaredFragment.element.isPrivate,
      _ => false,
    };
  }

  bool _areAllPrivate(VariableDeclarationList list) {
    return list.variables.every(
      (variable) => variable.declaredFragment?.element.isPrivate ?? false,
    );
  }
}
