// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:flutter_clean_lint/src/rules/avoid_commented_out_code.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'diagnostic_marker.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidCommentedOutCodeTest);
  });
}

@reflectiveTest
class AvoidCommentedOutCodeTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidCommentedOutCode();
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
// expect_lint! avoid_commented_out_code
// void foo() {}

// expect_lint! avoid_commented_out_code
// class A {}

// expect_lint! avoid_commented_out_code
// import 'dart:math';

// expect_lint! avoid_commented_out_code
// export 'a.dart';

// expect_lint! avoid_commented_out_code
// part 'b.dart';

// expect_lint! avoid_commented_out_code
// label: 1,

// expect_lint! avoid_commented_out_code
// foo(1, 2);

// expect_lint! avoid_commented_out_code
// if (true) {

// expect_lint! avoid_commented_out_code
// for (int i = 0; i < 10; i++) {

// expect_lint! avoid_commented_out_code
// while (false) {

// expect_lint! avoid_commented_out_code
// x = 5;

// expect_lint! avoid_commented_out_code
// return 5;

// expect_lint! avoid_commented_out_code
// @override

// expect_lint! avoid_commented_out_code
// int count;

// expect_lint! avoid_commented_out_code
/* void bar() {} */

// expect_lint! avoid_commented_out_code
// final x = 2;

// expect_lint! avoid_commented_out_code
// Text('You have pushed the button this many times:'),

// expect_lint! avoid_commented_out_code
/*Text(
     '$_counter',
     style: Theme.of(context).textTheme.headlineMedium,
),*/

// expect_lint! avoid_commented_out_code
// Text('You have pushed the button this many times:')

// expect_lint! avoid_commented_out_code
/*Text(
     '$_counter',
     style: Theme.of(context).textTheme.headlineMedium,
)*/

// expect_lint! avoid_commented_out_code
// void bar(int a, String b) {}

// expect_lint! avoid_commented_out_code
// class B<T> {}

// expect_lint! avoid_commented_out_code
// import "package:foo/bar.dart";

// expect_lint! avoid_commented_out_code
// export "b.dart";

// expect_lint! avoid_commented_out_code
// part "c.dart";

// expect_lint! avoid_commented_out_code
// label2: 'test',

// expect_lint! avoid_commented_out_code
// doSomething();

// expect_lint! avoid_commented_out_code
// for (final item in [1, 2]) {

// expect_lint! avoid_commented_out_code
// while (i < 10) {

// expect_lint! avoid_commented_out_code
// y = 3;

// expect_lint! avoid_commented_out_code
// return;

// expect_lint! avoid_commented_out_code
// @deprecated

// expect_lint! avoid_commented_out_code
// String message;

// expect_lint! avoid_commented_out_code
// final count = 0;

// expect_lint! avoid_commented_out_code
/* final z = 3; */

// expect_lint! avoid_commented_out_code
// anotherCall(),

// expect_lint! avoid_commented_out_code
// onPressed: () => anotherCall(),

// expect_lint! avoid_commented_out_code
// const Text('You have pushed the button this many times:'),

// expect_lint! avoid_commented_out_code
// Column(
// expect_lint! avoid_commented_out_code
//   children: [
// expect_lint! avoid_commented_out_code
//     Text(
//       'You have pushed the button this many times:',
// expect_lint! avoid_commented_out_code
//       style: Theme.of(context).textTheme.headlineSmall,
//     ),
//   ],
// ),

// expect_lint! avoid_commented_out_code
/*Column(
     children: [
        Text(
            'You have pushed the button this many times:',
            style: Theme.of(context).textTheme.headlineSmall,
         ),
       ],
   ),*/

// expect_lint! avoid_commented_out_code
// const Column(
// expect_lint! avoid_commented_out_code
//   children: [
// expect_lint! avoid_commented_out_code
//     Text(
//       'You have pushed the button this many times:',
//     ),
//   ],
// ),

// expect_lint! avoid_commented_out_code
/*const Column(
      children: [
        Text(
          'You have pushed the button this many times:',
        ),
      ],
),*/

// expect_lint! avoid_commented_out_code
// class TestWidget extends StatelessWidget {
// expect_lint! avoid_commented_out_code
//   const TestWidget({super.key});
//
// expect_lint! avoid_commented_out_code
//   @override
//   Widget build(BuildContext context) {
// expect_lint! avoid_commented_out_code
//     return const Placeholder();
//   }
// }

// expect_lint! avoid_commented_out_code
/*class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}*/
''';

const _ignoreCases = r'''
// ignore_for_file: todo, fixme, hack

// Prose comment without code
// This comment explains something.

/// A doc comment example
/// Another line of docs.

// TODO: this is a todo comment
// TODO(valeriinov): Refactor logic required
// NOTE: this is a note comment

// HH:MM

// ignore: avoid_as
// ignore: avoid_print
// ignore_for_file: avoid_commented_out_code

// Looks like code but missing semicolon - should not lint
// y = 3

// Looks like code but missing brace - should not lint
// if (false)

/** Multi-line doc */

// INFO: This should be ignored

// Reason: some reason here

// FIXME: fix later

// HACK: temporary hack

// USAGE: call foo() first

// Looks like variable but no semicolon
// int a = 3

// Looks like if without brace
// if (true)

// Looks like function without body
// void bar()

/* Not code comment */

/* TODO: fix inside */
''';
