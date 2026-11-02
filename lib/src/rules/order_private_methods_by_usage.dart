import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
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
      _checkMembers(_membersOf(declaration));
    }
  }

  void _checkMembers(List<ClassMember> members) {
    final methods = [
      for (final member in members)
        if (_privateMethodElement(member) case final element?)
          PrivateMethod(member as MethodDeclaration, element),
    ];

    if (methods.length < 2) {
      return;
    }

    _collectUsages(members, methods);

    for (final misplaced in misplacedPrivateMethods(methods)) {
      _report(misplaced);
    }
  }

  List<ClassMember> _membersOf(CompilationUnitMember declaration) {
    return switch (declaration) {
      ClassDeclaration(:final body) => body.members,
      MixinDeclaration(:final body) => body.members,
      ExtensionDeclaration(:final body) => body.members,
      ExtensionTypeDeclaration(:final body) => body.members,
      EnumDeclaration(:final body) => body.members,
      _ => const [],
    };
  }

  ExecutableElement? _privateMethodElement(ClassMember member) {
    if (member is! MethodDeclaration) {
      return null;
    }

    if (_isAccessorOrOperator(member)) {
      return null;
    }

    final element = member.declaredFragment?.element;

    if (element == null || !element.isPrivate) {
      return null;
    }

    return element;
  }

  void _collectUsages(List<ClassMember> members, List<PrivateMethod> methods) {
    final methodsByElement = {
      for (final method in methods) method.element: method,
    };

    for (final member in members) {
      member.accept(_UsageCollector(member, methodsByElement));
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

  bool _isAccessorOrOperator(MethodDeclaration method) {
    return method.isGetter || method.isSetter || method.isOperator;
  }
}

class _UsageCollector extends RecursiveAstVisitor<void> {
  final ClassMember _host;
  final Map<Element, PrivateMethod> _methodsByElement;

  _UsageCollector(this._host, this._methodsByElement);

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    final method = _methodsByElement[node.element?.baseElement];

    if (method == null || method.node == _host) {
      return;
    }

    method.usages.add(MethodUsage(host: _host, offset: node.offset));
  }
}
