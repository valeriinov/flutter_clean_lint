// ignore_for_file: dead_code, unused_field, unused_local_variable

// =====================  SEPARATED CORRECTLY  =====================

// ---------- Declarations / assignment ----------
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

// ---------- Control-statements ----------
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

  for (var i = 0; i < n; i++) {
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

// ---------- Try-catch ----------
void goodBeforeTry() {
  final path = 'data.txt';

  try {
    print(path);
  } catch (_) {}

  print('after');
}

// ---------- Early exit / assert / await ----------
int goodBeforeEarlyReturn(int x) {
  final y = x * 2;

  return y;
}

int goodAfterAssert(int x) {
  assert(x >= 0);

  final y = x + 1;

  return y;
}

Future<void> goodAwait() async {
  final length = await Future.value('url'.length);

  print(length);
}

// ---------- Local constructs ----------
void goodBeforeLocalFunction() {
  final base = 2;

  int square(int v) => v * v;

  final s = square(base);

  print(s);
}

void goodCascade() {
  final buffer = StringBuffer()
    ..write('a')
    ..write('b');

  print(buffer.toString());
}

// ---------- Complex ----------
void goodComplex() {
  final a = 1;

  if (a == 1) {
    print('condition');
  }

  for (var i = 0; i < 1; i++) {
    print(i);
  }

  while (false) {
    break;
  }
}

// ---------- Extra-focused counterparts ----------
void goodNoExtraBetweenDeclarations() {
  final a = 1;
  final b = 2;
  final c = 3;
  final d = 4;

  print(a + b + c + d);
}

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

Iterable goodNoExtraInsideGenerator() sync* {
  yield 1;
  yield 2;
}

// ---------- Baseline / trivial ----------
int singleLine() => 1;

void emptyBody() {}

void onlyDeclarations() {
  final a = 1;
  final b = 2;
  final c = a + b;
}

// =====================  SEPARATED CORRECTLY (calls)  =====================

// ---------- Method calls ----------
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

// =====================  GOOD ASSIGNMENTS TO FIELDS  =====================

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
