// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:flutter_clean_lint/src/fix/blank_line_fixer.dart';
import 'package:flutter_clean_lint/src/rules/insert_line_between_sections.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rules/diagnostic_marker.dart';
import '../rules/insert_line_between_sections_test.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(BlankLineFixerTest);
  });
}

@reflectiveTest
class BlankLineFixerTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = InsertLineBetweenSections();

    super.setUp();
  }

  Future<void> test_lintCases_should_leaveNoDiagnostics() async {
    final fixed = await _fix('lint_cases.dart', removeLintMarkers(lintCases));

    await assertNoDiagnostics(fixed);
  }

  Future<void> test_fixedLintCases_should_stayUnchanged() async {
    final fixed = await _fix('lint_cases.dart', removeLintMarkers(lintCases));
    final fixedAgain = await _fix('fixed_lint_cases.dart', fixed);

    expect(fixedAgain, fixed);
  }

  Future<void> test_blankLineBeforeLeadingOperator_should_beRemoved() async {
    final fixed = await _fix('leading_operator.dart', _leadingOperator);

    expect(fixed, _leadingOperatorFixed);
  }

  Future<void> test_crlfLineEndings_should_bePreserved() async {
    final source = _missingBlankLine.replaceAll('\n', '\r\n');

    final fixed = await _fix('crlf_line_endings.dart', source);

    expect(fixed, _missingBlankLineFixed.replaceAll('\n', '\r\n'));
  }

  Future<void> test_unfixableCases_should_stayUnchangedAndReported() async {
    final source = removeLintMarkers(_unfixableCases);
    final fixed = await _fix('unfixable_cases.dart', source);

    expect(fixed, source);

    await assertDiagnosticsFromMarkers(this, _unfixableCases);
  }

  Future<void> test_suppressedViolations_should_stayUnchanged() async {
    final fixedForFile = await _fix('ignored_for_file.dart', _ignoredCases);
    final fixedOnLine = await _fix('ignored_on_line.dart', _ignoredOnLine);

    expect(fixedForFile, _ignoredCases);
    expect(fixedOnLine, _ignoredOnLine);
  }

  Future<String> _fix(String fileName, String source) async {
    final file = newFile('$testPackageRootPath/lib/$fileName', source);
    final result = await resolveFile(file.path);

    return BlankLineFixer.fix(result.content, result.unit);
  }
}

const _leadingOperator = r'''
bool leadingOperator(bool a, bool b) {
  return a

      && b;
}
''';

const _leadingOperatorFixed = r'''
bool leadingOperator(bool a, bool b) {
  return a
      && b;
}
''';

const _missingBlankLine = r'''
void missingBlankLine() {
  final a = 1;
  print(a);
}
''';

const _missingBlankLineFixed = r'''
void missingBlankLine() {
  final a = 1;

  print(a);
}
''';

const _unfixableCases = r'''
void trailingComment() {
  print('a'); // note
  // expect_lint! insert_line_between_sections
  print('b');
}

void commentBeforeClosingBrace() {
  print('a');
  // note
  // expect_lint! insert_line_between_sections
}
''';

const _ignoredCases = r'''
// ignore_for_file: flutter_clean_lint/insert_line_between_sections

void ignoredForFile() {

  print('a');

  print('b');
}
''';

const _ignoredOnLine = r'''
void ignoredOnLine() {
  print('a');

  // ignore: flutter_clean_lint/insert_line_between_sections
  print('b');
}
''';
