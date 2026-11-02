// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:flutter_clean_lint/src/rules/order_private_methods_by_usage.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(OrderPrivateMethodsByUsageTest);
  });
}

@reflectiveTest
class OrderPrivateMethodsByUsageTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = OrderPrivateMethodsByUsage();

    super.setUp();
  }

  Future<void> test_callSitesInOneMember_should_followCallOrder() async {
    const source = r'''
class Screen {
  void build() {
    _a();
    _b();
  }

  void _b() {}

  void _a() {}
}
''';

    await assertDiagnostics(source, [lint(_nameOffset(source, '_b'), 2)]);
  }

  Future<void> test_calleeOfEarlierCall_should_followLaterCallSites() async {
    const source = r'''
class Screen {
  void build() {
    _a();
    _b();
  }

  void _a() => _a1();

  void _b() {}

  void _a1() {}
}
''';

    await assertNoDiagnostics(source);
  }

  Future<void> test_depthFirstOrder_should_report() async {
    const source = r'''
class Screen {
  void build() {
    _a();
    _b();
  }

  void _a() => _a1();

  void _a1() {}

  void _b() {}
}
''';

    await assertDiagnostics(source, [
      lint(
        _nameOffset(source, '_a1'),
        3,
        messageContainsAll: ["Move '_a1' after '_b'"],
      ),
    ]);
  }

  Future<void> test_nestedLevels_should_followLatestUsagePositions() async {
    const source = r'''
class Screen {
  void build() {
    _a();
    _b();
  }

  void _a() {
    _c();
    _d();
  }

  void _b() {}

  void _c() => _e();

  void _d() {}

  void _e() {}
}
''';

    await assertNoDiagnostics(source);
  }

  Future<void> test_sharedHelper_should_followItsLatestCaller() async {
    const source = r'''
class Screen {
  void build() {
    _a();
    _b();
  }

  void _a() => _shared();

  void _shared() {}

  void _b() => _shared();
}
''';

    await assertDiagnostics(source, [
      lint(
        _nameOffset(source, '_shared'),
        7,
        messageContainsAll: ["Move '_shared' after '_b'"],
      ),
    ]);
  }

  Future<void> test_latestUsage_should_definePlacement() async {
    const source = r'''
class Screen {
  void initState() => _a();

  void build() => _b();

  void dispose() => _a();

  void _b() {}

  void _a() {}
}
''';

    await assertNoDiagnostics(source);
  }

  Future<void> test_latestUsageInPrivateMethod_should_definePlacement() async {
    const source = r'''
class Screen {
  void build() {
    _shared();
    _a();
  }

  void _shared() {}

  void _a() => _shared();
}
''';

    await assertDiagnostics(source, [lint(_nameOffset(source, '_shared'), 7)]);
  }

  Future<void> test_recursion_should_beIgnored() async {
    const source = r'''
class Screen {
  void build() {
    _a(1);
    _b();
  }

  void _a(int depth) => depth > 0 ? _a(depth - 1) : null;

  void _b() {}
}
''';

    await assertNoDiagnostics(source);
  }

  Future<void> test_mutualCalls_should_startFromReachedMethod() async {
    const source = r'''
class Screen {
  void build() => _a(1);

  void _b(int depth) => _a(depth - 1);

  void _a(int depth) => depth > 0 ? _b(depth) : null;
}
''';

    await assertDiagnostics(source, [lint(_nameOffset(source, '_b'), 2)]);
  }

  Future<void> test_tearOffsAndQualifiedCalls_should_countAsUsages() async {
    const source = r'''
class Screen {
  static void _static() {}

  void build() {
    run(_handle);
    this._other();
    Screen._static();
  }

  void run(void Function() callback) => callback();

  void _handle() {}

  void _other() {}
}
''';

    await assertDiagnostics(source, [lint(_nameOffset(source, '_static'), 7)]);
  }

  Future<void> test_firstExpectedMethod_should_reportFirstPlacement() async {
    const source = r'''
class Screen {
  void build() {
    _a();
    _b();
    _c();
  }

  void _b() {}

  void _c() {}

  void _a() {}
}
''';

    await assertDiagnostics(source, [
      lint(
        _nameOffset(source, '_a'),
        2,
        messageContainsAll: ["Move '_a' before the other private methods"],
      ),
    ]);
  }

  Future<void> test_equivalentMoves_should_reportLaterMethod() async {
    const source = r'''
// ignore_for_file: unused_element

class Screen {
  void build() {
    _a();
    _b();
  }

  void _b() {}

  void _a() {}

  void _unused() {}
}
''';

    await assertDiagnostics(source, [
      lint(
        _nameOffset(source, '_b'),
        2,
        messageContainsAll: ["Move '_b' after '_a'"],
      ),
    ]);
  }

  Future<void> test_unusedMethod_should_goLast() async {
    const source = r'''
// ignore_for_file: unused_element

class Screen {
  void build() => _a();

  void _unused() {}

  void _a() {}
}
''';

    await assertDiagnostics(source, [lint(_nameOffset(source, '_unused'), 7)]);
  }

  Future<void> test_genericMethod_should_matchUsages() async {
    const source = r'''
class Box<T> {
  void build() {
    _a<int>();
    _b(1 as T);
  }

  void _b(T value) {}

  void _a<R>() {}
}
''';

    await assertDiagnostics(source, [lint(_nameOffset(source, '_b'), 2)]);
  }

  Future<void> test_mixinsEnumsAndExtensions_should_beChecked() async {
    const source = r'''
mixin Tracking {
  void track() {
    _a();
    _b();
  }

  void _b() {}

  void _a() {}
}

enum Mode {
  first;

  void run() {
    _a();
    _b();
  }

  void _b() {}

  void _a() {}
}

extension IntX on int {
  void run() {
    _a();
    _b();
  }

  void _b() {}

  void _a() {}
}
''';

    await assertDiagnostics(source, [
      lint(_nameOffset(source, '_b'), 2),
      lint(_nameOffset(source, '_b', from: source.indexOf('enum')), 2),
      lint(_nameOffset(source, '_b', from: source.indexOf('extension')), 2),
    ]);
  }

  Future<void> test_gettersSettersAndOperators_should_beIgnored() async {
    const source = r'''
class Screen {
  void build() {
    _a();
    _value;
    _value = 1;
  }

  set _value(int value) {}

  int get _value => 0;

  void _a() {}
}
''';

    await assertNoDiagnostics(source);
  }

  int _nameOffset(String source, String name, {int from = 0}) {
    return source.indexOf('void $name', from) + 'void '.length;
  }
}
