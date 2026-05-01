// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:flutter_clean_lint/src/rules/insert_line_between_sections.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'diagnostic_marker.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(InsertLineBetweenSectionsTest);
  });
}

@reflectiveTest
class InsertLineBetweenSectionsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = InsertLineBetweenSections();

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
// ignore_for_file: dead_code, unused_field, unused_local_variable

void badMissingBetweenDeclarationGroups() {
  final a = 1;
  final b = 2;
  final c = 3;
  final d = 4;
  final sum = a + b + c + d;
  // expect_lint! insert_line_between_sections
  if (sum > 0) {
    print(sum);
  }
}

void badMissingAfterAssignmentBlock() {
  final list = <int>[1, 2, 3];
  final mapped = list.map((e) => e * 2).toList();
  // expect_lint! insert_line_between_sections
  print(mapped);
}

int badMissingIf() {
  final a = 1;
  final b = 2;
  // expect_lint! insert_line_between_sections
  if (a + b == 3) {
    print('Sum is 3');
  }
  // expect_lint! insert_line_between_sections
  return a + b;
}

void badMissingAfterControlStatement() {
  final a = 1;

  if (a > 0) {
    print(a);
  }
  // expect_lint! insert_line_between_sections
  final b = 2;

  print(b);
}

void badMissingAfterPatternDeclaration() {
  final (a, b) = (1, 2);
  // expect_lint! insert_line_between_sections
  if (a > b) {
    print(a);
  }
}

void badMissingAfterControlBeforePattern(int x) {
  if (x > 0) {
    print(x);
  }
  // expect_lint! insert_line_between_sections
  final (a, b) = (x, x + 1);

  print(a + b);
}

void badLoopSequenceMissing() {
  final n = 3;
  // expect_lint! insert_line_between_sections
  for (int i = 0; i < n; i++) {
    print(i);
  }
  // expect_lint! insert_line_between_sections
  while (false) {
    break;
  }
  // expect_lint! insert_line_between_sections
  do {
    break;
  } while (false);
}

void badSwitchMissingBeforeSwitch(int x) {
  final value = x;
  // expect_lint! insert_line_between_sections
  switch (value) {
    case 0:
      print('zero');
    default:
      print('other');
  }
}

void badSwitchMissingAfterSwitch(int x) {
  final value = x;

  switch (value) {
    case 0:
      print('zero');
    default:
      print('other');
  }
  // expect_lint! insert_line_between_sections
  print('tail');
}

void badMissingAfterDeclarationBeforeTry() {
  final path = 'data.txt';
  // expect_lint! insert_line_between_sections
  try {
    print(path);
  } catch (_) {}
}

void badMissingAfterTry() {
  final path = 'data.txt';

  try {
    print(path);
  } catch (_) {}
  // expect_lint! insert_line_between_sections
  print('x');
}

int badMissingBeforeEarlyReturn(int x) {
  final y = x * 2;
  // expect_lint! insert_line_between_sections
  return y;
}

int badMissingLineAfterAssert(int x) {
  assert(x >= 0);
  // expect_lint! insert_line_between_sections
  final y = x + 1;

  return y;
}

Future<void> badAsyncMissing() async {
  final url = 'https://x';

  final data = await Future.value(url.length);
  // expect_lint! insert_line_between_sections
  print(data);
}

void badMissingBeforeLocalFunction() {
  final base = 2;
  // expect_lint! insert_line_between_sections
  int square(int value) => value * value;
  // expect_lint! insert_line_between_sections
  final squared = square(base);

  print(squared);
}

void badCascadeMissingAfter() {
  final buffer = StringBuffer()
    ..write('a')
    ..write('b');
  // expect_lint! insert_line_between_sections
  print(buffer.toString());
}

void badComplexCase() {
  final a = 1;
  final b = 2;
  // expect_lint! insert_line_between_sections
  if (a == 1) {
    print('condition');
  }

  final c = 2;
  // expect_lint! insert_line_between_sections
  for (int i = 0; i < b; i++) {
    print(i + c);
  }
  // expect_lint! insert_line_between_sections
  while (true) {
    break;
  }
}

void badExtraBetweenConsecutiveDeclarations() {
  final a = 1;
  final b = 2;

  // expect_lint! insert_line_between_sections
  final c = 3;
  final d = 4;

  print(a + b + c + d);
}

void badExtraAtBlockStart() {
  if (true) {

    // expect_lint! insert_line_between_sections
    print('work');
  }
}

void badExtraBeforeClosingBrace() {
  if (true) {
    print('x');

    // expect_lint! insert_line_between_sections
  }
}

void badExtraInsideSwitchCase() {
  final seed = 0;

  switch (seed) {
    case 0:

      // expect_lint! insert_line_between_sections
      print('zero');
      break;
    default:
      print('other');
  }
}

void badExtraInsideLoop() {
  for (int i = 0; i < 1; i++) {

    // expect_lint! insert_line_between_sections
    print(i);
  }
}

void badExtraInsideWhile() {
  int i = 0;

  while (i < 1) {

    // expect_lint! insert_line_between_sections
    i++;
  }
}

void badExtraInsideTry() {
  try {

    // expect_lint! insert_line_between_sections
    print('try');
  } catch (_) {}
}

void badExtraBeforeElse() {
  final x = 0;

  if (x == 0) {
    print('zero');
  }

  // expect_lint! insert_line_between_sections
  else {
    print('non-zero');
  }
}

void badExtraBeforeBreak() {
  for (int i = 0; i < 1; i++) {

    // expect_lint! insert_line_between_sections
    break;
  }
}

void badExtraInsideAssertGroup() {
  assert(1 == 1);

  // expect_lint! insert_line_between_sections
  assert(true);
}

void badExtraInsideLocalFunction() {
  int helper(int x) {

    // expect_lint! insert_line_between_sections
    return x + 1;
  }

  print(helper(1));
}

void badExtraInsideArrowLocal() {
  int helper(int x) => x +

      // expect_lint! insert_line_between_sections
      1;

  print(helper(1));
}

void badExtraInsideCascade() {
  final buffer = StringBuffer()

    // expect_lint! insert_line_between_sections
    ..write('a')
    ..write('b');

  print(buffer.toString());
}

void badExtraInsideCollectionLiteral() {
  final list = <int>[
    1,

    // expect_lint! insert_line_between_sections
    2,
    3,
  ];

  print(list.length);
}

void badExtraInsideMapLiteral() {
  final map = <String, int>{
    'a': 1,

    // expect_lint! insert_line_between_sections
    'b': 2,
  };

  print(map.length);
}

void badExtraInsideSetLiteral() {
  final set = <int>{
    1,

    // expect_lint! insert_line_between_sections
    2,
  };

  print(set.length);
}

Iterable<int> badExtraInsideSyncGenerator() sync* {
  yield 1;

  // expect_lint! insert_line_between_sections
  yield 2;
}

Stream<int> badExtraInsideAsyncGenerator() async* {
  yield 1;

  // expect_lint! insert_line_between_sections
  yield 2;
}

int badMultipleBlankLinesBeforeReturn(int x) {
  final y = x * 2;


  // expect_lint! insert_line_between_sections
  return y;
}

void badExtraBeforeCommentedReturn(bool shouldStop) {
  final canStop = shouldStop;

  // The caller only needs the state check above.
  // expect_lint! insert_line_between_sections
  return;
}

Future<void> badMissingBetweenCallAndAwait() async {
  print('before');
  print('before await');
  // expect_lint! insert_line_between_sections
  await Future.value(1);
  await Future.value(2);
}

Future<void> badMissingAfterAwaitCall() async {
  await Future.value(1);
  await Future.value(2);
  // expect_lint! insert_line_between_sections
  print('after');
  print('after await');
}

class Test {
  int _value1 = 0;
  int _value2 = 0;
  int _value3 = 0;

  void badAssignValuesToFields() {
    _value1 = 1;

    // expect_lint! insert_line_between_sections
    _value2 = 1;

    // expect_lint! insert_line_between_sections
    _value3 = 1;
  }
}
''';

const _ignoreCases = r'''
// ignore_for_file: dead_code, unused_field, unused_local_variable

void goodBetweenDeclarationGroups() {
  final a = 1;
  final b = 2;
  final sum = a + b;
  final diff = a - b;

  print(sum + diff);
}

void goodAfterAssignmentBlock() {
  final items = [1, 2, 3];
  final doubled = items.map((e) => e * 2).toList();

  print(doubled);
}

int goodIf() {
  final a = 1;
  final b = 2;

  if (a + b == 3) {
    print('Sum is 3');
  }

  return a + b;
}

void goodAfterControlStatement() {
  final a = 1;

  if (a > 0) {
    print(a);
  }

  final b = 2;

  print(b);
}

void goodLoopSequence() {
  final n = 2;

  for (int i = 0; i < n; i++) {
    print(i);
  }

  while (false) {
    break;
  }

  do {
    break;
  } while (false);
}

void goodSwitch(int x) {
  final value = x;

  switch (value) {
    case 0:
      print('zero');
    case 1:
      print('one');
    default:
      print('other');
  }

  print('done');
}

void goodBeforeTry() {
  final path = 'data.txt';

  try {
    print(path);
  } catch (_) {}

  print('after');
}

int goodBeforeEarlyReturn(int x) {
  final y = x * 2;

  return y;
}

int goodAfterAssert(int x) {
  assert(x >= 0);

  final y = x + 1;

  return y;
}

int goodCommentedReturn(int value) {
  final result = value + 1;
  // Return the prepared value without starting a new section.
  return result;
}

int goodMultilineCommentedReturn(int value) {
  final result = value + 1;
  /*
   * Return the prepared value without starting a new section.
   * Keep the whole comment attached to the return statement.
   */
  return result;
}

int goodMultilineLineCommentedReturn(int value) {
  final result = value + 1;
  // Return the prepared value without starting a new section.
  // Keep the whole comment attached to the return statement.
  return result;
}

void goodCommentedIf(int value) {
  final shouldPrint = value > 0;
  // Print only positive values.
  if (shouldPrint) {
    print(value);
  }
}

void goodCommentedSwitch(int value) {
  final normalized = value.clamp(0, 1);
  // Handle the normalized branch immediately after clamping.
  switch (normalized) {
    case 0:
      print('zero');
    default:
      print('one');
  }
}

void goodCommentedExecution(int value) {
  final message = '$value';
  // Send the prepared message without starting a new section.
  print(message);
}

void goodCommentedAssignment(int value) {
  var result = 0;
  // Store the latest value in the local accumulator.
  result = value;

  print(result);
}

Future<void> goodAwait() async {
  final length = await Future.value('url'.length);

  print(length);
}

void goodBeforeLocalFunction() {
  final base = 2;

  int square(int value) => value * value;

  final squared = square(base);

  print(squared);
}

void goodCascade() {
  final buffer = StringBuffer()
    ..write('a')
    ..write('b');

  print(buffer.toString());
}

void goodComplex() {
  final a = 1;

  if (a == 1) {
    print('condition');
  }

  for (int i = 0; i < 1; i++) {
    print(i);
  }

  while (false) {
    break;
  }
}

void goodNoExtraBetweenDeclarations() {
  final a = 1;
  final b = 2;
  final c = 3;
  final d = 4;

  print(a + b + c + d);
}

void goodNoExtraBetweenRecordPatternDeclarations() {
  final targetBox = (top: 1, bottom: 2);
  final viewportBox = (top: 3, bottom: 4);
  final (targetTop, targetBottom) = _resolveVerticalRange(targetBox);
  final (viewportTop, viewportBottom) = _resolveVerticalRange(viewportBox);

  print(targetTop + targetBottom + viewportTop + viewportBottom);
}

(int, int) _resolveVerticalRange(({int top, int bottom}) box) {
  return (box.top, box.bottom);
}

Future<void> goodNoExtraBetweenAwaitPatternDeclarations() async {
  final (a, b) = await _fetchPair();
  final (c, d) = await _fetchPair();

  print(a + b + c + d);
}

Future<(int, int)> _fetchPair() async => (1, 2);

void goodNoExtraAtBlockStart() {
  if (true) {
    print('work');
  }
}

void goodNoExtraInsideTry() {
  try {
    print('try');
  } catch (_) {}
}

void goodNoExtraInsideCollectionLiteral() {
  final list = <int>[1, 2, 3];

  print(list.length);
}

Iterable<int> goodNoExtraInsideGenerator() sync* {
  yield 1;
  yield 2;
}

int singleLine() => 1;

void emptyBody() {}

void onlyDeclarations() {
  final a = 1;
  final b = 2;
  final c = a + b;
}

Future<void> goodBetweenCallAndAwait() async {
  print('before');
  print('before await');

  await Future.value(1);
  await Future.value(2);
}

Future<void> goodAfterAwaitCall() async {
  await Future.value(1);
  await Future.value(2);

  print('after');
  print('after await');
}

class Test {
  int _value1 = 0;
  int _value2 = 0;
  int _value3 = 0;

  void goodAssignValuesToFields() {
    _value1 = 1;
    _value2 = 1;
    _value3 = 1;
  }
}
''';
