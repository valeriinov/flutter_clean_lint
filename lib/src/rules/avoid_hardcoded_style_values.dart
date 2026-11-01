import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

/// Lints hard-coded colours and style numbers in widget code.
class AvoidHardcodedStyleValues extends AnalysisRule {
  static const _name = 'avoid_hardcoded_style_values';
  static const _description =
      'Avoid hard-coded colours and style numbers in widget code: '
      'take them from the theme.';
  static const code = LintCode(
    _name,
    "Take '{0}' from the theme instead of a hard-coded value.",
  );

  AvoidHardcodedStyleValues() : super(name: _name, description: _description);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (context.isInTestDirectory) {
      return;
    }

    registry.addCompilationUnit(this, _CompilationUnitVisitor(this));
  }
}

class _CompilationUnitVisitor extends SimpleAstVisitor<void> {
  final AvoidHardcodedStyleValues _rule;

  _CompilationUnitVisitor(this._rule);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final widgetClasses = [
      for (final declaration in node.declarations)
        if (declaration is ClassDeclaration && _isWidgetClass(declaration))
          declaration,
    ];

    if (widgetClasses.isEmpty) {
      return;
    }

    final styleVisitor = _StyleValueVisitor(_rule);

    for (final widgetClass in widgetClasses) {
      widgetClass.accept(styleVisitor);
    }

    for (final declaration in node.declarations) {
      if (declaration is TopLevelVariableDeclaration) {
        declaration.accept(styleVisitor);
      }
    }
  }

  bool _isWidgetClass(ClassDeclaration declaration) {
    final element = declaration.declaredFragment?.element;

    if (element == null) {
      return false;
    }

    return element.allSupertypes.any(
      (type) =>
          _isFlutterType(type.element, 'Widget') ||
          _isFlutterType(type.element, 'State'),
    );
  }
}

class _StyleValueVisitor extends RecursiveAstVisitor<void> {
  static const _styleParameters = {
    'strokeWidth',
    'thickness',
    'elevation',
    'fontSize',
  };
  static const _colorConstructors = {null, 'fromARGB', 'fromRGBO'};
  static const _colorPalettes = {'Colors', 'CupertinoColors'};
  static const _styleConstantTypes = {'BorderRadius', 'EdgeInsets'};

  final AvoidHardcodedStyleValues _rule;

  _StyleValueVisitor(this._rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (_isColorCreation(node)) {
      _report(node);
    }

    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (_isPaletteColor(node.prefix, node.identifier)) {
      _report(node);
    }

    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    final target = node.target;

    if (target is Identifier && _isPaletteColor(target, node.propertyName)) {
      _report(node);
    }

    super.visitPropertyAccess(node);
  }

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    if (node.value != 0 && _isStyleNumber(node)) {
      _report(node);
    }
  }

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    if (node.value != 0 && _isStyleNumber(node)) {
      _report(node);
    }
  }

  bool _isColorCreation(InstanceCreationExpression node) {
    final constructorName = node.constructorName;

    if (!_colorConstructors.contains(constructorName.name?.name)) {
      return false;
    }

    return _isFlutterType(constructorName.type.element, 'Color');
  }

  bool _isPaletteColor(Identifier palette, SimpleIdentifier color) {
    if (color.name == 'transparent') {
      return false;
    }

    return _colorPalettes.any((name) => _isFlutterType(palette.element, name));
  }

  bool _isStyleNumber(Literal node) {
    return _isStyleArgument(node) || _isStyleConstant(node);
  }

  void _report(AstNode node) {
    _rule.reportAtNode(node, arguments: [node.toSource()]);
  }

  bool _isStyleArgument(Literal node) {
    final parent = node.parent;

    if (parent is NamedArgument) {
      return _isStyleNamedArgument(parent);
    }

    if (parent is! ArgumentList) {
      return false;
    }

    final call = parent.parent;

    return call is InstanceCreationExpression &&
        (_isCreationOf(call, 'Radius', 'circular') ||
            _isCreationOf(call, 'BorderRadius', 'circular'));
  }

  bool _isStyleConstant(Literal node) {
    final parent = node.parent;

    if (parent is VariableDeclaration) {
      return _isFinalOrConst(parent) && _isDouble(parent);
    }

    final argumentList = parent is NamedArgument ? parent.parent : parent;

    if (argumentList is! ArgumentList) {
      return false;
    }

    final creation = argumentList.parent;

    if (creation is! InstanceCreationExpression) {
      return false;
    }

    final variable = creation.parent;

    return variable is VariableDeclaration &&
        _isFinalOrConst(variable) &&
        _isStyleConstantCreation(creation);
  }

  bool _isStyleNamedArgument(NamedArgument argument) {
    final argumentList = argument.parent;

    if (argumentList is! ArgumentList) {
      return false;
    }

    final name = argument.name.lexeme;

    if (_styleParameters.contains(name)) {
      return true;
    }

    final call = argumentList.parent;

    return name == 'width' &&
        call is InstanceCreationExpression &&
        _isBorderCreation(call);
  }

  bool _isDouble(VariableDeclaration variable) {
    return variable.declaredFragment?.element.type.isDartCoreDouble ?? false;
  }

  bool _isFinalOrConst(VariableDeclaration variable) {
    return variable.isConst || variable.isFinal;
  }

  bool _isStyleConstantCreation(InstanceCreationExpression creation) {
    final element = creation.constructorName.type.element;

    return _styleConstantTypes.any((name) => _isFlutterType(element, name));
  }

  bool _isBorderCreation(InstanceCreationExpression call) {
    return _isCreationOf(call, 'BorderSide', null) ||
        _isCreationOf(call, 'Border', 'all');
  }

  bool _isCreationOf(
    InstanceCreationExpression node,
    String typeName,
    String? constructorName,
  ) {
    return node.constructorName.name?.name == constructorName &&
        _isFlutterType(node.constructorName.type.element, typeName);
  }
}

bool _isFlutterType(Element? element, String name) {
  if (element is! InterfaceElement || element.name != name) {
    return false;
  }

  final uri = element.library.uri.toString();

  return uri.startsWith('dart:ui') || uri.startsWith('package:flutter/');
}
