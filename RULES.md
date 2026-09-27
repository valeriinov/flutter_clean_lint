## avoid_commented_out_code

### Description:

This rule flags common commented-out Dart code patterns in your Dart and Flutter files.

The rule is heuristic: it detects typical commented declarations, imports, control flow,
assignments, returns, annotations, and invocations. It skips documentation comments and known
explanatory prefixes such as `TODO`, `NOTE`, `INFO`, `FIXME`, `HACK`, `USAGE`, `ignore`, and
`ignore_for_file`.

### Motivation:

Commented-out code fragments clutter your codebase, reduce readability, and often lead to confusion
about whether a piece of code is still relevant. All changes are already tracked in version control
systems (such as Git), so there's no need to keep old or unused code in comments.
By enforcing this rule, you keep your project clean and focused only on active, working code.

### Example:

```dart
// BAD: There is commented-out code mixed with active code.
final value = 42;
// print('Debug value: $value');

final result = calculate(value);
// int oldResult = oldCalculate(value);

// GOOD: No commented-out code, only relevant and clean code remains.
final value = 42;
final result = calculate(value);
```

## insert_line_between_sections

### Description:

This rule enforces vertical spacing in Dart code blocks and selected multiline expressions.
Each statement has a kind, and two neighbouring statements of the same kind stay together while
statements of different kinds are separated by exactly one blank line. Statements of the same kind:

- declarations, as long as all of them initialize with `await` or none of them do;
- `await` expressions, including assignments of an awaited value;
- assignments without `await`;
- invocations (`foo()`, `a.b()`); a constructor call such as `Timer(...)` is not one;
- `assert` statements;
- `yield` statements.

`break` and `continue` join the statement above them. Every other statement (`if`, `for`,
`return`, `try`, a local function, ...) stands apart. It reports three kinds of violations:

1. Missing blank line – when two statements of different kinds touch each other with no empty line
   in-between.
2. Extra blank line – when a blank line appears between statements of the same kind, at a block
   start or end, before `else`, inside a switch case, inside a collection literal, inside a cascade,
   or inside a binary expression.
3. Detached leading comment – when a comment that belongs to the next statement has a blank line
   after it (separating the comment from the statement).

The rule treats a leading comment as part of the following statement. A comment explaining a
`return`, `if`, `switch`, assignment, or function call must sit directly above that statement.

A comment between a statement and the closing `}`, and a trailing comment after a statement
(`a(); // note`), are reported as well.

### Fix:

`dart run flutter_clean_lint:fix_blank_lines <path>...` rewrites blank lines in the analyzed Dart
files under the given paths and prints each file it changed. It leaves the two comment cases above
to be fixed by hand and skips violations suppressed with `ignore` or `ignore_for_file`.

### Motivation:

Consistent vertical spacing makes code easier to scan and understand. A single blank line cleanly
separates what the code is doing from how the next step continues, while related statements stay
visually connected. Enforcing this rule keeps functions readable, highlights logical groupings, and
prevents comments or expressions from looking detached from the code they describe.

### Example:

```dart
// BAD: Missing blank line between declarations and the if-statement.
void badMissingBetweenDeclarationGroups() {
  final a = 1;
  final b = 2;
  if (a == b) { // ← LINT
    print('equal');
  }
}

// BAD: Extra blank line between consecutive declarations.
void badExtraBetweenDeclarations() {
  final a = 1;
  final b = 2;

  final c = a + b; // ← LINT

  print(c);
}

// BAD: The leading comment is detached from the statement it describes.
void badDetachedComment(bool shouldStop) {
  final canStop = shouldStop;

  // The caller only needs the state check above.

  return; // ← LINT
}

// GOOD: Exactly one blank line separates each logical section.
void goodSeparatedSections() {
  final a = 1;
  final b = 2;

  if (a == b) {
    print('equal');
  }

  final sum = a + b;

  print(sum);
}

// GOOD: Leading comments stay attached to the statements they describe.
void goodCommentedStatements(int value) {
  final shouldPrint = value > 0;

  // Print only positive values.
  if (shouldPrint) {
    print(value);
  }

  final normalized = value.clamp(0, 1);

  // Handle the normalized branch immediately after clamping.
  switch (normalized) {
    case 0:
      print('zero');
    default:
      print('one');
  }

  final message = '$value';

  // Send the prepared message without starting a new section.
  print(message);
}
```
