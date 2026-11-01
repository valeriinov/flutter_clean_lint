// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:flutter_clean_lint/src/rules/avoid_hardcoded_style_values.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidHardcodedStyleValuesTest);
  });
}

@reflectiveTest
class AvoidHardcodedStyleValuesTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = AvoidHardcodedStyleValues();

    super.setUp();

    newFile('$packagesRootPath/flutter/lib/src/test_stubs.dart', _stubs);
  }

  Future<void> test_lintCases_should_reportExpectedDiagnostics() async {
    await _assertDiagnosticsFromBrackets(_lintCases);
  }

  Future<void> test_ignoreCases_should_notReportDiagnostics() async {
    await assertNoDiagnostics(_ignoreCases);
  }

  Future<void> test_fileWithoutWidgets_should_notReportDiagnostics() async {
    await assertNoDiagnostics(_fileWithoutWidgets);
  }

  Future<void> test_fileInTestDirectory_should_notReportDiagnostics() async {
    final file = newFile(
      '$testPackageRootPath/test/widget_test.dart',
      _fileInTestDirectory,
    );

    await assertNoDiagnosticsInFile(file.path);
  }

  Future<void> _assertDiagnosticsFromBrackets(String source) async {
    final matches = _flaggedPattern.allMatches(source).toList();
    final expected = [
      for (final (index, match) in matches.indexed)
        lint(
          match.start - index * _bracketsLength,
          match.end - match.start - _bracketsLength,
        ),
    ];
    final cleanSource = source.replaceAllMapped(
      _flaggedPattern,
      (match) => match.group(1) ?? '',
    );

    await assertDiagnostics(cleanSource, expected);
  }
}

final _flaggedPattern = RegExp(r'\[\[(.*?)\]\]');
const _bracketsLength = 4;

const _stubs = r'''
import 'package:flutter/widgets.dart';

abstract class ThemeExtension<T extends ThemeExtension<T>> {
  const ThemeExtension();
}

class Divider extends StatelessWidget {
  const Divider({super.key, double? thickness});
}

class CircularProgressIndicator extends StatelessWidget {
  const CircularProgressIndicator({super.key, double? strokeWidth});
}

abstract final class Colors {
  static const Color transparent = Color(0x00000000);

  static const Color red = Color(0xFFF44336);
}
''';

const _lintCases = r'''
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/src/test_stubs.dart' hide Colors;

const _accent = [[Color(0xFF00AA00)]];
const _gap = [[12.5]];

class ProfileCard extends StatelessWidget {
  static const _lineWidth = [[2.0]];
  static final _radius = BorderRadius.circular([[8]]);
  static const _padding = EdgeInsets.all([[16]]);
  static const _insets = EdgeInsets.only(left: [[20]]);

  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    const spacing = [[4.0]];

    return Container(
      color: [[Color.fromARGB(255, 1, 2, 3)]],
      decoration: BoxDecoration(
        color: [[Colors.red]].shade100,
        border: Border.all(width: [[3]]),
        borderRadius: BorderRadius.all(Radius.circular([[5]])),
      ),
      child: Text(
        'Hi',
        style: TextStyle(fontSize: [[14]], color: [[CupertinoColors.white]]),
      ),
    );
  }
}

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  final _shadow = [[Color.fromRGBO(1, 2, 3, 0.5)]];
  final _side = BorderSide(width: [[6]]);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(elevation: [[7]]),
        Divider(thickness: [[1]]),
        CircularProgressIndicator(strokeWidth: [[9]]),
        Container(
          color: [[m.Colors.red]],
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular([[10]]),
          ),
        ),
      ],
    );
  }
}
''';

const _ignoreCases = r'''
import 'package:flutter/widgets.dart' hide Color;
import 'package:flutter/src/test_stubs.dart';

class Color {
  const Color(int value);
}

class AppPalette {
  static const primary = Color(0xFF123456);
  static const radius = 8.0;
}

class AppColors extends ThemeExtension<AppColors> {
  final brand = const Color(0xFF000001);
  final cornerRadius = 4.0;
}

class Tile extends StatefulWidget {
  const Tile({super.key});

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  static const _count = 3;
  double _progress = 0.5;
  final _empty = 0.0;
  final _local = const Color(0xFF000002);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(width: 16),
          Divider(thickness: 0),
        ],
      ),
    );
  }
}
''';

const _fileWithoutWidgets = r'''
import 'package:flutter/material.dart';

const brand = Color(0xFF000000);
const radius = 8.0;
final accent = Colors.red;
''';

const _fileInTestDirectory = r'''
import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  static const _radius = 8.0;

  const Badge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.red);
  }
}
''';
