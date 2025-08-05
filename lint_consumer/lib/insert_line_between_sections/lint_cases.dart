// =====================  MISSING  =====================

// ---------- Declarations / assignment ----------
void badMissingBetweenDeclarationGroups() {
  final a = 1;
  final b = 2;
  final c = 3;
  final d = 4;
  final sum = a + b + c + d;
  // expect_lint: insert_line_between_sections
  if (sum > 0) {
    print(sum);
  }
}

void badMissingAfterAssignmentBlock() {
  final list = <int>[1, 2, 3];
  final mapped = list.map((e) => e * 2).toList();
  // expect_lint: insert_line_between_sections
  print(mapped);
}

// ---------- Control-statements ----------
int badMissingIf() {
  final a = 1;
  final b = 2;
  // expect_lint: insert_line_between_sections
  if (a + b == 3) {
    print('Sum is 3');
  }
  // expect_lint: insert_line_between_sections
  return a + b;
}

void badMissingAfterControlStatement() {
  final a = 1;

  if (a > 0) {
    print(a);
  }
  // expect_lint: insert_line_between_sections
  final b = 2;

  print(b);
}

void badMissingBeforeFirstControl() {
  // preliminary comment
  // expect_lint: insert_line_between_sections
  if (true) {
    print('first');
  }
}

void badLoopSequenceMissing() {
  final n = 3;
  // expect_lint: insert_line_between_sections
  for (var i = 0; i < n; i++) {
    print(i);
  }
  // expect_lint: insert_line_between_sections
  while (false) {
    break;
  }
  // expect_lint: insert_line_between_sections
  do {
    break;
  } while (false);
}

void badSwitchMissingBeforeSwitch(int x) {
  final value = x;
  // expect_lint: insert_line_between_sections
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
  // expect_lint: insert_line_between_sections
  print('tail');
}

// ---------- Try-catch ----------
void badMissingAfterDeclarationBeforeTry() {
  final path = 'data.txt';
  // expect_lint: insert_line_between_sections
  try {
    print(path);
  } catch (_) {}
}

void badMissingAfterTry() {
  final path = 'data.txt';

  try {
    print(path);
  } catch (_) {}
  // expect_lint: insert_line_between_sections
  print('x');
}

// ---------- Early exit / assert / await ----------
int badMissingBeforeEarlyReturn(int x) {
  final y = x * 2;
  // expect_lint: insert_line_between_sections
  return y;
}

int badMissingLineAfterAssert(int x) {
  assert(x >= 0);
  // expect_lint: insert_line_between_sections
  final y = x + 1;

  return y;
}

Future<void> badAsyncMissing() async {
  final url = 'https://x';

  final data = await Future.value(url.length);
  // expect_lint: insert_line_between_sections
  print(data);
}

// ---------- Local constructs ----------
void badMissingBeforeLocalFunction() {
  final base = 2;
  // expect_lint: insert_line_between_sections
  int square(int v) => v * v;
  // expect_lint: insert_line_between_sections
  final s = square(base);

  print(s);
}

void badCascadeMissingAfter() {
  final buffer = StringBuffer()
    ..write('a')
    ..write('b');
  // expect_lint: insert_line_between_sections
  print(buffer.toString());
}

// ---------- Complex ----------
void badComplexCase() {
  final a = 1;
  final b = 2;
  // expect_lint: insert_line_between_sections
  if (a == 1) {
    print('condition');
  }

  final c = 2;
  // expect_lint: insert_line_between_sections
  for (int i = 0; i < b; i++) {
    print(i);
  }
  // expect_lint: insert_line_between_sections
  while (true) {
    break;
  }
}

void badNestedBlocks() {
  final a = 1;

  if (a == 1) {
    final b = 2;
    // expect_lint: insert_line_between_sections
    if (b == 2) {
      print('nested');
    }
  }

  print(a);
}

void badMixed() {
  final seed = 1;
  // expect_lint: insert_line_between_sections
  try {
    print(seed);
  } catch (_) {}
  // expect_lint: insert_line_between_sections
  switch (seed) {
    case 0:
      print('zero');
    default:
      print('other');
  }
  // expect_lint: insert_line_between_sections
  for (var i = 0; i < 2; i++) {
    print(i);
  }
  // expect_lint: insert_line_between_sections
  return;
}

// =====================  EXTRA  =====================

// ---------- Declarations / block edges ----------
void badExtraBetweenConsecutiveDeclarations() {
  final a = 1;
  final b = 2;

  // expect_lint: insert_line_between_sections
  final c = 3;
  final d = 4;

  print(a + b + c + d);
}

void badExtraAtBlockStart() {
  if (true) {

    // expect_lint: insert_line_between_sections
    print('work');
  }
}

void badExtraBeforeClosingBrace() {
  if (true) {
    print('x');

    // expect_lint: insert_line_between_sections
  }
}

// ---------- Inside control-statements ----------
void badExtraInsideSwitchCase() {
  final seed = 0;

  switch (seed) {
    case 0:

    // expect_lint: insert_line_between_sections
      print('zero');
      break;
    default:
      print('other');
  }
}

void badExtraInsideLoop() {
  for (var i = 0; i < 1; i++) {

    // expect_lint: insert_line_between_sections
    print(i);
  }
}

void badExtraInsideWhile() {
  var i = 0;

  while (i < 1) {

    // expect_lint: insert_line_between_sections
    i++;
  }
}

void badExtraInsideDo() {
  var i = 0;

  do {

    // expect_lint: insert_line_between_sections
    i++;
  } while (i < 1);
}

void badExtraInsideTry() {
  try {

    // expect_lint: insert_line_between_sections
    print('try');
  } catch (_) {}
}

void badExtraInsideCatchFinally() {
  try {
    throw 'e';
  } catch (_) {

    // expect_lint: insert_line_between_sections
    print('caught');
  } finally {

    // expect_lint: insert_line_between_sections
    print('finally');
  }
}

void badExtraBeforeElse() {
  final x = 0;

  if (x == 0) {
    print('zero');
  }

  // expect_lint: insert_line_between_sections
  else {
    print('non-zero');
  }
}

void badExtraInsideIfElseChain() {
  final x = 1;

  if (x == 0) {
    print('zero');
  } else if (x == 1) {

    // expect_lint: insert_line_between_sections
    print('one');
  } else {
    print('other');
  }
}

void badExtraInsideSwitchMultipleCases() {
  final value = 2;

  switch (value) {
    case 1:
      print('one');
      break;
    case 2:

    // expect_lint: insert_line_between_sections
      print('two');
      break;
    case 3:
      print('three');
      break;
  }
}

// ---------- Early exit / assert / await ----------
void badExtraBeforeReturn() {
  final v = 1;

  // expect_lint: insert_line_between_sections
  return;
}

void badExtraBeforeBreak() {
  for (var i = 0; i < 1; i++) {

    // expect_lint: insert_line_between_sections
    break;
  }
}

void badExtraInsideAssertGroup() {
  assert(1 == 1);

  // expect_lint: insert_line_between_sections
  assert(true);
}

Future<void> badExtraBeforeAwait() async {
  final v = Future.value(1);

  // expect_lint: insert_line_between_sections
  print(await v);
}

// ---------- Local constructs & literals ----------
void badExtraInsideLocalFunction() {
  int helper(int x) {

    // expect_lint: insert_line_between_sections
    return x + 1;
  }

  print(helper(1));
}

void badExtraInsideArrowLocal() {
  int helper(int x) => x +

      // expect_lint: insert_line_between_sections
      1;

  print(helper(1));
}

void badExtraInsideCascade() {
  final buffer = StringBuffer()

  // expect_lint: insert_line_between_sections
    ..write('a')
    ..write('b');

  print(buffer.toString());
}

void badExtraInsideCollectionLiteral() {
  final list = <int>[
    1,

    // expect_lint: insert_line_between_sections
    2,
    3,
  ];

  print(list.length);
}

void badExtraInsideMapLiteral() {
  final map = <String, int>{
    'a': 1,

    // expect_lint: insert_line_between_sections
    'b': 2,
  };

  print(map.length);
}

void badExtraInsideSetLiteral() {
  final set = <int>{
    1,

    // expect_lint: insert_line_between_sections
    2,
  };

  print(set.length);
}

Iterable<void> badExtraInsideSyncGenerator() sync* {
  yield 1;

  // expect_lint: insert_line_between_sections
  yield 2;
}

Stream<int> badExtraInsideAsyncGenerator() async* {
  yield 1;

  // expect_lint: insert_line_between_sections
  yield 2;
}

int badMultipleBlankLinesBeforeReturn(int x) {
  final y = x * 2;


  // expect_lint: insert_line_between_sections
  return y;
}

// =====================  MISSING (calls)  =====================

// ---------- Method calls ----------

Future<void> badMissingBetweenCallAndAwait() async {
  print('before');
  print('before await');
  // expect_lint: insert_line_between_sections
  await Future.value(1);
  await Future.value(2);
}

Future<void> badMissingAfterAwaitCall() async {
  await Future.value(1);
  await Future.value(2);
  // expect_lint: insert_line_between_sections
  print('after');
  print('after await');
}

// =====================  EXTRA (calls)  =====================

// ---------- Method calls ----------
void badExtraBetweenAssignmentAndCall() {
  final value = 1;

  // expect_lint: insert_line_between_sections
  print(value);
}

Future<void> badExtraBetweenCallAndAwait() async {
  print('before');
  print('before await');

  // expect_lint: insert_line_between_sections
  await Future.value(1);
  await Future.value(2);
}

Future<void> badExtraAfterAwaitCall() async {
  await Future.value(1);
  await Future.value(2);

  // expect_lint: insert_line_between_sections
  print('after');
  print('after await');
}
