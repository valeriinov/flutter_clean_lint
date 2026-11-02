// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:flutter_clean_lint/src/fix/private_method_order_fixer.dart';
import 'package:flutter_clean_lint/src/rules/order_private_methods_by_usage.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PrivateMethodOrderFixerTest);
  });
}

@reflectiveTest
class PrivateMethodOrderFixerTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = OrderPrivateMethodsByUsage();

    super.setUp();
  }

  Future<void> test_misorderedMethods_should_followUsageOrder() async {
    final fixed = await _fix('misordered.dart', _misordered);

    expect(fixed, _misorderedFixed);
  }

  Future<void> test_fixedMethods_should_leaveNoDiagnostics() async {
    final fixed = await _fix('no_diagnostics.dart', _misordered);

    await assertNoDiagnostics(fixed);
  }

  Future<void> test_fixedMethods_should_stayUnchanged() async {
    final fixed = await _fix('first_run.dart', _misordered);
    final fixedAgain = await _fix('second_run.dart', fixed);

    expect(fixedAgain, fixed);
  }

  Future<void> test_commentsAndAnnotation_should_moveWithMethod() async {
    final fixed = await _fix('attached_comments.dart', _attachedComments);

    expect(fixed, _attachedCommentsFixed);
  }

  Future<void> test_trailingComment_should_moveWithMethod() async {
    final fixed = await _fix('trailing_comment.dart', _trailingComment);

    expect(fixed, _trailingCommentFixed);
  }

  Future<void> test_headerSeparatedByBlankLine_should_stay() async {
    final fixed = await _fix('separated_header.dart', _separatedHeader);

    expect(fixed, _separatedHeaderFixed);
  }

  Future<void> test_blockComment_should_moveWithMethod() async {
    final fixed = await _fix('block_comment.dart', _blockComment);

    expect(fixed, _blockCommentFixed);
  }

  Future<void> test_mutualCalls_should_beOrderedAndStable() async {
    final fixed = await _fix('mutual_calls.dart', _mutualCalls);
    final fixedAgain = await _fix('mutual_calls_again.dart', fixed);

    expect(fixed, _mutualCallsFixed);
    expect(fixedAgain, fixed);
  }

  Future<void> test_enumMixinAndExtensionType_should_beFixed() async {
    final fixed = await _fix('declarations.dart', _declarations);

    expect(fixed, _declarationsFixed);
  }

  Future<void> test_ignoreComment_should_leaveDeclarationUntouched() async {
    final fixed = await _fix('ignored_on_line.dart', _ignoredOnLine);

    expect(fixed, _ignoredOnLine);
  }

  Future<void> test_ignoreForFile_should_leaveDeclarationUntouched() async {
    final fixed = await _fix('ignored_for_file.dart', _ignoredForFile);

    expect(fixed, _ignoredForFile);
  }

  Future<String> _fix(String fileName, String source) async {
    final file = newFile('$testPackageRootPath/lib/$fileName', source);
    final result = await resolveFile(file.path);

    return PrivateMethodOrderFixer.fix(result.content, result.unit);
  }
}

const _misordered = r'''
class Order {
  void build() {
    _first();
    _second();
  }

  void _second() {}

  void _first() {
    _third();
  }

  void _third() {}
}
''';

const _misorderedFixed = r'''
class Order {
  void build() {
    _first();
    _second();
  }

  void _first() {
    _third();
  }

  void _second() {}

  void _third() {}
}
''';

const _attachedComments = r'''
class Order {
  void build() {
    _first();
    _second();
  }

  // Plain header.
  /// Documented.
  @pragma('vm:prefer-inline')
  void _second() {}

  void _first() {}
}
''';

const _attachedCommentsFixed = r'''
class Order {
  void build() {
    _first();
    _second();
  }

  void _first() {}

  // Plain header.
  /// Documented.
  @pragma('vm:prefer-inline')
  void _second() {}
}
''';

const _trailingComment = r'''
class Order {
  void build() {
    _first();
    _second();
  }

  void _second() {} // trailing
  void _first() {}
}
''';

const _trailingCommentFixed = r'''
class Order {
  void build() {
    _first();
    _second();
  }

  void _first() {}
  void _second() {} // trailing
}
''';

const _separatedHeader = r'''
class Order {
  void build() {
    _first();
    _second();
  }

  // Section header.

  void _second() {}

  void _first() {}
}
''';

const _separatedHeaderFixed = r'''
class Order {
  void build() {
    _first();
    _second();
  }

  // Section header.

  void _first() {}

  void _second() {}
}
''';

const _blockComment = r'''
class Order {
  void build() {
    _first();
    _second();
  }

  /* Block note. */
  void _second() {}

  void _first() {}
}
''';

const _blockCommentFixed = r'''
class Order {
  void build() {
    _first();
    _second();
  }

  void _first() {}

  /* Block note. */
  void _second() {}
}
''';

const _mutualCalls = r'''
class Order {
  void build() {
    _b();
  }

  void _a() {
    _b();
  }

  void _b() {
    _a();
  }
}
''';

const _mutualCallsFixed = r'''
class Order {
  void build() {
    _b();
  }

  void _b() {
    _a();
  }

  void _a() {
    _b();
  }
}
''';

const _declarations = r'''
enum Mode {
  on;

  void run() {
    _first();
    _second();
  }

  void _second() {}

  void _first() {}
}

mixin Runner {
  void run() {
    _first();
    _second();
  }

  void _second() {}

  void _first() {}
}

extension type Id(int value) {
  void run() {
    _first();
    _second();
  }

  void _second() {}

  void _first() {}
}
''';

const _declarationsFixed = r'''
enum Mode {
  on;

  void run() {
    _first();
    _second();
  }

  void _first() {}

  void _second() {}
}

mixin Runner {
  void run() {
    _first();
    _second();
  }

  void _first() {}

  void _second() {}
}

extension type Id(int value) {
  void run() {
    _first();
    _second();
  }

  void _first() {}

  void _second() {}
}
''';

const _ignoredOnLine = r'''
class Order {
  void build() {
    _first();
    _second();
  }

  // ignore: flutter_clean_lint/order_private_methods_by_usage
  void _second() {}

  void _first() {}
}
''';

const _ignoredForFile = r'''
// ignore_for_file: flutter_clean_lint/order_private_methods_by_usage

class Order {
  void build() {
    _first();
    _second();
  }

  void _second() {}

  void _first() {}
}
''';
