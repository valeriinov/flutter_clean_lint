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
It reports three kinds of violations:

1. Missing blank line – when two unrelated code sections touch each other with no empty line
   in-between.
2. Extra blank line – when a blank line appears inside one logical section, at a block start or end,
   before `else`, inside a switch case, inside a collection literal, inside a cascade, or inside a
   binary expression.
3. Detached leading comment – when a comment that belongs to the next statement has a blank line
   before or after it.

The rule treats a leading comment as part of the following statement. A comment explaining a
`return`, `if`, `switch`, assignment, or function call must sit directly above that statement.

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
