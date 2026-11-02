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

## order_private_methods_by_usage

Opt-in lint, reported as info.

### Description:

This rule orders the private methods of a class, mixin, enum, extension, or extension type by
their usage inside that declaration: a private method is placed by its first usage in the file,
and a method used in several places is placed by its latest usage. The reader meets a call site
before the implementation it calls.

- Every member other than a private method keeps its place; its usages count at their position in
  the file. The rule does not move private methods relative to other members.
- Usages inside a private method count at that method's place, so all helpers called from one
  method come before the helpers those helpers call.
- A private method used in several places is placed after its latest usage, including a usage in
  `dispose` or in another private method.
- Calls, tear-offs (`onTap: _handleTap`), `this._method()`, and `Type._staticMethod()` count as
  usages. A recursive call to the method itself does not.
- When methods call each other, the method reached first from the other members goes first.
- Private methods without usages in the declaration go last, in file order.
- Private getters, setters, and operators are not ordered.

The rule reports the fewest methods that must move and names the method each one belongs after.

### Motivation:

Ordering helpers by usage keeps a top-down reading flow: the reader meets a call site first and
finds its implementation below.

### Example:

```dart
// BAD: `_trimInput` is used inside `_validate`, after the call sites in `submit`.
class LoginForm {
  void submit() {
    _validate();
    _send();
  }

  void _validate() => _trimInput();

  void _trimInput() {} // ← LINT

  void _send() {}
}

// GOOD: Helpers follow the order of their latest usage.
class LoginForm {
  void submit() {
    _validate();
    _send();
  }

  void _validate() => _trimInput();

  void _send() {}

  void _trimInput() {}
}
```

## avoid_doc_comments_on_private_members

Opt-in lint, reported as info.

### Description:

This rule flags a doc comment (`///` or `/** */`) on a library-private declaration: a private
field, method, getter, setter, constructor, top-level function or variable, class, mixin, enum,
enum constant, extension (including an unnamed one), extension type, or typedef. A field
declaration is flagged only when all of its variables are private. Public-named members of a
private class are not flagged.

A doc comment on a private member is kept only for SDK or framework behaviour, an external
contract, or an ordering whose breach fails silently. Suppress the lint on those:

```dart
// ignore: flutter_clean_lint/avoid_doc_comments_on_private_members
/// Must run before `super.initState()`; the framework reads it there.
void _prepare() {}
```

### Motivation:

Private members are read only next to their code. A doc comment there usually restates the name or
the body and goes stale; a clear name says the same thing.

### Example:

```dart
// BAD: The doc comment restates the method name.
/// Handles the tap.
void _handleTap() {} // ← LINT on the comment

// GOOD: The name says what the method does.
void _handleTap() {}
```

## avoid_hardcoded_style_values

Opt-in lint, reported as info.

### Description:

This rule checks files outside `test/` that declare a class extending Flutter `Widget` or `State`.
In such a file it checks the bodies of those classes and the top-level variables. Other classes,
such as palette classes and `ThemeExtension` subclasses, are not checked.

The rule flags three groups of values:

- Colours: `Color(...)`, `Color.fromARGB`, `Color.fromRGBO`, `Colors.<name>` and
  `CupertinoColors.<name>`. `Colors.transparent` is not flagged.
- Non-zero number literals passed as `strokeWidth`, `thickness`, `elevation` or `fontSize` of any
  call, as `width` of `BorderSide(...)` or `Border.all(...)`, and as the positional argument of
  `Radius.circular` or `BorderRadius.circular`.
- Non-zero number literals that initialize a `const` or `final` `double` variable, or that are a
  direct argument of a `BorderRadius` or `EdgeInsets` creation that initializes a `const` or
  `final` variable.

The literal `0` is never flagged. Spacing at the call site, such as `SizedBox` and padding, is not
flagged. The parameter list is fixed; the rule has no options.

### Motivation:

Colours and style numbers in widget code bypass the theme. A change of the design then needs an edit
in every widget. Values from the theme stay in one place and follow light and dark mode.

### Example:

```dart
class Card extends StatelessWidget {
  const Card({super.key});

  @override
  Widget build(BuildContext context) {
    // BAD: The colour, the stroke width and the radius are hard-coded.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.red, // ← LINT
        border: Border.all(width: 2), // ← LINT
        borderRadius: BorderRadius.circular(8), // ← LINT
      ),
    );
  }
}

class ThemedCard extends StatelessWidget {
  const ThemedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // GOOD: The values come from the theme. Zero and transparent are allowed.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        border: Border.all(width: 0),
        borderRadius: BorderRadius.zero,
        boxShadow: const [],
      ),
      child: const ColoredBox(color: Colors.transparent),
    );
  }
}
```
