// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:flutter_clean_lint/src/rules/avoid_doc_comments_on_private_members.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'diagnostic_marker.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidDocCommentsOnPrivateMembersTest);
  });
}

@reflectiveTest
class AvoidDocCommentsOnPrivateMembersTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidDocCommentsOnPrivateMembers();

    super.setUp();
  }

  Future<void> test_lintCases_should_reportExpectedDiagnostics() async {
    await assertDiagnosticsFromMarkers(this, _lintCases);
  }

  Future<void> test_ignoreCases_should_notReportDiagnostics() async {
    await assertNoDiagnostics(_ignoreCases);
  }
}

const _lintCases = r'''
// ignore_for_file: unused_element, unused_field, unused_element_parameter

class Widget {
  // expect_lint! avoid_doc_comments_on_private_members
  /// Counts taps.
  int _count = 0;

  // expect_lint! avoid_doc_comments_on_private_members
  /// Static private field.
  static const _limit = 3;

  // expect_lint! avoid_doc_comments_on_private_members
  /// Named private constructor.
  Widget._();

  // expect_lint! avoid_doc_comments_on_private_members
  /// Private getter.
  int get _doubled => _count * 2;

  // expect_lint! avoid_doc_comments_on_private_members
  /// Private setter.
  set _value(int value) => _count = value;

  // expect_lint! avoid_doc_comments_on_private_members
  /// Handles a tap.
  /// Spans two lines.
  void _handleTap() {}

  // expect_lint! avoid_doc_comments_on_private_members
  /** Block doc comment. */
  void _reset() {}
}

// expect_lint! avoid_doc_comments_on_private_members
/// Private class.
class _EmailField {}

// expect_lint! avoid_doc_comments_on_private_members
/// Private top-level function.
void _helper() {}

// expect_lint! avoid_doc_comments_on_private_members
/// Private top-level variable.
final _cache = <int>[];

// expect_lint! avoid_doc_comments_on_private_members
/// Private mixin.
mixin _Tracking {}

// expect_lint! avoid_doc_comments_on_private_members
/// Private enum.
enum _Mode {
  // expect_lint! avoid_doc_comments_on_private_members
  /// Private-looking constant.
  _first,
}

// expect_lint! avoid_doc_comments_on_private_members
/// Private extension.
extension _IntX on int {}

// expect_lint! avoid_doc_comments_on_private_members
/// Unnamed extension.
extension on String {}

// expect_lint! avoid_doc_comments_on_private_members
/// Private typedef.
typedef _Callback = void Function();
''';

const _ignoreCases = r'''
// ignore_for_file: unused_element, unused_field

/// Public class.
class Widget {
  /// Public field.
  int count = 0;

  // Regular comment on a private field.
  int _hidden = 0;

  /// Mixed field list with a public variable.
  int visible = 0, _other = 0;

  /// Public method.
  void build() {}

  // ignore: avoid_doc_comments_on_private_members
  /// Must run before [build]; the framework calls it otherwise.
  void _prepare() {}
}

class _Private {
  /// Unnamed constructor of a private class.
  _Private();

  /// Public-named member of a private class.
  void build() {}
}

/// Public top-level function.
void helper() {}
''';
