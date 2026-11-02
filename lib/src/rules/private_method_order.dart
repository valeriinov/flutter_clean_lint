import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

/// A private method of a class-like declaration and the places that use it.
class PrivateMethod {
  final MethodDeclaration node;
  final ExecutableElement element;
  final List<MethodUsage> usages = [];

  PrivateMethod(this.node, this.element);

  String get name {
    return node.name.lexeme;
  }
}

/// A reference to a private method inside the member [host].
class MethodUsage {
  final ClassMember host;
  final int offset;

  const MethodUsage({required this.host, required this.offset});
}

/// A private method that must move to restore the usage order.
class MisplacedPrivateMethod {
  final PrivateMethod method;
  final PrivateMethod? expectedPredecessor;

  const MisplacedPrivateMethod(this.method, this.expectedPredecessor);
}

/// Returns the [methods], given in file order, that must move so that each
/// private method follows the latest of its usages.
///
/// Members other than private methods keep their offsets. Private methods are
/// placed one by one: the next one is the method whose latest usage comes
/// first among those whose usages are all placed already. Usages inside not
/// yet placed methods are skipped only when every remaining method has one,
/// which happens for mutual calls. Methods without usages go last. Ties keep
/// the file order. The methods to move are those outside the longest run that
/// already follows that order.
List<MisplacedPrivateMethod> misplacedPrivateMethods(
  List<PrivateMethod> methods,
) {
  final expected = orderedPrivateMethods(methods);
  final expectedIndexes = [
    for (final method in methods) expected.indexOf(method),
  ];
  final keptIndexes = _longestIncreasingRun(expectedIndexes);

  return [
    for (int index = 0; index < methods.length; index++)
      if (!keptIndexes.contains(index))
        MisplacedPrivateMethod(
          methods[index],
          _predecessor(expected, expectedIndexes[index]),
        ),
  ];
}

/// Returns the private methods of the [declaration] in file order, each with
/// its usages inside the other members of the declaration.
///
/// The unit that holds the [declaration] must be resolved.
List<PrivateMethod> collectPrivateMethods(CompilationUnitMember declaration) {
  final members = _membersOf(declaration);
  final methods = [
    for (final member in members)
      if (_privateMethodElement(member) case final element?)
        PrivateMethod(member as MethodDeclaration, element),
  ];

  _collectUsages(members, methods);

  return methods;
}

/// Returns the [methods], given in file order, in the order in which each one
/// follows the latest of its usages.
///
/// The placement rules are those of [misplacedPrivateMethods].
List<PrivateMethod> orderedPrivateMethods(List<PrivateMethod> methods) {
  final placed = <PrivateMethod>[];
  final remaining = [...methods];

  while (remaining.isNotEmpty) {
    final next = _nextMethod(remaining, placed);

    placed.add(next);
    remaining.remove(next);
  }

  return placed;
}

PrivateMethod _nextMethod(
  List<PrivateMethod> remaining,
  List<PrivateMethod> placed,
) {
  final ready = [
    for (final method in remaining)
      if (_hasOnlyPlacedUsages(method, remaining)) method,
  ];
  final readyUsed = _withPlacedUsage(ready, remaining, placed);

  if (readyUsed.isNotEmpty) {
    return _earliestLatestUsage(readyUsed, remaining, placed);
  }

  final reachable = _withPlacedUsage(remaining, remaining, placed);

  if (reachable.isNotEmpty) {
    return _earliestLatestUsage(reachable, remaining, placed);
  }

  return remaining.first;
}

bool _hasOnlyPlacedUsages(PrivateMethod method, List<PrivateMethod> remaining) {
  return method.usages.every((usage) => !_hostsUsage(remaining, usage));
}

List<PrivateMethod> _withPlacedUsage(
  List<PrivateMethod> methods,
  List<PrivateMethod> remaining,
  List<PrivateMethod> placed,
) {
  return [
    for (final method in methods)
      if (_latestPlacedUsage(method, remaining, placed) != null) method,
  ];
}

PrivateMethod _earliestLatestUsage(
  List<PrivateMethod> candidates,
  List<PrivateMethod> remaining,
  List<PrivateMethod> placed,
) {
  PrivateMethod earliest = candidates.first;

  for (final candidate in candidates.skip(1)) {
    final comparison = _compareUsagePositions(
      _latestPlacedUsage(candidate, remaining, placed),
      _latestPlacedUsage(earliest, remaining, placed),
    );

    if (comparison < 0) {
      earliest = candidate;
    }
  }

  return earliest;
}

(int, int)? _latestPlacedUsage(
  PrivateMethod method,
  List<PrivateMethod> remaining,
  List<PrivateMethod> placed,
) {
  (int, int)? latest;

  for (final usage in method.usages) {
    if (_hostsUsage(remaining, usage)) {
      continue;
    }

    final position = _usagePosition(usage, placed);

    if (_compareUsagePositions(position, latest) > 0) {
      latest = position;
    }
  }

  return latest;
}

bool _hostsUsage(List<PrivateMethod> methods, MethodUsage usage) {
  return methods.any((method) => method.node == usage.host);
}

(int, int) _usagePosition(MethodUsage usage, List<PrivateMethod> placed) {
  final hostIndex = placed.indexWhere((method) => method.node == usage.host);

  return (hostIndex, usage.offset);
}

int _compareUsagePositions((int, int)? first, (int, int)? second) {
  if (first == null) {
    return second == null ? 0 : -1;
  }

  if (second == null) {
    return 1;
  }

  if (first.$1 != second.$1) {
    return first.$1.compareTo(second.$1);
  }

  return first.$2.compareTo(second.$2);
}

Set<int> _longestIncreasingRun(List<int> values) {
  final lengths = List.filled(values.length, 1);
  final previous = List.filled(values.length, -1);

  for (int index = 0; index < values.length; index++) {
    _extendRun(values, lengths, previous, index);
  }

  final kept = <int>{};
  int index = _indexOfMax(lengths);

  while (index != -1) {
    kept.add(index);
    index = previous[index];
  }

  return kept;
}

void _extendRun(
  List<int> values,
  List<int> lengths,
  List<int> previous,
  int index,
) {
  for (int before = 0; before < index; before++) {
    if (_extendsRun(values, lengths, before, index)) {
      lengths[index] = lengths[before] + 1;
      previous[index] = before;
    }
  }
}

bool _extendsRun(List<int> values, List<int> lengths, int before, int index) {
  return values[before] < values[index] &&
      lengths[before] + 1 >= lengths[index];
}

int _indexOfMax(List<int> values) {
  int maxIndex = 0;

  for (int index = 1; index < values.length; index++) {
    if (values[index] >= values[maxIndex]) {
      maxIndex = index;
    }
  }

  return maxIndex;
}

PrivateMethod? _predecessor(List<PrivateMethod> expected, int expectedIndex) {
  if (expectedIndex == 0) {
    return null;
  }

  return expected[expectedIndex - 1];
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

bool _isAccessorOrOperator(MethodDeclaration method) {
  return method.isGetter || method.isSetter || method.isOperator;
}

void _collectUsages(List<ClassMember> members, List<PrivateMethod> methods) {
  final methodsByElement = {
    for (final method in methods) method.element: method,
  };

  for (final member in members) {
    member.accept(_UsageCollector(member, methodsByElement));
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
