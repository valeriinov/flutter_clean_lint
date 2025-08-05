## avoid_commented_out_code

### Description:

This rule flags any code that is commented out in your Dart and Flutter files.

### Motivation:

Commented-out code fragments clutter your codebase, reduce readability, and often lead to confusion
about whether a piece of code is still relevant. All changes are already tracked in version control
systems (such as Git), so there’s no need to keep old or unused code in comments.
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

This rule enforces exactly one blank line between logically distinct sections of code inside a
function body.It reports two kinds of violations:

1. Missing blank line – when two unrelated code sections touch each other with no empty line
   in-between.
2. Extra blank line – when more than one consecutive empty line appears where only one is allowed.

### Motivation:

Consistent vertical spacing makes code easier to scan and understand.A single blank line cleanly
separates what the code is doing from how the next step continues, while avoiding both visual
noise (too many empty lines) and tightly packed blocks (no empty lines). Enforcing this rule keeps
functions readable, highlights logical groupings, and aligns with common style guides.

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

// GOOD: Exactly one blank line separates each logical section.
void goodSeparatedSections() {
  final a = 1;
  final b = 2;

  if (a == b) {
    print('equal');
  }

  final sum = a + b;

  return sum;
}
```